import { useState, useEffect } from 'react'
import { listarProductos, eliminarProducto } from '../services/api'
import ProductoCard from './ProductoCard'

const ITEMS_POR_PAGINA = 6

export default function ProductoLista() {
  const [productos, setProductos] = useState([])
  const [cargando, setCargando] = useState(true)
  const [error, setError] = useState(null)
  const [filtro, setFiltro] = useState('')
  const [mensaje, setMensaje] = useState(null)
  const [pagina, setPagina] = useState(1)
  const [totalPaginas, setTotalPaginas] = useState(1)

  useEffect(() => {
    cargarProductos()
  }, [pagina])

  async function cargarProductos() {
    try {
      setCargando(true)
      const data = await listarProductos({ pagina, tamano: ITEMS_POR_PAGINA })
      setProductos(data.items || data)
      setTotalPaginas(data.total_paginas || 1)
      setError(null)
    } catch (err) {
      setError('Error al cargar productos: ' + err.message)
    } finally {
      setCargando(false)
    }
  }

  async function handleEliminar(id) {
    if (!confirm('¿Eliminar este producto?')) return
    try {
      await eliminarProducto(id)
      setMensaje({ tipo: 'exito', texto: 'Producto eliminado' })
      cargarProductos()
    } catch (err) {
      setMensaje({ tipo: 'error', texto: 'Error al eliminar' })
    }
  }

  const productosFiltrados = filtro
    ? productos.filter(p =>
        p.nombre?.toLowerCase().includes(filtro.toLowerCase()) ||
        p.codigo?.toLowerCase().includes(filtro.toLowerCase()))
    : productos

  if (cargando) {
    return (
      <div className="estado-container">
        <div className="spinner"></div>
        <p>Cargando productos...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="estado-container error">
        <i className="fas fa-exclamation-triangle"></i>
        <p>{error}</p>
        <button onClick={cargarProductos} className="btn-reintentar">Reintentar</button>
      </div>
    )
  }

  return (
    <div className="producto-lista">
      {mensaje && (
        <div className={`mensaje ${mensaje.tipo}`}>
          {mensaje.texto}
          <button onClick={() => setMensaje(null)}>&times;</button>
        </div>
      )}
      <div className="lista-header">
        <h2>Productos ({productos.length})</h2>
        <div className="lista-acciones">
          <input
            type="text"
            placeholder="Buscar producto..."
            value={filtro}
            onChange={e => setFiltro(e.target.value)}
            className="buscador"
          />
          <a href="/productos/nuevo" className="btn-crear">+ Nuevo Producto</a>
        </div>
      </div>

      {productosFiltrados.length === 0 ? (
        <div className="vacio">
          <i className="fas fa-box-open"></i>
          <p>{filtro ? 'Sin resultados para "' + filtro + '"' : 'No hay productos'}</p>
        </div>
      ) : (
        <>
          <div className="productos-grid">
            {productosFiltrados.map(producto => (
              <ProductoCard key={producto.id} producto={producto} onEliminar={handleEliminar} />
            ))}
          </div>

          {totalPaginas > 1 && (
            <div className="paginacion">
              <button
                onClick={() => setPagina(p => Math.max(1, p - 1))}
                disabled={pagina === 1}
                className="btn-pagina"
              >
                &laquo; Anterior
              </button>
              <span className="pagina-info">Página {pagina} de {totalPaginas}</span>
              <button
                onClick={() => setPagina(p => Math.min(totalPaginas, p + 1))}
                disabled={pagina === totalPaginas}
                className="btn-pagina"
              >
                Siguiente &raquo;
              </button>
            </div>
          )}
        </>
      )}
    </div>
  )
}
