import { useState, useEffect } from 'react'
import { listarUsuarios, eliminarUsuario, actualizarUsuario } from '../services/api'
import { useAuth } from '../contexts/AuthContext'

function ConfirmModal({ abierto, titulo, mensaje, confirmando, onConfirmar, onCancelar }) {
  if (!abierto) return null
  return (
    <div className="modal-overlay" onClick={onCancelar}>
      <div className="modal-contenido" onClick={e => e.stopPropagation()}>
        <h3>{titulo}</h3>
        <p>{mensaje}</p>
        <div className="modal-acciones">
          <button onClick={onCancelar} className="btn-cancelar" disabled={confirmando}>Cancelar</button>
          <button onClick={onConfirmar} className="btn-danger" disabled={confirmando}>
            {confirmando ? 'Procesando...' : 'Confirmar'}
          </button>
        </div>
      </div>
    </div>
  )
}

export default function AdminUsuarios() {
  const { usuario: currentUser } = useAuth()
  const [usuarios, setUsuarios] = useState([])
  const [cargando, setCargando] = useState(true)
  const [error, setError] = useState(null)
  const [mensaje, setMensaje] = useState(null)
  const [confirmar, setConfirmar] = useState(null)
  const [procesando, setProcesando] = useState(false)

  useEffect(() => { cargarUsuarios() }, [])

  async function cargarUsuarios() {
    try {
      setCargando(true)
      const data = await listarUsuarios()
      setUsuarios(data)
      setError(null)
    } catch (err) {
      setError('Error al cargar usuarios')
    } finally {
      setCargando(false)
    }
  }

  async function handleToggleEstado(usuario) {
    setProcesando(true)
    try {
      await actualizarUsuario(usuario.id, {
        username: usuario.username,
        nombre_completo: usuario.nombre_completo,
        email: usuario.email,
        rol_id: usuario.rol_id,
      })
      setMensaje({ tipo: 'exito', texto: `Usuario ${usuario.estado ? 'desactivado' : 'activado'}` })
      cargarUsuarios()
    } catch (err) {
      setMensaje({ tipo: 'error', texto: 'Error al actualizar usuario' })
    } finally {
      setProcesando(false)
    }
  }

  async function handleEliminarConfirmado() {
    if (!confirmar) return
    setProcesando(true)
    try {
      await eliminarUsuario(confirmar.id)
      setMensaje({ tipo: 'exito', texto: 'Usuario eliminado' })
      setConfirmar(null)
      cargarUsuarios()
    } catch (err) {
      setMensaje({ tipo: 'error', texto: 'Error al eliminar' })
    } finally {
      setProcesando(false)
    }
  }

  if (cargando) {
    return <div className="estado-container"><div className="spinner"></div><p>Cargando usuarios...</p></div>
  }

  if (error) {
    return (
      <div className="estado-container error">
        <i className="fas fa-exclamation-triangle"></i>
        <p>{error}</p>
        <button onClick={cargarUsuarios} className="btn-reintentar">Reintentar</button>
      </div>
    )
  }

  return (
    <div className="admin-page">
      <h2><i className="fas fa-users-cog"></i> Administración de Usuarios</h2>
      <p className="admin-subtitle">Gestión de usuarios, roles y permisos del sistema</p>

      {mensaje && (
        <div className={`mensaje ${mensaje.tipo}`}>
          {mensaje.texto}
          <button onClick={() => setMensaje(null)}>&times;</button>
        </div>
      )}

      {usuarios.length === 0 ? (
        <div className="vacio">
          <i className="fas fa-users"></i>
          <p>No hay usuarios registrados</p>
        </div>
      ) : (
        <div className="usuarios-table-container">
          <table className="usuarios-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Usuario</th>
                <th>Nombre</th>
                <th>Email</th>
                <th>Rol</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {usuarios.map(u => (
                <tr key={u.id} className={u.id === currentUser?.id ? 'row-current' : ''}>
                  <td>{u.id}</td>
                  <td><code>{u.username}</code></td>
                  <td>{u.nombre_completo}</td>
                  <td>{u.email}</td>
                  <td>
                    <span className={`rol-badge ${u.rol?.nombre === 'Administrador' ? 'rol-admin' : 'rol-user'}`}>
                      {u.rol?.nombre || 'Sin rol'}
                    </span>
                  </td>
                  <td>
                    <span className={`estado-badge ${u.estado ? 'activo' : 'inactivo'}`}>
                      {u.estado ? 'Activo' : 'Inactivo'}
                    </span>
                  </td>
                  <td className="acciones-cell">
                    {u.id !== currentUser?.id ? (
                      <>
                        <button onClick={() => handleToggleEstado(u)}
                          className="btn-small btn-warning"
                          disabled={procesando}
                          title={u.estado ? 'Desactivar' : 'Activar'}>
                          <i className={`fas fa-${u.estado ? 'ban' : 'check'}`}></i>
                        </button>
                        <button onClick={() => setConfirmar(u)}
                          className="btn-small btn-danger"
                          disabled={procesando}
                          title="Eliminar">
                          <i className="fas fa-trash"></i>
                        </button>
                      </>
                    ) : (
                      <span className="text-muted">Tu cuenta</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmModal
        abierto={!!confirmar}
        titulo="Eliminar Usuario"
        mensaje={confirmar ? `¿Eliminar permanentemente a "${confirmar.nombre_completo}" (${confirmar.username})? Esta acción no se puede deshacer.` : ''}
        confirmando={procesando}
        onConfirmar={handleEliminarConfirmado}
        onCancelar={() => setConfirmar(null)}
      />
    </div>
  )
}
