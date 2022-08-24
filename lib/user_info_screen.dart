import 'package:chill/app_bar_title.dart';
import 'package:chill/authentication.dart';
import 'package:chill/custom_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'sign_in_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen(
      {Key? key, required User user, required List<String>? fileList})
      : _user = user,
        _fileList = fileList,
        super(key: key);

  final User _user;
  final List<String>? _fileList;

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late User _user;
  late List<String>? fileList;
  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    _user = widget._user;
    fileList = widget._fileList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(),
              _user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _user.photoURL!,
                          fit: BoxFit.fitHeight,
                          width: 20,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: CustomColors.firebaseGrey,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 8.0),
              Text(
                _user.displayName!,
                style: TextStyle(
                  color: CustomColors.firebaseYellow,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                '( ${_user.email!} )',
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 24.0),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(fileList![i],
                          style: TextStyle(color: Colors.white)),
                    );
                  },
                  itemCount: fileList!.length,
                ),
              ),
              SizedBox(height: 16.0),
              _isSigningOut
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Row(
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.redAccent,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isSigningOut = true;
                            });
                            await Authentication.signOut(context: context);
                            setState(() {
                              _isSigningOut = false;
                            });
                            Navigator.of(context)
                                .pushReplacement(_routeToSignInScreen());
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            List<String> aa =
                                await Authentication.listGoogleDriveFiles();
                            Future.delayed(Duration(seconds: 5))
                                .then((value) => setState(() {
                                      fileList = aa;
                                      print("AA");
                                    }));
                            // .then((value) => {
                            //   print("AA"),
                            //       setState(() {
                            //         fileList = value;
                            //       }),
                            //     });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              'Refresh',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
