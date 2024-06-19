import 'package:flutter/material.dart';
import 'package:google_map/firebaseauth.dart';
import 'package:google_map/ui/profile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  final _forkey = GlobalKey<FormState>();
  final _forkey1 = GlobalKey<FormState>();

  @override
  void dispose() {
    otpController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Login",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MAKE YOUR EVERY DESTINATION CLOSER",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 100),
            Form(
              key: _forkey,
              child: TextFormField(
                controller: phoneNumberController,
                validator: (value) {
                  if (value!.length != 10) {
                    return "invalid phone number";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    prefixText: "+91",
                    hintText: "  enter your number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () {
                if (_forkey.currentState!.validate()) {
                  AuthService.sentOtp(
                      phone: phoneNumberController.text,
                      errorStep: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Error in sending otp",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black,
                          )),
                      nextStep: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("otp verification"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("6 digit otp"),
                                SizedBox(
                                  height: 10,
                                ),
                                Form(
                                  key: _forkey1,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: otpController,
                                    validator: (value) {
                                      if (value!.length != 6) {
                                        return "invalid otp number";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.phone),
                                        hintText: "enter otp",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    if (_forkey1.currentState!.validate()) {
                                      AuthService.loginWithOtp(
                                              otp: otpController.text)
                                          .then((value) {
                                        if (value == "Success") {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Profile(),
                                              ));
                                        } else {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              value,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.black,
                                          ));
                                        }
                                      });
                                    }
                                  },
                                  child: Text("Submit"))
                            ],
                          ),
                        );
                      });
                }
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Profile(),
                //     ));
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(400, 55),
                  backgroundColor: Colors.black),
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
