import 'package:flutter/material.dart';

import '../servicios/room_service.dart';

class PantallaSala extends StatefulWidget {
  final RoomService roomService;
  final Future<void> Function(RoomSnapshot) onSalaConectada;

  const PantallaSala({
    super.key,
    required this.roomService,
    required this.onSalaConectada,
  });

  @override
  State<PantallaSala> createState() => _PantallaSalaState();
}

class _PantallaSalaState extends State<PantallaSala> {
  final _codigoController = TextEditingController();
  int _nivel = 1;
  bool _ocupado = false;
  String? _error;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _conectar(Future<RoomSnapshot> Function() accion) async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final sala = await accion();
      if (mounted) await widget.onSalaConectada(sala);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partida multijugador')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              const Icon(Icons.groups_rounded, size: 64, color: Colors.indigo),
              const SizedBox(height: 12),
              const Text(
                'Juega con tus amigos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              const Text(
                'Crear una sala',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _nivel,
                decoration: const InputDecoration(
                  labelText: 'Nivel de la partida',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  4,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('Nivel ${index + 1}'),
                  ),
                ),
                onChanged: _ocupado
                    ? null
                    : (nivel) {
                        if (nivel != null) setState(() => _nivel = nivel);
                      },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _ocupado
                    ? null
                    : () => _conectar(
                          () => widget.roomService.crearSala(_nivel),
                        ),
                icon: const Icon(Icons.add),
                label: const Text('Crear sala'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('O'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              const Text(
                'Unirse con código',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codigoController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.join,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Código de invitación',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                onSubmitted: (_) => _unirse(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _ocupado ? null : _unirse,
                icon: const Icon(Icons.login),
                label: const Text('Unirse a la sala'),
              ),
              if (_ocupado) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unirse() {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() => _error = 'Escribe el código de invitación');
      return Future<void>.value();
    }
    return _conectar(() => widget.roomService.unirse(codigo));
  }
}
