import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePick extends StatefulWidget {
  const ImagePick({super.key, required this.imagePath});
  final void Function(File? pickedImage) imagePath;
  @override
  State<ImagePick> createState() {
    return _ImagePickState();
  }
}

class _ImagePickState extends State<ImagePick> {
  File? _image;
  void _takeImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
         widget.imagePath(_image!);
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _image != null
            ? CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey,
                backgroundImage: FileImage(_image!),
              )
            : CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).colorScheme.background,
                foregroundColor: Colors.grey,
                child: const Icon(
                  Icons.person,
                  size: 65,
                ),
              ),
        IconButton(
          onPressed: _takeImage,
          color: Colors.grey,
          icon: const Icon(Icons.photo_camera),
        ),
      ],
    );
  }
}
