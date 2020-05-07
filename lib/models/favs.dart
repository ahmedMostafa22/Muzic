import 'package:muzic/tools/db_helper.dart';
import 'package:muzic/tools/injection.dart';

class Fav {
  final int id;
  final String title;

  Fav({this.id, this.title});

  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map["title"] = title;
    return map;
  }

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    map["id"] = id;
    map["title"] = title;
    return map;
  }

  factory Fav.fromMap(Map<String, dynamic> data) => new Fav(
        id: data['id'],
        title: data['title'],
      );

  DatabaseHelper _databaseHelper = Injection.injector.get();
  Future<int> create(String title) async {
    final fav = new Fav(title: title);
    int id = await _databaseHelper.db.insert("favs", fav.toMapWithoutId());
    return id;
  }

  Future<bool> getFavouritesByTitle(String title) async {
    List<Map> list = await _databaseHelper.db
        .rawQuery("Select * from favs where title = ?", [title]);
    if (list.length > 0) {
      return true;
    }
    return false;
  }

  Future<int> updateItem(Fav fav) async {
    //databaseHelper has been injected in the class
    return await _databaseHelper.db
        .update("favs", fav.toMap(), where: "id = ?", whereArgs: [fav.id]);
  }

  Future<int> deleteItem(String title) async {
    return await _databaseHelper.db
        .delete("favs", where: "title = ?", whereArgs: [title]);
  }
}
