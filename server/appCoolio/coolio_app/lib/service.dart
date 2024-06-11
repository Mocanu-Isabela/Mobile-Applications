import 'dart:convert';
import 'databaseHelper.dart';
import 'recipe.dart';
import 'package:http/http.dart';

class ServiceApi{

  final String apiUrl = "http://192.168.100.151:3000";

  DatabaseHelper _dbHelper = DatabaseHelper.instanceDB;

  Future<bool> isActive() async {
    var response;
    try {
      response = await get('$apiUrl/recipes').timeout(const Duration(seconds: 3));
    } catch (e) {
      return false;
    }
    return response != null && response.statusCode == 200;
  }

  Future<List<Recipe>> getAllRecipes() async {
    Response res = await get('$apiUrl/recipes');
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<Recipe> recipes = body.map((dynamic item) => Recipe.fromJson(item))
          .toList();
      return recipes;
    } else {
      throw "Failed to load recipes list";
    }
  }

  Future<Response> insert(Recipe recipe) async {
    Map<String, dynamic> data = {
      'id': recipe.id,
      'name': recipe.name,
      'cookingTime': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps
    };
    Response res;
    try {
      res = await post('$apiUrl/add',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: json.encode(data));
    } catch(e) {
      res = Response("add error", 500);
    }
    return res;
  }

  Future<Response> del(int id) async {
    Response res;
    try {
      res = await delete('$apiUrl/delete/$id');
    } catch(e) {
      res = Response("del error", 500);
    }
    return res;
  }

  Future<Response> update(Recipe recipe) async {
    Map<String, dynamic> data = {
      'id': recipe.id,
      'name': recipe.name,
      'cookingTime': recipe.cookingTime,
      'difficulty': recipe.difficulty,
      'ingredients': recipe.ingredients,
      'steps': recipe.steps
    };
    Response res;
    try {
      res = await put('$apiUrl/update',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
          body: json.encode(data));
    } catch(e) {
      res = Response("update error", 500);
    }
    return res;
  }

  void syncDb() async {
    print("server working");
    List<Recipe> remoteRecipes = await this.getAllRecipes();
    List<Recipe> localRecipes = await _dbHelper.fetchRecipes();

    for(Recipe recipe in localRecipes){
      await _dbHelper.delete(recipe.id);
    }

    for(Recipe recipe in remoteRecipes){
      await _dbHelper.insert(recipe);
    }
  }

  void syncServer() async {
    print("server was off and now is working");
    List<Recipe> localRecipes = await _dbHelper.fetchRecipes();

    for(Recipe recipe in localRecipes){
      await this.insert(recipe);
    }
  }

}