import 'package:app/src/pages/profile/settings.dart';
import 'package:app/src/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  void launchSnackbar(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void signUp() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: usernameController.text, password: passwordController.text);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: usernameController.text, password: passwordController.text);

      launchSnackbar(AppLocalizations.of(context)!.createUserMessage);

      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsWidget(),
      ));
      usernameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        launchSnackbar(AppLocalizations.of(context)!.weakPasswordMessage);
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        launchSnackbar(AppLocalizations.of(context)!.emailAlreadyExistsMessage);
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(""),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: AppColors.font_black, //change your color here
          ),
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(100.0),
                        child: TextField(
                          controller: usernameController,
                          autofocus: false,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              prefixIcon: Icon(
                                MdiIcons.accountCircleOutline,
                                color: AppColors.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              labelText: AppLocalizations.of(context)!.email),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(100.0),
                        child: TextField(
                          controller: passwordController,
                          autofocus: false,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              prefixIcon: Icon(
                                MdiIcons.lockOutline,
                                color: AppColors.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              labelText: AppLocalizations.of(context)!.userPassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(100.0),
                        child: TextField(
                          controller: confirmPasswordController,
                          autofocus: false,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              prefixIcon: Icon(
                                MdiIcons.lockOutline,
                                color: AppColors.primary,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              labelText: AppLocalizations.of(context)!.confirmUserPassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: MaterialButton(
                height: 45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: loading
                    ? CircularProgressIndicator(
                        color: AppColors.white,
                      )
                    : Text(
                        AppLocalizations.of(context)!.signup,
                        style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                onPressed: () {
                  signUp();
                },
                splashColor: Colors.white,
              )),
            ]))));
  }
}

