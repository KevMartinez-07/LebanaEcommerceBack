import express from "express";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

import productsRoutes from "./routes/products.routes.js";
import cartRoutes from "./routes/cart.routes.js";
import ordersRoutes from "./routes/orders.routes.js";
import { reconcilePendingPayments } from "./services/payments/reconcile.service.js";

setInterval(() => reconcilePendingPayments().catch(console.error), 5 * 60 * 1000);

const app = express();

app.use(cors({ origin: process.env.APP_URL || "*", credentials: true }));
app.use(express.json());

// Mock de auth (borralo cuando agregues login)
app.use((req, _res, next) => { req.user = { id: 1 }; next(); });

app.use("/api/products", productsRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", ordersRoutes);

app.get("/api/health", (_req, res) => res.json({ ok: true }));

app.use((err, _req, res, _next) => {
  console.error("Error:", err);
  res.status(err.status || 500).json({ message: err.message || "Error interno" });
});

app.post("/api/admin/reconcile", async (_req, res) => {
  await reconcilePendingPayments();
  res.json({ ok: true });
});

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`API escuchando en http://localhost:${port}`));
