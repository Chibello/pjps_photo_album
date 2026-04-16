import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/remark_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/remark_model.dart';
//import '../../widgets/custom_button.dart';

class RemarkBookScreen extends ConsumerStatefulWidget {
  final String contentType;
  final String objectId;

  const RemarkBookScreen({
    super.key,
    required this.contentType,
    required this.objectId,
  });

  @override
  ConsumerState<RemarkBookScreen> createState() => _RemarkBookScreenState();
}

class _RemarkBookScreenState extends ConsumerState<RemarkBookScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'GENERAL';
  String _selectedVisibility = 'INTERNAL';

  final List<String> _remarkTypes = [
    'GENERAL',
    'ACADEMIC',
    'BEHAVIORAL',
    'ACHIEVEMENT',
    'ATTENDANCE',
    'OTHER',
  ];

  final List<String> _visibilityLevels = [
    'PRIVATE',
    'INTERNAL',
    'PUBLIC',
  ];

  @override
  void initState() {
    super.initState();
    ref.read(remarksProvider.notifier).loadRemarkBook(
          widget.contentType,
          widget.objectId,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showAddRemarkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Add Remark'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter remark title',
              ),
              const SizedBox(height: 12),

              // Remark Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Remark Type',
                  border: OutlineInputBorder(),
                ),
                items: _remarkTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Visibility Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedVisibility,
                decoration: const InputDecoration(
                  labelText: 'Visibility',
                  border: OutlineInputBorder(),
                ),
                items: _visibilityLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVisibility = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Content Field
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter remark details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addRemark,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _contentController.clear();
    _selectedType = 'GENERAL';
    _selectedVisibility = 'INTERNAL';
  }

  Future<void> _addRemark() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(remarksProvider.notifier).addRemark(
          contentType: widget.contentType,
          objectId: widget.objectId,
          title: _titleController.text,
          content: _contentController.text,
          remarkType: _selectedType,
          visibility: _selectedVisibility,
        );

    if (success && mounted) {
      _clearForm();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remark added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remarksState = ref.watch(remarksProvider);
    final remarkBook = remarksState.currentRemarkBook;
    final remarks = remarkBook?.remarks ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(remarkBook?.title ?? 'Remarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRemarkDialog,
          ),
        ],
      ),
      body: remarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 64,
                    color: AppColors.secondaryAsh.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No remarks yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryAsh,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a remark',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryAsh.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: remarks.length,
              itemBuilder: (context, index) {
                final remark = remarks[index];
                return RemarkCard(
                  remark: remark,
                  onTap: () {
                    _showRemarkDetail(remark);
                  },
                );
              },
            ),
    );
  }

  void _showRemarkDetail(RemarkModel remark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAsh.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Remark Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(remark.remarkType)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              remark.remarkType,
                              style: TextStyle(
                                color: _getTypeColor(remark.remarkType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getVisibilityColor(remark.visibility)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              remark.visibility,
                              style: TextStyle(
                                color: _getVisibilityColor(remark.visibility),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        remark.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        remark.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Author and Date
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 16,
                              color: AppColors.secondaryAsh,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              remark.authorName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryAsh,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.secondaryAsh,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, yyyy • h:mm a')
                                  .format(DateTime.parse(remark.createdAt)),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryAsh,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 32),

                      // Comments Section
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comments List
                      ...remark.comments
                          .map((comment) => _buildCommentTile(comment)),

                      if (remark.comments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No comments yet',
                              style: TextStyle(
                                color: AppColors.secondaryAsh.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentTile(RemarkCommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, yyyy')
                    .format(DateTime.parse(comment.createdAt)),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryAsh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ACADEMIC':
        return Colors.blue;
      case 'BEHAVIORAL':
        return Colors.orange;
      case 'ACHIEVEMENT':
        return Colors.green;
      case 'ATTENDANCE':
        return Colors.purple;
      default:
        return AppColors.primaryGold;
    }
  }

  Color _getVisibilityColor(String visibility) {
    switch (visibility) {
      case 'PRIVATE':
        return Colors.red;
      case 'INTERNAL':
        return Colors.orange;
      case 'PUBLIC':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
