import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export default function Login() {
  const navigate = useNavigate()
  const { login } = useAuth()
  const [form, setForm] = useState({ username: '', password: '' })
  const [error, setError] = useState(null)
  const [enviando, setEnviando] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setEnviando(true)
    setError(null)
    try {
      const data = await login(form.username, form.password)
      // Redirigir según el rol
      if (data.usuario.rol?.nombre === 'Administrador') {
        navigate('/admin')
      } else {
        navigate('/productos')
      }
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al iniciar sesión')
    } finally {
      setEnviando(false)
    }
  }

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-header">
          <i className="fas fa-boxes"></i>
          <h2>Iniciar Sesión</h2>
          <p>Sistema de Inventario SENA</p>
        </div>

        {error && <div className="error-banner"><i className="fas fa-exclamation-circle"></i> {error}</div>}

        <form onSubmit={handleSubmit} className="auth-form">
          <div className="form-group">
            <label>Usuario</label>
            <input
              name="username" value={form.username}
              onChange={e => setForm({ ...form, username: e.target.value })}
              required autoFocus
            />
          </div>
          <div className="form-group">
            <label>Contraseña</label>
            <input
              name="password" type="password" value={form.password}
              onChange={e => setForm({ ...form, password: e.target.value })}
              required
            />
          </div>
          <button type="submit" className="btn-guardar btn-full" disabled={enviando}>
            {enviando ? 'Ingresando...' : 'Ingresar'}
          </button>
        </form>

        <div className="auth-footer">
          <p>¿No tienes cuenta? <a href="/register">Registrarse</a></p>
          <div className="auth-credenciales">
            <p><strong>Demo:</strong> admin / admin123</p>
            <p><strong>Demo:</strong> cliente / admin123</p>
          </div>
        </div>
      </div>
    </div>
  )
}
