import 'dart:core';

class Match {
  Match() {
    this.nome = '';
    this.preco = '';
    this.data = '';
    this.status = '';
    this.uid = '';
    this.urlImage = '';
    this.timeUid = '';
  }

  int id = 0;
  String uid;
  String nome;
  String preco;
  String data;
  String userAdm;
  String status;
  String campoUid;
  String estabelecimentoUid;
  String urlImage;
  String timeUid;
}