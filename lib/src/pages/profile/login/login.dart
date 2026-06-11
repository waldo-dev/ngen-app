import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;

import 'package:app/core/theme/ngen_theme.dart';
import 'package:app/src/pages/profile/login/auth_navigation.dart';
import 'package:app/src/pages/profile/login/recover_password.dart';
import 'package:app/src/pages/profile/login/sign_up.dart';
import 'package:app/src/pages/profile/settings.dart';
import 'package:app/src/util/colors.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
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

  void login() async {
    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: usernameController.text, password: passwordController.text);
      launchSnackbar(AppLocalizations.of(context)!.loginSuccessful);
      closeAuthFlow(context, true);
      usernameController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        launchSnackbar(AppLocalizations.of(context)!.noUserWithThisEmailMessage);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        launchSnackbar(AppLocalizations.of(context)!.wrongPasswordMessage);
        print('Wrong password provided for that user.');
      }
    }

    setState(() {
      loading = false;
    });
  }

  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsWidget(),
      ));
    } catch (e) {
      print(e);
    }
  }

  void signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

    try {
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsWidget(),
      ));
    } catch (e) {
      print(e);

      await FacebookAuth.instance.logOut();
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    try {
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsWidget(),
      ));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(''),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: NgenTheme.loginBackground(),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                alignment: Alignment.center,
                height: 140,
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
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
              Container(
                  padding: EdgeInsets.only(top: 0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.forgotPassword,
                        style: TextStyle(color: AppColors.font_bold, fontSize: 12),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                          textStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () {
                          pushAuthScreen(context, RecoverPasswordScreen());
                        },
                        child: Text(AppLocalizations.of(context)!.recoverPassword),
                      ),
                    ],
                  )),
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
                        AppLocalizations.of(context)!.login,
                        style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                onPressed: () {
                  login();
                },
                splashColor: Colors.white,
              )),
              Container(
                  padding: EdgeInsets.only(top: 0),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                          textStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () {
                          pushAuthScreen(context, const SignUpScreen());
                        },
                        child: Text(AppLocalizations.of(context)!.userCreate),
                      ),
                    ],
                  )),
              SizedBox(
                height: 50,
              ),
              Container(
                  padding: EdgeInsets.only(top: 0),
                  alignment: Alignment.center,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Visibility(
                      visible: Platform.isIOS,
                      child: Container(
                          width: 50,
                          padding: EdgeInsets.zero,
                          child: MaterialButton(
                            onPressed: () {
                              signInWithApple();
                            },
                            elevation: 4,
                            splashColor: AppColors.white,
                            color: Colors.black,
                            textColor: Colors.white,
                            child: Icon(
                              MdiIcons.apple,
                              color: AppColors.white,
                              size: 38,
                            ),
                            padding: EdgeInsets.only(top: 6, bottom: 10, left: 6, right: 10),
                            shape: CircleBorder(),
                          )),
                    ),
                    Visibility(
                      visible: Platform.isIOS,
                      child: SizedBox(
                        width: 20,
                      ),
                    ),
                    Container(
                        width: 50,
                        padding: EdgeInsets.zero,
                        child: MaterialButton(
                          onPressed: () {
                            signInWithGoogle();
                          },
                          elevation: 4,
                          splashColor: AppColors.white,
                          color: Color.fromARGB(255, 219, 68, 55),
                          textColor: Colors.white,
                          child: Icon(
                            MdiIcons.google,
                            color: AppColors.white,
                            size: 40,
                          ),
                          padding: EdgeInsets.all(4),
                          shape: CircleBorder(),
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                        width: 50,
                        padding: EdgeInsets.zero,
                        child: MaterialButton(
                          onPressed: () {
                            signInWithFacebook();
                          },
                          elevation: 4,
                          splashColor: AppColors.white,
                          color: Color.fromARGB(255, 60, 90, 153),
                          textColor: Colors.white,
                          child: Icon(
                            MdiIcons.facebook,
                            color: AppColors.white,
                            size: 40,
                          ),
                          padding: EdgeInsets.all(4),
                          shape: CircleBorder(),
                        )),
                  ])),
            ])),
          ),
        ),
    );
  }
}

