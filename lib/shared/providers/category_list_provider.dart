import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/category/domain/category.dart';
import '../../features/category/domain/category_repository.dart';

final sharedCategoryListProvider = FutureProvider<List<Category>>((ref) async {
  return CategoryRepository().getAll();
});
