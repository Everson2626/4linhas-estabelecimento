import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projeto_empresa/object/Campo.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:projeto_empresa/ui/campo/Time_Page.dart';


class EditCampo extends StatefulWidget {
  final String campoId;

  const EditCampo({Key key, this.campoId}) : super(key: key);
  @override
  _CreateCampoState createState() => _CreateCampoState();
}

class _CreateCampoState extends State<EditCampo> {
  FirebaseService firebaseService = new FirebaseService(FirebaseAuth.instance);
  String estabelecimentoId = FirebaseAuth.instance.currentUser.uid;


  final nomeController = new TextEditingController();
  final limiteJogadores = new TextEditingController();
  final comprimentoController = new TextEditingController();
  final larguraController = new TextEditingController();
  String imageCampo;
  PickedFile imageFile;


  @override
  void initState() {
    setState(() {
      getCampoData();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Editar Campo",
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TimePage(campoId: widget.campoId)));
            },
            icon: Icon(Icons.more_time)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(10.0 ),
            color: Colors.white,
            //height: 400.0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: GestureDetector(
                      onTap: (){
                        this._openGallery(context).then((value) => uploadFile(value.path));
                      },
                      child: campoImage()
                  ),
                ),
                Container(
                  child: Text(
                    "EDITAR",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: TextField(
                    controller: nomeController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Nome",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: TextField(
                    controller: limiteJogadores,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)
                      ),
                      labelText: "Limite jogadores",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    new Flexible(
                      flex: 5,
                      child: TextField(
                        controller: comprimentoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          labelText: "Comprimento",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    new Flexible(
                      flex: 5,
                      child: TextField(
                        controller: larguraController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          labelText: "Largura",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                RaisedButton(
                    color: Colors.black,
                    child: Container(
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      firebaseService.editCampo(
                          Campo(
                            nomeController.text,
                            limiteJogadores.text,
                            comprimentoController.text,
                            larguraController.text
                          ),
                          this.estabelecimentoId,
                          widget.campoId,
                          this.imageCampo
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget campoImage() {
    if(imageCampo != null){
      return Container(
        width: 300.0,
        height: 200.0,
        child: Image.network(
          imageCampo,
          fit: BoxFit.fill,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
        ),
      );

    }else{
      return Container(
        width: 300.0,
        height: 200.0,
        child: Icon(
          Icons.image,
          size: 150.0,
          color: Colors.black,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
        ),
      );
    }
  }

  Future<void> getCampoData() async {
    await FirebaseFirestore.instance
        .collection('Establishment')
        .doc(this.estabelecimentoId)
        .collection('campo')
        .doc(widget.campoId)
        .get()
        .then((value) => {
      this.nomeController.text = value['nome'],
      this.limiteJogadores.text = value['limite_jogadores'].toString(),
      this.larguraController.text = value['largura'].toString(),
      this.comprimentoController.text = value['comprimento'].toString(),
    });
    this.imageCampo = await firebase_storage.FirebaseStorage.instance
        .ref('estabelecimento/'+this.estabelecimentoId+'/'+widget.campoId)
        .getDownloadURL();

    setState(() {

    });
  }
  Future<PickedFile> _openGallery(BuildContext context) async {
    print("Aqui 2");
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    this.imageFile = pickedFile;
    return this.imageFile;
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);

    await firebase_storage.FirebaseStorage.instance
        .ref('estabelecimento/'+this.estabelecimentoId+'/'+widget.campoId)
        .putFile(file);
    this.getCampoData();
  }
}
