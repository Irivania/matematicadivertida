import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> loginWithEmail(String email, String password);
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<UserCredential?> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> _garantirInicializacaoGoogle() async {
    if (_googleSignInInitialized) return;

    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  @override
  Future<UserCredential?> loginWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      return await _auth.signInWithPopup(googleProvider);
    }

    await _garantirInicializacaoGoogle();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}