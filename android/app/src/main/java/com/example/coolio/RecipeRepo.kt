package com.example.coolio

import android.content.Context

class RecipeRepo(context:Context) {

    companion object{
        private val recipes: ArrayList<Recipe> = java.util.ArrayList()
        private var autoIncremented = 0
    }

    fun insertRecipe(recipe: Recipe): Int  {
        recipe.id = autoIncremented
        return if (recipes.contains(recipe)){
            -1
        } else {
            recipes.add(recipe)
            autoIncremented++
            1
        }
    }

    fun getAllRecipes(): ArrayList<Recipe> {
        return recipes
    }

    fun getRecipeIndex(recipe: Recipe): Int {
        for (i in 0..recipes.size) {
            if(recipes[i] == recipe)
                return i
        }
        return -1
    }

    fun getRecipe(id: Int): Int {
        for (i in 0..recipes.size) {
            if(recipes[i].id == id)
                return i
        }
        return -1
    }

    fun updateRecipe(recipe: Recipe): Int {
        return if (recipes.contains(recipe)){
            val index: Int = getRecipeIndex(recipe)
            recipes[index] = recipe
            1
        } else {
            -1
        }
    }

    fun deleteRecipeById(id: Int): Int{
        val index: Int = getRecipe(id)
        return if (index != -1){
            recipes.removeAt(index)
            1
        } else {
            -1
        }
    }
}