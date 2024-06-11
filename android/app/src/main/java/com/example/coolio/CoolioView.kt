package com.example.coolio

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class CoolioView : AppCompatActivity() {
    private lateinit var ETname: EditText
    private lateinit var ETcooking_time: EditText
    private lateinit var ETdifficulty: EditText
    private lateinit var ETingredients: EditText
    private lateinit var ETsteps: EditText

    private lateinit var bttnAdd: Button
    private lateinit var bttnView: Button
    private lateinit var bttnUpdate: Button

    private lateinit var recyclerView: RecyclerView
    private var adapter: CoolioAdapter? = null
    private var recipe: Recipe?=null
    private lateinit var recipeRepo: RecipeRepo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.coolio_view)

        try {
        initView()
        initRecyclerView()
        recipeRepo = RecipeRepo(this)
        } catch (e: Exception) {
            Toast.makeText(this, e.message, Toast.LENGTH_SHORT).show()
        }

        bttnAdd.setOnClickListener{ addRecipe() }
        bttnView.setOnClickListener{ getRecipes() }
        bttnUpdate.setOnClickListener{ updateRecipe() }
        adapter?.setOnClickItem {
            Toast.makeText(this, it.name, Toast.LENGTH_SHORT).show()
            ETname.setText(it.name)
            ETcooking_time.setText(it.cooking_time)
            ETdifficulty.setText(it.difficulty)
            ETingredients.setText(it.ingredients)
            ETsteps.setText(it.steps)
            recipe = it
        }

        adapter?.setOnClickDeleteItem {
            deleteRecipe(it.id)
        }
    }

    private fun getRecipes() {
        val recipes = recipeRepo.getAllRecipes()
        Log.e("here", "${recipes.size}")
        adapter?.addItems(recipes)
    }

    private fun addRecipe(){
        val name = ETname.text.toString()
        val cooking_time = ETcooking_time.text.toString()
        val difficulty = ETdifficulty.text.toString()
        val ingredients = ETingredients.text.toString()
        val steps = ETsteps.text.toString()

        if (name.isEmpty() || cooking_time.isEmpty() || difficulty.isEmpty() || ingredients.isEmpty() || steps.isEmpty()){
            Toast.makeText(this, "Please enter the required fields", Toast.LENGTH_SHORT).show()
        } else {
            val recipe = Recipe(name = name, cooking_time = cooking_time, difficulty = difficulty, ingredients = ingredients, steps = steps)
            val status = recipeRepo.insertRecipe(recipe)
            if (status > 0) {
                Toast.makeText(this, "The recipe was added", Toast.LENGTH_SHORT).show()
                clearEditText()
                getRecipes()
            } else {
                Toast.makeText(this, "Recipe already exists", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun updateRecipe() {
        val name = ETname.text.toString()
        val cooking_time = ETcooking_time.text.toString()
        val difficulty = ETdifficulty.text.toString()
        val ingredients = ETingredients.text.toString()
        val steps = ETsteps.text.toString()

        if (name == recipe?.name && cooking_time == recipe?.cooking_time && difficulty == recipe?.difficulty && ingredients == recipe?.ingredients && steps == recipe?.steps) {
            Toast.makeText(this, "The recipe was not updated", Toast.LENGTH_SHORT).show()
            return
        }

        if (recipe == null) return
        val recipe = Recipe(id = recipe!!.id, name = name, cooking_time = cooking_time, difficulty = difficulty, ingredients = ingredients, steps = steps)
        val status = recipeRepo.updateRecipe(recipe)
        if (status > -1) {
            clearEditText()
            getRecipes()
        } else {
            Toast.makeText(this, "Recipe not updated", Toast.LENGTH_SHORT).show()
        }
    }

    private fun clearEditText() {
        ETname.setText("")
        ETcooking_time.setText("")
        ETdifficulty.setText("")
        ETingredients.setText("")
        ETsteps.setText("")
        ETname.requestFocus()
    }

    private fun deleteRecipe(id: Int) {
        val builder = AlertDialog.Builder(this)
        builder.setMessage("Are you sure you want to delete the recipe?")
        builder.setCancelable(true)
        builder.setPositiveButton("Yes") { dialog, _->
            recipeRepo.deleteRecipeById(id)
            getRecipes()
            dialog.dismiss()
        }
        builder.setNegativeButton("No") { dialog, _ ->
            dialog.dismiss()
        }
        val alert = builder.create()
        alert.show()
    }

    private fun initRecyclerView() {
        recyclerView.layoutManager = LinearLayoutManager(this)
        adapter = CoolioAdapter()
        recyclerView.adapter = adapter
    }

    private fun initView(){
        ETname = findViewById(R.id.name)
        ETcooking_time = findViewById(R.id.cooking_time)
        ETdifficulty = findViewById(R.id.difficulty)
        ETingredients = findViewById(R.id.ingredients)
        ETsteps = findViewById(R.id.steps)
        bttnAdd = findViewById(R.id.bttnAdd)
        bttnUpdate = findViewById(R.id.bttnUpdate)
        bttnView = findViewById(R.id.bttnView)
        recyclerView = findViewById(R.id.recyclerView)
    }
}