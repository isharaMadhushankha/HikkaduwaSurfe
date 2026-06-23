import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Color emptyColor;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.color = const Color(0xFFF59E0B),
    this.emptyColor = const Color(0xFFE5E7EB),
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;

        if (rating >= starValue) {
          // Full star
          return Icon(Icons.star_rounded, size: size, color: color);
        } else if (rating >= starValue - 0.5) {
          // Half star
          return Stack(
            children: [
              Icon(Icons.star_rounded, size: size, color: emptyColor),
              ClipRect(
                clipper: _HalfClipper(),
                child: Icon(Icons.star_rounded, size: size, color: color),
              ),
            ],
          );
        } else {
          // Empty star
          return Icon(Icons.star_rounded, size: size, color: emptyColor);
        }
      }),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
