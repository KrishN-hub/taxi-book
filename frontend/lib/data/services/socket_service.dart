import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../app/config/app_config.dart';

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  io.Socket get socket => _socket!;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (_socket != null) return;

    _socket = io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
