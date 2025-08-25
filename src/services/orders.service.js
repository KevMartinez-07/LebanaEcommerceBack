import pool from "../config/db.js";

export const createOrderFromCart = async (userId) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // 1) Items del carrito del usuario
    const cartRes = await client.query(
      `SELECT ci.productid, ci.quantity, ci.price, c.cartid
       FROM carts c
       JOIN cart_items ci ON c.cartid = ci.cartid
       WHERE c.userid = $1`,
      [userId]
    );
    const cartItems = cartRes.rows;
    if (cartItems.length === 0) throw new Error("Carrito vacío");

    // 2) Total
    const total = cartItems.reduce((sum, it) => sum + Number(it.price) * Number(it.quantity), 0);

    // 3) Crear orden
    const orderRes = await client.query(
      `INSERT INTO orders (userid, total, status, created_at)
       VALUES ($1, $2, 'pendiente', NOW())
       RETURNING *`,
      [userId, total]
    );
    const order = orderRes.rows[0];

    // 4) Items de la orden
    for (const it of cartItems) {
      await client.query(
        `INSERT INTO order_items (orderid, productid, quantity, price)
         VALUES ($1, $2, $3, $4)`,
        [order.orderid, it.productid, it.quantity, it.price]
      );
    }

    // 5) Vaciar carrito
    const cartId = cartItems[0].cartid;
    await client.query(`DELETE FROM cart_items WHERE cartid = $1`, [cartId]);
    await client.query(`DELETE FROM carts WHERE cartid = $1`, [cartId]);

    await client.query("COMMIT");
    return order;
  } catch (err) {
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
};

export const getOrderById = async (orderId, userId) => {
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
