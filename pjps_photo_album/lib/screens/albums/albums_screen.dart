import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/providers.dart';
import '../../widgets/year_card.dart';

class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(albumProvider.notifier).loadYearLevels();
    });
  }

  Future<void> _loadYearLevels() async {
    await ref.read(albumProvider.notifier).loadYearLevels();
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(albumProvider);
    final yearLevels = albumState.yearLevels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Albums'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadYearLevels,
        child: albumState.isLoading && yearLevels.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : yearLevels.isEmpty
                ? Center(
                    child: Text(albumState.error ?? 'No year levels found'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95, // more vertical space
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: yearLevels.length,
                    itemBuilder: (context, index) {
                      final year = yearLevels[index];
                      return YearCard(
                        year: year,
                        onTap: () {
                          // Navigate to student list for this year
                          context.push(
                            '/albums/year/${year.id}',
                            extra: year.name,
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
