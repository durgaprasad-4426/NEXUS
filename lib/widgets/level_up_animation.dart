import 'package:flutter/material.dart';
import 'dart:math';

class LevelUpCelebration extends StatefulWidget {
  final int level;

  const LevelUpCelebration({super.key, required this.level});

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _textController;
  late AnimationController _numberController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _rewardsController;
  late AnimationController _fadeOutController;

  late Animation<double> _flashAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<double> _numberScaleAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeOutAnimation;

  final List<ConfettiParticle> confetti = [];
  bool _canDismiss = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    // Confetti generation
    for (int i = 0; i < 60; i++) {
      confetti.add(ConfettiParticle());
    }

    _flashController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flashAnimation =
        CurvedAnimation(parent: _flashController, curve: Curves.easeOut);

    _textController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textScaleAnimation = CurvedAnimation(
        parent: _textController, curve: Curves.elasticOut);

    _numberController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _numberScaleAnimation = CurvedAnimation(
        parent: _numberController, curve: Curves.elasticOut);

    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = CurvedAnimation(
        parent: _shakeController, curve: Curves.easeInOut);

    _confettiController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    _rewardsController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeOutController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeOutAnimation =
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut);

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    _flashController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _textController.forward();
    _shakeController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _numberController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _confettiController.repeat();

    await Future.delayed(const Duration(milliseconds: 300));
    _rewardsController.forward();

    await Future.delayed(const Duration(seconds: 5));
    if (mounted) setState(() => _canDismiss = true);

    
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted && !_isDismissing) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !_canDismiss) return;
    _isDismissing = true;

    await _fadeOutController.forward();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _flashController.dispose();
    _textController.dispose();
    _numberController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _rewardsController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: ReverseAnimation(_fadeOutAnimation),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Flash burst
              AnimatedBuilder(
                animation: _flashAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5 * _flashAnimation.value,
                        colors: [
                          Colors.white.withOpacity((1 - _flashAnimation.value) * 0.9),
                          Colors.yellow.withOpacity((1 - _flashAnimation.value) * 0.6),
                          Colors.orange.withOpacity((1 - _flashAnimation.value) * 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // Confetti
              ...confetti.map(
                (particle) => _ConfettiWidget(
                  particle: particle,
                  animation: _confettiController,
                ),
              ),

              // Main content
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake =
                      sin(_shakeAnimation.value * pi * 4) * 10 * (1 - _shakeAnimation.value);
                  return Transform.translate(offset: Offset(shake, 0), child: child);
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LEVEL UP text
                      ScaleTransition(
                        scale: _textScaleAnimation,
                        child: Stack(
                          children: [
                            Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 8
                                  ..color = Colors.yellow.withOpacity(0.5)
                                  ..maskFilter =
                                      const MaskFilter.blur(BlurStyle.solid, 20),
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.yellow.shade200,
                                  Colors.orange.shade400,
                                  Colors.deepOrange.shade600,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'LEVEL UP!',
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 6,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 6),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Big Level Number
                      ScaleTransition(
                        scale: _numberScaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${widget.level}',
                              style: TextStyle(
                                fontSize: 200,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 20
                                  ..color = Colors.yellow.withOpacity(0.3)
                                  ..maskFilter =
                                      const MaskFilter.blur(BlurStyle.solid, 40),
                              ),
                            ),
                            Text(
                              '${widget.level}',
                              style: TextStyle(
                                fontSize: 200,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 12
                                  ..color = Colors.orange.withOpacity(0.8),
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.yellow.shade100,
                                  Colors.amber.shade300,
                                  Colors.orange.shade400,
                                  Colors.deepOrange.shade500,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                '${widget.level}',
                                style: const TextStyle(
                                  fontSize: 200,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Rewards
                      AnimatedBuilder(
                        animation: _rewardsController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RewardBadge(
                                icon: Icons.star,
                                label: '+100 XP',
                                delay: 0.0,
                                controller: _rewardsController,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 20),
                              _RewardBadge(
                                icon: Icons.bolt,
                                label: '+5 Energy',
                                delay: 0.2,
                                controller: _rewardsController,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 20),
                              _RewardBadge(
                                icon: Icons.diamond,
                                label: '+50 Coins',
                                delay: 0.4,
                                controller: _rewardsController,
                                color: Colors.purple,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Tap hint
                      AnimatedOpacity(
                        opacity: _canDismiss ? 1 : 0,
                        duration: const Duration(milliseconds: 600),
                        child: const Text(
                          'Tap anywhere to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double delay;
  final AnimationController controller;
  final Color color;

  const _RewardBadge({
    required this.icon,
    required this.label,
    required this.delay,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, delay + 0.4, curve: Curves.elasticOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speedX;
  final double speedY;
  final double rotation;

  ConfettiParticle()
      : x = Random().nextDouble(),
        y = -0.1,
        size = 8 + Random().nextDouble() * 12,
        color = [
          Colors.yellow,
          Colors.orange,
          Colors.pink,
          Colors.purple,
          Colors.red,
          Colors.amber,
        ][Random().nextInt(6)],
        speedX = (Random().nextDouble() - 0.5) * 0.3,
        speedY = 0.3 + Random().nextDouble() * 0.4,
        rotation = Random().nextDouble() * pi * 2;
}

class _ConfettiWidget extends StatelessWidget {
  final ConfettiParticle particle;
  final Animation<double> animation;

  const _ConfettiWidget({
    required this.particle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        final x = particle.x + particle.speedX * progress;
        final y = particle.y + particle.speedY * progress;

        if (y > 1.1) return const SizedBox.shrink();

        return Positioned(
          left: x * screenWidth,
          top: y * screenHeight,
          child: Transform.rotate(
            angle: particle.rotation + progress * pi * 4,
            child: Container(
              width: particle.size,
              height: particle.size * 1.5,
              decoration: BoxDecoration(
                color: particle.color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: particle.color.withOpacity(0.6),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
