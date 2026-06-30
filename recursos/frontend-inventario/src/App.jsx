import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import Navbar from './components/Navbar'
import ProtectedRoute from './components/ProtectedRoute'
import Login from './pages/Login'
import Register from './pages/Register'
import ProductoLista from './components/ProductoLista'
import ProductoForm from './components/ProductoForm'
import AdminUsuarios from './pages/AdminUsuarios'
import './App.css'

function Inicio() {
  const { isAuthenticated, usuario } = useAuth()
  return (
    <div className="inicio">
      <h1>Sistema de Inventario</h1>
      <p>FastAPI + React 19 — Autenticación JWT + Roles</p>
      {isAuthenticated ? (
        <div className="inicio-stats">
          <div className="stat-card">
            <i className="fas fa-boxes"></i>
            <h3>Gestión de Productos</h3>
            <p>CRUD completo con JWT y control por roles</p>
            <a href="/productos" className="btn-link">Ir a Productos →</a>
          </div>
          {usuario?.rol?.nombre === 'Administrador' && (
            <div className="stat-card">
              <i className="fas fa-users-cog"></i>
              <h3>Administración</h3>
              <p>Gestión de usuarios con roles y permisos</p>
              <a href="/admin" className="btn-link">Ir a Admin →</a>
            </div>
          )}
        </div>
      ) : (
        <div className="inicio-stats">
          <div className="stat-card">
            <i className="fas fa-sign-in-alt"></i>
            <h3>Inicia Sesión</h3>
            <p>Accede al sistema de inventario con tu cuenta</p>
            <a href="/login" className="btn-link">Ingresar →</a>
          </div>
          <div className="stat-card">
            <i className="fas fa-user-plus"></i>
            <h3>Regístrate</h3>
            <p>Crea una cuenta para comenzar</p>
            <a href="/register" className="btn-link">Registrarse →</a>
          </div>
        </div>
      )}
    </div>
  )
}

function AppRoutes() {
  return (
    <BrowserRouter>
      <Navbar />
      <main className="contenido">
        <Routes>
          {/* Rutas públicas */}
          <Route path="/" element={<Inicio />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Rutas protegidas (cualquier usuario autenticado) */}
          <Route path="/productos" element={
            <ProtectedRoute><ProductoLista /></ProtectedRoute>
          } />
          <Route path="/productos/nuevo" element={
            <ProtectedRoute><ProductoForm /></ProtectedRoute>
          } />
          <Route path="/productos/:id/editar" element={
            <ProtectedRoute><ProductoForm /></ProtectedRoute>
          } />

          {/* Rutas protegidas (solo Admin) */}
          <Route path="/admin" element={
            <ProtectedRoute adminOnly={true}><AdminUsuarios /></ProtectedRoute>
          } />

          {/* Ruta por defecto */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </BrowserRouter>
  )
}

export default function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  )
}
