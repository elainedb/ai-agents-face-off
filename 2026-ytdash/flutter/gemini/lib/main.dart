import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'core/config/env_config.dart';
import 'core/di/injection.dart' as di;
import 'test_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  await TestConfig.init();
  await AppConfig.load();
  await di.init();

  runApp(const YtDashApp());
}
