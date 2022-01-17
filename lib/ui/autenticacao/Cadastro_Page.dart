import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_empresa/object/LocationReturn.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/autenticacao/Login_Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_empresa/ui/autenticacao/Maps_Page.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);

  UserPlayer userEmpresa;
  String endereco = "Selecione o endereço";
  double latitude;
  double longitude;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    userEmpresa = UserPlayer();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          height: 550.0,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                child: Text(
                  "4 LINHAS",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Nome",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Senha",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 15.0),
                child: TextField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: confirmController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Confirmar Senha",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
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
                  child: Container(
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    userEmpresa.name = nameController.text;
                    userEmpresa.email = emailController.text;
                    userEmpresa.password = passwordController.text;
                    userEmpresa.confirmPassword = confirmController.text;
                    userEmpresa.endereco = endereco;
                    userEmpresa.latitude = latitude;
                    userEmpresa.longitude = longitude;
                    firebaseService
                        .cadastro(userEmpresa)
                        .then((value) => {mensagem(value.toString())});
                  }),
              GestureDetector(
                child: Text("Já possui login"),
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              )
            ],
          ),
        ),
      )),
    );
  }

  void mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
