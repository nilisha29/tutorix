// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class EditProfilePage extends ConsumerStatefulWidget {
//   const EditProfilePage({super.key});

//   @override
//   ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends ConsumerState<EditProfilePage> {
//   late TextEditingController fullNameController;
//   late TextEditingController phoneController;
//   late TextEditingController addressController;

//   @override
//   void initState() {
//     super.initState();
//     final auth = ref.read(authViewModelProvider).authEntity;

//     fullNameController = TextEditingController(text: auth?.fullName ?? '');
//     phoneController = TextEditingController(text: auth?.phoneNumber ?? '');
//     addressController = TextEditingController(text: auth?.address ?? '');
//   }

//   Future<void> _pickImage(bool fromCamera) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       ref.read(authViewModelProvider.notifier)
//           .setProfilePicture(pickedFile.path);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     ImageProvider? profileImage;
//     final profilePath =
//         authState.profilePicture ?? authState.authEntity?.profilePicture;

//     if (profilePath != null && profilePath.isNotEmpty) {
//       profileImage = profilePath.startsWith('http')
//           ? NetworkImage(profilePath)
//           : FileImage(File(profilePath));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         leading: BackButton(),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// Profile Image
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: profileImage,
//                   child: profileImage == null
//                       ? const Icon(Icons.person, size: 40)
//                       : null,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.camera_alt),
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       builder: (_) => Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ListTile(
//                             leading: const Icon(Icons.camera),
//                             title: const Text("Take Photo"),
//                             onTap: () {
//                               Navigator.pop(context);
//                               _pickImage(true);
//                             },
//                           ),
//                           ListTile(
//                             leading: const Icon(Icons.photo),
//                             title: const Text("Choose from Gallery"),
//                             onTap: () {
//                               Navigator.pop(context);
//                               _pickImage(false);
//                             },
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 )
//               ],
//             ),

//             const SizedBox(height: 20),

//             TextField(
//               controller: fullNameController,
//               decoration: const InputDecoration(labelText: "Full Name"),
//             ),
//             const SizedBox(height: 12),

//             TextField(
//               controller: phoneController,
//               decoration: const InputDecoration(labelText: "Phone Number"),
//             ),
//             const SizedBox(height: 12),

//             TextField(
//               controller: addressController,
//               decoration: const InputDecoration(labelText: "Address"),
//             ),

//             const Spacer(),

//             ElevatedButton(
//               onPressed: () async {
//                 await ref.read(authViewModelProvider.notifier).updateProfile(
//                       fullName: fullNameController.text,
//                       phoneNumber: phoneController.text,
//                       address: addressController.text,
//                       profilePicture: authState.profilePicture,
//                     );

//                 Navigator.pop(context);
//               },
//               child: const Text("Save Changes"),
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
import 'package:image_picker/image_picker.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authViewModelProvider).authEntity;

    fullNameController = TextEditingController(text: auth?.fullName ?? '');
    phoneController = TextEditingController(text: auth?.phoneNumber ?? '');
    addressController = TextEditingController(text: auth?.address ?? '');
  }

  Future<void> _pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      ref.read(authViewModelProvider.notifier).setProfilePicture(pickedFile.path);
    }
  }

  String _normalizeProfileUrl(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final url = value.trim();

    if (url.startsWith('http://localhost:') ||
        url.startsWith('https://localhost:') ||
        url.startsWith('http://127.0.0.1:') ||
        url.startsWith('https://127.0.0.1:')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final base = Uri.parse(ApiEndpoints.serverUrl);
        return Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.port,
          path: uri.path,
          query: uri.query.isEmpty ? null : uri.query,
        ).toString();
      }
    }

    if (url.startsWith('/')) return '${ApiEndpoints.mediaServerUrl}$url';
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    final rawProfilePath =
        authState.profilePicture ?? authState.authEntity?.profilePicture;
    final profilePath = _normalizeProfileUrl(rawProfilePath);

    Widget getProfileAvatar() {
      if (profilePath == null || profilePath.isEmpty) {
        return CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 50, color: Colors.grey),
        );
      }

      if (profilePath.startsWith('http')) {
        return CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(profilePath),
          onBackgroundImageError: (exception, stackTrace) {
            print('[DEBUG EDIT] Failed to load network image: $exception');
          },
        );
      } else {
        return CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: FileImage(File(profilePath)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 Profile Image Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  getProfileAvatar(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text("Take Photo"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(true);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text("Choose from Gallery"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📝 Name
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 📞 Phone
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🏠 Address
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // 💾 Save Changes Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await ref.read(authViewModelProvider.notifier).updateProfile(
                        fullName: fullNameController.text,
                        phoneNumber: phoneController.text,
                        address: addressController.text,
                        profilePicture: authState.profilePicture,
                      );
                  
                  final updatedState = ref.read(authViewModelProvider);
                  if (updatedState.status == AuthStatus.authenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (updatedState.status == AuthStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(updatedState.errorMessage ?? 'Failed to update profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

