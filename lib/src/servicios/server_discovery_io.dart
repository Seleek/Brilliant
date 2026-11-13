import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _discoveryRequest = 'BRILLIANT_DISCOVER_V1';
const _discoveryResponse = 'BRILLIANT_SERVER_V1';

bool get serverDiscoverySupported => true;

Future<String?> discoverServerHost({
  required int port,
  required Duration timeout,
  String broadcastAddress = '255.255.255.255',
}) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  socket.broadcastEnabled = true;
  final response = Completer<String?>();
  final subscription = socket.listen((event) {
    if (event != RawSocketEvent.read) return;

    final datagram = socket.receive();
    if (datagram == null) return;
    if (utf8.decode(datagram.data, allowMalformed: true) !=
        _discoveryResponse) {
      return;
    }

    if (!response.isCompleted) {
      response.complete(datagram.address.address);
    }
  });

  try {
    socket.send(
      utf8.encode(_discoveryRequest),
      InternetAddress(broadcastAddress),
      port,
    );
    return await response.future.timeout(
      timeout,
      onTimeout: () => null,
    );
  } finally {
    await subscription.cancel();
    socket.close();
  }
}
