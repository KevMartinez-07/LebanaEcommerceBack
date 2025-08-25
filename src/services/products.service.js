// 
import pool from "../config/db.js";

export const getAll = async () => {
  return pool.query(`
    SELECT productoid, descripcion, precio, imagen
    FROM productos
    ORDER BY productoid
  `);
};

export const getById = async (id) => {
  return pool.query(
    `SELECT productoid, descripcion, precio, imagen
     FROM productos
     WHERE productoid = $1`,
    [id]
  );
};
