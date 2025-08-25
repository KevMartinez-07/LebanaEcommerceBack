import * as cartSrv from "../services/cart.service.js";

/** POST /api/cart/items  { productId, quantity?, price? } */
export const add = async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 1; // mock si aún no hay auth
    const { productId, quantity, price } = req.body;

    const cart = await cartSrv.getOpenCart(userId);
    await cartSrv.addItem(cart.cartid, Number(productId), Number(quantity || 1), price);
    const detail = await cartSrv.getCartDetail(cart.cartid);

    res.json(detail.rows ?? detail);
  } catch (err) {
    console.error("❌ Error en controller (add):", err);
    next(err);
  }
};

/** GET /api/cart/items */
export const view = async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 1;
    const cart = await cartSrv.getOpenCart(userId);
    const detail = await cartSrv.getCartDetail(cart.cartid);
    res.json(detail.rows ?? detail);
  } catch (err) {
    console.error("❌ Error en controller (view):", err);
    next(err);
  }
};

/** DELETE /api/cart/items  (vaciar) */
export const clear = async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 1;
    const cart = await cartSrv.getOpenCart(userId);
    await cartSrv.clearCart(cart.cartid);
    res.status(204).end();
  } catch (err) {
    console.error("❌ Error en controller (clear):", err);
    next(err);
  }
};
