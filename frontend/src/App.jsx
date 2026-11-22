import { Routes, Route, Navigate } from 'react-router-dom';
import Login from './paginas/Login.jsx';
import Registro from './paginas/Registro.jsx';

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/registro" element={<Registro />} />
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  );
}
