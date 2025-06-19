// import 'package:flutter/material.dart';

// class CustomShimmer extends StatefulWidget {
//   final Widget child;
//   final bool isLoading;
//   final Duration duration;
//   final Color baseColor;
//   final Color highlightColor;

//   const CustomShimmer({
//     super.key,
//     required this.child,
//     required this.isLoading,
//     this.duration = const Duration(milliseconds: 1200),
//     this.baseColor = const Color(0xFFE0E0E0),
//     this.highlightColor = const Color(0xFFF5F5F5),
//   });

//   @override
//   State<CustomShimmer> createState() => _CustomShimmerState();
// }

// class _CustomShimmerState extends State<CustomShimmer>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: widget.duration)
//       ..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isLoading) return widget.child;

//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return ShaderMask(
//           shaderCallback: (Rect bounds) {
//             return LinearGradient(
//               colors: [
//                 widget.baseColor,
//                 widget.highlightColor,
//                 widget.baseColor,
//               ],
//               stops: const [0.1, 0.5, 0.9],
//               begin: Alignment(-1.0 - 2.0 * _controller.value, 0.0),
//               end: Alignment(1.0 + 2.0 * _controller.value, 0.0),
//             ).createShader(bounds);
//           },
//           blendMode: BlendMode.srcATop,
//           child: widget.child,
//         );
//       },
//     );
//   }
// }
