import 'package:app/core/theme/ngen_theme.dart';
import 'package:app/src/pages/profile/login/auth_navigation.dart';
import 'package:app/src/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void launchSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _passwordMismatchMessage(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'es' ? 'Las contraseñas no coinciden' : 'Passwords do not match';
  }

  Future<void> signUp() async {
    final email = usernameController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (email.isEmpty) {
      launchSnackbar(AppLocalizations.of(context)!.emailRequired);
      return;
    }
    if (password != confirm) {
      launchSnackbar(_passwordMismatchMessage(context));
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        final credential = EmailAuthProvider.credential(email: email, password: password);
        await user.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }

      if (!mounted) return;
      launchSnackbar(AppLocalizations.of(context)!.createUserMessage);
      closeAuthFlow(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'weak-password') {
        launchSnackbar(AppLocalizations.of(context)!.weakPasswordMessage);
      } else if (e.code == 'email-already-in-use') {
        launchSnackbar(AppLocalizations.of(context)!.emailAlreadyExistsMessage);
      } else if (e.code == 'invalid-email') {
        launchSnackbar(AppLocalizations.of(context)!.emailRequired);
      } else {
        launchSnackbar(e.message ?? e.code);
      }
    } catch (e) {
      if (mounted) launchSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: SvgPicture.asset('assets/images/logo.svg'),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.userCreate,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                _authField(
                  controller: usernameController,
                  icon: MdiIcons.accountCircleOutline,
                  label: AppLocalizations.of(context)!.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _authField(
                  controller: passwordController,
                  icon: MdiIcons.lockOutline,
                  label: AppLocalizations.of(context)!.userPassword,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _authField(
                  controller: confirmPasswordController,
                  icon: MdiIcons.lockCheckOutline,
                  label: AppLocalizations.of(context)!.confirmUserPassword,
                  obscure: true,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : signUp,
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(AppLocalizations.of(context)!.signup),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _authField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enableSuggestions: !obscure,
        autocorrect: false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
        ),
      ),
    );
  }
}
