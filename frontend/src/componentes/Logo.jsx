// Logo de Punto del día: casita con llave. Los colores vienen de global.css (modo claro/oscuro).
export default function Logo({ tamano = 48 }) {
  return (
    <svg width={tamano} height={tamano} viewBox="0 0 64 64" fill="none" aria-hidden="true">
      <rect className="logo-baldosa" width="64" height="64" rx="16" />
      <circle className="logo-circulo" cx="32" cy="32" r="22" />
      <path className="logo-casa" d="M32 12l11 8v10H21V20z" />
      <circle className="logo-punto" cx="32" cy="22" r="2.8" />
      <rect className="logo-casa" x="29.5" y="30" width="5" height="22" rx="2.5" />
      <rect className="logo-casa" x="34" y="39" width="7" height="3.4" rx="1.7" />
      <rect className="logo-casa" x="34" y="45.5" width="5" height="3.4" rx="1.7" />
    </svg>
  );
}
