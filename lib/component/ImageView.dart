import 'package:flutter/material.dart';
class ImageDialog extends StatelessWidget {
  final img;
  const ImageDialog({Key? key, this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 500,
        decoration: BoxDecoration(
            color:Colors.grey.shade300,
            image: DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.fitWidth
            )
        ),
      ),
    );
  }
}


