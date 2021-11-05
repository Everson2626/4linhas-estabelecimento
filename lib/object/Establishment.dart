import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class Establishment{
  String nome;
  String endereco;
  String uid;
  String urlImageProfile;
  double latitude;
  double longitude;
  int partidasPendentes = 0;
  int partidasConfirmadas = 0;
  int partidasIniciadas = 0;
  int partidasFinalizadas = 0;

  Establishment(){
    nome = '';
    endereco = '';
    uid = '';
    urlImageProfile = '';
  }

  Future<void> getEstablishmentAuthData(String uid) async {
    this.uid = uid;
    await FirebaseFirestore.instance
        .collection('Establishment')
        .doc(this.uid)
        .get()
        .then((value) => {
      this.nome = value['nome'],
    });
    this.urlImageProfile = await firebase_storage.FirebaseStorage.instance
        .ref('image_profile/'+uid)
        .getDownloadURL();

    //this.urlImageProfile = await firebase_storage.FirebaseStorage.instance
    //    .ref('image_profile/'+this.uid)
    //    .getDownloadURL();

    //this.getData();
    //this.setDataViaCache();
  }
}