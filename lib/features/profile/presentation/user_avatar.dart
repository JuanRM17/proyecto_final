import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final url = user?.photoUrl;
    final initial = (user?.name.isNotEmpty ?? false)
        ? user!.name.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Text(initial, style: TextStyle(fontSize: radius * 0.9))
          : null,
    );
  }
}