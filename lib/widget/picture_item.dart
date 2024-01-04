import 'package:flutter/material.dart';

class PictureItem extends StatelessWidget {
  final String imageUrl;
  final String dateTimeTaken;

  const PictureItem({
    required this.imageUrl,
    required this.dateTimeTaken,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: 300,
              ),
            ),
          ),
          SizedBox(height: 3),
          Text(
            dateTimeTaken,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}