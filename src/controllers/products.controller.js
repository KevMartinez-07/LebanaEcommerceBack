import * as srv from "../services/products.service.js";

/** GET /api/products */
export const getAll = async (_req, res, next) => {
  try {
    const data = await srv.getAll();             // puede ser {rows:[...]} o [...]
    const rows = Array.isArray(data) ? data : data?.rows ?? [];
    res.json(rows);
  } catch (e) { next(e); }
};

/** GET /api/products/:id */
export const getOne = async (req, res, next) => {
  try {
    const data = await srv.getById(req.params.id); // puede ser {rows:[...]} o objeto
    const row =
      data?.rows ? data.rows[0] :
      (Array.isArray(data) ? data[0] : data);

    if (!row) return res.status(404).end();
    res.json(row);
  } catch (e) { next(e); }
};
