import 'package:flutter/cupertino.dart';
import 'package:yapp/screens/login-registration/LoginPage.dart';
import 'package:yapp/screens/login-registration/RegisterPage.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {

  bool showLoginPage = true;


  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }


  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return Login(onTap: togglePages);
    }else{
      return Register(onTap: togglePages);
    }
  }
}
