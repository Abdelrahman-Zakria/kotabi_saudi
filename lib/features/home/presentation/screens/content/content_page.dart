import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:kotabi_saudi/main.dart';
import 'package:kotabi_saudi/core/theme/app_theme.dart';
import 'package:kotabi_saudi/core/services/local_storage_service.dart';
import 'package:kotabi_saudi/features/home/domain/repositories/educational_repository.dart';
import 'package:kotabi_saudi/features/home/domain/entities/educational_node.dart';
import 'package:kotabi_saudi/features/home/presentation/widgets/resource_chips.dart';
import 'cubit/content_cubit.dart';
import 'cubit/content_state.dart';

class ContentPage extends StatelessWidget {
  final EducationalNode? node;
  final String parentId;
  final String title;

  const ContentPage({super.key, this.node, required this.parentId, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContentCubit(
        repository: context.read<EducationalRepository>(),
        storage: sl<LocalStorageService>(),
      )..loadItems(parentId, node?.url),
      child: ContentView(node: node, parentId: parentId, title: title),
    );
  }
}

class ContentView extends StatelessWidget {
  final EducationalNode? node;
  final String parentId;
  final String title;

  const ContentView({super.key, this.node, required this.parentId, required this.title});

  @override
  Widget build(BuildContext context) {
    final pdfResource = node?.resources.where((r) => r.type == 'pdf_viewer' || r.type == 'pdf_direct').firstOrNull;
    final otherResources = node?.resources.where((r) => r.type != 'pdf_viewer' && r.type != 'pdf_direct').toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(node?.title ?? title),
        actions: [
          if (node != null)
            BlocBuilder<ContentCubit, ContentState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(state.isFavorite ? Icons.favorite : Icons.favorite_border, color: state.isFavorite ? Colors.red : Colors.white),
                  onPressed: () => context.read<ContentCubit>().toggleFavorite(node!),
                );
              },
            ),
          if (pdfResource != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                context.read<ContentCubit>().addToLibrary(node!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تمت الإضافة إلى التنزيلات")));
              },
            ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildBreadcrumbs(),
            if (otherResources.isNotEmpty) ResourceChips(resources: otherResources),
            if (pdfResource != null)
              Expanded(child: _buildPdfViewer(pdfResource.url))
            else
              Expanded(child: _buildItemsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    if (node == null || node!.breadcrumbs.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: node!.breadcrumbs.map((b) => Text("${b.title} » ", style: const TextStyle(fontSize: 11, color: AppTheme.subTextColor))).toList(),
        ),
      ),
    );
  }

  Widget _buildPdfViewer(String url) {
    return SfPdfViewer.network(url);
  }

  Widget _buildItemsList(BuildContext context) {
    return BlocBuilder<ContentCubit, ContentState>(
      builder: (context, state) {
        if (state is ContentLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ContentLoaded) {
          if (state.items.isEmpty) {
             if (node != null && node!.description.isNotEmpty) {
               return SingleChildScrollView(
                 padding: const EdgeInsets.all(16),
                 child: Text(node!.description, style: const TextStyle(height: 1.6, color: AppTheme.textColor)),
               );
             }
             return const Center(child: Text("لا توجد محتويات"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentPage(
                          node: item,
                          parentId: item.id,
                          title: item.title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
