import 'dart:convert';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AiScanPipelineStep { recognizing, parsing, completed }

class AiScanResult {
  final double amount;
  final String type;
  final String? categoryName;
  final DateTime? date;
  final String? note;

  const AiScanResult({
    required this.amount,
    required this.type,
    this.categoryName,
    this.date,
    this.note,
  });

  factory AiScanResult.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num?)?.toDouble() ?? 0;
    final typeRaw = (json['type'] as String? ?? 'expense').toLowerCase();
    final type =
        typeRaw.contains('income') || typeRaw.contains('收入') ? 'income' : 'expense';

    DateTime? date;
    if (json['date'] != null) {
      date = DateTime.tryParse(json['date'] as String);
    }

    return AiScanResult(
      amount: amount,
      type: type,
      categoryName: json['category'] as String?,
      date: date,
      note: json['note'] as String?,
    );
  }
}

class AiScanPipelineResult {
  final String ocrText;
  final AiScanResult scanResult;

  const AiScanPipelineResult({required this.ocrText, required this.scanResult});
}

class AiScanException implements Exception {
  final String message;
  final AiScanPipelineStep? step;
  final int? httpStatusCode;

  const AiScanException(this.message, {this.step, this.httpStatusCode});

  @override
  String toString() => message;
}

class AiScanService {
  static final AiScanService instance = AiScanService._();
  AiScanService._();

  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const String _apiKeyPrefKey = 'deepseek_api_key';

  // ── API Key persistence ──

  Future<String?> getSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPrefKey);
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, key);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefKey);
  }

  // ── OCR ──

  Future<String> recognizeText({
    required Uint8List bytes,
    required String filePath,
  }) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      textRecognizer.close();
    }
  }

  // ── DeepSeek API ──

  Future<AiScanResult> parseText({
    required String text,
    required String apiKey,
  }) async {
    final body = jsonEncode({
      'model': 'deepseek-chat',
      'messages': [
        {
          'role': 'system',
          'content': '你是精确的记账助手。只返回JSON，不返回其他内容。',
        },
        {
          'role': 'user',
          'content': '从以下账单文字中提取记账信息，返回JSON：\n\n$text\n\n'
              '格式：{"amount":数字,"type":"expense或income","category":"分类","date":"YYYY-MM-DD","note":"备注"}\n'
              '规则：消费→expense，收入→income。分类选：餐饮、交通、购物、娱乐、账单、医疗、教育、居住、日用、通讯、服饰、数码、运动、宠物、居家、订阅、学习、其他、工资、兼职、投资、礼金、退款、奖金、理财、副业。',
        },
      ],
      'temperature': 0.1,
      'max_tokens': 256,
      'response_format': {'type': 'json_object'},
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw _wrapApiError(Exception('API error ${response.statusCode}'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['choices'] as List).first['message']['content'] as String;
    final result = jsonDecode(content) as Map<String, dynamic>;
    return AiScanResult.fromJson(result);
  }

  // ── Pipeline: OCR → DeepSeek ──

  Future<AiScanPipelineResult> scanImage({
    required Uint8List bytes,
    required String filePath,
    required String apiKey,
    void Function(AiScanPipelineStep)? onProgress,
  }) async {
    onProgress?.call(AiScanPipelineStep.recognizing);

    final ocrText = await recognizeText(bytes: bytes, filePath: filePath);

    if (ocrText.isEmpty) {
      throw const AiScanException(
        'OCR 未能识别文字，请手动输入账单文字后点击解析',
        step: AiScanPipelineStep.recognizing,
      );
    }

    onProgress?.call(AiScanPipelineStep.parsing);

    try {
      final result = await parseText(text: ocrText, apiKey: apiKey);
      onProgress?.call(AiScanPipelineStep.completed);
      return AiScanPipelineResult(ocrText: ocrText, scanResult: result);
    } catch (e) {
      throw _wrapApiError(e);
    }
  }

  AiScanException _wrapApiError(dynamic e) {
    if (e is AiScanException) return e;
    final msg = e.toString();
    if (msg.contains('401')) {
      return const AiScanException('API Key 无效，请检查后重试', httpStatusCode: 401);
    }
    if (msg.contains('429')) {
      return const AiScanException('请求过于频繁，请稍后再试', httpStatusCode: 429);
    }
    if (msg.contains('500') || msg.contains('503')) {
      return const AiScanException('DeepSeek 服务异常，请稍后再试', httpStatusCode: 500);
    }
    return const AiScanException('解析失败，请检查网络后重试');
  }
}
