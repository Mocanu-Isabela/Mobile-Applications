package com.example.coolio

data class Recipe (
    var id: Int= 0,
    var name: String = "",
    var cooking_time: String = "",
    var difficulty: String = "",
    var steps: String = "",
    var ingredients: String = ""
)
{
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Recipe) return false
        if (id != other.id) return false
        return true
    }
}