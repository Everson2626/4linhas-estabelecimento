import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_empresa/object/Campo.dart';
import 'package:projeto_empresa/object/Establishment.dart';
import 'package:projeto_empresa/object/LocationReturn.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/object/Match.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/autenticacao/Cadastro_Page.dart';
import 'package:projeto_empresa/ui/home_page.dart';

class FirebaseService {
  FirebaseAuth auth = FirebaseAuth.instance;
  Stream<User> get authStateChanges => auth.idTokenChanges();


  FirebaseService(this.auth);
  final databaseReference = FirebaseDatabase.instance.reference();
  final firestoreInstance = FirebaseFirestore.instance;
  //final CollectionReference collectionReference = new CollectionReference();
  BuildContext get context => null;


  Future<String> cadastro(UserPlayer empresa) async {
    if(empresa.name.isEmpty || empresa.email.isEmpty || empresa.name.isEmpty || empresa.confirmPassword.isEmpty){
      String retorno = "";
      if(empresa.email.isEmpty){
        retorno += "Insira um email!\n";
      }
      if(empresa.name.isEmpty){
        retorno += "Insira um nome!\n";
      }
      if(empresa.password.isEmpty){
        retorno += "Insira uma senha!\n";
      }
      if(empresa.confirmPassword.isEmpty){
        retorno += "Prencha o campo de confirmação de senha\n";
      }
      if(empresa.endereco.isEmpty){
        retorno += "Selecione um endereço\n";
      }
      return await retorno;
    }
    try {
      if (empresa.password == empresa.confirmPassword) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: empresa.email,
            password: empresa.password
        );
        empresa.uid = userCredential.user.uid;
        addUserData(empresa);
        return await "Usuario cadastrado";
      } else {
        String msg = '';
        if (empresa.name.isEmpty) {
          return await 'Insira um nome\n';
        }
        return await msg + "As senhas não coincidem ";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return await 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        return await 'Esse E-mail já está cadastrado';
      }
    } catch (e) {
      return await 'Dados Inválidos!';
    }
  }

  Future<void> sair() async {
    await auth.signOut();
  }

  void atualizar(Establishment establishment){
    FirebaseFirestore
      .instance
      .collection('Establishment')
      .doc(establishment.uid)
      .get().then((value) => {
        if(establishment.nome == null || establishment.nome == ""){
          establishment.nome = value.data()['nome']
        },
        if(establishment.endereco == null || establishment.endereco == "" || establishment.endereco == "Selecione o endereço"){
          establishment.endereco = value.data()['endereco']
        },
        if(establishment.latitude == null){
          establishment.latitude = value.data()['latitude']
        },
        if(establishment.longitude == null){
          establishment.longitude = value.data()['longitude']
        },
    }).whenComplete(() => {
      FirebaseFirestore.instance
        .collection('Establishment')
        .doc(establishment.uid)
        .update({
          'nome': establishment.nome,
          "endereco": establishment.endereco,
          "latitude": establishment.latitude,
          "longitude": establishment.longitude
      }),
      LocationReturn.endereco = "Selecione o endereço",
      LocationReturn.longitude = null,
      LocationReturn.latitude = null,
    });
  }

  void addUserData(UserPlayer establishment){
    firestoreInstance.collection("Establishment").doc(establishment.uid).set(
        {
          "uid": establishment.uid,
          "nome": establishment.name,
          "endereco": establishment.endereco,
          "latitude": establishment.latitude,
          "longitude": establishment.longitude,

        }).then((value) {
      LocationReturn.endereco = "Selecione o endereço";
      LocationReturn.longitude = null;
      LocationReturn.latitude = null;
    });
  }

  Future<UserPlayer>getUser(){

  }

  Future<bool> login(UserPlayer player) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: player.email, password: player.password);
      FirebaseAuth auth = FirebaseAuth.instance;
      auth.setPersistence(Persistence.SESSION);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        //mensagem('Não existe um usuario com esse email cadastrado');
      } else if (e.code == 'wrong-password') {
        //mensagem('Senha incoreta');
      }
      return false;
    }
  }

  void createCampo(Campo campo, String establishmentId) async{
    await FirebaseFirestore.instance
        .collection("Establishment")
        .doc(establishmentId)
        .collection('campo')
        .add(
          {
            "nome": campo.nome,
            "limite_jogadores": campo.limite_jogadores,
            "largura": campo.largura,
            "comprimento": campo.comprimento,
          }
        ).then((value) => {print(value)});
  }

  void editCampo(Campo campo, String establishmentId, String campoId, String urlImage) async{
    print(campo.nome);
    await FirebaseFirestore.instance
        .collection("Establishment")
        .doc(establishmentId)
        .collection('campo')
        .doc(campoId)
        .set(
        {
          "nome": campo.nome,
          "limite_jogadores": campo.limite_jogadores,
          "largura": campo.largura,
          "comprimento": campo.comprimento,
          "urlImage": urlImage
        }
    );
  }

  void createEstablishment(Establishment establishment) async{
    await firestoreInstance.collection("Establishment").add(
        {
          "nome": establishment.nome,
          "endereco": establishment.endereco,
        }).then((value) {
      print(value.id);
    });
  }
  void createMatch(Match match) {
    firestoreInstance.collection("match").add(
        {
          "nome": match.nome,
          "preco": match.preco,
          "data": match.data,
          "criador": match.userAdm,
          "status": 'pendente'
        }).then((value) {
      print(value.id);
    });
  }
  Future<void> updateMatch(Match match) async{
    print("Id partida: " + match.nome);
    firestoreInstance.collection("match")
        .doc(match.uid)
        .get().then((value) =>
    {
      if(match.nome == null || match.nome == ""){
        match.nome = value.data()['nome']
      },
      if(match.preco == null || match.preco == ""){
        match.preco = value.data()['preco']
      },
      if(match.data == null || match.data == ""){
        match.data = value.data()['data']
      },
      if(match.userAdm == null || match.userAdm == ""){
        match.userAdm = value.data()['criador']
      },
      if(match.status == null || match.status == ""){
        match.status = value.data()['status']
      },
      if(match.campoUid == null || match.campoUid == ""){
        match.campoUid = value.data()['campoUid']
      },
      if(match.estabelecimentoUid == null || match.estabelecimentoUid == ""){
        match.estabelecimentoUid = value.data()['estabelecimentoUid']
      },
      if(match.urlImage == null || match.urlImage == ""){
        match.urlImage = value.data()['urlImage']
      },
      if(match.timeUid == null || match.timeUid == ""){
        match.timeUid = value.data()['timeUid']
      },
      firestoreInstance.collection("match").doc(match.uid).update({
        "nome": match.nome,
        "preco": match.preco,
        "data": match.data,
        "criador": match.userAdm,
        "status": match.status,
        'campoUid': match.campoUid,
        'estabelecimentoUid': match.estabelecimentoUid,
        'criador': match.userAdm,
        'urlImage': match.urlImage,
        'timeUid': match.timeUid
      })
    });
  }

  void deleteMatch(String matchUid) {
    firestoreInstance.collection("match").doc(matchUid).delete();
  }

  getMatch() {

  }

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> verificaSePossuiCollection(String userUid) async{
    UserPlayer novoUser = new UserPlayer();
    novoUser.uid = userUid;
    await FirebaseFirestore
        .instance
        .collection('Establishment')
        .where(FieldPath.documentId, isEqualTo: userUid)
        .get().then((value) => {
      if(value.size <= 0){
        FirebaseFirestore
            .instance
            .collection('User')
            .doc(userUid)
            .get().then((value) => {
          novoUser.name = value.data()['nome'],
          addUserData(novoUser)
        })
      }
    });
  }
}
