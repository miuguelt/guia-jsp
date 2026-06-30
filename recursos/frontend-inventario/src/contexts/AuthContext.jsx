import { createContext, useContext, useState, useEffect } from 'react'
import { login as apiLogin, getPerfil } from '../services/api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [usuario, setUsuario] = useState(null)
  const [cargando, setCargando] = useState(true)

  // Al cargar la app, verificar si hay un token guardado
  useEffect(() => {
    const token = localStorage.getItem('access_token')
    const userData = localStorage.getItem('usuario')
    if (token && userData) {
      setUsuario(JSON.parse(userData))
    }
    setCargando(false)
  }, [])

  const login = async (username, password) => {
    const data = await apiLogin(username, password)
    localStorage.setItem('access_token', data.access_token)
    localStorage.setItem('usuario', JSON.stringify(data.usuario))
    setUsuario(data.usuario)
    return data
  }

  const logout = () => {
    localStorage.removeItem('access_token')
    localStorage.removeItem('usuario')
    setUsuario(null)
    window.location.href = '/login'
  }

  const isAuthenticated = !!usuario
  const isAdmin = usuario?.rol?.nombre === 'Administrador'

  return (
    <AuthContext.Provider value={{
      usuario, login, logout, cargando,
      isAuthenticated, isAdmin,
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth debe usarse dentro de AuthProvider')
  }
  return context
}
