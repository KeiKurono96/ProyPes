import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class ReportPost extends StatelessWidget {
  final String imageUrl;
  final String imageName;

  const ReportPost({
    super.key, 
    required this.imageUrl, 
    required this.imageName
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storageService, child) => Container( 
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: Column(
          children: [
            Text(imageName),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 2,
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if(loadingProgress != null){
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        ),
                      ),
                    );
                  } else {
                    return child;
                  }
                },
              ),
            ),
          ],
        ),      
      )
    );
  }
}