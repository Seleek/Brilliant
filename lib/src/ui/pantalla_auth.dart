import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';

class PantallaAuth extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginExitoso;

  const PantallaAuth({
    super.key,
    required this.authService,
    required this.onLoginExitoso,
  });

  @override
  State<PantallaAuth> createState() => _PantallaAuthState();
}

class _PantallaAuthState extends State<PantallaAuth> {
  final _usuarioController = TextEditingController();
  final _passController = TextEditingController();
  bool _esModoRegistro = false;
  String? _mensajeError;
  bool _cargando = false;

  Future<void> _enviarFormulario() async {
    setState(() {
      _cargando = true;
      _mensajeError = null;
    });

    final user = _usuarioController.text.trim();
    final pass = _passController.text.trim();

    try {
      if (_esModoRegistro) {
        await widget.authService.registrar(user, pass);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cuenta creada con éxito. Ahora inicia sesión.')),
          );
          setState(() => _esModoRegistro = false);
        }
      } else {
        await widget.authService.iniciarSesion(user, pass);
        widget.onLoginExitoso();
      }
    } catch (e) {
      setState(() => _mensajeError = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esModoRegistro ? 'Crear Cuenta' : 'Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                if (_mensajeError != null) ...[
                  const SizedBox(height: 12),
                  Text(_mensajeError!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                if (_cargando)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _enviarFormulario,
                    child: Text(_esModoRegistro ? 'Registrar' : 'Entrar'),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _esModoRegistro = !_esModoRegistro;
                      _mensajeError = null;
                    });
                  },
                  child: Text(_esModoRegistro
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}