import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Recipe implements Comparable{
  final int id;
  final String name;
  final String cookingTime;
  final String difficulty;
  final String ingredients;
  final String steps;

  const Recipe({
      required this.id,
      required this.name,
      required this.cookingTime,
      required this.difficulty,
      required this.ingredients,
      required this.steps});

  String get fullRecipe => '$name $cookingTime $difficulty $ingredients $steps';
  String get detailsRecipe => 'cooking time: $cookingTime, difficulty : $difficulty, ingredients: $ingredients, steps: $steps';

  Recipe.fromRow(Map<String, Object?> row) : id = row['ID'] as int, name = row['NAME'] as String, cookingTime = row['COOKING_TIME'] as String, difficulty = row['DIFFICULTY'] as String, ingredients = row['INGREDIENTS'] as String, steps = row['STEPS'] as String;

  @override
  int compareTo(covariant Recipe other) => other.id.compareTo(id);

  @override
  bool operator == (covariant Recipe other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe, id = $id, name: $name, cookingTime: $cookingTime, difficulty : $difficulty, ingredients: $ingredients, steps: $steps';
}

class RecipeDB {
  final String dbName;
  Database? _db;
  List<Recipe> _recipes = [];
  final _streamController = StreamController<List<Recipe>>.broadcast();
  RecipeDB({required this.dbName});

  Future<List<Recipe>> _fetchRecipes() async {
    final db = _db;
    if (db == null) {
      return [];
    }
    try {
      final read = await db.query(
        'RECIPE',
        distinct: true,
        columns: [
          'ID',
          'NAME',
          'COOKING_TIME',
          'DIFFICULTY',
          'INGREDIENTS',
          'STEPS',
        ],
        orderBy: 'ID'
      );

      final recipes = read.map((row) => Recipe.fromRow(row)).toList();
      return recipes;
    } catch (e) {
      print('Error fetching recipes = $e');
      return [];
    }
  }

  Future<bool> create(String name, String cookingTime, String difficulty, String ingredients, String steps) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final id = await db.insert('RECIPE', {
        'NAME' : name,
        'COOKING_TIME' : cookingTime,
        'DIFFICULTY' : difficulty,
        'INGREDIENTS' : ingredients,
        'STEPS' : steps,
      });
      final recipe = Recipe(id: id, name: name, cookingTime: cookingTime, difficulty: difficulty, ingredients: ingredients, steps: steps, );
      _recipes.add(recipe);
      _streamController.add(_recipes);
      return true;
    } catch(e) {
      print('Error in creating recipe = $e');
      return false;
    }
  }

  Future<bool> delete(Recipe recipe) async {
    final db = _db;
    if (db == null) {
      return false;
    }

    try {
      final deletedCount = await db.delete(
        'RECIPE',
        where: 'ID = ?',
        whereArgs: [recipe.id],
      );

      if (deletedCount == 1) {
        _recipes.remove(recipe);
        _streamController.add(_recipes);
        return true;
      } else {
        return false;
      }
    } catch(e) {
      print('Deletion failed with error $e');
      return false;
    }
  }

  Future<bool> update(Recipe recipe) async {
    final db = _db;
    if (db == null) {
      return false;
    }
    try {
      final updateCount = await db.update(
          'RECIPE', {
        'NAME' : recipe.name,
        'COOKING_TIME' : recipe.cookingTime,
        'DIFFICULTY' : recipe.difficulty,
        'INGREDIENTS' : recipe.ingredients,
        'STEPS' : recipe.steps,
      },
      where: 'ID = ?',
      whereArgs: [recipe.id],
      );

      if (updateCount == 1) {
        _recipes.removeWhere((other) => other.id == recipe.id);
        _recipes.add(recipe);
        _streamController.add(_recipes);
        return true;
      } else {
        return false;
      }
    } catch(e) {
      print('Failed to update recipe, error = $e');
      return false;
    }
  }

  Future<bool> close() async {
    final db = _db;
    if (db == null) {
      return false;
    }
    await db.close();
    return true;
  }

  // the part that does error handling
  Future<bool> open() async {
    if (_db != null) {
      return true;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$dbName';

    try {
      final db = await openDatabase(path);
      _db = db;

      //create table
      const create = '''CREATE TABLE IF NOT EXISTS RECIPE(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        NAME STRING NOT NULL,
        COOKING_TIME STRING NOT NULL,
        DIFFICULTY STRING NOT NULL,
        INGREDIENTS STRING NOT NULL,
        STEPS STRING NOT NULL
      )''';

      await db.execute(create);

      // read all existing recipes objects from the db
      _recipes = await _fetchRecipes();
      _streamController.add(_recipes);
      return true;
    } catch (e) {
      print('Error = $e');
      return false;
    }
  }
  Stream<List<Recipe>> all() => _streamController.stream.map((recipes) => recipes..sort());
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RecipeDB _crudStorage;

  @override
  void initState() {
    _crudStorage = RecipeDB(dbName: 'db.sqlite');
    _crudStorage.open();
    super.initState();
  }

  @override
  void dispose() {
    _crudStorage.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coolio'),
      ),
      body: StreamBuilder(
        stream: _crudStorage.all(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final recipes = snapshot.data as List<Recipe>;
              return Column(
                children: [
                  ComposeWidget(
                      onCompose: (name, cookingTime, difficulty, ingredients, steps) async {
                        await _crudStorage.create(name, cookingTime, difficulty, ingredients, steps);
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          onTap: () async {
                            final editedRecipe = await showUpdateDialog(context, recipe);
                            if (editedRecipe != null) {
                              await _crudStorage.update(editedRecipe);
                            }
                          },
                          title: Text(recipe.name),
                          subtitle: Text(recipe.detailsRecipe),
                          trailing: TextButton(
                            onPressed: () async {
                              final shouldDelete = await showDeleteDialog(context);
                            if (shouldDelete) {
                              await _crudStorage.delete(recipe);
                            }
                            },
                            child: const Icon(Icons.disabled_by_default_rounded,
                            color: Colors.blueAccent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop(false);
          },
            child: const Text('No'),
          ),
          TextButton(onPressed: () {
            Navigator.of(context).pop(true);
          },
            child: const Text('Delete'),
          ),
        ],
      );
  },
  ).then((value) {
    if (value is bool) {
      return value;
    } else {
      return false;
    }
  });
}

final _nameController = TextEditingController();
final _cookingTimeController = TextEditingController();
final _difficultyController = TextEditingController();
final _ingredientsController = TextEditingController();
final _stepsController = TextEditingController();

Future<Recipe?> showUpdateDialog(BuildContext context, Recipe recipe) {
  _nameController.text = recipe.name;
  _cookingTimeController.text = recipe.cookingTime;
  _difficultyController.text = recipe.difficulty;
  _ingredientsController.text = recipe.ingredients;
  _stepsController.text = recipe.steps;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column (
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your updated values here:'),
              TextField(controller: _nameController),
              TextField(controller: _cookingTimeController),
              TextField(controller: _difficultyController),
              TextField(controller: _ingredientsController),
              TextField(controller: _stepsController),
            ],
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop(null);
            },
                child: const Text('Cancel'),
            ),
            TextButton(
                onPressed: () {
                  final editedRecipe = Recipe(
                    id: recipe.id,
                    name: _nameController.text,
                    cookingTime: _cookingTimeController.text,
                    difficulty: _difficultyController.text,
                    ingredients: _ingredientsController.text,
                    steps: _stepsController.text,
                  );
                  Navigator.of(context).pop(editedRecipe);
                },
                child: const Text('Save'),
            ),
          ],
        );
      },
  ).then((value) {
    if (value is Recipe) {
      return value;
    } else {
      return null;
    }
  });
}

