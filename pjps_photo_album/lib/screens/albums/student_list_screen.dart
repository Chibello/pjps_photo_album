import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import 'package:go_router/go_router.dart';

class StudentListScreen extends ConsumerWidget {
  final String yearId;
  final String? yearName; // optional (for better UX)

  const StudentListScreen({
    super.key,
    required this.yearId,
    this.yearName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsByYearProvider(yearId));

    return Scaffold(
      appBar: AppBar(
        title: Text(yearName ?? 'Students'),
      ),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(
              child: Text('No students in this year'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final student = students[index];

              return ListTile(
                leading: student.profilePhotoThumbnail != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(student.profilePhotoThumbnail!),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                title: Text(student.fullName),
                subtitle: Text(student.registrationNumber),
                onTap: () {
                  context.pushNamed(
                    'studentDetail',
                    pathParameters: {'studentId': student.id},
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error fetching students:\n$e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
