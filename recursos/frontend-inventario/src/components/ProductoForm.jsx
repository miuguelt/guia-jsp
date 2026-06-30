import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { crearProducto, actualizarProducto, obtenerProducto } from '../services/api'

export default function ProductoForm() {
  const navigate = useNavigate()
  const { id } = useParams()
  const esEdicion = Boolean(id)

  const [form, setForm] = useState({
    codigo: '',
    nombre: '',
    descripcion: '',
    precio: '',
    stock: '0',
    categoria: '',
  })
  const [enviando, setEnviando] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (id) {
      obtenerProducto(id)
        .then(data => setForm({
          codigo: data.codigo,
          nombre: data.nombre,
          descripcion: data.descripcion || '',
          precio: data.precio.toString(),
          stock: data.stock.toString(),
          categoria: data.categoria || '',
        }))
        .catch(() => setError('Error al cargar producto'))
    }
  }, [id])

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setEnviando(true)
    setError(null)
    try {
      const datos = {
        ...form,
        precio: parseFloat(form.precio),
        stock: parseInt(form.stock),
      }
      if (esEdicion) {
        await actualizarProducto(id, datos)
        alert('Producto actualizado exitosamente')
      } else {
        await crearProducto(datos)
        alert('Producto creado exitosamente')
      }
      navigate('/')
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al guardar producto')
    } finally {
      setEnviando(false)
    }
  }

  return (
    <div className="producto-form-container">
      <h2>{esEdicion ? 'Editar Producto' : 'Nuevo Producto'}</h2>
      {error && (
        <div className="error-banner">
          <i className="fas fa-exclamation-circle"></i> {error}
        </div>
      )}
      <form onSubmit={handleSubmit} className="producto-form">
        <div className="form-grid">
          <div className="form-group">
            <label>Código *</label>
            <input name="codigo" value={form.codigo} onChange={handleChange} required minLength={3} />
          </div>
          <div className="form-group">
            <label>Nombre *</label>
            <input name="nombre" value={form.nombre} onChange={handleChange} required />
          </div>
          <div className="form-group full-width">
            <label>Descripción</label>
            <textarea name="descripcion" value={form.descripcion} onChange={handleChange} rows={3} />
          </div>
          <div className="form-group">
            <label>Precio *</label>
            <input name="precio" type="number" step="0.01" value={form.precio} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Stock *</label>
            <input name="stock" type="number" value={form.stock} onChange={handleChange} required />
          </div>
          <div className="form-group">
            <label>Categoría</label>
            <select name="categoria" value={form.categoria} onChange={handleChange}>
              <option value="">Seleccionar...</option>
              <option value="Tecnología">Tecnología</option>
              <option value="Accesorios">Accesorios</option>
              <option value="Audio">Audio</option>
            </select>
          </div>
        </div>
        <div className="form-acciones">
          <button type="button" onClick={() => navigate('/')} className="btn-cancelar">Cancelar</button>
          <button type="submit" disabled={enviando} className="btn-guardar">
            {enviando ? 'Guardando...' : (esEdicion ? 'Actualizar' : 'Crear Producto')}
          </button>
        </div>
      </form>
    </div>
  )
}
