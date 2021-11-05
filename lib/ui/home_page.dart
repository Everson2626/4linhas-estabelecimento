import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_empresa/object/Establishment.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'package:projeto_empresa/ui/campo/Create_Campo.dart';
import 'package:projeto_empresa/ui/partida/Details_Match.dart';
import 'package:projeto_empresa/ui/user/Edit_User_Page.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hexcolor/hexcolor.dart';

import 'campo/Edit_Campo.dart';

class HomePlayer extends StatefulWidget {
  @override
  _HomePlayerState createState() => _HomePlayerState();
}

int _index = 1;

class _HomePlayerState extends State<HomePlayer> {
  List<Match> match;
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);
  final firestoreInstance = FirebaseFirestore.instance;
  Establishment userAuth = new Establishment();
  List<String> partidas = [];
  String statusFiltro = 'pendente';
  bool selectPendente = true;
  bool selectConfirmado = false;
  bool selectIniciado = false;
  bool selectFinalizado = false;

  @override
  void initState() {
    setState(() {
      this.getUsetAuthData();
    });

    this.partidas = [];
    this.getMatchs();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (_index) {
      case 0:
        child = Column(
          children: [
            menu(),
            meusCampos(),
          ],
        );
        break;
      case 1:
        child = Column(
          children: [
            menu(),
            inputChip(),
            partidasTelas(),
          ],
        );
        break;
    }
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0),
        title: Text(
          "4 LINHAS",
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
      ),
      body: SizedBox.expand(child: child),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 60.0,
              child: DrawerHeader(
                child: Text(
                  '4 LINHAS',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
              ),
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () async {
                firebaseService.sair();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CreateCampo(estabelecimentoId: userAuth.uid)));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (newIndex) => setState(() => _index = newIndex),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_volleyball_outlined),
            label: 'Meus campos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Partidas',
          ),
        ],
        selectedItemColor: Colors.green,
      ),
    );
  }

  Widget meusCampos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 400.0,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Establishment")
                .doc(userAuth.uid)
                .collection("campo")
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  LinearProgressIndicator();
                  break;
                default:
                  return ListView(
                    //physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:
                        snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditCampo(campoId: doc.id)));
                        },
                        child: campoCard(
                          doc.data()['nome'],
                          doc.data()['limite_jogadores'],
                          doc.data()['largura'],
                          doc.data()['comprimento'],
                          doc.data()['urlImage'],
                        ),
                      );
                    }).toList(),
                  );
              }
              return Text('');
            },
          ),
        ),
      ],
    );
  }

  Widget partidasTelas() {
    int _value = 1;
    return Expanded(
        child: SingleChildScrollView(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("match")
            .where("estabelecimentoUid", isEqualTo: userAuth.uid)
            .where("status", isEqualTo: statusFiltro)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              LinearProgressIndicator();
              break;
            default:
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children:
                    snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                  return jogo(
                      doc.data()['nome'],
                      doc.data()['data'],
                      doc.data()['preco'].toString(),
                      2,
                      doc.id,
                      doc.data()['status'],
                      doc.data()['urlImage']);
                }).toList(),
              );
          }
          return Text('');
        },
      ),
    ));
  }

  Widget inputChip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#8B0000"),
              selectedColor: HexColor("#FF0000"),
              label: Text('Pendentes'),
              selected: selectPendente,
              onSelected: (bool value) {
                statusFiltro = 'pendente';
                setState(() {
                  selectPendente = true;
                  selectConfirmado = false;
                  selectIniciado = false;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#006400"),
              selectedColor: HexColor("#00FF00"),
              label: Text('Confirmadas'),
              selected: selectConfirmado,
              onSelected: (bool value) {
                statusFiltro = 'confirmada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = true;
                  selectIniciado = false;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#FFD700"),
              selectedColor: HexColor("#FFFF00"),
              label: Text('Em andamento'),
              selected: selectIniciado,
              onSelected: (bool value) {
                statusFiltro = 'iniciada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = false;
                  selectIniciado = true;
                  selectFinalizado = false;
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: InputChip(
              backgroundColor: HexColor("#A9A9A9"),
              selectedColor: HexColor("#FFFFFF"),
              label: Text('Finalizado'),
              selected: selectFinalizado,
              onSelected: (bool value) {
                statusFiltro = 'finalizada';
                setState(() {
                  selectPendente = false;
                  selectConfirmado = false;
                  selectIniciado = false;
                  selectFinalizado = true;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget historico(String dia) {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 5.0),
      child: Column(
        children: [
          Text(
            dia,
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("match")
                .where(FieldPath.documentId, whereIn: this.partidas)
                .get()
                .asStream(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  LinearProgressIndicator();
                  break;
                default:
                  if (snapshot.data == null) {
                    return LinearProgressIndicator();
                  }
                  ListView(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children:
                        snapshot.data.docs.map<Widget>((DocumentSnapshot doc) {
                      if (doc.data() != null) {
                        return jogo(
                            doc.data()['nome'],
                            doc.data()['data'],
                            doc.data()['preco'].toString(),
                            2,
                            doc.id,
                            doc.data()['status'],
                            doc.data()['urlImage']);
                      }
                    }).toList(),
                  );
              }
              return Text('');
            },
          ),
        ],
      ),
    );
  }

  Widget campoCard(String nome, int lim_jogador, int largura, int comprimento,
      String urlImage) {
    return Card(
      child: Container(
        color: Colors.lightGreen,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: campoImage(urlImage),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    color: Colors.lightGreen,
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            nome,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            "Jogadores: (0/$lim_jogador)",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            "Dimensões: $comprimento/$largura",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getMatchs() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(userAuth.uid)
        .collection('matchs')
        .get()
        .then((value) => value.docs.forEach((element) => {
              this.partidas.add(element.data()['matchUid']),
            }));
  }

  Widget jogo(String nome, String data, String preco, int km, String id,
      String status, String urlImage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DetailsMatch(matchId: id)));
        firebaseService.getMatch();
      },
      child: Card(
        child: Container(
          color: Colors.lightGreen,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: campoImage(urlImage),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      color: Colors.lightGreen,
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              nome,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Text(
                                  "Data: $data",
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              Text(
                                "${km} Km",
                                style: TextStyle(fontSize: 13.0),
                              ),
                            ],
                          ),
                          Text(
                            "Preço: R\$ $preco",
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Text(
                            "Status: $status",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoImage(String urlImage) {
    if (urlImage != null) {
      return Image.network(
        urlImage,
        height: 90.0,
        width: 70.0,
        fit: BoxFit.fill,
      );
    } else {
      return Container(
        height: 90.0,
        width: 70.0,
        color: Colors.grey,
        child: Icon(
          Icons.image,
          size: 60.0,
          color: Colors.white,
        ),
      );
    }
  }

  Widget menu() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => UserEditPage()));
      },
      child: Container(
        height: 135.0,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                  padding: EdgeInsets.all(8.0), child: homeImagemProfile()),
            ),
            Expanded(
              flex: 7,
              child: Container(
                child: Column(
                  children: [
                    Text(
                      userAuth.nome,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Jogos pendentes: " +
                                  this.userAuth.partidasPendentes.toString(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Jogos confirmados: " +
                                  this.userAuth.partidasConfirmadas.toString(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Jogos em andamento: " +
                                  this.userAuth.partidasIniciadas.toString(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Text(
                              "Jogos finalizados: " +
                                  this.userAuth.partidasFinalizadas.toString(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeImagemProfile() {
    print("Image: " + userAuth.urlImageProfile);
    if (userAuth.urlImageProfile == null || userAuth.urlImageProfile == "") {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.black,
          size: 70.0,
        ),
      );
    } else {
      return ClipOval(
          child: Image.network(
        userAuth.urlImageProfile,
        height: 90.0,
        width: 70.0,
        fit: BoxFit.fill,
      ));
    }
  }

  Future<void> getUsetAuthData() async {
    var user = FirebaseAuth.instance.currentUser.uid;
    this.userAuth.uid = user;
    await FirebaseFirestore.instance
        .collection('Establishment')
        .doc(user)
        .get()
        .then((value) => {
              this.userAuth.nome = value['nome'],
            });
    this.userAuth.urlImageProfile = await firebase_storage
        .FirebaseStorage.instance
        .ref('image_profile/' + user)
        .getDownloadURL();

    await FirebaseFirestore.instance
        .collection("match")
        .where("estabelecimentoUid", isEqualTo: userAuth.uid)
        .where("status", isEqualTo: "pendente")
        .get()
        .then((value) => {this.userAuth.partidasPendentes = value.size});

    await FirebaseFirestore.instance
        .collection("match")
        .where("estabelecimentoUid", isEqualTo: userAuth.uid)
        .where("status", isEqualTo: "confirmada")
        .get()
        .then((value) => {
              print(value.size),
              this.userAuth.partidasConfirmadas = value.size
            });

    await FirebaseFirestore.instance
        .collection("match")
        .where("estabelecimentoUid", isEqualTo: userAuth.uid)
        .where("status", isEqualTo: "iniciada")
        .get()
        .then((value) => {this.userAuth.partidasIniciadas = value.size});

    await FirebaseFirestore.instance
        .collection("match")
        .where("estabelecimentoUid", isEqualTo: userAuth.uid)
        .where("status", isEqualTo: "finalizada")
        .get()
        .then((value) => {this.userAuth.partidasFinalizadas = value.size});

    setState(() {});
  }
}
