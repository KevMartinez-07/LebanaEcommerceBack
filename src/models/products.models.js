const { getProducts } = require('../services/products.service');

exports.getAll = async (req, res) => {
  try {
    const result = await getProducts();
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
