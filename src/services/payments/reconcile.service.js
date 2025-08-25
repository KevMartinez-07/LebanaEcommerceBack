// src/services/payments/reconcile.service.js
import pool from "../../config/db.js";
import { mpClient, Payment } from "../../config/mp.js";

const PENDING = new Set(["pending","in_process","authorized"]);

export const reconcilePendingPayments = async () => {
  const { rows } = await pool.query(
    `SELECT mp_payment_id
       FROM order_payments
      WHERE status IS NULL OR status IN ('pending','in_process','authorized')
      ORDER BY id DESC
      LIMIT 100`
  );

  const payment = new Payment(mpClient);

  for (const r of rows) {
    try {
      const p = await payment.get({ id: r.mp_payment_id });
      const status = p.status;

      await pool.query(
        `UPDATE order_payments
            SET status=$2, status_detail=$3, amount=$4, currency=$5, payer_email=$6, raw=$7, last_checked_at=NOW()
          WHERE mp_payment_id=$1`,
        [p.id, status, p.status_detail || null, p.transaction_amount, p.currency_id, p.payer?.email || null, p]
      );

      const orderid = Number(p.external_reference);
      if (orderid) {
        const newStatus =
          status === "approved" ? "confirmed" :
          PENDING.has(status) ? "pending" :
          "rejected";
        await pool.query(`UPDATE orders SET status=$2 WHERE orderid=$1`, [orderid, newStatus]);
      }
    } catch (e) {
      console.error("reconcile error:", r.mp_payment_id, e.message);
    }
  }
};
