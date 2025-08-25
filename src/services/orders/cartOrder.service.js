import pool from "../../config/db.js";

/** Crea orden desde items del carrito de un usuario y limpia el carrito */
export const createFromCart = async (userId) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const cartRes = await client.query(
      `SELECT ci.productid, ci.quantity, ci.price, c.cartid
         FROM carts c
         JOIN cart_items ci ON c.cartid = ci.cartid
        WHERE c.userid = $1`,
      [userId]
    );
    const cartItems = cartRes.rows;
    if (!cartItems.length) throw new Error("Carrito vacío");

    const total = cartItems.reduce((s, it) => s + Number(it.price) * Number(it.quantity), 0);

    const orderRes = await client.query(
      `INSERT INTO orders (userid, total, status, created_at)
       VALUES ($1, $2, 'pendiente', NOW())
       RETURNING *`,
      [userId, total]
    );
    const order = orderRes.rows[0];

    for (const it of cartItems) {
      await client.query(
        `INSERT INTO order_items (orderid, productid, quantity, price)
         VALUES ($1, $2, $3, $4)`,
        [order.orderid, it.productid, it.quantity, it.price]
      );
    }

    const cartId = cartItems[0].cartid;
    await client.query(`DELETE FROM cart_items WHERE cartid = $1`, [cartId]);
    await client.query(`DELETE FROM carts WHERE cartid = $1`, [cartId]);

    await client.query("COMMIT");
    return order;
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
};

export const getById = async (orderId, userId) => {
  const { rows } = await pool.query(
    `SELECT o.orderid, o.userid, o.total, o.status, o.created_at,
            json_agg(json_build_object(
              'productid', oi.productid,
              'quantity', oi.quantity,
              'price', oi.price
            )) AS items
       FROM orders o
       JOIN order_items oi ON oi.orderid = o.orderid
      WHERE o.orderid = $1 AND o.userid = $2
      GROUP BY o.orderid`,
    [orderId, userId]
  );
  return rows[0] || null;
};
