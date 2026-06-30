// =============================================================================
//  Pantalla: UsuarioFormScreen
//  Formulario para crear o editar un usuario.
//  Solo accesible por Administradores.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/usuario.dart';
import '../../providers/auth_provider.dart';
import '../../providers/usuarios_provider.dart';

class UsuarioFormScreen extends ConsumerStatefulWidget {
  /// ID del usuario a editar (null si es creacion).
  final int? usuarioId;

  const UsuarioFormScreen({super.key, this.usuarioId});

  @override
  ConsumerState<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends ConsumerState<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingUsuario = false;

  List<Rol> _roles = [];
  Rol? _selectedRol;
  bool _loadingRoles = true;

  /// Indica si estamos en modo edicion.
  bool get _isEditing => widget.usuarioId != null;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    if (_isEditing) {
      _loadUsuario();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await ref.read(authProvider.notifier).getRoles();
      if (mounted) {
        setState(() {
          _roles = roles;
          _loadingRoles = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRoles = false);
    }
  }

  Future<void> _loadUsuario() async {
    setState(() => _isLoadingUsuario = true);
    try {
      final usuarios = await ref.read(usuariosProvider.future);
      final usuario = usuarios.firstWhere((u) => u.id == widget.usuarioId);
      _usernameController.text = usuario.username;
      _nombreController.text = usuario.nombreCompleto;
      _emailController.text = usuario.email;
      // Seleccionar el rol actual
      if (usuario.rol != null) {
        setState(() => _selectedRol = usuario.rol);
      } else {
        // Buscar rol por id
        final rol = _roles.where((r) => r.id == usuario.rolId).firstOrNull;
        if (rol != null) setState(() => _selectedRol = rol);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar usuario: $e')),
        );
        context.go('/usuarios');
      }
    } finally {
      if (mounted) setState(() => _isLoadingUsuario = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un rol')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'username': _usernameController.text.trim(),
        'nombre_completo': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'rol_id': _selectedRol!.id,
      };

      if (_isEditing) {
        await ref
            .read(usuariosProvider.notifier)
            .update(widget.usuarioId!, data);
      } else {
        // En creacion, solicitar contrasena por defecto
        data['password'] = 'cambio123';
        await ref.read(usuariosProvider.notifier).create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Usuario actualizado correctamente'
                  : 'Usuario creado correctamente',
            ),
          ),
        );
        context.go('/usuarios');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      ),
      body: _isLoadingUsuario
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre de usuario
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (v.trim().length < 3) return 'Minimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre completo
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Correo electronico
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Correo invalido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seleccion de rol
                    _loadingRoles
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<Rol>(
                            value: _selectedRol,
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              prefixIcon: Icon(Icons.shield_outlined),
                            ),
                            items: _roles.map((rol) {
                              return DropdownMenuItem(
                                value: rol,
                                child: Text(rol.nombre),
                              );
                            }).toList(),
                            onChanged: (rol) {
                              setState(() => _selectedRol = rol);
                            },
                            validator: (v) =>
                                v == null ? 'Seleccione un rol' : null,
                          ),
                    const SizedBox(height: 32),

                    // Boton de envio
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Guardar Cambios'
                                  : 'Crear Usuario',
                            ),
                    ),

                    if (!_isEditing) ...[
                      const SizedBox(height: 16),
                      Text(
                        'La contrasena inicial sera: cambio123',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
