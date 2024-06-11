import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'databaseHelper.dart';
import 'service.dart';

import 'recipe.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {

  final nameController = TextEditingController();
  final cookingTimeController = TextEditingController();
  final difficultyController = TextEditingController();
  final ingredientsController = TextEditingController();
  final stepsController = TextEditingController();

  final ServiceApi service = ServiceApi();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    cookingTimeController.dispose();
    difficultyController.dispose();
    ingredientsController.dispose();
    stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
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
              onPressed: addRecipe,
              child: Text('Add')
          ),
        ],
      ),
    );
  }

  void addRecipe() async{
    final name = nameController.text;
    final cookingTime = cookingTimeController.text;
    final difficulty = difficultyController.text;
    final ingredients = ingredientsController.text;
    final steps = stepsController.text;

    if(await service.isActive()){
      service.insert(Recipe(name: name, cookingTime: cookingTime, difficulty: difficulty, ingredients: ingredients, steps: steps));
      print('server added recipe');
    } else {
      DatabaseHelper.instanceDB.insert(Recipe(name: name, cookingTime: cookingTime, difficulty: difficulty, ingredients: ingredients, steps: steps));
      print('db added recipe');
    }

    Navigator.pushReplacementNamed(context, '/home');
  }
}
