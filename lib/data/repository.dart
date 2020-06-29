import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:save_the_earth/model/HelthData.dart';
import 'package:save_the_earth/model/User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User> signInWithGoogle() async {
  FirebaseUser firebaseUser = await _auth.currentUser();
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  if (firebaseUser != null) {
    return User(name: firebaseUser.displayName, email: firebaseUser.email, photoUrl: firebaseUser.photoUrl, userId: googleSignInAccount.id);
  }

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);

  firebaseUser = authResult.user;

  // Checking if email and name is null
  assert(firebaseUser.email != null);
  assert(firebaseUser.displayName != null);
  assert(firebaseUser.photoUrl != null);

  assert(!firebaseUser.isAnonymous);
  assert(await firebaseUser.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(firebaseUser.uid == currentUser.uid);

  return User(name: firebaseUser.displayName, email: firebaseUser.email, photoUrl: firebaseUser.photoUrl, userId: googleSignInAccount.id);
}

void signOutGoogle() async {
  await googleSignIn.signOut();
}

Future<HealthData> getFirecloudData(String userId) async {
  int lastSync = 0;
  int steps = 0;
  bool firstTime = true;
  DocumentSnapshot documentSnapshot = await Firestore.instance.collection('steps').document(userId).get();

  if (documentSnapshot.data != null) {
    lastSync = documentSnapshot.data["lastSync"];
    steps = documentSnapshot.data["steps"];
    firstTime = false;
  }

  return HealthData(lastSync: lastSync, steps: steps, firstTime: firstTime);
}

Future<void> updateFirecloudData(userId, HealthData healthData) async {
  await Firestore.instance.collection('steps').document(userId).setData({'steps': healthData.steps, 'lastSync': healthData.lastSync}, merge: true);
}
