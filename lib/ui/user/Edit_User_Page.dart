import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_empresa/object/Establishment.dart';
import 'package:projeto_empresa/object/LocationReturn.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'package:projeto_empresa/ui/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UserEditPage extends StatefulWidget {
  final String userId;
  const UserEditPage({Key key, this.userId}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  Establishment userAuth = new Establishment();
  TextEditingController nome = new TextEditingController();
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  PickedFile imageFile;
  String endereco = "Selecione o endereço";
  double latitude;
  double longitude;

  @override
  void initState() {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    setState(() {
      this.getUsetAuthData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Edite a conta"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: GestureDetector(
                        onTap: () {
                          this
                              ._openGallery(context)
                              .then((value) => uploadFile(value.path));
                        },
                        child: imagemProfile()),
                  ),
                  Container(
                      child: Text(
                    nome.text,
                    style: TextStyle(fontSize: 25.0, color: Colors.black),
                  )),
                  TextField(
                    decoration:
                        InputDecoration(labelText: "Nome do estabelecimento"),
                    controller: nome,
                    onChanged: (nome) {
                      setState(() {});
                    },
                  ),
                  Container(
                    width: 200.0,
                    child: RaisedButton(
                        color: Colors.green,
                        child: Text(
                          LocationReturn.endereco,
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/maps_page');

                          setState(() {
                            this.endereco = LocationReturn.endereco;
                            this.longitude = LocationReturn.longitude; 
                            this.latitude = LocationReturn.latitude;
                          });
                        }),
                  ),
                  RaisedButton(
                    color: Colors.black,
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      this.userAuth.uid = FirebaseAuth.instance.currentUser.uid;
                      this.userAuth.nome = nome.text;
                      this.userAuth.endereco = this.endereco;
                      this.userAuth.latitude = this.latitude;
                      this.userAuth.longitude = this.longitude;
                      firebaseService.atualizar(this.userAuth);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> getUsetAuthData() async {
    var user = FirebaseAuth.instance.currentUser.uid;
    await FirebaseFirestore.instance
        .collection('Establishment')
        .doc(user)
        .get()
        .then((value) => {
              this.nome.text = value['nome'],
            });
    this.userAuth.urlImageProfile = await firebase_storage
        .FirebaseStorage.instance
        .ref('image_profile/' + user)
        .getDownloadURL();
    setState(() {});
  }

  Future<PickedFile> _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    this.imageFile = pickedFile;
    return this.imageFile;
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);

    await firebase_storage.FirebaseStorage.instance
        .ref('image_profile/' + userAuth.uid)
        .putFile(file);
    this.getUsetAuthData();
  }

  Widget imagemProfile() {
    print(userAuth.urlImageProfile);
    if (userAuth.urlImageProfile == null || userAuth.urlImageProfile == "") {
      return Container(
        width: 200.0,
        height: 200.0,
        child: Icon(
          Icons.person,
          size: 150.0,
          color: Colors.black,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 5.0),
          borderRadius: BorderRadius.circular(180.0),
        ),
      );
    } else {
      return Container(
        width: 200.0,
        height: 200.0,
        child: ClipOval(
          child: Image.network(
            userAuth.urlImageProfile,
            height: 200.0,
            width: 200.0,
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }
}
