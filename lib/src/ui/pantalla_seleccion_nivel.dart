import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';

class PantallaSeleccionNivel extends StatelessWidget {
  final AuthService authService;
  final Function(int) onNivelElegido;
  final VoidCallback onLogout;
  final VoidCallback? onMultijugador;

  const PantallaSeleccionNivel({
    super.key,
    required this.authService,
    required this.onNivelElegido,
    required this.onLogout,
    this.onMultijugador,
  });

  // Colores de la paleta
  final Color _colorPrimario = const Color(0xFF4F46E5); // Azul Índigo
  final Color _colorFondo = const Color(0xFFF8FAFC); // Blanco Hueso
  final Color _colorTexto = const Color(0xFF1E293B); // Gris Oscuro

  // Menú de opciones (Cerrar sesión / Borrar cuenta)
  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ajustes de cuenta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _colorTexto,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blueGrey),
                  title: Text('Cerrar Sesión',
                      style: TextStyle(color: _colorTexto)),
                  onTap: () async {
                    Navigator.pop(ctx); // Cerrar bottom sheet
                    await authService.cerrarSesion();
                    onLogout();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Eliminar Cuenta',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(ctx); // Cerrar bottom sheet
                    _confirmarEliminarCuenta(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Diálogo de confirmación para eliminar la cuenta
  Future<void> _confirmarEliminarCuenta(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await authService.borrarCuenta();
        onLogout();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos solo 4 niveles según el diseño
    final niveles = [1, 2, 3, 4];

    return Scaffold(
      backgroundColor: _colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Usuario, Estado, Configuración
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            '@${authService.currentUser ?? 'usuario'}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _colorTexto,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'En línea',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: _colorTexto),
                    onPressed: () => _mostrarOpciones(context),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Título de Selección
              Text(
                'Selecciona un Nivel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _colorTexto,
                ),
              ),
              const SizedBox(height: 24),
              if (onMultijugador != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onMultijugador,
                    icon: const Icon(Icons.groups_rounded),
                    label: const Text('Jugar con amigos'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Cuadrícula de niveles (Grid 2x2)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85, // Tarjetas ligeramente altas
                  ),
                  itemCount: niveles.length,
                  itemBuilder: (context, index) {
                    final nivel = niveles[index];
                    return GestureDetector(
                      onTap: () => onNivelElegido(nivel),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _colorPrimario.withOpacity(0.3),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: _colorPrimario.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nivel $nivel',
                              style: TextStyle(
                                fontSize: 16,
                                color: _colorTexto.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$nivel',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: _colorPrimario,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
