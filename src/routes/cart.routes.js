import { Router } from "express";
import { add, view, clear } from "../controllers/cart.controller.js";

const router = Router();

router.get("/items", view);      // ver carrito
router.post("/items", add);      // agregar item
router.delete("/items", clear);  // vaciar carrito completo

export default router;
