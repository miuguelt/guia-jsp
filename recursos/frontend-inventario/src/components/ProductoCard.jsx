export default function ProductoCard({ producto, onEliminar }) {
  const formatoPrecio = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0,
  })

  return (
    <div className="producto-card">
      <div className="producto-header">
        <span className="producto-codigo">{producto.codigo}</span>
        <span className={`producto-estado ${producto.estado ? 'activo' : 'inactivo'}`}>
          {producto.estado ? 'Activo' : 'Inactivo'}
        </span>
      </div>
      <h3 className="producto-nombre">{producto.nombre}</h3>
      {producto.descripcion && (
        <p className="producto-descripcion">{producto.descripcion}</p>
      )}
      <div className="producto-detalles">
        <div className="producto-precio">
          <span className="label">Precio:</span>
          <span className="valor">{formatoPrecio.format(producto.precio)}</span>
        </div>
        <div className="producto-stock">
          <span className="label">Stock:</span>
          <span className={`valor ${producto.stock < 10 ? 'stock-bajo' : 'stock-normal'}`}>
            {producto.stock} unidades
          </span>
        </div>
        <div className="producto-categoria">
          <span className="label">Categoría:</span>
          <span className="valor">{producto.categoria || 'Sin categoría'}</span>
        </div>
      </div>
      <div className="producto-acciones">
        <a href={`/productos/${producto.id}/editar`} className="btn-editar">
          <i className="fas fa-edit"></i> Editar
        </a>
        <button onClick={() => onEliminar(producto.id)} className="btn-eliminar">
          <i className="fas fa-trash"></i> Eliminar
        </button>
      </div>
    </div>
  )
}
