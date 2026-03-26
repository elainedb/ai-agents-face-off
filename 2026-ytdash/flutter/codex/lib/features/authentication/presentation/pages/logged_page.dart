import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../../videos/presentation/pages/videos_page.dart';

class LoggedPage extends StatelessWidget {
  const LoggedPage({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return VideosPage(user: user);
  }
}
