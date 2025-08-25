// controllers/orders.controller.js
import { createFromCart, getById } from "../services/orders/cartOrder.service.js";
import { createEmailOrder } from "../services/orders/emailOrder.service.js";
import { createPreference, handleWebhook } from "../services/payments/mp.service.js";
import { getPaymentInfo } from "../services/payments/debug.service.js";

// POST /api/orders/checkout  -> confirma pedido desde el carrito (DB)
export const checkout = async (req, res, next) => {
  try {
    const userId = req.user?.id ?? req.body.userId ?? 1;
    const order = await createFromCart(userId);
    return res.status(201).json(order);
  } catch (e) {
    next(e);
  }
};

// GET /api/orders/:orderId  -> detalle de orden
export const detail = async (req, res, next) => {
  try {
    const userId = req.user?.id ?? req.query.userId ?? 1;
    const order = await getById(req.params.orderId, userId);
    if (!order) return res.status(404).end();
    return res.json(order);
  } catch (e) {
    next(e);
  }
};

// POST /api/orders/email  -> pedido por email (retiro/envío)
export const emailOrder = async (req, res, next) => {
  try {
    await createEmailOrder(req.body);
    return res.json({ ok: true });
  } catch (e) {
    next(e);
  }
};

// POST /api/orders/checkout/mp  -> crear preferencia de MP
export const mpCheckout = async (req, res, next) => {
  try {
    const { items, customer, shipping, orderid } = req.body || {};
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: "items requeridos" });
    }
    const pref = await createPreference({ items, customer, shipping, orderid });
    return res.json(pref); // { init_point, preference_id }
  } catch (e) {
    next(e);
  }
};

// POST /api/orders/webhooks/mercadopago  -> webhook de MP
export const mpWebhook = async (req, res, next) => {
  try {
    // log mínimo para rastrear si algo no llega
    console.info("[MP webhook] payload:", JSON.stringify(req.body));
    await handleWebhook(req.body);
    return res.sendStatus(204); // No Content
  } catch (e) {
    console.error("[mpWebhook] error:", e?.response?.data || e.message);
    // devolvemos 200/204 para que MP no reintente indefinidamente si es un error no crítico
    return res.sendStatus(200);
  }
};

// GET /api/orders/mp/payment/:id  -> debug: info completa de un pago en MP
export const mpPaymentInfo = async (req, res, next) => {
  try {
    const id = req.params.id; // string o number largo
    if (!id) return res.status(400).json({ message: "payment id requerido" });

    const info = await getPaymentInfo(id);
    return res.json(info);
  } catch (e) {
    next(e);
  }
};
