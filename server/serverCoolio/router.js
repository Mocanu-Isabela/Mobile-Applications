const Router = require("koa-router");
const router = new Router();
const { getMeals, addMeal, deleteMeal, updateMeal } = require("./controllers/events.controllers");

router.get("/meals", getMeals);
router.post("/add", addMeal);
router.del("/delete/:id", deleteMeal);
router.put("/update", updateMeal);

module.exports = router;