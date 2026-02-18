// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

class NexusSplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const NexusSplashScreen({super.key, required this.onFinish});

  @override
  State<NexusSplashScreen> createState() => _NexusSplashScreenState();
}

class _NexusSplashScreenState extends State<NexusSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..forward();

    Future.delayed(const Duration(seconds: 6), widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Subtle gradient backdrop
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      
                      const Color(0xFF1a1a2e).withOpacity(0.3),
                      const Color(0xFF000000),
                    ],
                  ),
                ),
              ),

              // Minimal geometric grid
              CustomPaint(
                painter: _MinimalGridPainter(progress: t),
              ),

              // Elegant floating particles
              if (t > 0.1)
                CustomPaint(
                  painter: _FloatingParticlesPainter(
                    progress: (t - 0.1) / 0.9,
                    seed: 101,
                  ),
                ),

              // Central minimalist logo
              if (t > 0.3)
                Center(
                  child: Opacity(
                    opacity: Curves.easeInOut.transform(
                      ((t - 0.3) / 0.4).clamp(0.0, 1.0),
                    ),
                    child: Transform.scale(
                      scale: 0.8 +
                          Curves.easeOutCubic.transform(
                                ((t - 0.3) / 0.4).clamp(0.0, 1.0),
                              ) *
                              0.2,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6C63FF).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF4A47A3),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

             
              if (t > 0.5)
                Center(
                  child: Opacity(
                    opacity: ((t - 0.5) / 0.3).clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - Curves.easeOutQuart.transform(
                                      ((t - 0.5) / 0.3).clamp(0.0, 1.0),
                                    )),
                          ),
                          child: ShaderMask(
                            shaderCallback: (rect) => const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFCCCCCC),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(rect),
                            child: const Text(
                              "NEXUS",
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 54,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 18,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        if (t > 0.65)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Opacity(
                              opacity: ((t - 0.65) / 0.25).clamp(0.0, 1.0),
                              child: const Text(
                                "SEE BEYOND SYNTAX.",
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 4,
                                  color: Color.fromARGB(255, 129, 122, 255),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Minimalist loading indicator
              if (t < 0.9)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: t,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF6C63FF).withOpacity(0.6),
                              ),
                              minHeight: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Opacity(
                            opacity: 0.4,
                            child: Text(
                              "${(t * 100).toInt()}%",
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Final fade to white flash
              if (t > 0.92)
                Container(
                  color: Colors.white.withOpacity(
                    ((t - 0.92) / 0.08 * 0.3).clamp(0.0, 0.3),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// == Minimal Grid ==
class _MinimalGridPainter extends CustomPainter {
  final double progress;
  _MinimalGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;

    const step = 80.0;
    
  
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}


class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final int seed;
  _FloatingParticlesPainter({required this.progress, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final floatAmount = sin(progress * pi * 2 + i) * 20;
      final y = baseY + floatAmount;
      
      final opacity = (0.3 + sin(progress * pi * 2 + i * 0.5) * 0.2);
      final particleSize = 1.5 + random.nextDouble() * 1.5;

      paint.color = const Color(0xFF6C63FF).withOpacity(opacity * 0.4);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}