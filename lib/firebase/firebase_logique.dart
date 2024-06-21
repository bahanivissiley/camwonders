//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'dart:math';
import 'package:camwonders/auth_pages/suite_inscription.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return credential.user;
    }catch (e) {
      return null;
    }
  }

  Future signInWithPhoneNumber(String phone_number, BuildContext context) async {
    await _auth.verifyPhoneNumber(
    phoneNumber: phone_number,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Le numero de telephone est invalide.')),
          );
        }
    },
    codeSent: (String verificationId, int? resendToken) {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Suite_Inscription(phoneNumber: phone_number, verificationId: verificationId,)));
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
    timeout: Duration(seconds: 30),
  );
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        return null;  // L'utilisateur a annulé la connexion.
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
      return null;
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }


String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}


  Future<UserCredential> signInWithApple() async {
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


    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }




  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    dataCache.clearAllCache();
    try {
      var cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    } catch (e) {
    }

    // Effacer les Shared Preferences
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
    }

    // Effacer les données Hive
    try {
      late Box<Wonder> box;
      box = Hive.box<Wonder>('favoris_wonder');
      await box.clear();
    } catch (e) {
    }
  }
}