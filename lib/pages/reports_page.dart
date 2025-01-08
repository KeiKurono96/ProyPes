import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/report_post.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {

  @override
  void initState() {
    super.initState();

    fetchImages();
  }

  Future<void> fetchImages() async {
    await Provider.of<StorageService>(context, listen: false).fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, child) {
        // list of image urls
        final List<String> imageUrls = storageService.imageUrls;
        final List<String> imageNames = storageService.imageNames;

        return Scaffold(
          appBar: MyAppbar(title: storageService.isLoading
            ? "Cargando Reportes..."
            : "Reportes"
          ),
          body: ListView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              // Get each individual image
              final String imageUrl = imageUrls[index];
              final String imageName = imageNames[index];
              // Image post UI
              return ReportPost(imageName: imageName, imageUrl: imageUrl);
            },
          ),
        );
      },
    );
  }
}