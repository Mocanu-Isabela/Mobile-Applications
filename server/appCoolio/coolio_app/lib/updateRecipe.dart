import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'service.dart';

import 'databaseHelper.dart';
import 'recipe.dart';

class UpdateRecipePage extends StatefulWidget {
  const UpdateRecipePage({Key? key}) : super(key: key);

  @override
  State<UpdateRecipePage> createState() => _UpdateRecipePageState();
}

class _UpdateRecipePageState extends State<UpdateRecipePage> {

  final nameController = TextEditingController();
  final cookingTimeController = TextEditingController();
  final difficultyController = TextEditingController();
  final ingredientsController = TextEditingController();
  final stepsController = TextEditingController();

  final ServiceApi service = ServiceApi();

  @override
  Widget build(BuildContext context) {
    //setDataOfOldRecipe();
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Recipe'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Name'),
          ),
          TextField(
            controller: cookingTimeController,
            decoration: InputDecoration(hintText: 'Cooking time'),
          ),
          TextField(
            controller: difficultyController,
            decoration: InputDecoration(hintText: 'Difficulty'),
          ),
          TextField(
            controller: ingredientsController,
            decoration: InputDecoration(hintText: 'Ingredients'),
          ),
          TextField(
            controller: stepsController,
            decoration: InputDecoration(hintText: 'Steps'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: updateRecipe,
              child: Text('Update')
          ),
        ],
      ),
    );
  }

  void setDataOfOldRecipe() async{
    if(ModalRoute.of(context)?.settings.arguments != null) {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      final id = data['id'];

      Recipe oldRecipe = await DatabaseHelper.instanceDB.getRecipe(id);
      nameController.text = oldRecipe.name;
      cookingTimeController.text = oldRecipe.cookingTime;
      difficultyController.text = oldRecipe.difficulty;
      ingredientsController.text = oldRecipe.ingredients;
      stepsController.text = oldRecipe.steps;
    }
  }

  void updateRecipe() async {
    if(ModalRoute.of(context)?.settings.arguments != null) {
      final data = ModalRoute.of(context)?.settings.arguments as Map;
      final id = data['id'];

      final name = nameController.text;
      final cookingTime = cookingTimeController.text;
      final difficulty = difficultyController.text;
      final ingredients = ingredientsController.text;
      final steps = stepsController.text;

      if(await service.isActive()){
        await service.update(Recipe(id: id, name: name, cookingTime: cookingTime, difficulty: difficulty, ingredients: ingredients, steps: steps));
        print('server updated recipe');
      } else {
        await DatabaseHelper.instanceDB.update(Recipe(id: id, name: name, cookingTime: cookingTime, difficulty: difficulty, ingredients: ingredients, steps: steps));
        print('db updated recipe');
      }

      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
