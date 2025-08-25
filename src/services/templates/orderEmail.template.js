import { money, formatAddress } from "../utils/format.js";

export const buildOrderHtml = (order) => {
  const rows = (order.items || [])
    .map(
      (i) => `
      <tr>
        <td>${i.title}</td>
        <td style="text-align:center">${i.quantity}</td>
        <td style="text-align:right">$${money(i.unit_price)}</td>
        <td style="text-align:right">$${money(i.unit_price * i.quantity)}</td>
      </tr>`
    )
    .join("");

  const shipping =
    order.shipping?.mode === "delivery"
      ? `<p><b>Envío:</b> A domicilio — $${money(order.shipping.cost || 0)}</p>
         <p><b>Dirección:</b> ${formatAddress(order.shipping.address)}</p>`
      : `<p><b>Entrega:</b> Retiro en tienda ${order.store ? `— ${order.store}` : ""}</p>`;

  const mpBlock = order.mp
    ? `<p><b>MP:</b> pref=${order.mp.preference_id || "-"} · pago=${order.mp.payment_id || "-"} · estado=${order.mp.status || "-"}</p>`
    : "";

  return `
  <div style="font-family:Inter,Arial,sans-serif">
    <h2>Nuevo pedido</h2>
    <p><b>Cliente:</b> ${order.customer?.name || ""} — ${order.customer?.email || ""} — ${order.customer?.phone || "-"}</p>
    ${shipping}
    <p><b>Observaciones:</b> ${order.notes || "-"}</p>

    <table width="100%" cellspacing="0" cellpadding="8" style="border-collapse:collapse;margin-top:10px">
      <thead>
        <tr style="background:#f5f5f5">
          <th align="left">Producto</th><th>Cant.</th><th align="right">Precio</th><th align="right">Subtotal</th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>

    <h3 style="text-align:right;margin:8px 0 0">Total: $${money(order.total)}</h3>
    <p><b>Método:</b> ${order.payment_method}</p>
    ${mpBlock}
  </div>`;
};
