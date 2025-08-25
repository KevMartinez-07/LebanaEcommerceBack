// src/services/payments/debug.service.js
import { mpClient, Payment } from "../../config/mp.js";

export const getPaymentInfo = async (id) => {
  const payment = new Payment(mpClient);
  const p = await payment.get({ id }); // acepta string o number

  return {
    id: p.id,
    status: p.status,               // approved | rejected | pending | in_process...
    status_detail: p.status_detail, // motivo exacto
    transaction_amount: p.transaction_amount,
    payment_method_id: p.payment_method_id,
    installments: p.installments,
    payer: { email: p.payer?.email },
    external_reference: p.external_reference,
    metadata: p.metadata,
  };
};
