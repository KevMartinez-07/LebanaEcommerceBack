import { sendMail } from "../../config/mailer.js";
import { buildOrderHtml } from "../templates/orderEmail.template.js";

/**
 * order = {
 *   items:[{title,unit_price,quantity}],
 *   total,
 *   customer:{name,email,phone},
 *   payment_method:'pickup'|'delivery_email'|'mp_pending'|'mercado_pago',
 *   store?, notes?,
 *   shipping:{mode:'pickup'|'delivery', cost, address?},
 *   mp?: { preference_id?, payment_id?, status? }
 * }
 */
export const createEmailOrder = async (order) => {
  await sendMail({
    subject: `Nuevo pedido - ${order.customer?.name || ""} - ${order.payment_method}`,
    replyTo: order.customer?.email,
    html: buildOrderHtml(order),
  });
  return { ok: true };
};
