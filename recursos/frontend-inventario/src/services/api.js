import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

const api = axios.create({
  baseURL: API_URL,
  headers: { 'Content-Type': 'application/json' },
})

// =========================================================================
// Interceptor JWT
// =========================================================================
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token')
      localStorage.removeItem('usuario')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// =========================================================================
// Auth API
// =========================================================================
export const login = async (username, password) => {
  const response = await api.post('/auth/login', { username, password })
  return response.data
}

export const register = async (usuario) => {
  const response = await api.post('/auth/register', usuario)
  return response.data
}

export const getPerfil = async () => {
  const response = await api.get('/auth/me')
  return response.data
}

export const refreshToken = async () => {
  const response = await api.post('/auth/refresh')
  return response.data
}

// =========================================================================
// Productos API (con paginación)
// =========================================================================
export const listarProductos = async (opts = {}) => {
  const { pagina = 1, tamano = 10, categoria = null } = opts
  const params = { pagina, tamano }
  if (categoria) params.categoria = categoria
  const response = await api.get('/productos/', { params })
  return response.data  // { items, total, pagina, tamano, total_paginas }
}

export const obtenerProducto = async (id) => {
  const response = await api.get(`/productos/${id}`)
  return response.data
}

export const crearProducto = async (producto) => {
  const response = await api.post('/productos/', producto)
  return response.data
}

export const actualizarProducto = async (id, producto) => {
  const response = await api.put(`/productos/${id}`, producto)
  return response.data
}

export const eliminarProducto = async (id) => {
  await api.delete(`/productos/${id}`)
}

// =========================================================================
// Usuarios API (solo Admin)
// =========================================================================
export const listarUsuarios = async () => {
  const response = await api.get('/usuarios/')
  return response.data
}

export const obtenerUsuario = async (id) => {
  const response = await api.get(`/usuarios/${id}`)
  return response.data
}

export const actualizarUsuario = async (id, data) => {
  const response = await api.put(`/usuarios/${id}`, data)
  return response.data
}

export const eliminarUsuario = async (id) => {
  await api.delete(`/usuarios/${id}`)
}
