import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/src/servicios/server_discovery_io.dart'
    as discovery;

void main() {
  test('discovers the host that answers a LAN request', () async {
    final server =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = server.receive();
      if (datagram == null) return;
      server.send(
        'BRILLIANT_SERVER_V1'.codeUnits,
        datagram.address,
        datagram.port,
      );
    });

    try {
      final host = await discovery.discoverServerHost(
        port: server.port,
        timeout: const Duration(seconds: 1),
        broadcastAddress: '127.0.0.1',
      );

      expect(host, '127.0.0.1');
    } finally {
      await subscription.cancel();
      server.close();
    }
  });
}
