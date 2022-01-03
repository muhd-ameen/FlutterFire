// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enteward/provider/signInProvider.dart';
import 'package:enteward/view/home/add_data.dart';
import 'package:enteward/view/home/update_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginnedWidget extends StatefulWidget {
  const LoginnedWidget({Key? key}) : super(key: key);

  @override
  State<LoginnedWidget> createState() => _LoginnedWidgetState();
}

class _LoginnedWidgetState extends State<LoginnedWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController pnumberController = TextEditingController();
 
  var userId = "";
  fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
  }

  @override
  void initState() {
    fetchUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference groceries =
        FirebaseFirestore.instance.collection('groceries');

    final user = FirebaseAuth.instance.currentUser;
    print(user!.displayName);
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(5),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user.photoURL!),
          ),
        ),
        title: Text('Hi ' + user.displayName!.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.googleLogout();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddData(
                nameController: nameController,
                genderController: genderController,
                pnumberController: pnumberController,
              );
            },
          );
        },
        child: Icon(Icons.save_rounded),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            child: CupertinoTextField(
              controller: nameController,
              placeholder: 'Add Grocery Item...',
              prefix: Icon(Icons.person_pin_circle),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: groceries.orderBy('name').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.docs.isEmpty
                        ? Center(child: Text('No Data Found'))
                        : ListView(
                            padding: EdgeInsets.all(10),
                            children: snapshot.data!.docs.map((grocery) {
                              return ListTile(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EditData(
                                     
                                      grocery: grocery,
                                    );
                                  },
                                ),
                                onLongPress: () => grocery.reference.delete(),
                                title: Text(
                                    grocery['name'].toString().toUpperCase()),
                                leading: Image.network(grocery['imageUrl']),
                                subtitle: Text(
                                    grocery['gender'].toString().toUpperCase()),
                                trailing: Text(grocery['pnumber']
                                    .toString()
                                    .toUpperCase()),
                              );
                            }).toList(),
                          );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }
}

