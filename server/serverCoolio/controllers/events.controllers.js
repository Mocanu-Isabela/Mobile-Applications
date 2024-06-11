const list_meals = [];

const getMeals = (ctx) => {
  ctx.body = list_meals;
  ctx.status = 200;
};

const addMeal = (ctx) => {
  let maxId = list_meals.reduce((obj, { id }) => Math.max(obj, id), 0) + 1;
  const body = ctx.request.body;
  const name = body.name;
  const calories = body.calories;
  const proteins = body.proteins;
  const index = list_meals.findIndex(obj => obj.name == name);
  if (index !== -1) {
    ctx.response.body = { text: 'File already exists!' };
      ctx.response.status = 200;
  } else {
    let meal = {
        id: maxId,
        name,
        calories,
        proteins
      }
      list_meals.push(meal);
      ctx.response.body = meal;
      ctx.response.status = 200;
  }
  
};

const deleteMeal = (ctx) => {
  const id = ctx.params.id;
  const index = list_meals.findIndex(obj => obj.id == id);
  let delMeal = list_meals[index];
  list_meals.splice(index,1);
  ctx.response.body = delMeal;
  ctx.response.status = 200;
}

const updateMeal = (ctx) => {
  const body = ctx.request.body;
  const id = body.id;
  const index = list_meals.findIndex(obj => obj.id == id);
  list_meals[index].name = body.name;
  list_meals[index].calories = body.calories;
  list_meals[index].proteins = body.proteins;
  ctx.response.body = list_meals[index];
  ctx.response.status = 200;
}

module.exports = {
  getMeals,
  addMeal,
  deleteMeal,
  updateMeal
};