import 'dart:developer';

import 'package:flutter/material.dart';
import 'addRecipe.dart';
import 'databaseHelper.dart';
import 'service.dart';
import 'updateRecipe.dart';

import 'recipe.dart';

void main() {
  runApp(MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => RecipeList(),
        '/addPage': (context) => AddRecipePage(),
        '/updatePage': (context) => UpdateRecipePage(),
      },
      //home: RecipeList())
  ));
}

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {

  List<Recipe> recipes = [];
  late DatabaseHelper _dbHelper;
  final ServiceApi service = ServiceApi();
  var index = 0;

  @override
  void initState(){
    super.initState();
    _dbHelper = DatabaseHelper.instanceDB;
    //_dbHelper.cleanDb();
    _refreshRecipeList();
  }

  Future<void> _refreshRecipeList() async{
    bool isActive = await service.isActive();
    if(isActive) {
      print("yes active");
      if(index == 1) {
        service.syncServer();
        index = 0;
      }
      service.syncDb();
      var x = await service.getAllRecipes();
      setState(() {
        recipes = x;
      });
    } else {
      print("no active");
      index = 1;
      var x = await _dbHelper.fetchRecipes();
      setState(() {
        recipes = x;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text('Coolio'),
        centerTitle: true,
        backgroundColor: Colors.pink[200],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshRecipeList,
        child: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index] as Recipe;
              final id = recipe.id;
              return ListTile(
                leading: CircleAvatar(child: Text('${index+1}')),
                title: Text(recipe.name),
                subtitle: Text("time:${recipe.cookingTime}, diff:${recipe.difficulty}, ingred:${recipe.ingredients}, steps:${recipe.steps}"),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if(value == 'edit'){
                      Navigator.pushNamed(context, '/updatePage', arguments: {'id': id});
                    } else if(value == 'delete'){
                      deleteRecipe(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                          child: Text('Edit'),
                          value: 'edit'
                      ),
                      PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete'
                      ),
                    ];
                  },
                ),
              );
              }
        )
      ),

      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/addPage');
        },
        label: Text('Add Recipe')
      )
    );
  }

  void deleteRecipe(int id) async {
    if(await service.isActive()){
      await service.del(id);
      print('server deleted recipe');
    } else {
      await DatabaseHelper.instanceDB.delete(id);
      print('db deleted recipe');
    }
    _refreshRecipeList();
  }

}
