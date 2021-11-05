import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:hexcolor/hexcolor.dart';

class TimePage extends StatefulWidget {
  final String campoId;

  const TimePage({Key key, this.campoId}) : super(key: key);

  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final precoController = new TextEditingController();
  DateTime dateTime = DateTime.now();
  String establishmentUid = FirebaseAuth.instance.currentUser.uid;
  String dia = DateTime.now().day.toString() +"-" +DateTime.now().month.toString() + "-" +DateTime.now().year.toString();
  String hora = DateTime.now().hour.toString()+":"+DateTime.now().minute.toString();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Horários"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'd MMM, yyyy',
              initialValue: DateTime.now().toString(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              icon: Icon(Icons.event),
              dateLabelText: 'Data',
              timeLabelText: "Hora",
              selectableDayPredicate: (date) {
                return true;
              },
              onChanged: (val) => {
                dateTime = DateTime.parse(val),
                dia = dateTime.day.toString() +"-" +dateTime.month.toString() + "-" +dateTime.year.toString(),
                hora = dateTime.hour.toString()+":"+dateTime.minute.toString(),
                setState(() => {}),
              },
              validator: (val) {
                print(val);
                return null;
              },
              onSaved: (val) => print(val),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                new Flexible(
                  flex: 7,
                  child: TextField(
                    controller: precoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Preço",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                new Flexible(
                    flex: 3,
                    child: RaisedButton(
                      color: Colors.black,
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection("Establishment")
                            .doc(establishmentUid)
                            .collection("campo")
                            .doc(widget.campoId)
                            .collection("horarios")
                            .doc("info")
                            .collection(dia)
                            .doc()
                            .set({
                          "dia": dia,
                          "hora": hora,
                          "preco": precoController.text,
                          "Status": "livre"
                        });
                      },
                    )),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
            height: 5.0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Establishment")
                      .doc(establishmentUid)
                      .collection("campo")
                      .doc(widget.campoId)
                      .collection("horarios")
                      .doc("info")
                      .collection(dia)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return LinearProgressIndicator();
                        break;
                      default:
                        return ListView(

                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: snapshot.data.docs
                              .map<Widget>((DocumentSnapshot doc) {
                            return timeCard(doc.data()['dia'], doc.data()['hora'], doc.data()['preco'], doc.data()['Status'],);

                          }).toList(),
                        );
                    }
                  }

              ),
            )
          )

        ],
      ),
    );
  }

  Widget timeCard(String dia, String hora, String preco, String status) {
    MaterialColor cor;
    if(status == "livre"){
      cor = Colors.lightGreen;
    }else if(status == "pendente"){
      cor = Colors.yellow;
    }else{
      cor = Colors.red;
    }


    return Card(
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    color: cor,
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            dia.replaceAll("-", "/"),
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            "Horario: $hora",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            "Valor: R\$ $preco",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Text(
                            "Status: $status",
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
}
