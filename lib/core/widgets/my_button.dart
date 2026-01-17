// import 'package:flutter/material.dart';

// class MyButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool showArrow;
//   final bool isLoading;

//   const MyButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//      this.isLoading = false,
//     this.showArrow = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF47734D),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//               ),
//             ),

//             if (showArrow) ...[
//               const SizedBox(width: 10),
//               const Icon(Icons.arrow_forward, color: Colors.white),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool isLoading;

  const MyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF47734D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  if (showArrow) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}
