import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SosRadarButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String activeType;

  const SosRadarButton({
    super.key,
    required this.onPressed,
    required this.activeType,
  });

  @override
  State<SosRadarButton> createState() => _SosRadarButtonState();
}

class _SosRadarButtonState extends State<SosRadarButton> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Ripple Wave 1
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              final val = _radarController.value;
              return Container(
                width: 170 + (50 * val),
                height: 170 + (50 * val),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.redSos.withOpacity((1 - val) * 0.7),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // Animated Ripple Wave 2
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              final val = (_radarController.value + 0.5) % 1.0;
              return Container(
                width: 170 + (50 * val),
                height: 170 + (50 * val),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.redSos.withOpacity((1 - val) * 0.5),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),
          // Main Glowing Red Push Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            elevation: 12,
            shadowColor: AppTheme.redSos.withOpacity(0.8),
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.white24,
              highlightColor: AppTheme.redSosDark,
              onTap: widget.onPressed,
              child: Ink(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.3),
                    radius: 0.9,
                    colors: [
                      AppTheme.redSosLight,
                      AppTheme.redSos,
                      AppTheme.redSosDark,
                    ],
                  ),
                  border: Border.all(color: Colors.white30, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.redGlow,
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🚨', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 2),
                    const Text(
                      'SOS அனுப்பு',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Tamil',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const Text(
                      'SEND SOS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.4,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        'TYPE: ${widget.activeType}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFEF08A),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
