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

  // Paleta de colores del diseño
  final Color _colorPrimario = const Color(0xFF4F46E5); // Azul Índigo
  final Color _colorFondo = const Color(0xFFF8FAFC);    // Blanco Hueso
  final Color _colorTexto = const Color(0xFF1E293B);    // Gris Oscuro
  final Color _colorError = const Color(0xFFEF4444);    // Rojo Coral

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
            SnackBar(
              content: const Text('¡Cuenta creada con éxito! Ahora inicia sesión.'),
              backgroundColor: _colorPrimario,
            ),
          );
          setState(() {
            _esModoRegistro = false;
            _usuarioController.clear();
            _passController.clear();
          });
        }
      } else {
        await widget.authService.iniciarSesion(user, pass);
        widget.onLoginExitoso();
      }
    } catch (e) {
      setState(() {
        _mensajeError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Marca y Logo
                Icon(
                  Icons.diamond_outlined, // Isotipo de diamante de Brilliant
                  size: 72,
                  color: _colorPrimario,
                ),
                const SizedBox(height: 12),
                Text(
                  'Brilliant',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _colorTexto,
                    letterSpacing: 1.2,
                  ),
                ),

                // 2. Selector de Pestañas (Toggle)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _esModoRegistro = false;
                              _mensajeError = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_esModoRegistro ? _colorPrimario : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_esModoRegistro ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _esModoRegistro = true;
                              _mensajeError = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _esModoRegistro ? _colorPrimario : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Registrarse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _esModoRegistro ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Inputs Formulario (Mínimo 52px de altura)
                TextField(
                  controller: _usuarioController,
                  style: TextStyle(color: _colorTexto),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: _colorTexto.withOpacity(0.6)),
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: _colorTexto.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _colorPrimario, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  style: TextStyle(color: _colorTexto),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outlined, color: _colorTexto.withOpacity(0.6)),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: _colorTexto.withOpacity(0.6)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _colorPrimario, width: 2),
                    ),
                  ),
                ),
                
                // Alerta de error integrada en la UI
                if (_mensajeError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _colorError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _colorError.withOpacity(0.3)),
                    ),
                    child: Text(
                      _mensajeError!,
                      style: TextStyle(color: _colorError, fontSize: 13, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // 4. Botón Call To Action Principal (56px de altura)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _enviarFormulario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimario,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _colorPrimario.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _esModoRegistro ? '[ Registrarse ]' : '[ Entrar a Jugar ]',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passController.dispose();
    super.dispose();
  }
}