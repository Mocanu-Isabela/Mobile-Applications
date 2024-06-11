import 'list_page.dart';
import 'package:flutter/material.dart';

import '../entities/recipe.dart';
import '../services/firebase_crud.dart';

class EditPage extends StatefulWidget {
  final Recipe? recipe;
  EditPage({this.recipe});

  @override
  State<StatefulWidget> createState() {
    return _EditPage();
  }
}

class _EditPage extends State<EditPage> {
  final _recipe_name = TextEditingController();
  final _recipe_cooking_time = TextEditingController();
  final _recipe_difficulty = TextEditingController();
  final _recipe_ingredients = TextEditingController();
  final _recipe_steps = TextEditingController();
  final _docid = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _docid.value = TextEditingValue(text: widget.recipe!.recipeId.toString());
    _recipe_name.value = TextEditingValue(text: widget.recipe!.name.toString());
    _recipe_cooking_time.value = TextEditingValue(text: widget.recipe!.cookingTime.toString());
    _recipe_difficulty.value = TextEditingValue(text: widget.recipe!.difficulty.toString());
    _recipe_ingredients.value = TextEditingValue(text: widget.recipe!.ingredients.toString());
    _recipe_steps.value = TextEditingValue(text: widget.recipe!.steps.toString());
  }

  @override
  Widget build(BuildContext context) {
    final docIDField = TextField(
        controller: _docid,
        readOnly: true,
        autofocus: false,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Id",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    
    final nameField = TextFormField(
        controller: _recipe_name,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Name",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    final cooking_timeField = TextFormField(
        controller: _recipe_cooking_time,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Cooking Time",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    final difficultyField = TextFormField(
        controller: _recipe_difficulty,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Difficulty",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    final ingredientsField = TextFormField(
        controller: _recipe_ingredients,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Ingredients",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
    final stepsField = TextFormField(
        controller: _recipe_steps,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Steps",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

    final viewListbutton = TextButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ListPage(),
            ),
                (route) => false, //if you want to disable back feature set to false
          );
        },
        child: const Text('View List of recipes'));

    final SaveButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var response = await FirebaseCrud.updateRecipe(
                recipeName: _recipe_name.text,
                recipeCookingTime: _recipe_cooking_time.text,
                recipeDifficulty: _recipe_difficulty.text,
                recipeIngredients: _recipe_ingredients.text,
                recipeSteps: _recipe_steps.text,
                docId: _docid.text);
            if (response.code != 200) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(response.message.toString()),
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(response.message.toString()),
                    );
                  });
            }
          }
        },
        child: Text(
          "Done",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Update recipe'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  docIDField,
                  const SizedBox(height: 30.0),
                  nameField,
                  const SizedBox(height: 30.0),
                  cooking_timeField,
                  const SizedBox(height: 30.0),
                  difficultyField,
                  const SizedBox(height: 30.0),
                  ingredientsField,
                  const SizedBox(height: 30.0),
                  stepsField,
                  const SizedBox(height: 10.0),
                  viewListbutton,
                  const SizedBox(height: 70.0),
                  SaveButon,
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}