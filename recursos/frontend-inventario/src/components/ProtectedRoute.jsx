import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export default function ProtectedRoute({ children, adminOnly = false }) {
  const { isAuthenticated, isAdmin, cargando } = useAuth()

  if (cargando) {
    return <div className="estado-container"><div className="spinner"></div><p>Verificando sesión...</p></div>
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />
  }

  if (adminOnly && !isAdmin) {
    return (
      <div className="estado-container error">
        <i className="fas fa-shield-alt"></i>
        <h2>Acceso Denegado</h2>
        <p>Se requiere rol de Administrador para acceder a esta sección.</p>
        <a href="/" className="btn-reintentar">Volver al Inicio</a>
      </div>
    )
  }

  return children
}
