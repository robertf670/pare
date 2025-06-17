import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// Custom page transitions for smooth navigation
class AnimatedPageTransition extends PageRouteBuilder {
  final Widget child;
  final TransitionType transitionType;
  final Duration duration;
  final Curve curve;

  AnimatedPageTransition({
    required this.child,
    this.transitionType = TransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation,
              secondaryAnimation,
              child,
              transitionType,
              curve,
            );
          },
        );

  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.1,
            end: 0.0,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case TransitionType.none:
        return child;
    }
  }
}

enum TransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fadeScale,
  rotation,
  none,
}

/// Animated container for day sections with sophisticated effects
class AnimatedDaySection extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;
  final bool showGlow;

  const AnimatedDaySection({
    super.key,
    required this.child,
    required this.isActive,
    this.onTap,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.showGlow = true,
  });

  @override
  State<AnimatedDaySection> createState() => _AnimatedDaySectionState();
}

class _AnimatedDaySectionState extends State<AnimatedDaySection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: const Color(0x10007AFF),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.isActive) {
      _controller.forward();
      if (widget.showGlow) {
        _startGlowAnimation();
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedDaySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
        if (widget.showGlow) {
          _startGlowAnimation();
        }
      } else {
        _controller.reverse();
        _glowController.stop();
      }
    }
  }

  void _startGlowAnimation() {
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _elevationAnimation,
          _glowAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.98 : _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                color: _colorAnimation.value,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                  if (widget.showGlow && widget.isActive)
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(
                        alpha: 0.2 * _glowAnimation.value,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Staggered list animation for task items
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration itemDuration;
  final Curve curve;

  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimation();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.itemDuration,
        vsync: this,
      ),
    );

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      ));
    }).toList();
  }

  void _startStaggeredAnimation() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: widget.delay.inMilliseconds * i),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => AnimatedBuilder(
          animation: Listenable.merge([
            _slideAnimations[index],
            _fadeAnimations[index],
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value * 30,
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: widget.children[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating Action Button with morphing animation
class MorphingFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final IconData? secondaryIcon;
  final String? tooltip;
  final bool isExpanded;

  const MorphingFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.secondaryIcon,
    this.tooltip,
    this.isExpanded = false,
  });

  @override
  State<MorphingFAB> createState() => _MorphingFABState();
}

class _MorphingFABState extends State<MorphingFAB>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );

    _morphAnimation = Tween<double>(
      begin: 56.0,
      end: 120.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isExpanded) {
      _morphController.forward();
    }
  }

  @override
  void didUpdateWidget(MorphingFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _morphController.forward();
      } else {
        _morphController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return Container(
          width: _morphAnimation.value,
          height: 56.0,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      widget.isExpanded && widget.secondaryIcon != null
                          ? widget.secondaryIcon!
                          : widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (widget.isExpanded && widget.tooltip != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.tooltip!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 