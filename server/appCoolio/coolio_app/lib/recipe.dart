
class Recipe {

  static const tableRecipe = 'recipesTable';
  static const columnId='ID';
  static const columnName='Name';
  static const columnCookingTime='CookingTime';
  static const columnDifficulty='Difficulty';
  static const columnIngredients='Ingredients';
  static const columnSteps='Steps';

  Recipe({this.id=0,this.name="",this.cookingTime="",this.difficulty="",this.ingredients="",this.steps=""});

  int id=0;
  String name="";
  String cookingTime="";
  String difficulty="";
  String ingredients="";
  String steps="";

  Recipe.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    cookingTime = map[columnCookingTime];
    difficulty = map[columnDifficulty];
    ingredients = map[columnIngredients];
    steps = map[columnSteps];
  }

  /*
  Recipe.fromMap(Map<String,dynamic> item):
      id=item[columnId],name=item[columnName],
        cookingTime=item[columnCookingTime], difficulty=item[columnDifficulty],
        ingredients=item[columnIngredients], steps=item[columnSteps];
  */

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{columnName: name, columnCookingTime: cookingTime, columnDifficulty: difficulty, columnIngredients: ingredients, columnSteps: steps};
    if (id != 0) {
      map[columnId] = id;
    }
    return map;
  }

  Recipe.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    cookingTime = json['cookingTime'];
    difficulty = json['difficulty'];
    ingredients = json['ingredients'];
    steps = json['steps'];
  }

  Map<String, dynamic> toJson(){
    var map = <String, dynamic>{'name': name, 'cookingTime': cookingTime, 'difficulty': difficulty, 'ingredients': ingredients, 'steps': steps};
    if(id!=null){
      map['id'] = id;
    }
    return map;
  }

}