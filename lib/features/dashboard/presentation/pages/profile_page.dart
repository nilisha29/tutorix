// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.green,
//       ),
//       body: const Center(
//         child: Text(
//           'Welcome to the Profile Page',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 👤 Profile Info
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.orange,
//               child: Icon(Icons.person, size: 50, color: Colors.white),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               "Sophia Carter",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const Text("Age: 12"),
//             const Text("sophia.carter@email.com"),
//             const Text("9867456789"),

//             const SizedBox(height: 20),

//             // ✏️ Edit Profile
//             ElevatedButton(
//               onPressed: () {},
//               child: const Text("Edit Profile"),
//             ),

//             const SizedBox(height: 24),

//             // ⚙️ Account Settings
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Account Settings",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // 🔒 Change Password
//             ListTile(
//               leading: const Icon(Icons.lock),
//               title: const Text("Change Password"),
//               onTap: () {},
//             ),

//             // 🛡 Privacy
//             ListTile(
//               leading: const Icon(Icons.security),
//               title: const Text("Privacy & Security"),
//               onTap: () {},
//             ),

//             // 🌙 Dark Mode
//             SwitchListTile(
//               secondary: const Icon(Icons.dark_mode),
//               title: const Text("Dark Mode"),
//               value: false,
//               onChanged: (value) {},
//             ),

//             // 🚪 Logout
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text(
//                 "Log Out",
//                 style: TextStyle(color: Colors.red),
//               ),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class ProfilePage extends ConsumerWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);

//     ImageProvider? profileImage;
//     final profileUrl = authState.authEntity?.profilePicture;

//     if (profileUrl != null && profileUrl.startsWith("http")) {
//       profileImage = NetworkImage(profileUrl);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 55,
//               backgroundImage: profileImage,
//               child: profileImage == null
//                   ? const Icon(Icons.person, size: 40)
//                   : null,
//             ),

//             const SizedBox(height: 16),

//             Text(
//               authState.authEntity?.fullName ?? "User",
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 6),

//             Text(
//               authState.authEntity?.email ?? "",
//               style: const TextStyle(color: Colors.grey),
//             ),

//             const SizedBox(height: 30),

//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text("Edit Profile"),
//               onTap: () {
//                 // we’ll implement this next
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.dark_mode),
//               title: const Text("Dark Mode"),
//               trailing: Switch(
//                 value: false,
//                 onChanged: (_) {},
//               ),
//             ),

//             const Spacer(),

//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 minimumSize: const Size(double.infinity, 45),
//               ),
//               onPressed: () {
//                 ref.read(authViewModelProvider.notifier).logout();
//               },
//               icon: const Icon(Icons.logout),
//               label: const Text("Logout"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/features/auth/presentation/pages/login_page.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';


// class ProfilePage extends ConsumerWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);
//     final authNotifier = ref.read(authViewModelProvider.notifier);

//     ImageProvider? profileImage;

//     if (authState.authEntity?.profilePicture != null) {
//       final url = authState.authEntity!.profilePicture!;
//       profileImage = NetworkImage(url);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 👤 Profile Image
//             CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.orange.shade100,
//               backgroundImage: profileImage,
//               child: profileImage == null
//                   ? const Icon(Icons.person, size: 50, color: Colors.orange)
//                   : null,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               authState.authEntity?.fullName ?? "User",
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(authState.authEntity?.email ?? "example@email.com"),
//             Text(authState.authEntity?.phoneNumber ?? "N/A"),

//             const SizedBox(height: 20),

//             // ✏️ Edit Profile
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to Edit Profile Page
//               },
//               child: const Text("Edit Profile"),
//             ),

//             const SizedBox(height: 24),

//             // ⚙️ Account Settings
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Account Settings",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             ListTile(
//               leading: const Icon(Icons.lock),
//               title: const Text("Change Password"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.security),
//               title: const Text("Privacy & Security"),
//               onTap: () {},
//             ),
//             SwitchListTile(
//               secondary: const Icon(Icons.dark_mode),
//               title: const Text("Dark Mode"),
//               value: false,
//               onChanged: (value) {},
//             ),

//             // 🚪 Logout
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text(
//                 "Log Out",
//                 style: TextStyle(color: Colors.red),
//               ),
//               onTap: () {
//                 // ✅ Logout
//                 authNotifier.logout();

//                 // Navigate to login page and remove all previous routes
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/features/auth/presentation/pages/login_page.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class ProfilePage extends ConsumerWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);
//     final authNotifier = ref.read(authViewModelProvider.notifier);

//     // Determine profile image
//     ImageProvider? profileImage;
//     final profilePath = authState.profilePicture ?? authState.authEntity?.profilePicture;
//     if (profilePath != null && profilePath.isNotEmpty) {
//       if (profilePath.startsWith('http')) {
//         profileImage = NetworkImage(profilePath);
//       } else {
//         profileImage = FileImage(File(profilePath));
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 👤 Profile Image
//             CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.orange.shade100,
//               backgroundImage: profileImage,
//               child: profileImage == null
//                   ? const Icon(Icons.person, size: 50, color: Colors.orange)
//                   : null,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               authState.authEntity?.fullName ?? "User",
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             Text(authState.authEntity?.email ?? "example@email.com"),
//             Text(authState.authEntity?.phoneNumber ?? "N/A"),
//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to Edit Profile page if implemented
//               },
//               child: const Text("Edit Profile"),
//             ),

//             const SizedBox(height: 24),

//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Account Settings",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             ListTile(
//               leading: const Icon(Icons.lock),
//               title: const Text("Change Password"),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.security),
//               title: const Text("Privacy & Security"),
//               onTap: () {},
//             ),
//             SwitchListTile(
//               secondary: const Icon(Icons.dark_mode),
//               title: const Text("Dark Mode"),
//               value: false,
//               onChanged: (value) {},
//             ),

//             // 🚪 Logout
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text(
//                 "Log Out",
//                 style: TextStyle(color: Colors.red),
//               ),
//               onTap: () {
//                 // Clear user state
//                 authNotifier.logout();

//                 // Navigate to login page and remove all previous routes
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/auth/presentation/pages/login_page.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/features/editprofile/presentation/pages/edit_profile.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authNotifier = ref.read(authViewModelProvider.notifier);

    ImageProvider? profileImage;
    final profilePath =
        authState.profilePicture ?? authState.authEntity?.profilePicture;

    if (profilePath != null && profilePath.isNotEmpty) {
      profileImage = profilePath.startsWith('http')
          ? NetworkImage(profilePath)
          : FileImage(File(profilePath));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: profileImage,
              child: profileImage == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),

            Text(
              authState.authEntity?.fullName ?? "User",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(authState.authEntity?.email ?? ""),
            Text(authState.authEntity?.phoneNumber ?? ""),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfilePage(),
                  ),
                );
              },
              child: const Text("Edit Profile"),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Account Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Privacy & Security"),
              onTap: () {},
            ),

             SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              value: false,
              onChanged: (value) {},
            ),

            // const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                authNotifier.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}









