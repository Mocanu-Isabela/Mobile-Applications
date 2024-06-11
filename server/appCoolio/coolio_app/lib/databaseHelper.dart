import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'recipe.dart';

class DatabaseHelper{

  static final _dbName = 'RecipesDB.db';
  static final _dbVersion = 1;

  // singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instanceDB = DatabaseHelper._privateConstructor();

  static var _database;

  Future<Database> get database async{
    if (_database != null) {
      return _database;
    }
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async{
    await db.execute(
      '''
      CREATE TABLE ${Recipe.tableRecipe} (
      ${Recipe.columnId} INTEGER PRIMARY KEY,
      ${Recipe.columnName} TEXT NOT NULL,
      ${Recipe.columnCookingTime} TEXT NOT NULL,
      ${Recipe.columnDifficulty} TEXT NOT NULL,
      ${Recipe.columnIngredients} TEXT NOT NULL,
      ${Recipe.columnSteps} TEXT NOT NULL )
      '''
    );
  }

  Future<int> insert(Recipe recipe) async{
    Database db = await database;
    var res;
    try {
      res = await db.insert(Recipe.tableRecipe, recipe.toMap());
    } catch(e) {
      var m = await this.getRecipe(recipe.id);
      res = m.id;
    }
    return res;
  }

  Future<List<Recipe>> fetchRecipes() async{
    Database db = await database;
    List<Map> recipes = await db.query(Recipe.tableRecipe);
    return recipes.length == 0 ? [] : recipes.map((x) => Recipe.fromMap(x)).toList();
  }

  Future<Recipe> getRecipe(int id) async{
    Database db = await database;
    List<Map> recipes = await db.rawQuery('SELECT * FROM ${Recipe.tableRecipe} WHERE ${Recipe.columnId} == $id');
    return recipes.map((x) => Recipe.fromMap(x)).toList()[0];
  }

  Future<int> update(Recipe recipe) async{
    Database db = await database;
    return await db.update(Recipe.tableRecipe, recipe.toMap(), where: '${Recipe.columnId} = ?', whereArgs: [recipe.id]);
  }

  Future<int> delete(int id) async{
    Database db = await database;
    return await db.delete(Recipe.tableRecipe, where: '${Recipe.columnId} = ?', whereArgs: [id]);
  }

  void cleanDb() async {
    List<Recipe> localRecipes = await this.fetchRecipes();

    for(Recipe recipe in localRecipes){
      await this.delete(recipe.id);
    }
  }

}