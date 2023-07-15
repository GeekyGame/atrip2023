import 'dart:io';
import 'dart:math';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../Home/userMenu/user_menu.dart';
import 'ImageView.dart';


File? file;
var imgpicked;
var imgname;


class app_bar_container extends StatefulWidget {
  @override
  State<app_bar_container> createState() => _app_bar_containerState();
}

class _app_bar_containerState extends State<app_bar_container> {
  var imgstate;

  var imgUrl= ImgUrl;

  var textColor;

  void initState() {
    super.initState();
    setState(() {
      imgpicked = null;
      imgstate = 'Change Your Image';
      textColor = Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(), // Use a custom clipper
      child:  Container(

        height: 300,
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade300,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Set the shadow color
              offset: Offset(0, 5), // Set the shadow offset
              blurRadius: 10, // Set the shadow blur radius
            ),
          ],
        ),
        child:  Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    radius: 70.0,
                    child:  ClipOval(
                      child: Image.network(
                        "$ImgUrl",
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: HexColor('#FAB916'),
                              value:
                              loadingProgress.expectedTotalBytes !=
                                  null
                                  ? loadingProgress
                                  .cumulativeBytesLoaded /
                                  loadingProgress
                                      .expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(img: ImgUrl,)
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit,
                        color: textColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${imgstate}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await _pickImage(context);
                    if (imgpicked != null) {
                      setState(() {
                        textColor = Colors.lightGreen;
                        imgstate = 'Image picked';
                      });
                      imgname = basename(file!.path);
                      var random = Random().nextInt(100000000);
                      imgname = "$random$imgname";
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100); // Start at the bottom-left corner
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100); // Add a quadratic curve
    path.lineTo(size.width, 0); // End at the top-right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


_pickImage(context) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please Choose Image',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () async {
                  imgpicked =
                  await ImagePicker().getImage(source: ImageSource.gallery);
                  if (imgpicked != null) {
                    file = File(imgpicked.path);
                    Navigator.of(context).pop();

                    const snackBar = const SnackBar(
                        content: Text(
                          'Image Picked',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.lightGreen);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    const snackBar = const SnackBar(
                        content: Text(
                          'Image Not Picked',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_outlined,
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'From Gallery',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  imgpicked =
                  await ImagePicker().getImage(source: ImageSource.camera);
                  if (imgpicked != null) {
                    file = File(imgpicked.path);
                    Navigator.of(context).pop();
                    const snackBar = const SnackBar(
                        content: Text(
                          'Image Picked',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.lightGreen);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    const snackBar = const SnackBar(
                        content: Text(
                          'Image Not Picked',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera,
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        'From Camera',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
