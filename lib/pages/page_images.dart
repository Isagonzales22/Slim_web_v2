import 'package:flutter/material.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';

class PageImages extends StatelessWidget {
  const PageImages({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Image.network(images[index]);
          },
        ),
      )
    );
  }
}