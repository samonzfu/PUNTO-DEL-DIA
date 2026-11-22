import { useState } from 'react';
import { Link } from 'react-router-dom';
import PanelMarca from '../componentes/PanelMarca.jsx';
import Campo from '../componentes/Campo.jsx';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  function enviar(e) {
    e.preventDefault();
    // Semana 2: aquí se llamará a la API (POST /api/auth/login).
  }

  return (
    <div className="pagina-auth">
      <PanelMarca />
      <main className="zona-form">
        <form className="tarjeta" onSubmit={enviar}>
          <h2>Iniciar sesión</h2>
          <p className="tarjeta__sub">Accede con tu cuenta de vecino.</p>
          <div className="campos">
            <Campo id="email" etiqueta="Correo electrónico" tipo="email" valor={email} alCambiar={setEmail} placeholder="nombre@correo.com" autoComplete="email" />
            <Campo id="password" etiqueta="Contraseña" tipo="password" valor={password} alCambiar={setPassword} placeholder="Tu contraseña" autoComplete="current-password" />
            <button type="submit" className="boton">Entrar</button>
          </div>
          <p className="tarjeta__pie">¿Aún no tienes cuenta? <Link to="/registro">Crear cuenta</Link></p>
        </form>
      </main>
    </div>
  );
}
