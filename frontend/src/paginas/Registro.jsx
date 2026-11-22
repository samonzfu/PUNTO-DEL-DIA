import { useState } from 'react';
import { Link } from 'react-router-dom';
import PanelMarca from '../componentes/PanelMarca.jsx';
import Campo from '../componentes/Campo.jsx';

export default function Registro() {
  const [nombre, setNombre] = useState('');
  const [apellidos, setApellidos] = useState('');
  const [email, setEmail] = useState('');
  const [telefono, setTelefono] = useState('');
  const [password, setPassword] = useState('');
  const [repetir, setRepetir] = useState('');
  const [error, setError] = useState('');

  function enviar(e) {
    e.preventDefault();
    if (password.length < 8) {
      setError('La contraseña debe tener al menos 8 caracteres.');
      return;
    }
    if (password !== repetir) {
      setError('Las contraseñas no coinciden.');
      return;
    }
    setError('');
    // Semana 2: aquí se llamará a la API (POST /api/auth/registro).
  }

  return (
    <div className="pagina-auth">
      <PanelMarca />
      <main className="zona-form">
        <form className="tarjeta" onSubmit={enviar}>
          <h2>Crear cuenta</h2>
          <p className="tarjeta__sub">Regístrate para unirte a tu comunidad.</p>
          <div className="campos">
            <div className="fila">
              <Campo id="nombre" etiqueta="Nombre" valor={nombre} alCambiar={setNombre} placeholder="Nombre" autoComplete="given-name" />
              <Campo id="apellidos" etiqueta="Apellidos" valor={apellidos} alCambiar={setApellidos} placeholder="Apellidos" autoComplete="family-name" />
            </div>
            <Campo id="email" etiqueta="Correo electrónico" tipo="email" valor={email} alCambiar={setEmail} placeholder="nombre@correo.com" autoComplete="email" />
            <Campo id="telefono" etiqueta="Teléfono (opcional)" tipo="tel" valor={telefono} alCambiar={setTelefono} placeholder="600 000 000" autoComplete="tel" requerido={false} />
            <Campo id="password" etiqueta="Contraseña" tipo="password" valor={password} alCambiar={setPassword} placeholder="Mínimo 8 caracteres" autoComplete="new-password" />
            <Campo id="repetir" etiqueta="Repite la contraseña" tipo="password" valor={repetir} alCambiar={setRepetir} placeholder="Repite la contraseña" autoComplete="new-password" />
            {error && <p className="error" role="alert">{error}</p>}
            <button type="submit" className="boton">Crear cuenta</button>
          </div>
          <p className="tarjeta__pie">¿Ya tienes cuenta? <Link to="/login">Iniciar sesión</Link></p>
        </form>
      </main>
    </div>
  );
}
