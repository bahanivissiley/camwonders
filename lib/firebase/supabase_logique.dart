import 'dart:convert';
import 'dart:math';
import 'package:camwonders/auth_pages/suite_inscription.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _supabase.auth.currentUser;

  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  Future<void> signInWithPhoneNumber(String phoneNumber, BuildContext context) async {
    try {
      final response = await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => Suite_Inscription(phoneNumber: phoneNumber),
          ),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      const webClientId = '573150666152-hotru9egif0el5dgbueam9q6p16pig17.apps.googleusercontent.com';

      const iosClientId = '573150666152-cod0vnbem2ihbngdhi67r8m3vllas5iu.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return googleUser;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur : $e");
      }
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

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        nonce: nonce,
      );

      return appleCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur : $e");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _googleSignIn.signOut();
    dataCache.clearAllCache();

    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la suppression du cache : $e");
      }
    }

    // Effacer les Shared Preferences
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la suppression du cache : $e");
      }
    }

    // Effacer les données Hive
    try {
      late Box<Wonder> box;
      box = Hive.box<Wonder>('favoris_wonder');
      await box.clear();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la suppression des données Hive : $e");
      }
    }
  }
}