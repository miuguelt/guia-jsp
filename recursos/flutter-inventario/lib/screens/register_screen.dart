// =============================================================================
//  Pantalla: RegisterScreen
//  Formulario de registro de nuevo usuario.
//  Carga la lista de roles desde la API y permite seleccionar uno.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/usuario.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<Rol> _roles = [];
  Rol? _selectedRol;
  bool _loadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      if (mounted) {
        setState(() => _loadingRoles = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un rol')),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
          _usernameController.text.trim(),
          _passwordController.text,
          _nombreController.text.trim(),
          _emailController.text.trim(),
          _selectedRol!.id,
        );

    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Campo: Nombre de usuario
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

                // Campo: Nombre completo
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

                // Campo: Correo electronico
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
                      return 'Ingrese un correo valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector: Rol
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
                const SizedBox(height: 16),

                // Campo: Contrasena
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contrasena',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Minimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Confirmar contrasena
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contrasena',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirme su contrasena';
                    if (v != _passwordController.text) {
                      return 'Las contrasenas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Mensaje de error
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Boton: Crear cuenta
                ElevatedButton(
                  onPressed:
                      authState.isLoading ? null : _handleRegister,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear Cuenta'),
                ),
                const SizedBox(height: 16),

                // Enlace: Volver al login
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text.rich(
                    TextSpan(
                      text: 'Ya tienes cuenta? ',
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: 'Inicia sesion',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
