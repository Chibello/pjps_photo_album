import 'package:flutter/material.dart';
//import '../../core/theme/app_colors.dart';
import '../../services/album_service.dart';
import '../../services/api_service.dart';

class DeleteStudentScreen extends StatefulWidget {
  final String studentId;

  const DeleteStudentScreen({super.key, required this.studentId});

  @override
  State<DeleteStudentScreen> createState() => _DeleteStudentScreenState();
}

class _DeleteStudentScreenState extends State<DeleteStudentScreen> {
  final AlbumService _albumService = AlbumService(ApiService());
  bool _isLoading = false;

  Future<void> _deleteStudent() async {
    setState(() => _isLoading = true);

    try {
      await _albumService.deleteStudent(widget.studentId);

      Navigator.pop(context, true); // return true to indicate deleted

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student deleted'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Student')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Are you sure you want to delete this student?',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _deleteStudent,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
