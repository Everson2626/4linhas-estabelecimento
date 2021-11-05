import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projeto_empresa/service/firebaseService.dart';
import 'package:projeto_empresa/ui/autenticacao/Maps_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/estabelecimento/Create_Establishment.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/estabelecimento/Establishment_List_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/autenticacao/Cadastro_Page.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/campo/Create_Campo.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/partida/Create_Match.dart';
import 'file:///C:/Users/Pichau/AndroidStudioProjects/projeto_empresa/lib/ui/autenticacao/Login_Page.dart';
import 'package:projeto_empresa/ui/home_page.dart';
import 'package:projeto_empresa/ui/partida/Details_Match.dart';
import 'package:projeto_empresa/ui/user/Edit_User_Page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      Provider<FirebaseService>(
        create: (_) => FirebaseService(FirebaseAuth.instance),
      ),
      StreamProvider(
        create: (context) => context.read<FirebaseService>().authStateChanges,
      )
    ],
    child: MaterialApp(
      initialRoute: '/',
      routes: {
        '/login_page': (context) => LoginPage(),
        '/cadastro_page': (context) => CadastroPage(),
        '/home_page': (context) => HomePlayer(),
        '/create_match': (context) => CreateMatchPage(),
        '/establishment_list': (context) => EstablishmentListPage(),
        '/create_establishment': (context) => CreateEstablishment(),
        '/create_list_establishment': (context) => CreateEstablishment(),
        '/create_campo': (context) => CreateCampo(),
        '/details_match': (context) => DetailsMatch(),
        '/edit_user_page': (context) => UserEditPage(),
        '/maps_page': (context) => MapsPage(),
      },
      title: "4 Linhas",
      home: AuthenticationWrapper(),
    ),
  ));
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomePlayer();
    }
    return LoginPage();
  }
}
