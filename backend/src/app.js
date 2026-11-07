import express from 'express';
import cors from 'cors';
import pool from './configuracion/baseDatos.js';

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

app.get('/api/salud', (req, res) => {
  res.json({ mensaje: 'Punto del día funcionando' });
});

app.get('/api/salud-bd', async (req, res) => {
  try {
    const [filas] = await pool.query(
      'SELECT COUNT(*) AS categorias FROM categorias_incidencia'
    );
    res.json({ mensaje: 'Conectado a MySQL', categorias: filas[0].categorias });
  } catch (error) {
    console.error(error);
    res.status(500).json({ mensaje: 'Error de conexión con la BBDD' });
  }
});

export default app;