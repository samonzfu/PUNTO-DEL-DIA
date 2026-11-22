// Etiqueta + input reutilizable para los formularios.
export default function Campo({ id, etiqueta, tipo = 'text', valor, alCambiar, placeholder, autoComplete, requerido = true }) {
  return (
    <div>
      <label htmlFor={id}>{etiqueta}</label>
      <input
        id={id}
        name={id}
        type={tipo}
        value={valor}
        onChange={(e) => alCambiar(e.target.value)}
        placeholder={placeholder}
        autoComplete={autoComplete}
        required={requerido}
      />
    </div>
  );
}
