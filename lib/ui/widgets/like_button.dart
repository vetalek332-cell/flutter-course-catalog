import 'package:flutter/material.dart';

/// Кнопка лайка с анимацией нажатия
/// (дополнительная опция «Анимации»).
class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    this.onTap,
    this.size = 24,
    this.deactiveColor = const Color(0xFFBDBDBD),
  });

  final bool isLiked;
  final VoidCallback? onTap;
  final double size;

  /// Цвет нелайкнутого состояния (на обложке — белый).
  final Color deactiveColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isLiked ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, _) {
          return Transform.scale(
            scale: 1 + 0.25 * value,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: size,
              color: Color.lerp(
                deactiveColor,
                const Color(0xFFE53935),
                value,
              ),
            ),
          );
        },
      ),
    );
  }
}