typedef OnCompose = void Function(String name, String cookingTime, String difficulty, String ingredients, String steps);

class ComposeWidget extends StatefulWidget {
  final OnCompose onCompose;
  const ComposeWidget({ Key? key, required this.onCompose, }) : super(key: key);

  @override
  _ComposeWidgetState createState() => _ComposeWidgetState();

}

class _ComposeWidgetState extends State<ComposeWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _cookingTimeController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _stepsController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _cookingTimeController = TextEditingController();
    _difficultyController = TextEditingController();
    _ingredientsController = TextEditingController();
    _stepsController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookingTimeController.dispose();
    _difficultyController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter name',)),
          TextField(controller: _cookingTimeController,
              decoration: const InputDecoration(hintText: 'Enter cooking time',)),
          TextField(controller: _difficultyController,
              decoration: const InputDecoration(hintText: 'Enter difficulty',)),
          TextField(controller: _ingredientsController,
              decoration: const InputDecoration(hintText: 'Enter ingredients',)),
          TextField(controller: _stepsController,
              decoration: const InputDecoration(hintText: 'Enter steps',)),
          TextButton(onPressed: () {
            final name = _nameController.text;
            final cookingTime = _cookingTimeController.text;
            final difficulty = _difficultyController.text;
            final ingredients = _ingredientsController.text;
            final steps = _stepsController.text;
            widget.onCompose(name, cookingTime, difficulty, ingredients, steps);
            _nameController.text = '';
            _cookingTimeController.text = '';
            _difficultyController.text = '';
            _ingredientsController.text = '';
            _stepsController.text = '';
          }, child: const Text('Add to list', style: TextStyle(fontSize: 24),),
          ),
        ],
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.pink,
    ),
    home: const HomePage(),
  ),);
}
