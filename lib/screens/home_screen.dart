import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emergency_card.dart';
import '../widgets/profile_dialog.dart';
import '../widgets/sos_radar_button.dart';
import 'auth_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _notesController = TextEditingController();
  final MapController _mapController = MapController();

  late UserModel _currentUser;
  String _selectedEmergencyType = 'MEDICAL';

  double _latitude = LocationService.fallbackLat;
  double _longitude = LocationService.fallbackLng;
  double _accuracy = LocationService.fallbackAccuracy;
  bool _isFallbackLocation = true;
  bool _isLoadingGps = false;
  bool _isSubmittingSos = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchGpsLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchGpsLocation() async {
    setState(() => _isLoadingGps = true);
    final loc = await LocationService.getCurrentLocation();
    setState(() {
      _latitude = loc.latitude;
      _longitude = loc.longitude;
      _accuracy = loc.accuracy;
      _isFallbackLocation = loc.isFallback;
      _isLoadingGps = false;
    });

    try {
      _mapController.move(LatLng(_latitude, _longitude), 15.0);
    } catch (_) {}
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showProfileModal() {
    showDialog(
      context: context,
      builder: (_) => ProfileDialog(
        user: _currentUser,
        onLogout: () async {
          await ApiService.instance.clearToken();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
          }
        },
        onServerUrlChanged: () {
          _fetchGpsLocation();
        },
      ),
    );
  }

  Future<void> _triggerSos() async {
    if (_isSubmittingSos) return;

    setState(() => _isSubmittingSos = true);

    try {
      final sos = await ApiService.instance.createSos(
        emergencyType: _selectedEmergencyType,
        latitude: _latitude,
        longitude: _longitude,
        accuracyM: _accuracy,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(sos: sos, user: _currentUser),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.redSos,
            content: Text('Dispatch Failed: ${e.toString().replaceAll('Exception: ', '')}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingSos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.redSos,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(text: 'AERO', style: TextStyle(color: Colors.white)),
                  TextSpan(text: '-SOS', style: TextStyle(color: AppTheme.redSos)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // User Chip
          InkWell(
            onTap: _showProfileModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppTheme.bgSubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.redSos,
                    child: Text(
                      _currentUser.fullName.isNotEmpty ? _currentUser.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentUser.fullName.isNotEmpty ? _currentUser.fullName.split(' ')[0] : 'User',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top GPS Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isFallbackLocation ? AppTheme.amberWarning : AppTheme.greenSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isFallbackLocation ? 'DEMO LOCATION MODE' : 'LIVE GPS ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _isFallbackLocation ? AppTheme.amberWarning : AppTheme.greenSuccess,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E (±${_accuracy.toInt()}m)',
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppTheme.textSub),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isLoadingGps
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh, size: 18, color: AppTheme.textSub),
                        onPressed: _isLoadingGps ? null : _fetchGpsLocation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Emergency Contact Card
                if (_currentUser.emergencyContactPhone.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(color: AppTheme.amberWarning, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🆘', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('அவசர தொடர்பு / Emergency Contact:', style: TextStyle(fontSize: 10, color: AppTheme.textSub)),
                              Text(
                                '${_currentUser.emergencyContactName} (${_currentUser.emergencyContactPhone})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _makeCall(_currentUser.emergencyContactPhone),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.greenSuccess.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.greenSuccess.withOpacity(0.4)),
                            ),
                            child: const Text('📞 Call', style: TextStyle(fontSize: 11, color: AppTheme.greenSuccess, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Emergency Selector
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.redSos, borderRadius: BorderRadius.circular(4)),
                      child: const Text('STEP 1', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'அவசர நிலையைத் தேர்ந்தெடுக்கவும் / Select Emergency:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Grid of 6 categories
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: EmergencyCategory.all.length,
                  itemBuilder: (context, index) {
                    final cat = EmergencyCategory.all[index];
                    return EmergencyCardWidget(
                      category: cat,
                      isSelected: _selectedEmergencyType == cat.key,
                      onTap: () => setState(() => _selectedEmergencyType = cat.key),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Notes Field
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'கூடுதல் குறிப்புகள் / Optional Dispatch Notes (Floor, injuries)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSub),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notesController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Trapped on 2nd floor, bleeding, cardiac issue',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Massive Pulsating SOS Button
                Center(
                  child: SosRadarButton(
                    onPressed: _isSubmittingSos ? () {} : _triggerSos,
                    activeType: _selectedEmergencyType,
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'உடனடி ட்ரோன் அனுப்ப பொத்தானை அழுத்தவும்\nTap button to deploy immediate autonomous emergency drone',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSub, height: 1.3),
                  ),
                ),
                const SizedBox(height: 20),

                // Live Tactical Map Card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('🗺️', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'நேரடி இருப்பிட வரைபடம் / Live Map',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isFallbackLocation
                                    ? AppTheme.amberWarning.withOpacity(0.18)
                                    : AppTheme.greenSuccess.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isFallbackLocation ? AppTheme.amberWarning : AppTheme.greenSuccess,
                                ),
                              ),
                              child: Text(
                                _isFallbackLocation ? 'DEMO MODE' : 'LIVE GPS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _isFallbackLocation ? AppTheme.amberWarning : AppTheme.greenSuccess,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_latitude, _longitude),
                              initialZoom: 15.0,
                              onTap: (_, point) {
                                setState(() {
                                  _latitude = point.latitude;
                                  _longitude = point.longitude;
                                  _accuracy = 10;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.aerosos.dispatch',
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: LatLng(_latitude, _longitude),
                                    color: AppTheme.redSos.withOpacity(0.2),
                                    borderColor: AppTheme.redSos,
                                    borderStrokeWidth: 1.5,
                                    radius: 35,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_latitude, _longitude),
                                    width: 32,
                                    height: 32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.redSos,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppTheme.redGlow,
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '💡 குறிப்பு / Tip: Tap anywhere on map to calibrate coordinates.',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
