import '../datasources/local_content_datasource.dart';
import '../models/category_model.dart';

class CategoryRepository {
  const CategoryRepository(this._contentDataSource);

  final LocalContentDataSource _contentDataSource;

  Future<List<CategoryModel>> getCategories() {
    return _contentDataSource.getCategories();
  }
}
