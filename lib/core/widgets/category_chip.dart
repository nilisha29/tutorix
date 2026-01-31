// import 'package:flutter/material.dart';

// class CategoryChip extends StatelessWidget {
//   final String title;
//   final bool active;

//   const CategoryChip({
//     super.key,
//     required this.title,
//     required this.active,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: active ? Colors.green : Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(25),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         title,
//         style: TextStyle(
//           color: active ? Colors.white : Colors.black54,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
  
// }


import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool active;

  const CategoryChip({
    super.key,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

