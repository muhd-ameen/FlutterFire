// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditData extends StatefulWidget {
  const EditData({
    Key? key,
    required this.grocery,
  }) : super(key: key);
  final QueryDocumentSnapshot<Object?> grocery;

  @override
  State<EditData> createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController genderEditingController = TextEditingController();
  final TextEditingController pnumberEditingController = TextEditingController();
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

  dynamic imgurl;

  Future<String?> uploadPic(File _image) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child(widget.grocery.id);
    UploadTask uploadTask = ref.putFile(_image);
    await uploadTask.whenComplete(() {
      ref.getDownloadURL().then((fileURL) {
        setState(() {
          imgurl = fileURL;
        });
        widget.grocery.reference.update({
          'name': nameEditingController.text,
          'gender': genderEditingController.text,
          'pnumber': pnumberEditingController.text,
          'imageUrl': imgurl,
        });
      });
    });
    return imgurl;
  }

  Future<void> saveImages(File image) async {
    uploadPic(image);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: Column(
        children: [
          TextFormField(
            controller: nameEditingController,
            decoration: InputDecoration(
              hintText: widget.grocery['name'],
            ),
          ),
          TextFormField(
            controller: genderEditingController,
            decoration: InputDecoration(
              hintText: widget.grocery['gender'],
            ),
          ),
          TextFormField(
            controller: pnumberEditingController,
            decoration: InputDecoration(
              hintText: widget.grocery['pnumber'],
            ),
          ),
          Container(
              child: _image == null
                  ? Image.network(widget.grocery['imageUrl'])
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
      ),
      actions: [
        TextButton(
          child: Text('Add'),
          onPressed: () async {
            _image == null
                ? widget.grocery.reference.update({
                    'name': nameEditingController.text,
                    'gender': genderEditingController.text,
                    'pnumber': pnumberEditingController.text,
                  })
                : saveImages(_image!);
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop();
            });
          },
        ),
      ],
    );
  }
}
