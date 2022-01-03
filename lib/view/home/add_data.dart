// ignore_for_file: prefer_const_constructors, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class AddData extends StatefulWidget {
  const AddData({
    Key? key,
    required this.nameController,
    required this.genderController,
    required this.pnumberController,
  }) : super(key: key);
  final TextEditingController nameController;
  final TextEditingController genderController;
  final TextEditingController pnumberController;

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
//   Future<String> uploadFile(File _image) async {
//   StorageReference storageReference = FirebaseStorage.instance
//       .ref()
//       .child('sightings/${Path.basename(_image.path)}');
//   StorageUploadTask uploadTask = storageReference.putFile(_image);
//   await uploadTask.onComplete;
//   print('File Uploaded');
//   String returnURL;
//   await storageReference.getDownloadURL().then((fileURL) {
//     returnURL =  fileURL;
//   });
//   return returnURL;
// }
  dynamic imgurl;

  // Image Picker
  // List<File> _images = [];
  File? _image; // Used only if you need a single picture
  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      pickedFile = (await picker.getImage(source: ImageSource.gallery))!;
    } else {
      pickedFile = (await picker.getImage(
        source: ImageSource.camera,
      ))!;
    }
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> uploadPic(File _image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    CollectionReference groceries =
        FirebaseFirestore.instance.collection('groceries');
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(_image);
    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((fileURL) {
        setState(() {
          imgurl = fileURL;
        });
        groceries.add({
          'name': widget.nameController.text,
          'gender': widget.genderController.text,
          'pnumber': widget.pnumberController.text,
          'imageUrl': imgurl,
        });
        widget.nameController.clear();
        widget.genderController.clear();
        widget.pnumberController.clear();
      });
    });
    return imgurl;
  }

  Future<void> saveImages(File image, CollectionReference ref) async {
    uploadPic(image);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              hintText: 'Name',
            ),
          ),
          TextFormField(
            controller: widget.genderController,
            decoration: InputDecoration(
              hintText: 'gender',
            ),
          ),
          TextFormField(
            controller: widget.pnumberController,
            decoration: InputDecoration(
              hintText: 'Phone Number',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            child: Text('Add'),
            onPressed: () async {
              CollectionReference groceries =
                  FirebaseFirestore.instance.collection('groceries');
              await saveImages(_image!, groceries);

              // uploadPic(_image!).then((url) {
              //   CollectionReference groceries =
              //       FirebaseFirestore.instance.collection('groceries');
              //   print('7777777777777777777777$imgurl');
              //   groceries.add({
              //     'name': widget.nameController.text,
              //     'gender': widget.genderController.text,
              //     'pnumber': widget.pnumberController.text,
              //     'imageUrl': imgurl,
              //   });

              Future.delayed(Duration(seconds: 2), () {
                Navigator.of(context).pop();
              });
              // });
            }),
        Container(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(_image!)),
        Center(
          child: RawMaterialButton(
            fillColor: Theme.of(context).accentColor,
            child: Icon(
              Icons.add_photo_alternate_rounded,
              color: Colors.white,
            ),
            elevation: 8,
            onPressed: () {
              getImage(true);
            },
            padding: EdgeInsets.all(15),
            shape: CircleBorder(),
          ),
        )
      ],
    );
  }
}
