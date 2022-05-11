import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/user_input.dart';
import '../utils/http_util.dart';
import '../screens/admin/main.dart';
import '../screens/user/main.dart';
import './signup.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  LoginScreen({Key? key}) : super(key: key);

  Widget login(IconData icon) {
    return Container(
      height: 50,
      width: 115,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          TextButton(onPressed: () {}, child: const Text('Login')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            fit: BoxFit.fill,
            image: NetworkImage(
              'https://upload.wikimedia.org/wikipedia/commons/7/70/Example.png',
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 510,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 45),
                    userInput(
                        emailController, 'Email', TextInputType.emailAddress),
                    userInput(passwordController, 'Password',
                        TextInputType.visiblePassword,
                        isPassword: true),
                    Container(
                      height: 55,
                      padding:
                          const EdgeInsets.only(top: 5, left: 70, right: 70),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25))),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.indigo.shade800),
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            )
                                .then((userCredential) {
                              HttpUtil().uid = (userCredential.user?.uid) ?? '';
                              userCredential.user
                                  ?.getIdToken()
                                  .then((idToken) async {
                                HttpUtil().login(idToken);
                              });
                            });
                            HttpUtil().isAdmin()
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => AdminScreen()))
                                : Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => UserScreen()));
                          } on FirebaseAuthException catch (e) {
                            print(e);
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text('Forgot password ?'),
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 0, color: Colors.white),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Text('Don\'t have an account yet ? ', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => SignUpScreen()));
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
