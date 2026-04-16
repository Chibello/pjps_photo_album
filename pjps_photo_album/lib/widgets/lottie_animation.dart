import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/theme/app_colors.dart';

/// Single LottieAnimation widget with full functionality
class LottieAnimation extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;
  final VoidCallback? onCompleted;

  const LottieAnimation({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.reverse = false,
    this.controller,
    this.onLoaded,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      onLoaded: (composition) {
        if (controller != null) {
          controller!.duration = composition.duration;
          controller!.forward().whenComplete(() {
            if (onCompleted != null) onCompleted!();
          });
        } else {
          if (onCompleted != null) {
            Future.delayed(composition.duration, onCompleted!);
          }
        }
        if (onLoaded != null) onLoaded!(composition);
      },
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ['**'],
            value: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}

/// Optional animated logo wrapper
class AnimatedLogo extends StatefulWidget {
  final double size;

  const AnimatedLogo({super.key, this.size = 100});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      assetPath: 'assets/animations/splash_animation.json',
      width: widget.size,
      height: widget.size,
      controller: _controller,
    );
  }
}

/// Loading spinner widget
class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingSpinner({super.key, this.size = 50, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/loading_animation.json',
        width: size,
        height: size,
        delegates: LottieDelegates(
          values: [
            if (color != null)
              ValueDelegate.color(
                const ['**'],
                value: color!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Success animation widget
class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const SuccessAnimation({super.key, this.size = 100, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/success_animation.json',
      width: size,
      height: size,
      repeat: false,
      onLoaded: (composition) {
        Future.delayed(composition.duration, () {
          if (onComplete != null) onComplete!();
        });
      },
    );
  }
}

/// Empty state animation
class EmptyStateAnimation extends StatelessWidget {
  final String type; // 'albums', 'staff', 'remarks', 'search'
  final String message;
  final double size;

  const EmptyStateAnimation({
    super.key,
    required this.type,
    required this.message,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty_animation.json',
          width: size,
          height: size,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.secondaryAsh,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
