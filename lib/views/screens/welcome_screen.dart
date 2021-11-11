import 'package:during_interview/custom_widget/custom_button.dart';
import 'package:during_interview/custom_widget/custom_text_field.dart';
import 'package:during_interview/views/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

enum MobileVerificationState {
  showMainWidget,
  showOtpWidget,
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  MobileVerificationState currentState = MobileVerificationState.showMainWidget;
  final phoneController = TextEditingController();

  final otpController = TextEditingController();
  bool showLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        SharedPreferences sharedPreference=await SharedPreferences.getInstance();
        sharedPreference.setBool("isLoggedIn", true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(initialChangeIndex: 1,),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      _scaffoldKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  getMainWidget(context) {
    return Column(
      children: [
        const Spacer(
          flex: 3,
        ),
        SizedBox(
          width: sizeWidth(context) / 1.2,
          child: const Center(
            child: Text(
              "Enter your phone number to sign in",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const Spacer(
          flex: 3,
        ),
        SizedBox(
          height: 50.0,
          width: sizeWidth(context) / 1.2,
          child: CustomTextFormField(
            controller: phoneController,
            hintText: "Enter Your Phone Number",
            isObscure: false,
            keyBoardType: TextInputType.name,
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        SizedBox(
          height: 50.0,
          width: sizeWidth(context) / 1.2,
          child: CustomButton(
            buttonColor: Colors.white,
            buttonText: "Next",
            textColor: Colors.black,
            onPress: () async {
              setState(() {
                showLoading = true;
              });

              await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCredential) async {
                  setState(() {
                    showLoading = false;
                  });
                  //signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (verificationFailed) async {
                  setState(() {
                    showLoading = false;
                  });
                  _scaffoldKey.currentState!.showSnackBar(SnackBar(
                      content: Text(verificationFailed.message.toString())));
                },
                codeSent: (verificationId, resendingToken) async {
                  setState(() {
                    showLoading = false;
                    currentState = MobileVerificationState.showOtpWidget;
                    this.verificationId = verificationId;
                  });
                },
                codeAutoRetrievalTimeout: (verificationId) async {},
              );
            },
          ),
        ),
        const Spacer(
          flex: 4,
        ),
        SizedBox(
          height: 50.0,
          width: sizeWidth(context) / 1.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: sizeWidth(context) * 0.35,
                child: const Divider(
                  color: Colors.black,
                  thickness: 1.0,
                ),
              ),
              Text(
                "OR",
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: sizeWidth(context) * 0.35,
                child: const Divider(
                  color: Colors.black,
                  thickness: 1.0,
                ),
              ),
            ],
          ),
        ),
        const Spacer(
          flex: 4,
        ),
        SizedBox(
          height: 50.0,
          width: sizeWidth(context) / 1.2,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            onPressed: () async {
              handleLoginWithGoogle();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 1,
                ),
                SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: Image.asset("assets/images/google.png")),
                const Spacer(
                  flex: 1,
                ),
                Text(
                  "Continue with google".toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                const Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        SizedBox(
          height: 50.0,
          width: sizeWidth(context) / 1.2,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            onPressed: () async {
              FirebaseService firebaseService = FirebaseService();
              try {
                await firebaseService.signInWithFacebook(context);
              } on FirebaseAuthException catch (e) {
                print(e.message);
              }
              // handleLoginWithFb();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 1,
                ),
                SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: Image.asset("assets/images/fb.png")),
                const Spacer(
                  flex: 1,
                ),
                Text(
                  "Continue with Facebook".toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.black),
                  // textAlign: TextAlign.center,
                ),
                const Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
        const Spacer(
          flex: 1,
        ),
        SizedBox(
          width: sizeWidth(context) / 1.1,
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: "By Tapping \"Next\" you agree to",
                style: TextStyle(color: Colors.grey),
                children: <TextSpan>[
                  TextSpan(
                    text: "Terms and Condition",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " and",
                  ),
                  TextSpan(
                    text: " Privacy Policy",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(
          flex: 1,
        )
      ],
    );
  }

  getOtpWidget(context) {
    return Column(
      children: [
        const Spacer(),
        TextField(
          controller: otpController,
          decoration: const InputDecoration(
            hintText: "Enter OTP",
          ),
        ),
        CustomButton(
          buttonText: "Verify".toUpperCase(),
          buttonColor: primaryColor,
          textColor: Colors.white,
          onPress: () async {
            PhoneAuthCredential phoneAuthCredential =
                PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: otpController.text);

            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
        ),
        const Spacer(),
      ],
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void handleLoginWithGoogle() async {
    final UserCredential user = await signInWithGoogle();
    // Here signInWithGoogle() is your defined function!
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(initialChangeIndex: 1,),
        ),
      );
    } else {
      // Something Wrong!
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: showLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : currentState == MobileVerificationState.showMainWidget
                ? getMainWidget(context)
                : getOtpWidget(context),
        padding: const EdgeInsets.all(16),
      ),
    ));
  }
}

class FirebaseService {
  Future<UserCredential> signInWithFacebook(context) async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    print("Login Result=>${loginResult.status}");

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }
}
