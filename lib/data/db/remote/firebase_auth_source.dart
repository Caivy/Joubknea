import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:joubknea/data/db/remote/response.dart';

import '../../provider/user_provider.dart';

class FirebaseAuthSource {
  FirebaseAuth instance = FirebaseAuth.instance;
  
  Future<Response<UserCredential>> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await instance.signInWithEmailAndPassword(
          email: email, password: password);
      return Response.success(userCredential);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future<Response<UserCredential>> register(String email, String password) async {
    try {
      UserCredential userCredential = await instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return Response.success(userCredential);
    } catch (e) {
      return Response.error(
          ((e as FirebaseException).message ?? e.toString()));
    }
  }

  Future verifyNumber(BuildContext context, String phone) async {
     UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      instance.verifyPhoneNumber(phoneNumber: phone, 
      verificationCompleted: (PhoneAuthCredential credential) async {
         await instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int resendToken) {
        userProvider.veriID(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print(e.messages);
    }
  }
}
