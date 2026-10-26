import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmergencyCategory {
  final String key;
  final String icon;
  final String tamilLabel;
  final String englishLabel;
  final String description;

  const EmergencyCategory({
    required this.key,
    required this.icon,
    required this.tamilLabel,
    required this.englishLabel,
    required this.description,
  });

  static const List<EmergencyCategory> all = [
    EmergencyCategory(
      key: 'MEDICAL',
      icon: '🚑',
      tamilLabel: 'மருத்துவம்',
      englishLabel: 'MEDICAL',
      description: 'Defibrillator Kit',
    ),
    EmergencyCategory(
      key: 'FIRE',
      icon: '🔥',
      tamilLabel: 'தீ விபத்து',
      englishLabel: 'FIRE',
      description: 'Extinguisher Ball',
    ),
    EmergencyCategory(
      key: 'FLOOD',
      icon: '🌊',
      tamilLabel: 'வெள்ளம்',
      englishLabel: 'FLOOD',
      description: 'Life Vest & Rope',
    ),
    EmergencyCategory(
      key: 'ACCIDENT',
      icon: '🚗',
      tamilLabel: 'விபத்து',
      englishLabel: 'ACCIDENT',
      description: 'Trauma Pack',
    ),
    EmergencyCategory(
      key: 'SECURITY',
      icon: '🛡️',
      tamilLabel: 'பாதுகாப்பு',
      englishLabel: 'SECURITY',
      description: 'Strobe Siren',
    ),
    EmergencyCategory(
      key: 'OTHER',
      icon: '⚠️',
      tamilLabel: 'பிற அவசரம்',
      englishLabel: 'OTHER',
      description: 'Rescue Aid',
    ),
  ];
}

class EmergencyCardWidget extends StatelessWidget {
  final EmergencyCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const EmergencyCardWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.redSos.withOpacity(0.18) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.redSos : AppTheme.borderLight,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.redSos.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                category.tamilLabel,
                style: TextStyle(
                  fontFamily: 'Noto Sans Tamil',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.textMain,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                category.englishLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFFFCA5A5) : AppTheme.textSub,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
