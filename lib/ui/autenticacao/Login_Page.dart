import 'package:flutter/material.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'Redefinir_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/autenticacao/Cadastro_Page.dart';
import 'package:projeto_empresa/ui/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  UserPlayer player;

  @override
  void initState() {
    super.initState();
    //firebaseCloudMessaging_Listeners();
  }


  @override
  Widget build(BuildContext context) {



    player = UserPlayer();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.white,
          height: 450.0,
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
                padding: EdgeInsets.only(bottom: 30.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    labelText: "Login",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        labelText: "Senha",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5.0, left: 5.0),
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RedefinirPage()));
                        },
                        child: Text(
                          "Redefinir senha",
                        ),
                      ),
                    )
                  ],
                ),

              ),
              RaisedButton(
                  color: Colors.black,
                  child: Container(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    player.email = emailController.text;
                    player.password = passwordController.text;
                    String userUid;
                    firebaseService.login(player).then((value) => {
                      if(value){
                        Navigator.pushNamed(context, '/home_page'),
                        userUid = FirebaseAuth.instance.currentUser.uid,
                        firebaseService.verificaSePossuiCollection(userUid).whenComplete(() => {
                          Navigator.pushNamed(context, '/home_page'),

                          mensagem("Login realizado!")
                        }),
                        mensagem("Login realizado!")
                      }else{
                        mensagem("Falha ao realizar o login!")
                      }
                    });

                  }

              ),
              GestureDetector(
                child: Text("Cadastrar"),
                onTap: () {
                  Navigator.pushNamed(context, '/cadastro_page');
                },
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /*void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token){
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }*/
}
