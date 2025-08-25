// src/config/mp.js
import "dotenv/config";
import { MercadoPagoConfig, Preference, Payment } from "mercadopago";

// Tomamos el token desde .env
const accessToken = process.env.MP_ACCESS_TOKEN;

// Fallar rápido si falta la credencial (evita errores crípticos más adelante)
if (!accessToken) {
  throw new Error(
    "MP_ACCESS_TOKEN no está definido en .env. " +
    "Usa el Access Token de TEST de la cuenta vendedora."
  );
}

// Cliente v2
export const mpClient = new MercadoPagoConfig({
  accessToken,
});

// Re-export de clases para usar en servicios
export { Preference, Payment };
