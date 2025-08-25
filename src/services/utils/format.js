export const money = (n) => Number(n || 0).toFixed(2);

export const formatAddress = (a) => {
  if (!a) return "-";
  const parts = [
    a.street && a.number ? `${a.street} ${a.number}` : a.street || "",
    a.apartment ? `Dpto ${a.apartment}` : "",
    a.city || "",
    a.state || "",
    a.zip ? `(CP ${a.zip})` : "",
  ].filter(Boolean);
  return parts.join(", ");
};
