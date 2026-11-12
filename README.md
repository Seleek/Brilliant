# Brilliant

## Jugar en la misma red Wi-Fi

El servidor acepta conexiones de la red local en el puerto `8080`. La app web
usa automáticamente el mismo nombre o IP del equipo desde el que se abrió para
conectarse a la API. Si necesitas alojar la API en otro equipo, puedes
configurarla al compilar con `--dart-define=API_BASE_URL=http://HOST:8080/api`.

1. En una terminal, inicia el servidor desde su carpeta:

   ```powershell
   dart run bin/server.dart
   ```

2. En otra terminal, desde la carpeta de esta app, inicia la web accesible en
   la red:

   ```powershell
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
   ```

3. En el equipo del servidor, ejecuta `ipconfig` y busca su dirección IPv4.
   Comparte con tus amigos `http://IP_DEL_SERVIDOR:8081` y el código de la
   sala. Todos deben estar conectados a la misma red Wi-Fi y crear o iniciar
   sesión con su propia cuenta.

Si Windows Firewall pregunta, permite Dart/Flutter en redes privadas o crea
reglas de entrada TCP para los puertos `8080` (API) y `8081` (web). No uses
esta configuración para exponer el servidor directamente a Internet.

Las salas viven en memoria: se pueden usar mientras el servidor siga encendido,
pero se pierden al detenerlo.

## Desconexiones durante una partida

Si un jugador deja de enviar actividad durante 60 segundos, la partida se
pausa para todos durante un máximo de cinco minutos. Los jugadores conectados
pueden votar con **Continuar sin el jugador**; con unanimidad, la partida sigue
sin él. Si regresa antes de que venza el plazo, la partida se reanuda. Al
terminar los cinco minutos sin unanimidad, el jugador se retira automáticamente.
En partidas de dos jugadores, gana quien permanece conectado.
