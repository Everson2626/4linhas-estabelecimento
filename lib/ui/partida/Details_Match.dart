import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto_empresa/object/Match.dart';
import 'package:projeto_empresa/object/User.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'package:projeto_empresa/ui/partida/Edit_Match.dart';

class DetailsMatch extends StatefulWidget {
  final String matchId;

  const DetailsMatch({Key key, this.matchId}) : super(key: key);

  @override
  _DetailsMatchState createState() => _DetailsMatchState();
}

class _DetailsMatchState extends State<DetailsMatch> {
  Match match = new Match();
  UserPlayer userAuth = new UserPlayer();
  List<String> players = [];
  FirebaseService firebaseService = FirebaseService(FirebaseAuth.instance);

  @override
  void initState() {
    userAuth.uid = FirebaseAuth.instance.currentUser.uid;
    this.getUser();
    getMatchData();
  }

  @override
  Widget build(BuildContext context) {
    print(this.players);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "Detalhes da partida",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: 60),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    match.nome,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    "Dia: " + match.data,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    "Valor: R\$ " + match.preco,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    "Status: " + match.status,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  height: 3.0,
                ),
                partidaConfirmada(),
              ],
            ),
          ),
        ));
  }

  Widget partidaConfirmada() {
    if (match.status == "confirmada") {
      return Text(
        "Partida confirmada",
        style: TextStyle(color: Colors.lightGreen),
      );
    } else if (match.status == "recusada") {
      return Text(
        "Partida recusada",
        style: TextStyle(color: Colors.red),
      );
    }
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RaisedButton(
              color: Colors.black,
              child: Text(
                "Confirmar partida",
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              onPressed: () {
                match.uid = widget.matchId;
                match.status = "confirmada";
                firebaseService
                    .updateMatch(match)
                    .then((value) => setState(() => {}));
                FirebaseFirestore.instance
                    .collection("Establishment")
                    .doc(match.estabelecimentoUid)
                    .collection("campo")
                    .doc(match.campoUid)
                    .collection("horarios")
                    .doc("info")
                    .collection(match.data.split(" ")[0])
                    .doc(match.timeUid)
                    .update({"Status": "ocupado"});
              }),
          RaisedButton(
              color: Colors.black,
              child: Text(
                "Recusar partida",
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              onPressed: () {
                match.uid = widget.matchId;
                match.status = "recusada";
                firebaseService
                    .updateMatch(match)
                    .then((value) => setState(() => {}));
                FirebaseFirestore.instance
                    .collection("Establishment")
                    .doc(match.estabelecimentoUid)
                    .collection("campo")
                    .doc(match.campoUid)
                    .collection("horarios")
                    .doc("info")
                    .collection(match.data.split(" ")[0])
                    .doc(match.timeUid)
                    .update({"Status": "livre"});
              })
        ],
      );
    }
  }

  Widget playerCard(DocumentSnapshot doc) {
    String positions = "";
    FirebaseFirestore.instance
        .collection('User')
        .doc(doc.id)
        .collection("position")
        .doc("position")
        .get()
        .then((position) => {
              if (position['GO'] == true) {positions += "GO "},
              if (position['ZG'] == true) {positions += "ZG "},
              if (position['LT'] == true) {positions += "LT "},
              if (position['MC'] == true) {positions += "MC "},
              if (position['AT'] == true) {positions += "AT "},
              if (positions == "") {positions = "Sem posições"},
            });

    return Card(
      child: Container(
        padding: EdgeInsets.only(right: 8.0, left: 8.0),
        color: Colors.lightGreen,
        width: 400.0,
        height: 80.0,
        child: Row(
          children: [
            Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.data()['nome'],
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Divider(),
                    Text(
                      "Posições: " + positions,
                      style: TextStyle(fontSize: 13.0),
                    )
                  ],
                )),
            Expanded(
                flex: 2,
                child: Container(
                  width: 30,
                  height: 60,
                  child: Icon(
                    Icons.delete,
                    size: 30.0,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180.0),
                    color: Colors.red,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> getUser() async {
    this.players = [];
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .collection('players')
        .get()
        .then((value) => value.docs.forEach((element) => {
              this.players.add(element.data()['matchUid']),
              print(element.data()['matchUid']),
            }));

    //return this.partidas;
  }

  void mensagem(String mensagem) {
    final snackBar = SnackBar(
      content: Text(mensagem),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getMatchData() async {
    await FirebaseFirestore.instance
        .collection('match')
        .doc(widget.matchId)
        .get()
        .then((value) => {
              match.nome = value['nome'],
              match.data = value['data'],
              match.preco = value['preco'],
              match.status = value['status'],
              match.campoUid = value['campoUid'],
              match.estabelecimentoUid = value['estabelecimentoUid'],
              match.userAdm = value['criador'],
              match.timeUid = value['timeUid']
            });

    setState(() {});
    print(match.toString());
  }
}
