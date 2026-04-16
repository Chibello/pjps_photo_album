import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/student_card.dart';
//import '../../models/student_model.dart';

class YearAlbumScreen extends ConsumerStatefulWidget {
  final String yearId;
  final String yearName;

  const YearAlbumScreen({
    super.key,
    required this.yearId,
    required this.yearName,
  });

  @override
  ConsumerState<YearAlbumScreen> createState() => _YearAlbumScreenState();
}

class _YearAlbumScreenState extends ConsumerState<YearAlbumScreen> {
  @override
  void initState() {
    super.initState();

    // This delays the provider update until after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    await ref.read(albumProvider.notifier).loadStudentsByYear(widget.yearId);
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(albumProvider);
    final students = albumState.currentStudents;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.yearName),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: albumState.isLoading && students.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : students.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.secondaryAsh,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondaryAsh,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return StudentCard(
                        student: student,
                        onTap: () {
                          context.push('/students/${student.id}');
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
