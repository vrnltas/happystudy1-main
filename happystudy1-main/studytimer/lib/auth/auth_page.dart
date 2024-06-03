
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class AuthService{

  final _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('AuthService');

  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

    Future<User?> loginUserWithEmailAndPassword(
    String email,String password) async {
      try{
        final cred = await _auth.signInWithEmailAndPassword(
      email: email, password: password);
      return cred.user;
      }catch (e) {
        _logger.severe("Something went wrong");
      }
    return null;
  }

  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> signout() async{
    try{
      _auth.signOut();
    }catch(e) {
        _logger.severe("Something went wrong");
    }
  }

  
}

