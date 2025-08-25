// routes/orders.routes.js
import { Router } from "express";
import {
  checkout,
  detail,
  emailOrder,
  mpCheckout,
  mpWebhook,
  mpPaymentInfo,
} from "../controllers/orders.controller.js";

const router = Router();

/**
 * IMPORTANTE: las rutas más específicas primero.
 * Dejar `/:orderId` al final para que no capture `/mp/payment/:id`.
 */

// Mercado Pago
router.post("/checkout/mp", mpCheckout);              // crear preferencia MP
router.post("/webhooks/mercadopago", mpWebhook);      // webhook MP
router.get("/mp/payment/:id", mpPaymentInfo);         // debug de pago (status/status_detail)

// Email / Carrito
router.post("/email", emailOrder);                    // pedido por email (retiro/envío)
router.post("/checkout", checkout);                   // orden desde carrito (DB)

// Detalle de orden (dejar al final)
router.get("/:orderId", detail);

export default router;
