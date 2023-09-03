import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  Auth._();
  static final instance = Auth._();
  UserCredential? user;
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    user = await FirebaseAuth.instance.signInWithCredential(credential);
    if (user == null || user?.user == null) {
      return null;
    }
    ;

    final usersRef = db.collection('users');
    final userRef = usersRef.doc(user?.user?.uid);
    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      final userData = {
        'displayName': user?.user?.displayName,
        'avatar': user?.user?.photoURL,
        'email': user?.user?.email,
        'uid': user?.user?.uid
      };

      await userRef.set({...userData});
    }
    return user;
  }

  logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}
