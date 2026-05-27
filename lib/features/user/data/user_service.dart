import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String avatar;
  double monthlyBudget;

  UserProfile({
    this.name = '未设置',
    this.avatar = '👤',
    this.monthlyBudget = 0,
  });
}

class UserService {
  static Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString('user_name') ?? '未设置',
      avatar: prefs.getString('user_avatar') ?? '👤',
      monthlyBudget: prefs.getDouble('user_monthly_budget') ?? 0,
    );
  }

  static Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', profile.name);
    await prefs.setString('user_avatar', profile.avatar);
    await prefs.setDouble('user_monthly_budget', profile.monthlyBudget);
  }
}
