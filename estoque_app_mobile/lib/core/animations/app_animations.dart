import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/app_colors.dart';

class AppAnimations {
  // Animation durations
  static const Duration quickDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration verySlowDuration = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOut;

  // Common animation extensions
  static List<Effect> fadeIn({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return [
      FadeEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? defaultCurve,
        begin: begin ?? 0.0,
        end: end ?? 1.0,
      ),
    ];
  }

  static List<Effect> fadeOut({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return [
      FadeEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? defaultCurve,
        begin: begin ?? 1.0,
        end: end ?? 0.0,
      ),
    ];
  }

  static List<Effect> slideInFromLeft({
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return [
      SlideEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? slideCurve,
        begin: begin ?? const Offset(-1.0, 0.0),
        end: end ?? Offset.zero,
      ),
    ];
  }

  static List<Effect> slideInFromRight({
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return [
      SlideEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? slideCurve,
        begin: begin ?? const Offset(1.0, 0.0),
        end: end ?? Offset.zero,
      ),
    ];
  }

  static List<Effect> slideInFromTop({
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return [
      SlideEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? slideCurve,
        begin: begin ?? const Offset(0.0, -1.0),
        end: end ?? Offset.zero,
      ),
    ];
  }

  static List<Effect> slideInFromBottom({
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return [
      SlideEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? slideCurve,
        begin: begin ?? const Offset(0.0, 1.0),
        end: end ?? Offset.zero,
      ),
    ];
  }

  static List<Effect> scaleIn({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return [
      ScaleEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? defaultCurve,
        begin: Offset(begin ?? 0.0, begin ?? 0.0),
        end: Offset(end ?? 1.0, end ?? 1.0),
      ),
    ];
  }

