package com.example.coolio

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView

class CoolioAdapter : RecyclerView.Adapter<CoolioAdapter.CoolioViewHolder>(){
    private var recipes: ArrayList<Recipe> = java.util.ArrayList()
    private var onClickItem: ((Recipe) -> Unit)? = null
    private var onClickDeleteItem: ((Recipe) -> Unit)? = null

    fun addItems(items: ArrayList<Recipe>) {
        this.recipes = items
        notifyDataSetChanged()
    }

    fun setOnClickItem(callback: (Recipe) -> Unit) {
        this.onClickItem = callback
    }

    fun setOnClickDeleteItem(callback: (Recipe) -> Unit) {
        this.onClickDeleteItem = callback
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = CoolioViewHolder(
        LayoutInflater.from(parent.context).inflate(R.layout.card_items_recipes, parent, false)
    )

    override fun onBindViewHolder(holder: CoolioViewHolder, position: Int) {
        val recipe = recipes[position]
        holder.bindView(recipe)
        holder.itemView.setOnClickListener{ onClickItem?.invoke(recipe) }
        holder.bttnDelete.setOnClickListener{ onClickDeleteItem?.invoke(recipe)}
    }

    override fun getItemCount(): Int {
        return recipes.size
    }

    class CoolioViewHolder(var view: View): RecyclerView.ViewHolder(view){
        private var id = view.findViewById<TextView>(R.id.tvId)
        private var name = view.findViewById<TextView>(R.id.tvName)
        private var cooking_time = view.findViewById<TextView>(R.id.tvCooking_time)
        private var difficulty = view.findViewById<TextView>(R.id.tvDifficulty)
        private var steps = view.findViewById<TextView>(R.id.tvSteps)
        private var ingredients = view.findViewById<TextView>(R.id.tvIngredients)
        var bttnDelete = view.findViewById<TextView>(R.id.bttnDelete)

        fun bindView(recipe: Recipe){
            id.text = recipe.id.toString()
            name.text = recipe.name
            cooking_time.text = recipe.cooking_time
            difficulty.text = recipe.difficulty.toString()
            steps.text = recipe.steps
            ingredients.text = recipe.ingredients
        }
    }
}