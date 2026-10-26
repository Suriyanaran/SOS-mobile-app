import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  void connect(String sosId) {
    disconnect();

    final base = ApiService.instance.baseUrl;
    final wsBase = base.startsWith('https://')
        ? base.replaceFirst('https://', 'wss://')
        : base.replaceFirst('http://', 'ws://');

    final wsUri = Uri.parse('$wsBase/ws/sos/$sosId');

    try {
      _channel = WebSocketChannel.connect(wsUri);
      _subscription = _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message.toString());
            _statusController.add(data);
          } catch (e) {
            // Ignore parse errors on raw string pongs
          }
        },
        onError: (err) {
          // print('[WS Error] $err');
        },
        onDone: () {
          // print('[WS Done]');
        },
      );
    } catch (e) {
      // print('[WS Connection Error] $e');
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
