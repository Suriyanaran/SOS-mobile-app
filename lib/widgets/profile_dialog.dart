import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ProfileDialog extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onServerUrlChanged;

  const ProfileDialog({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onServerUrlChanged,
  });

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showServerConfig(BuildContext context) {
    final controller = TextEditingController(text: ApiService.instance.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Backend Server URL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set host URL for local PC server:\n• Android Emulator: http://10.0.2.2:8000\n• Physical Phone: http://<LAN_IP>:8000',
              style: TextStyle(fontSize: 12, color: AppTheme.textSub),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://10.0.2.2:8000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.instance.setBaseUrl(controller.text);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context); // close profile dialog
                onServerUrlChanged();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.redSos,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Emergency Citizen',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        user.phoneNumber,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSub),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.redSos,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.bloodGroup,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            const Divider(color: AppTheme.borderLight, height: 28),
            _infoRow('வயது / Age', user.age?.toString() ?? 'N/A'),
            _infoRow('பாலினம் / Gender', user.gender.isNotEmpty ? user.gender : 'N/A'),
            _infoRow('முகவரி / Address', user.address.isNotEmpty ? user.address : 'N/A'),
            const SizedBox(height: 8),
            // Emergency Contact Action Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.amberWarning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Text('🆘', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'அவசர தொடர்பு / Emergency Contact',
                          style: TextStyle(fontSize: 10, color: AppTheme.textSub),
                        ),
                        Text(
                          '${user.emergencyContactName} (${user.emergencyContactPhone})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (user.emergencyContactPhone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone, color: AppTheme.greenSuccess),
                      onPressed: () => _makeCall(user.emergencyContactPhone),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.blueTech,
                      side: BorderSide(color: AppTheme.blueTech.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Server IP', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showServerConfig(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.redSosLight,
                      side: BorderSide(color: AppTheme.redSos.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Logout', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      Navigator.pop(context);
                      onLogout();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSub)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
