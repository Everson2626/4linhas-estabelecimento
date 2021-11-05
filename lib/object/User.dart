import 'dart:core';

class UserPlayer {

  String uid;
  String name;
  String email;
  String password;
  String confirmPassword;
  String endereco;
  double latitude;
  double longitude;

  String positions;

  UserPlayer(){
    this.uid = '';
    this.email = '';
    this.password = '';
    this.confirmPassword = '';
    this.name = '';
    this.positions = '';
    this.endereco = '';
    this.longitude = 0;
    this.latitude = 0;
  }

  String getData(){
    String retorno;
    retorno = "Uid: ${this.uid}\n"+
              "Email: ${this.email}\n"+
              "Senha: ${this.password}\n"+
              "Confirma Senha: ${this.confirmPassword}\n"+
              "Nome: ${this.name}";
    return retorno;
  }
}