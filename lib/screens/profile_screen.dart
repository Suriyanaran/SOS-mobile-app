import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _addressController;

  String _gender = 'Male';
  String _bloodGroup = 'O+';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    _contactNameController = TextEditingController(text: widget.user.emergencyContactName);
    _contactPhoneController = TextEditingController(text: widget.user.emergencyContactPhone);
    _addressController = TextEditingController(text: widget.user.address);
    if (widget.user.gender.isNotEmpty) _gender = widget.user.gender;
    if (widget.user.bloodGroup.isNotEmpty) _bloodGroup = widget.user.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = UserModel(
        phoneNumber: widget.user.phoneNumber,
        fullName: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
        bloodGroup: _bloodGroup,
        emergencyContactName: _contactNameController.text.trim(),
        emergencyContactPhone: _contactPhoneController.text.trim(),
        address: _addressController.text.trim(),
        profileCompleted: true,
      );

      final saved = await ApiService.instance.updateProfile(updatedUser);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: saved)),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('அவசர சுயவிவரம்', style: TextStyle(fontFamily: 'Noto Sans Tamil', fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Emergency Profile Setup', style: TextStyle(fontSize: 12, color: AppTheme.textSub)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: AppTheme.bgCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Essential rescue details used by first responder drones during emergency dispatches.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSub),
                      ),
                      const SizedBox(height: 18),

                      // Full Name
                      const Text('முழு பெயர் / Full Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(hintText: 'e.g. Surya Prakash'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Age & Gender
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('வயது / Age *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(hintText: '26'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('பாலினம் / Gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  dropdownColor: AppTheme.bgCard,
                                  decoration: const InputDecoration(),
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _gender = v);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Blood Group Pills
                      const Text('இரத்த வகை / Blood Group *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _bloodGroups.map((bg) {
                          final isSelected = _bloodGroup == bg;
                          return ChoiceChip(
                            label: Text(bg, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textMain)),
                            selected: isSelected,
                            selectedColor: AppTheme.redSos,
                            backgroundColor: AppTheme.bgInput,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: isSelected ? AppTheme.redSos : AppTheme.borderLight),
                            ),
                            onSelected: (_) => setState(() => _bloodGroup = bg),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Emergency Contact Name
                      const Text('அவசர தொடர்பு பெயர் / Emergency Contact Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(hintText: 'e.g. S. Ramanathan (Brother)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Emergency Contact Phone
                      const Text('அவசர தொடர்பு எண் / Emergency Contact Phone *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '+91 98765 00000'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact phone' : null,
                      ),
                      const SizedBox(height: 14),

                      // Address
                      const Text('முகவரி / Residential Address *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(hintText: 'Street, Landmark, Chennai, Tamil Nadu'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter address' : null,
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.redSos.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.redSos.withOpacity(0.4)),
                          ),
                          child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Color(0xFFFF8B99))),
                        ),
                        const SizedBox(height: 14),
                      ],

                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('சுயவிவரத்தை சேமி / SAVE & PROCEED'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
