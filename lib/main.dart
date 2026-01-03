// import 'package:tutorix/app.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter/widgets.dart';

// void main(){
//   runApp(App());
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/app.dart';
import 'package:tutorix/app/theme/app.dart';
import 'package:tutorix/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(const ProviderScope(child: App()));
}

