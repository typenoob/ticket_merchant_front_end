import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('注册'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          const BackButtonWidget(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                const IconButton(icon: Icon(Icons.person), onPressed: null),
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(right: 20, left: 10),
                        child: const TextField(
                          decoration: InputDecoration(hintText: 'Username'),
                        )))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                const IconButton(icon: Icon(Icons.lock), onPressed: null),
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(right: 20, left: 10),
                        child: TextField(
                          controller: _passwordController,
                          decoration:
                              const InputDecoration(hintText: 'Password'),
                        )))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                const IconButton(icon: Icon(Icons.mail), onPressed: null),
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(right: 20, left: 10),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(hintText: 'Email'),
                        )))
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                const Radio(value: null, groupValue: null, onChanged: null),
                RichText(
                    text: const TextSpan(
                        text: 'I have accepted the',
                        style: TextStyle(color: Colors.black),
                        children: [
                      TextSpan(
                          text: 'Terms & Condition',
                          style: TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold))
                    ]))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text);
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF00a79B))),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Positioned(
          child: Stack(
        children: <Widget>[
          Positioned(
              top: 20,
              child: Row(
                children: <Widget>[
                  IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  const Text(
                    'Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              )),
          const Positioned(
            bottom: 20,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Create New Account',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          )
        ],
      )),
    );
  }
}
