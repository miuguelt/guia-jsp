import { Link } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export default function Navbar() {
  const { usuario, logout, isAuthenticated, isAdmin } = useAuth()

  return (
    <nav className="navbar">
      <div className="navbar-left">
        <Link to="/" className="navbar-brand">
          <i className="fas fa-boxes"></i>
          <span>Inventario SENA</span>
        </Link>
        <div className="navbar-links">
          <Link to="/">Inicio</Link>
          {isAuthenticated && <Link to="/productos">Productos</Link>}
          {isAdmin && <Link to="/admin">Admin</Link>}
        </div>
      </div>
      <div className="navbar-right">
        {isAuthenticated ? (
          <div className="navbar-user">
            <span className="user-badge" title={usuario.rol?.nombre}>
              <i className="fas fa-user-circle"></i>
              {usuario.nombre_completo}
              {isAdmin && <span className="admin-tag">Admin</span>}
            </span>
            <button onClick={logout} className="btn-logout" title="Cerrar sesión">
              <i className="fas fa-sign-out-alt"></i>
            </button>
          </div>
        ) : (
          <div className="navbar-auth">
            <Link to="/login" className="btn-login-nav">Ingresar</Link>
            <Link to="/register" className="btn-register-nav">Registrarse</Link>
          </div>
        )}
      </div>
    </nav>
  )
}
