// services/payments/mp.service.js
import { mpClient, Preference, Payment } from "../../config/mp.js";
import { createEmailOrder } from "../orders/emailOrder.service.js";

/**
 * Crea una preferencia de Checkout Pro (SDK v2)
 * - Sanea items (números)
 * - Sólo agrega shipments si es delivery
 * - Usa sandbox_init_point si está disponible
 * - Pasa metadata útil al pago / reconciliación
 * - Loguea datos clave para depuración
 */
export const createPreference = async ({
  items = [],
  customer = {},
  shipping = {},
  orderid,
} = {}) => {
  const mpItems = (items || []).map((i) => ({
    title: String(i.title ?? "Producto"),
    unit_price: Number(i.unit_price ?? 0),
    quantity: Number(i.quantity ?? 1),
    currency_id: "ARS",
  }));

  const isDelivery = String(shipping?.mode || "").toLowerCase() === "delivery";
  const shippingCost = Number(shipping?.cost ?? 0);

  const body = {
    items: mpItems,
    payer: {
      name: customer?.name || undefined,
      email: customer?.email || undefined, // sólo prellena
    },
    shipments: isDelivery ? { mode: "not_specified", cost: shippingCost } : undefined,

    metadata: {
      delivery_mode: isDelivery ? "delivery" : "pickup",
      address: shipping?.address || null,
      orderid: orderid ?? null,
      // guardamos también preference_id del lado MP cuando llegue el pago
    },

    // útil para reconciliar con tu DB
    external_reference: orderid ? String(orderid) : undefined,

    back_urls: {
      success: `${process.env.APP_URL}/checkout/result?from=mp&when=success`,
      pending: `${process.env.APP_URL}/checkout/result?from=mp&when=pending`,
      failure: `${process.env.APP_URL}/checkout/result?from=mp&when=failure`,
    },
    auto_return: "approved",

    // si querés forzar sólo approved/rejected (evitar pending en sandbox), descomentá:
    // binary_mode: true,

    notification_url: `${
      process.env.API_URL || "http://localhost:4000"
    }/api/orders/webhooks/mercadopago`,
  };

  const preference = new Preference(mpClient);
  const resp = await preference.create({ body }); // SDK v2 → { body }

  const init_point = resp.sandbox_init_point || resp.init_point;

  // Logs útiles para depurar
  console.info("[MP] Preferencia creada", {
    preference_id: resp.id,
    init_point,
    items: body.items.map((i) => ({ t: i.title, q: i.quantity, p: i.unit_price })),
    shipping: isDelivery ? { cost: shippingCost } : "pickup",
    external_reference: body.external_reference || null,
  });

  return { init_point, preference_id: resp.id };
};

/**
 * Webhook de Mercado Pago (SDK v2)
 * - Maneja sólo 'payment'
 * - Busca el pago y dispara el mail
 * - Loguea info clave
 */
export const handleWebhook = async (payload) => {
  try {
    const { type, data } = payload || {};
    if (type !== "payment" || !data?.id) return { ok: true };

    const payment = new Payment(mpClient);
    const p = await payment.get({ id: data.id }); // SDK v2 → { id }

    console.info("[MP webhook] payment recibido", {
      id: p.id,
      status: p.status,
      status_detail: p.status_detail,
      external_reference: p.external_reference || null,
      pref_meta_orderid: p.metadata?.orderid || null,
    });

    const orderForMail = {
      items: [
        {
          title: "Pago Mercado Pago",
          unit_price: Number(p.transaction_amount || 0),
          quantity: 1,
        },
      ],
      total: Number(p.transaction_amount || 0),
      customer: {
        name: p.payer?.first_name || "",
        email: p.payer?.email || "",
      },
      payment_method: "mercado_pago",
      shipping: {
        mode: p.metadata?.delivery_mode || "pickup",
        cost: 0,
        address: p.metadata?.address,
      },
      mp: {
        payment_id: p.id,
        status: p.status,
        status_detail: p.status_detail,
        preference_id: p.metadata?.preference_id || null,
        external_reference: p.external_reference || null,
        orderid: p.metadata?.orderid || null,
      },
    };

    await createEmailOrder(orderForMail);
    return { ok: true };
  } catch (err) {
    console.error("[MP webhook] error:", err?.response?.data || err.message);
    return { ok: false };
  }
};
