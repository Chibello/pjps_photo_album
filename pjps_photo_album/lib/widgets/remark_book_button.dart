import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import '../core/theme/app_colors.dart';

class RemarkBookButton extends StatelessWidget {
  final String contentType;
  final String objectId;

  const RemarkBookButton({
    super.key,
    required this.contentType,
    required this.objectId,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.note_alt_outlined),
      onPressed: () {
        context.push('/remarks/$contentType/$objectId');
      },
      tooltip: 'View Remarks',
    );
  }
}
