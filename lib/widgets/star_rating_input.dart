import 'package:flutter/material.dart';

class StarRatingInput extends StatelessWidget {
  final int rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onRatingChanged;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40,
    this.activeColor = const Color(0xFFF59E0B),
    this.inactiveColor = const Color(0xFFE5E7EB),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= rating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: starValue <= rating ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
