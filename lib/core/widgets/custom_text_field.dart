// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String hint;
//   final IconData icon;
//   final bool obscure;
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;

//   const CustomTextField({
//     super.key,
//     required this.hint,
//     required this.icon,
//     this.obscure = false,
//     this.controller,
//     this.keyboardType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(1, 3),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         obscureText: obscure,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.grey.shade600),
//           hintText: hint,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String hint;
//   final IconData icon;
//   final TextEditingController controller;
//   final bool obscure;
//   final TextInputType keyboardType;
//   final Widget? suffixIcon;
//   final String? Function(String?)? validator; // ✅ add validator support

//   const CustomTextField({
//     super.key,
//     required this.hint,
//     required this.icon,
//     required this.controller,
//     this.obscure = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.suffixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscure,
//         keyboardType: keyboardType,
//         validator: validator, // ✅ apply validator
//         decoration: InputDecoration(
//           hintText: hint,
//           prefixIcon: Icon(icon),
//           suffixIcon: suffixIcon,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 20,
//             horizontal: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // ✅ same rounded look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: suffixIcon,
          hintText: hint,
          border: InputBorder.none, // ✅ important
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

