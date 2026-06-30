import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { register as apiRegister } from '../services/api'

export default function Register() {
  const navigate = useNavigate()
  const [form, setForm] = useState({
    username: '', password: '', confirmar: '',
    nombre_completo: '', email: '', rol_id: 2,  // Default: Cliente
  })
  const [error, setError] = useState(null)
  const [enviando, setEnviando] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (form.password !== form.confirmar) {
      setError('Las contraseñas no coinciden')
      return
    }
    setEnviando(true)
    setError(null)
    try {
      await apiRegister({
        username: form.username,
        password: form.password,
        nombre_completo: form.nombre_completo,
        email: form.email,
        rol_id: parseInt(form.rol_id),
      })
      alert('Registro exitoso. Ahora puedes iniciar sesión.')
      navigate('/login')
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al registrarse')
    } finally {
      setEnviando(false)
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <i className="fas fa-user-plus"></i>
          <h2>Crear Cuenta</h2>
          <p>Regístrate en el Sistema de Inventario</p>
        </div>

        {error && <div className="error-banner"><i className="fas fa-exclamation-circle"></i> {error}</div>}

        <form onSubmit={handleSubmit} className="auth-form">
          <div className="form-group">
            <label>Usuario *</label>
            <input name="username" value={form.username}
              onChange={e => setForm({ ...form, username: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Nombre Completo *</label>
            <input name="nombre_completo" value={form.nombre_completo}
              onChange={e => setForm({ ...form, nombre_completo: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Email *</label>
            <input name="email" type="email" value={form.email}
              onChange={e => setForm({ ...form, email: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Contraseña *</label>
            <input name="password" type="password" value={form.password}
              onChange={e => setForm({ ...form, password: e.target.value })} required minLength={6} />
          </div>
          <div className="form-group">
            <label>Confirmar Contraseña *</label>
            <input name="confirmar" type="password" value={form.confirmar}
              onChange={e => setForm({ ...form, confirmar: e.target.value })} required />
          </div>
          <button type="submit" className="btn-guardar btn-full" disabled={enviando}>
            {enviando ? 'Registrando...' : 'Crear Cuenta'}
          </button>
        </form>

        <div className="auth-footer">
          <p>¿Ya tienes cuenta? <a href="/login">Iniciar Sesión</a></p>
        </div>
      </div>
    </div>
  )
}
