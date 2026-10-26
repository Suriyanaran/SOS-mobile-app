import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/sos_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../theme/app_theme.dart';

class TrackingScreen extends StatefulWidget {
  final SosModel sos;
  final UserModel user;

  const TrackingScreen({super.key, required this.sos, required this.user});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final WebSocketService _wsService = WebSocketService();
  final MapController _trackingMapController = MapController();
  StreamSubscription? _wsSubscription;

  late SosModel _currentSos;
  DroneInfo? _assignedDrone;
  String _currentStatus = 'SOS_RECEIVED';
  String _heroTamil = 'உதவி கோரப்பட்டது';
  String _heroEnglish = 'SOS RECEIVED';
  String _heroDescription = 'Emergency beacon logged into emergency dispatch queue.';
  String _heroIcon = '🚨';

  // Step timestamps
  String? _t1;
  String? _t2;
  String? _t3;
  String? _t4;

  bool _isCancelled = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentSos = widget.sos;
    _currentStatus = _currentSos.status;
    _t1 = _formatTime(DateTime.now());

    _initWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _initWebSocket() {
    _wsService.connect(_currentSos.sosId);
    _wsSubscription = _wsService.statusStream.listen((data) {
      if (!mounted) return;
      _handleStatusUpdate(data);
    });
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    final status = data['status']?.toString() ?? '';
    final entry = data['entry'] as Map<String, dynamic>? ?? {};
    final meta = entry['metadata'] as Map<String, dynamic>? ?? {};
    final details = entry['details'] as Map<String, dynamic>? ?? {};

    setState(() {
      _currentStatus = status;
      final nowStr = _formatTime(DateTime.now());

      if (meta['ta'] != null) _heroTamil = meta['ta'];
      if (meta['en'] != null) _heroEnglish = meta['en'];
      if (meta['desc'] != null) _heroDescription = meta['desc'];

      if (status == 'SOS_RECEIVED') {
        _heroIcon = '🚨';
        _t1 = nowStr;
      } else if (status == 'SEARCHING_FOR_DRONE') {
        _heroIcon = '📡';
        _t2 = nowStr;
      } else if (status == 'DRONE_ASSIGNED') {
        _heroIcon = '🛸';
        _t3 = nowStr;
        if (details['drone'] != null) {
          _assignedDrone = DroneInfo.fromJson(details['drone']);
        }
      } else if (status == 'WAITING_FOR_OPERATOR_APPROVAL') {
        _heroIcon = '⏳';
        _t4 = nowStr;
      } else if (status == 'MISSION_ABORTED') {
        _heroIcon = '🛑';
        _heroTamil = 'ரத்து செய்யப்பட்டது';
        _heroEnglish = 'MISSION ABORTED';
        _heroDescription = 'Emergency rescue mission cancelled by requester.';
        _isCancelled = true;
      }
    });

    // Update map zoom to fit drone & user
    if (_assignedDrone?.telemetryLat != null && _assignedDrone?.telemetryLng != null) {
      try {
        final bounds = LatLngBounds(
          LatLng(_currentSos.latitude, _currentSos.longitude),
          LatLng(_assignedDrone!.telemetryLat!, _assignedDrone!.telemetryLng!),
        );
        _trackingMapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(35)),
        );
      } catch (_) {}
    }
  }

  Future<void> _cancelSos() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Cancel Emergency SOS?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'நிச்சயமாக அவசர கோரிக்கையை ரத்து செய்ய விரும்புகிறீர்களா?\nAre you sure you want to abort this emergency rescue mission?',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redSos),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);

    try {
      await ApiService.instance.cancelSos(_currentSos.sosId);
      setState(() => _isCancelled = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancel failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPos = LatLng(_currentSos.latitude, _currentSos.longitude);
    final LatLng? dronePos = (_assignedDrone?.telemetryLat != null && _assignedDrone?.telemetryLng != null)
        ? LatLng(_assignedDrone!.telemetryLat!, _assignedDrone!.telemetryLng!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'பணி கண்காணிப்பு • Live Tracking',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: _isCancelled,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top ID & Time bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.redSos.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.redSos.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppTheme.redSos, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentSos.sosId,
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _t1 ?? 'Just now',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Hero Status Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.redSos.withOpacity(_isCancelled ? 0.08 : 0.25),
                        AppTheme.bgCard,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isCancelled ? AppTheme.borderLight : AppTheme.redSos.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.bgInput,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Center(
                          child: Text(_heroIcon, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _heroTamil,
                              style: const TextStyle(
                                fontFamily: 'Noto Sans Tamil',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _heroEnglish,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFCA5A5),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _heroDescription,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSub, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Drone Telemetry Card (Shown when drone is assigned)
                if (_assignedDrone != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.blueTech.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.blueTech.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('🛸', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _assignedDrone!.droneId,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      _assignedDrone!.model,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.textSub),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.blueTech,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('LOCKED & READY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                            ),
                          ],
                        ),
                        const Divider(color: AppTheme.borderLight, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _droneMetric('ETA', '~${_assignedDrone!.etaMinutes} mins', AppTheme.amberWarning),
                            _droneMetric('BATTERY', _assignedDrone!.battery, AppTheme.greenSuccess),
                            _droneMetric('PAYLOAD', _assignedDrone!.payloadType, Colors.white),
                            _droneMetric('SPEED', '${_assignedDrone!.speedKmh.toInt()} km/h', Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Operator Standby Notification (When in WAITING_FOR_OPERATOR_APPROVAL)
                if (_currentStatus == 'WAITING_FOR_OPERATOR_APPROVAL') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amberWarning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.amberWarning.withOpacity(0.4)),
                    ),
                    child: const Row(
                      children: [
                        Text('⏳', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aero-Q Operator Flight Authorization',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFDE68A)),
                              ),
                              Text(
                                'Flight corridor verified. Standing by for human operator safety sign-off.',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSub),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Mission Progress Stepper Timeline
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பணி முன்னேற்ற காலவரிசை / Mission Timeline',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSub),
                      ),
                      const SizedBox(height: 14),
                      _timelineStep(
                        stepNum: 1,
                        ta: 'உதவி கோரப்பட்டது',
                        en: 'SOS RECEIVED',
                        time: _t1,
                        isDone: true,
                        isActive: _currentStatus == 'SOS_RECEIVED',
                      ),
                      _timelineStep(
                        stepNum: 2,
                        ta: 'ட்ரோன் தேடப்படுகிறது',
                        en: 'SEARCHING FOR DRONE',
                        time: _t2,
                        isDone: _t2 != null,
                        isActive: _currentStatus == 'SEARCHING_FOR_DRONE',
                      ),
                      _timelineStep(
                        stepNum: 3,
                        ta: 'ட்ரோன் ஒதுக்கப்பட்டது',
                        en: 'DRONE ASSIGNED',
                        time: _t3,
                        isDone: _t3 != null,
                        isActive: _currentStatus == 'DRONE_ASSIGNED',
                      ),
                      _timelineStep(
                        stepNum: 4,
                        ta: 'ஆபரேட்டர் ஒப்புதலுக்காக காத்திருக்கிறது',
                        en: 'WAITING OPERATOR APPROVAL',
                        time: _t4,
                        isDone: _t4 != null,
                        isActive: _currentStatus == 'WAITING_FOR_OPERATOR_APPROVAL',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mini Map View
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _trackingMapController,
                      options: MapOptions(
                        initialCenter: userPos,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.aerosos.dispatch',
                        ),
                        // Flight path polyline
                        if (dronePos != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [dronePos, userPos],
                                color: AppTheme.blueTech,
                                strokeWidth: 3.0,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            // User beacon
                            Marker(
                              point: userPos,
                              width: 24,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.redSos,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                            // Drone marker
                            if (dronePos != null)
                              Marker(
                                point: dronePos,
                                width: 34,
                                height: 34,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppTheme.blueTech,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('🛸', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Cancel SOS Button or Return Button
                if (!_isCancelled) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.redSosLight,
                      side: const BorderSide(color: AppTheme.redSos, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isCancelling
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.redSos))
                        : const Icon(Icons.cancel_outlined, size: 20),
                    label: const Text(
                      'ரத்து செய் / CANCEL SOS',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    onPressed: _isCancelling ? null : _cancelSos,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ஆபரேட்டர் அனுமதிக்கு முன் எப்போது வேண்டுமானாலும் ரத்து செய்யலாம்.\nYou can cancel anytime before drone dispatch launch approval.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('புதிய SOS அனுப்பு / CREATE NEW SOS'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _droneMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textSub, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _timelineStep({
    required int stepNum,
    required String ta,
    required String en,
    required String? time,
    required bool isDone,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppTheme.greenSuccess : (isActive ? AppTheme.redSos : AppTheme.bgInput),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.white : AppTheme.borderLight,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '$stepNum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone ? AppTheme.greenSuccess.withOpacity(0.5) : AppTheme.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ta,
                      style: TextStyle(
                        fontFamily: 'Noto Sans Tamil',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDone || isActive ? Colors.white : AppTheme.textSub,
                      ),
                    ),
                    Text(
                      en,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDone ? const Color(0xFF86EFAC) : (isActive ? const Color(0xFFFCA5A5) : AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                Text(
                  time ?? 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: isDone ? AppTheme.textSub : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
