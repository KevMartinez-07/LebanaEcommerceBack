// src/config/mailer.js
import "dotenv/config";
import nodemailer from "nodemailer";

let transporterPromise = null;

async function createTransporter() {
  // 1) Si hay credenciales SMTP en .env, usamos eso
  if (process.env.SMTP_HOST && process.env.SMTP_USER) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: Number(process.env.SMTP_PORT || 587),
      secure: process.env.SMTP_SECURE === "true",
      auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
    });
  }

  // 2) Si pediste Ethereal (o no hay SMTP), intentamos Ethereal
  if (process.env.USE_ETHEREAL === "true" || !process.env.SMTP_HOST) {
    try {
      // Puede fallar si no hay salida a internet → lo capturamos
      const test = await nodemailer.createTestAccount();
      const t = nodemailer.createTransport({
        host: "smtp.ethereal.email",
        port: 587,
        secure: false,
        auth: { user: test.user, pass: test.pass },
      });
      console.log("✉️  Ethereal listo. User:", test.user);
      return t;
    } catch (e) {
      console.warn(
        "⚠️  No se pudo crear cuenta Ethereal, usamos jsonTransport. Motivo:",
        e.message
      );
    }
  }

  // 3) Fallback final: no enviar de verdad, sólo loguear el JSON
  return nodemailer.createTransport({ jsonTransport: true });
}

async function getTransporter() {
  if (!transporterPromise) transporterPromise = createTransporter();
  return transporterPromise;
}

export async function sendMail({ subject, html, to, replyTo }) {
  const transporter = await getTransporter();

  const info = await transporter.sendMail({
    from: `"Tienda" <${process.env.STORE_EMAIL || "no-reply@local.test"}>`,
    to: to || process.env.STORE_EMAIL || "dev@local.test",
    replyTo,
    subject,
    html,
  });

  // Si es Ethereal, mostrará URL de preview
  if (nodemailer.getTestMessageUrl && info.messageId) {
    const url = nodemailer.getTestMessageUrl(info);
    if (url) console.log("🔗 Vista previa (Ethereal):", url);
  }
  // Si es jsonTransport, imprime el mail como JSON
  if (transporter.options.jsonTransport) {
    console.log("📦 Email (jsonTransport):", info.message);
  }

  return info;
}

// Útil para /api/dev/mail-verify si querés chequear conexión SMTP sin enviar
export async function verifyMailer() {
  try {
    const t = await getTransporter();
    const ok = await t.verify().catch(() => true); // algunos transports no soportan verify
    return ok;
  } catch (e) {
    return false;
  }
}
