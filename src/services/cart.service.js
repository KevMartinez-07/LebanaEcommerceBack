import pool from "../config/db.js";

/** Obtiene el carrito abierto del usuario o lo crea */
export const getOpenCart = async (userId) => {
  const client = await pool.connect();
  try {
    const found = await client.query(
      `SELECT cartid
         FROM carts
        WHERE userid = $1
        ORDER BY created_at DESC
        LIMIT 1`,
      [userId]
    );

    if (found.rows.length) return { cartid: found.rows[0].cartid };

    const created = await client.query(
      `INSERT INTO carts (userid, created_at)
       VALUES ($1, NOW())
       RETURNING cartid`,
      [userId]
    );
    return { cartid: created.rows[0].cartid };
  } catch (err) {
    console.error("❌ Error en service (getOpenCart):", err);
    throw err;
  } finally {
    client.release();
  }
};

/** Agrega un item al carrito; si no mandan price, lo toma de productos.precio */
export const addItem = async (cartId, productId, quantity, price) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    let unitPrice = Number(price || 0);
    if (!unitPrice) {
      const pr = await client.query(
        `SELECT precio FROM productos WHERE productoid = $1`,
        [productId]
      );
      if (!pr.rows.length) throw new Error("Producto no encontrado");
      unitPrice = Number(pr.rows[0].precio);
    }

    await client.query(
      `INSERT INTO cart_items (cartid, productid, quantity, price)
       VALUES ($1, $2, $3, $4)`,
      [cartId, productId, quantity, unitPrice]
    );

    await client.query("COMMIT");
  } catch (err) {
    await client.query("ROLLBACK");
    console.error("❌ Error en service (addItem):", err);
    throw err;
  } finally {
    client.release();
  }
};

/** Detalle del carrito con descripciones e imagen, incluye subtotal */
export const getCartDetail = async (cartId) => {
  return pool.query(
    `SELECT
        ci.cartitemid,
        ci.productid,
        ci.quantity,
        ci.price,
        (ci.quantity * ci.price) AS subtotal,
        p.descripcion,
        p.imagen
     FROM cart_items ci
     JOIN productos p ON p.productoid = ci.productid
     WHERE ci.cartid = $1
     ORDER BY ci.cartitemid`,
    [cartId]
  );
};

/** Vacía el carrito */
export const clearCart = async (cartId) => {
  await pool.query(`DELETE FROM cart_items WHERE cartid = $1`, [cartId]);
};
