import Logo from './Logo.jsx';

const PUNTOS = [
  'Contraseñas guardadas de forma cifrada',
  'Cada comunidad ve únicamente sus datos',
  'Acceso según tu rol: vecino, presidente o administrador',
];

export default function PanelMarca() {
  return (
    <aside className="panel-marca">
      <div className="panel-marca__logo">
        <Logo />
        <span>Punto del día</span>
      </div>
      <div>
        <h1>Tu comunidad, en orden y a un clic</h1>
        <p>Incidencias, reservas, votaciones y avisos de tu finca, reunidos en un solo lugar.</p>
      </div>
      <ul className="panel-marca__puntos">
        {PUNTOS.map((texto) => (
          <li key={texto}>
            <svg width="22" height="22" viewBox="0 0 22 22" fill="none" aria-hidden="true">
              <circle className="check-fondo" cx="11" cy="11" r="11" />
              <path className="check-trazo" d="M6 11.5l3.2 3.2L16 8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
            {texto}
          </li>
        ))}
      </ul>
    </aside>
  );
}