  static List<Effect> scaleOut({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return [
      ScaleEffect(
        duration: duration ?? normalDuration,
        curve: curve ?? defaultCurve,
        begin: Offset(begin ?? 1.0, begin ?? 1.0),
        end: Offset(end ?? 0.0, end ?? 0.0),
      ),
    ];
  }

  static List<Effect> bounceIn({Duration? duration, Curve? curve}) {
    return [
      ScaleEffect(
        duration: duration ?? slowDuration,
        curve: curve ?? bounceCurve,
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }

  static List<Effect> elasticIn({Duration? duration, Curve? curve}) {
    return [
      ScaleEffect(
        duration: duration ?? slowDuration,
        curve: curve ?? elasticCurve,
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }

  static List<Effect> shimmer({Duration? duration, Color? color}) {
    return [
      ShimmerEffect(
        duration: duration ?? Duration(milliseconds: 1500),
        color: color ?? AppColors.gray200,
      ),
    ];
  }

  static List<Effect> shake({Duration? duration, double? hz}) {
    return [
      ShakeEffect(
        duration: duration ?? Duration(milliseconds: 600),
        hz: hz ?? 4,
      ),
    ];
  }

  static List<Effect> pulse({
    Duration? duration,
    double? minScale,
    double? maxScale,
  }) {
    return [
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        begin: Offset(minScale ?? 1.0, minScale ?? 1.0),
        end: Offset(maxScale ?? 1.1, maxScale ?? 1.1),
      ),
    ];
  }

  static List<Effect> glow({Duration? duration, Color? color}) {
    return [
      TintEffect(
        duration: duration ?? Duration(milliseconds: 1000),
        color: color ?? AppColors.primary,
      ),
    ];
  }

  // Complex animation combinations
  static List<Effect> cardEntrance({Duration? duration, int? delay}) {
    return [
      FadeEffect(duration: duration ?? normalDuration, begin: 0.0, end: 1.0),
      SlideEffect(
        duration: duration ?? normalDuration,
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ),
      ScaleEffect(
        duration: duration ?? normalDuration,
        begin: const Offset(0.95, 0.95),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }

  static List<Effect> buttonPress({Duration? duration, double? scale}) {
    return [
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 100),
        begin: const Offset(1.0, 1.0),
        end: Offset(scale ?? 0.95, scale ?? 0.95),
      ),
    ];
  }

  static List<Effect> successFeedback({Duration? duration}) {
    return [
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
      ),
      TintEffect(
        duration: duration ?? Duration(milliseconds: 300),
        color: AppColors.success,
      ),
    ];
  }

  static List<Effect> errorFeedback({Duration? duration}) {
    return [
      ShakeEffect(duration: duration ?? Duration(milliseconds: 500), hz: 4),
      TintEffect(
        duration: duration ?? Duration(milliseconds: 300),
        color: AppColors.error,
      ),
    ];
  }

  static List<Effect> listItemEntrance({Duration? duration, int? delay}) {
    return [
      FadeEffect(
        duration: duration ?? Duration(milliseconds: 400),
        begin: 0.0,
        end: 1.0,
      ),
      SlideEffect(
        duration: duration ?? Duration(milliseconds: 400),
        begin: const Offset(0.0, 0.2),
        end: Offset.zero,
      ),
    ];
  }

  static List<Effect> pageTransition({
    Duration? duration,
    SlideDirection direction = SlideDirection.left,
  }) {
    Offset slideOffset;
    switch (direction) {
      case SlideDirection.left:
        slideOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        slideOffset = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        slideOffset = const Offset(0.0, -1.0);
        break;
      case SlideDirection.down:
        slideOffset = const Offset(0.0, 1.0);
        break;
    }

    return [
      SlideEffect(
        duration: duration ?? Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        begin: slideOffset,
        end: Offset.zero,
      ),
      FadeEffect(
        duration: duration ?? Duration(milliseconds: 300),
        begin: 0.0,
        end: 1.0,
      ),
    ];
  }

  static List<Effect> modalEntrance({Duration? duration}) {
    return [
      FadeEffect(
        duration: duration ?? Duration(milliseconds: 250),
        begin: 0.0,
        end: 1.0,
      ),
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 250),
        curve: Curves.easeOut,
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }

  static List<Effect> fabEntrance({Duration? duration, int? delay}) {
    return [
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }

  static List<Effect> navigationItemSelect({Duration? duration}) {
    return [
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.1, 1.1),
      ),
      TintEffect(
        duration: duration ?? Duration(milliseconds: 200),
        color: AppColors.primary,
      ),
    ];
  }

  static List<Effect> loadingSpinner({Duration? duration}) {
    return [
      RotateEffect(
        duration: duration ?? Duration(milliseconds: 1000),
        curve: Curves.linear,
        begin: 0.0,
        end: 1.0,
      ),
    ];
  }

  static List<Effect> staggeredListAnimation({
    required int index,
    Duration? duration,
    Duration? staggerDelay,
  }) {
    return [
      FadeEffect(
        duration: duration ?? Duration(milliseconds: 300),
        begin: 0.0,
        end: 1.0,
      ),
      SlideEffect(
        duration: duration ?? Duration(milliseconds: 300),
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ),
    ];
  }

  static List<Effect> infiniteRotation({Duration? duration}) {
    return [
      RotateEffect(
        duration: duration ?? Duration(seconds: 2),
        curve: Curves.linear,
        begin: 0.0,
        end: 1.0,
      ),
    ];
  }

  static List<Effect> breathingAnimation({
    Duration? duration,
    double? minOpacity,
    double? maxOpacity,
  }) {
    return [
      FadeEffect(
        duration: duration ?? Duration(milliseconds: 2000),
        curve: Curves.easeInOut,
        begin: minOpacity ?? 0.3,
        end: maxOpacity ?? 1.0,
      ),
    ];
  }

  static List<Effect> morphTransition({
    Duration? duration,
    BorderRadius? fromBorderRadius,
    BorderRadius? toBorderRadius,
  }) {
    return [
      // This would need custom implementation for complex morphing
      ScaleEffect(
        duration: duration ?? Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.0, 1.0),
      ),
    ];
  }
}

enum SlideDirection { left, right, up, down }

// Custom Animation Widgets
class AnimatedAppear extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final List<Effect> effects;
  final int? delay;

  const AnimatedAppear({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.effects = const [],
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    List<Effect> animationEffects = effects.isEmpty
        ? AppAnimations.cardEntrance(duration: duration, delay: delay)
        : effects;

    return child.animate(effects: animationEffects);
  }
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.style,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
          ),
          child: child,
        );
      },
      child: Text(
        '${prefix ?? ''}$value${suffix ?? ''}',
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Duration duration;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 500),
    this.color,
    this.backgroundColor,
    this.height = 6.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.gray200,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: duration,
        curve: Curves.easeInOut,
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(widget.icon, color: widget.color, size: widget.size),
          );
        },
      ),
    );
  }
}
