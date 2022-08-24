import 'package:chill/google_http_client.dart';
import 'package:chill/user_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:googleapis/drive/v3.dart' as drive;

final GoogleSignIn googleSignIn =
    GoogleSignIn(scopes: [drive.DriveApi.driveScope]);

class Authentication {
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    // if (user != null) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (context) => UserInfoScreen(
    //         user: user,
    //         fileList: [],
    //       ),
    //     ),
    //   );
    // }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      authProvider.addScope(drive.DriveApi.driveScope);

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static Future<List<String>> listGoogleDriveFiles() async {
    List<String> driveFileList = [];
    var client = GoogleAuthClient(await googleSignIn.currentUser!.authHeaders);
    var drive2 = drive.DriveApi(client);

    //From Shared Drive
    drive2.drives.list().then(
          (value)  {
              for (var i = 0; i < value.drives!.length; i++) {
                driveFileList
                    .add("Share Drive - ${value.drives![i].id}");
                print("${value.drives![i].id}");
              }
          },
        );



    //From My Drive
    drive2.files
        .list(
         //q: "'root' in parents and trashed=false and (mimeType = 'video/mp4' or mimeType = 'application/vnd.google-apps.folder')",
        q: "'0AKBim_WgextGUk9PVA' in parents and trashed=false and (mimeType = 'video/mp4' or mimeType = 'application/vnd.google-apps.folder')",
        supportsAllDrives: true,
        supportsTeamDrives: false,
        includeItemsFromAllDrives: true,
        orderBy: 'name',
         pageSize: 1000
    )
        .then((value) {
      drive.FileList list = value;
      for (var i = 0; i < list.files!.length; i++) {
        print(list.files![i].id);
        driveFileList
            .add("My - ${list.files![i].name} ${list.files![i].id}");
      }
    });
    print("AA 1");
    return Future.value(driveFileList);
  }
}
