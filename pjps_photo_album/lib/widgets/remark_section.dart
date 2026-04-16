import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/providers.dart';
//import '../models/remark_model.dart';
import 'remark_card.dart';

class RemarkSection extends ConsumerStatefulWidget {
  final String contentType;
  final String objectId;

  const RemarkSection({
    super.key,
    required this.contentType,
    required this.objectId,
  });

  @override
  ConsumerState<RemarkSection> createState() => _RemarkSectionState();
}

class _RemarkSectionState extends ConsumerState<RemarkSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pass Map<String, String> to match provider
    final remarksAsync = ref.watch(
      remarkBookProvider({
        'contentType': widget.contentType,
        'objectId': widget.objectId,
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Remarks',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a remark...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;

                try {
                  await ref.read(remarksServiceProvider).addRemark(
                        contentType: widget.contentType,
                        objectId: widget.objectId,
                        title: 'Remark',
                        content: text,
                        remarkType: 'GENERAL',
                        visibility: 'INTERNAL',
                      );

                  _controller.clear();

                  // Refresh provider using Map key
                  ref.invalidate(
                    remarkBookProvider({
                      'contentType': widget.contentType,
                      'objectId': widget.objectId,
                    }),
                  );
                } catch (e) {
                  debugPrint('Error posting remark: $e');
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        remarksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (remarkBook) {
            if (remarkBook.remarks.isEmpty) {
              return const Text('No remarks yet');
            }

            // Use RemarkCard here
            return Column(
              children: remarkBook.remarks
                  .map(
                    (r) => RemarkCard(
                      remark: r,
                      onTap: () {
                        // Optional: handle tap, e.g., open details or comments
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
