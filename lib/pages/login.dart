import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_vault/widgets/button.dart';
import 'package:secure_vault/widgets/icon-button.dart';
import 'package:local_auth/local_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _passwordbox = Hive.box('passwordbox');
  // List<int> password = [1,2,3,4];
  List<dynamic> epass = [];
  void _fingerprint(){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
            )
          ),
          child: Center(child: Text("Fingerprint coming soon",style: TextStyle(color: Colors.deepPurple),)),
        );
      },
    );
  }

  void _confirmpassword(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Password"),
          content: Text("Are you sure?"),
          actions: [
            GestureDetector(
              onTap: () {
                _passwordbox.put(1, epass.join());
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Password set"),
                    duration: Duration(seconds: 3),
                  )
                );
              },
              child: MyIconButton(height: 85, width: 85, color: Colors.green, radius: 12, icon: Icons.check, iconcolor: Colors.white, size: 20)),
            GestureDetector(
                    onTap: () {
                      setState(() {
                        epass.clear();
                        Navigator.pop(context);
                      });
                    },
                    child: MyIconButton(height: 85, width: 85, color: Colors.red, radius: 12, icon: Icons.cancel, iconcolor: Colors.white, size: 20)),
          ],
        );
      },
    );
  }

  final LocalAuthentication auth = LocalAuthentication();
  Future<void> _authenticatewithbiometrics()async{
    try{
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock SecureVault',
        biometricOnly: true
        );
        if (didAuthenticate && mounted){
          Navigator.pushReplacementNamed(context, '/home');
        }
    }catch (e){
      debugPrint('Error using biometrics: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:  const Color.fromARGB(255, 36, 29, 45),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color:   Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(150),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple,
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 0)
                    )
                  ]
                ),
                child: Icon(Icons.lock_outline,size: 70,),
              ),
              SizedBox(height: 20,),
              Text(_passwordbox.isNotEmpty ? "SecureVault": "New Password", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text("Enter you 4-digit Master PIN",style: TextStyle(fontSize: 17),),
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 20, 70, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.circle,color: epass.isNotEmpty ? Colors.deepPurple:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5),),
                    Icon(Icons.circle,color: epass.length >= 2 ? Colors.deepPurple:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5),),
                    Icon(Icons.circle,color: epass.length >= 3 ? Colors.deepPurple:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5),),
                    Icon(Icons.circle,color: epass.length == 4 ? Colors.deepPurple:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5),),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(1);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "1")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(2);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "2")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(3);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "3")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(4);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "4")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(5);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "5")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(6);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "6")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(7);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "7")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(8);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "8")),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(9);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                              print("Password list:$epass");
                              print("Password: $epass.join()");
                              print("Real password: $_passwordbox.get(1)");
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "9")),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (epass.isNotEmpty) {
                            setState(() {
                              epass.removeLast();
                            });
                          }
                        },
                        child: MyIconButton(height: 85, width: 85, color:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, icon: Icons.backspace, iconcolor: Colors.deepPurple, size: 30)),
                      GestureDetector(
                        onTap: () {
                          if (epass.length <= 3) {
                            setState(() {
                              epass.add(0);
                            });
                          }
                          if (_passwordbox.isNotEmpty) {
                            if(epass.join() == _passwordbox.get(1)){
                              Navigator.pushReplacementNamed(context, '/home');
                            }else if(epass.length == 4){
                              epass.clear();
                            }
                          }else if(epass.length == 4){
                              _confirmpassword();
                            }
                        },
                        child: Button(height: 85, width: 85, color: const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, text: "0")),
                  GestureDetector(
                    onTap: () {
                      _authenticatewithbiometrics();
                    },
                    child: MyIconButton(height: 85, width: 85, color:  const Color.fromARGB(255, 65, 65, 66).withOpacity(0.5), radius: 70, icon: Icons.fingerprint, iconcolor: Colors.deepPurple, size: 50)),
                    ],
                  ),


                ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}