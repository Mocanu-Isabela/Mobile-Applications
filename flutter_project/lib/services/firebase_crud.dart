import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('Recipe');

class FirebaseCrud {
  static Future<Response> addRecipe({
    required String recipeName,
    required String recipeCookingTime,
    required String recipeDifficulty,
    required String recipeIngredients,
    required String recipeSteps,
  }) async {

    Response response = Response();
    DocumentReference documentReferencer = _Collection.doc();

    Map<String, dynamic> data = <String, dynamic>{
      "name": recipeName,
      "cookingTime": recipeCookingTime,
      "difficulty" : recipeDifficulty,
      "ingredients" : recipeIngredients,
      "steps" : recipeSteps
    };

    await documentReferencer
        .set(data)
        .whenComplete(() {
      response.code = 200;
      response.message = "Successfully added recipe";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });
    return response;
  }

  static Future<Response> updateRecipe({
    required String recipeName,
    required String recipeCookingTime,
    required String recipeDifficulty,
    required String recipeIngredients,
    required String recipeSteps,
    required String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer = _Collection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "name": recipeName,
      "cookingTime": recipeCookingTime,
      "difficulty" : recipeDifficulty,
      "ingredients" : recipeIngredients,
      "steps" : recipeSteps
    };

    await documentReferencer
        .update(data)
        .whenComplete(() {
      response.code = 200;
      response.message = "Successfully updated recipe";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });
    return response;
  }

  static Future<Response> deleteRecipe({
    required String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer = _Collection.doc(docId);

    await documentReferencer
        .delete()
        .whenComplete((){
      response.code = 200;
      response.message = "Successfully deleted recipe";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e;
    });

    return response;
  }

  static Stream<QuerySnapshot> readRecipe() {
    CollectionReference notesItemCollection = _Collection;
    return notesItemCollection.snapshots();
  }
}