// // import 'dart:io';
// // import 'package:device_info_plus/device_info_plus.dart';
// // import 'package:emerge_business/Authentication/forgotpassword.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:animate_do/animate_do.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart'
// //     as flutterSecureStorage;
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:lottie/lottie.dart';
// // import 'package:uuid/uuid.dart';

// // class LoginPage extends StatefulWidget {
// //   @override
// //   _LoginPageState createState() => _LoginPageState();
// // }

// // class _LoginPageState extends State<LoginPage> {
// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();
// //   final FocusNode _emailFocusNode = FocusNode();
// //   final FocusNode _passwordFocusNode = FocusNode();

// //   bool _isLoading = false;
// //   String? _error;
// //   bool _passwordVisible = false;

// //   Future<void> _login() async {
// //     final input = _emailController.text.trim();
// //     final password = _passwordController.text.trim();

// //     if (input.isEmpty || password.isEmpty) {
// //       setState(() {
// //         _error = 'Please enter both email/phone and password';
// //       });
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     try {
// //       String? email;

// //       // Basic check to see if input is an email
// //       final isEmail = RegExp(
// //         r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
// //       ).hasMatch(input);

// //       if (isEmail) {
// //         email = input;
// //       } else {
// //         // Try to find user with matching phone number
// //         final querySnapshot = await FirebaseFirestore.instance
// //             .collection('vendor')
// //             .where('phone', isEqualTo: input)
// //             .limit(1)
// //             .get();

// //         if (querySnapshot.docs.isEmpty) {
// //           setState(() {
// //             _error = 'No user found with this phone number or email';
// //           });
// //           return;
// //         }

// //         final userData = querySnapshot.docs.first.data();
// //         email = userData['email'];
// //       }

// //       // Check if user is already logged in somewhere else
// //       final userQuerySnapshot = await FirebaseFirestore.instance
// //           .collection('vendor')
// //           .where('email', isEqualTo: email)
// //           .limit(1)
// //           .get();

// //       if (userQuerySnapshot.docs.isNotEmpty) {
// //         final userData = userQuerySnapshot.docs.first.data();
// //         final bool isLoggedInElsewhere = userData['isLoggedIn'] ?? false;
// //         final String existingDeviceId = userData['deviceId'] ?? '';
// //         final String currentDeviceId = await _getDeviceId();

// //         if (isLoggedInElsewhere && existingDeviceId != currentDeviceId) {
// //           final shouldForceLogout = await _showForceLogoutDialog(context);
// //           if (!shouldForceLogout) {
// //             setState(() {
// //               _error = 'Login cancelled by user.';
// //             });
// //             return;
// //           }
// //           await FirebaseFirestore.instance
// //               .collection('vendor')
// //               .doc(userQuerySnapshot.docs.first.id)
// //               .update({
// //                 'isLoggedIn': true,
// //                 'deviceId': currentDeviceId,
// //                 'lastLoginAt': FieldValue.serverTimestamp(),
// //               });
// //         }
// //       }

// //       // Sign in with the resolved email
// //       UserCredential userCredential = await FirebaseAuth.instance
// //           .signInWithEmailAndPassword(email: email!, password: password);

// //       // Check email verification

// //       // Get user role
// //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
// //           .collection('vendor')
// //           .doc(userCredential.user!.uid)
// //           .get();

// //       if (!userDoc.exists) {
// //         await FirebaseAuth.instance.signOut();
// //         setState(() {
// //           _error = 'Account not found. Please contact support.';
// //         });
// //         return;
// //       }

// //       final fullUserData = userDoc.data() as Map<String, dynamic>;
// //       final String role = fullUserData['role'] ?? 'vendor';

// //       if (role == 'admin') {
// //         // Update user's login status and device ID
// //         final String deviceId = await _getDeviceId();
// //         await FirebaseFirestore.instance
// //             .collection('vendor')
// //             .doc(userCredential.user!.uid)
// //             .update({
// //               'isLoggedIn': true,
// //               'deviceId': deviceId,
// //               'lastLoginAt': FieldValue.serverTimestamp(),
// //               'emailVerified': true,
// //             });

// //         if (mounted) {
// //           Navigator.pushNamedAndRemoveUntil(
// //             context,
// //             '/admin',
// //             (route) => false,
// //           );
// //         }
// //         return;
// //       }

// //       // For non-admin users, check if user is active
// //       final isActive = fullUserData['isActive'] ?? false;

// //       if (!isActive) {
// //         await FirebaseAuth.instance.signOut();
// //         setState(() {
// //           _error = 'Your account has been disabled. Please contact support.';
// //         });
// //         return;
// //       }

// //       // Update user's login status and device ID
// //       final String deviceId = await _getDeviceId();
// //       await FirebaseFirestore.instance
// //           .collection('vendor')
// //           .doc(userCredential.user!.uid)
// //           .update({
// //             'isLoggedIn': true,
// //             'deviceId': deviceId,
// //             'lastLoginAt': FieldValue.serverTimestamp(),
// //             'emailVerified': true,
// //           });

// //       // Check if profile_status exists in users collection
// //       final userDoc1 = await FirebaseFirestore.instance
// //           .collection('vendor')
// //           .doc(userCredential.user!.uid)
// //           .get();

// //       String destination = '/'; // Default to home page
// //       if (!userDoc.exists || userDoc1.data()!['profile_status'] != true) {
// //         // If user document doesn't exist or profile_status is not true, navigate to profile page
// //         destination = '/';
// //       }

// //       // Success: Navigate to appropriate page
// //       if (mounted) {
// //         Navigator.pushNamedAndRemoveUntil(
// //           context,
// //           destination,
// //           (route) => false,
// //         );
// //       }
// //     } on FirebaseAuthException catch (e) {
// //       print('FirebaseAuthException code: ${e.code}');
// //       String errorMessage = 'An error occurred during sign in';

// //       switch (e.code) {
// //         case 'user-not-found':
// //           errorMessage = 'No user found with this email';
// //           break;
// //         case 'wrong-password':
// //           errorMessage = 'Incorrect password';
// //           break;
// //         case 'invalid-email':
// //           errorMessage = 'Invalid email address';
// //           break;
// //         case 'too-many-requests':
// //           errorMessage = 'Too many failed login attempts. Try again later';
// //           break;
// //         case 'invalid-credential':
// //           errorMessage =
// //               'Invalid credentials. Please check your email and password.';
// //           break;
// //         default:
// //           errorMessage = 'Authentication failed. (${e.code})';
// //       }

// //       setState(() {
// //         _error = errorMessage;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _error = e.toString();
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<bool> _showForceLogoutDialog(BuildContext context) async {
// //     return await showDialog<bool>(
// //           context: context,
// //           barrierDismissible: false, // Prevents dismissing by tapping outside
// //           builder: (context) => AlertDialog(
// //             title: const Text(
// //               'Force Logout',
// //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
// //             ),
// //             content: const Text(
// //               'This account is already logged in on another device. Do you want to log out from that device and continue?',
// //               style: TextStyle(fontSize: 16),
// //             ),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(
// //                 12,
// //               ), // Consistent corner radius
// //             ),
// //             backgroundColor: Theme.of(
// //               context,
// //             ).colorScheme.surface, // Theme-aware background
// //             actionsPadding: const EdgeInsets.symmetric(
// //               horizontal: 8,
// //               vertical: 8,
// //             ), // Standard padding
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context, false),
// //                 child: const Text('Cancel', style: TextStyle(fontSize: 16)),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () => Navigator.pop(context, true),
// //                 style: ElevatedButton.styleFrom(
// //                   minimumSize: const Size(100, 40), // Consistent button size
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                 ),
// //                 child: const Text('Continue', style: TextStyle(fontSize: 16)),
// //               ),
// //             ],
// //           ),
// //         ) ??
// //         false;
// //   }

// //   Future<void> _resendVerificationEmail() async {
// //     final input = _emailController.text.trim();
// //     if (input.isEmpty) {
// //       setState(() {
// //         _error = 'Please enter your email to resend verification';
// //       });
// //       return;
// //     }

// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     try {
// //       String? email;

// //       final isEmail = RegExp(
// //         r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
// //       ).hasMatch(input);

// //       if (isEmail) {
// //         email = input;
// //       } else {
// //         final querySnapshot = await FirebaseFirestore.instance
// //             .collection('vendor')
// //             .where('phone', isEqualTo: input)
// //             .limit(1)
// //             .get();

// //         if (querySnapshot.docs.isEmpty) {
// //           setState(() {
// //             _error = 'No user found with this phone number or email';
// //           });
// //           return;
// //         }

// //         final userData = querySnapshot.docs.first.data();
// //         email = userData['email'];
// //       }

// //       // Sign in to get the user
// //       await FirebaseAuth.instance
// //           .signInWithEmailAndPassword(
// //             email: email!,
// //             password: _passwordController.text.trim(),
// //           )
// //           .then((userCredential) async {
// //             if (!userCredential.user!.emailVerified) {
// //               await userCredential.user!.sendEmailVerification();
// //               setState(() {
// //                 _error =
// //                     'Verification email resent. Please check your inbox or spam folder.';
// //               });
// //               await FirebaseAuth.instance.signOut();
// //             }
// //           });
// //     } on FirebaseAuthException catch (e) {
// //       String errorMessage = 'Error resending verification email';
// //       if (e.code == 'user-not-found') {
// //         errorMessage = 'No user found with this email';
// //       } else if (e.code == 'wrong-password') {
// //         errorMessage = 'Incorrect password';
// //       }
// //       setState(() {
// //         _error = errorMessage;
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<String> _getDeviceId() async {
// //     try {
// //       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

// //       if (Platform.isAndroid) {
// //         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
// //         return androidInfo.id;
// //       } else if (Platform.isIOS) {
// //         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
// //         return iosInfo.identifierForVendor!;
// //       } else if (kIsWeb) {
// //         const storage = flutterSecureStorage.FlutterSecureStorage();
// //         String? deviceId = await storage.read(key: 'device_id');

// //         if (deviceId == null) {
// //           deviceId = Uuid().v4();
// //           await storage.write(key: 'device_id', value: deviceId);
// //         }

// //         return deviceId;
// //       }

// //       return 'unknown_device';
// //     } catch (e) {
// //       return DateTime.now().millisecondsSinceEpoch.toString();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     _emailFocusNode.dispose();
// //     _passwordFocusNode.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Stack(
// //         children: [
// //           SingleChildScrollView(
// //             child: Container(
// //               child: Column(
// //                 children: <Widget>[
// //                   Container(
// //                     height: 400,
// //                     decoration: BoxDecoration(
// //                       image: DecorationImage(
// //                         image: AssetImage('assets/images/background.png'),
// //                         fit: BoxFit.fill,
// //                       ),
// //                     ),
// //                     child: Stack(
// //                       children: <Widget>[
// //                         Positioned(
// //                           left: 30,
// //                           width: 80,
// //                           height: 200,
// //                           child: FadeInUp(
// //                             duration: Duration(seconds: 1),
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 image: DecorationImage(
// //                                   image: AssetImage(
// //                                     'assets/images/light-1.png',
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Positioned(
// //                           left: 140,
// //                           width: 80,
// //                           height: 150,
// //                           child: FadeInUp(
// //                             duration: Duration(milliseconds: 1200),
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 image: DecorationImage(
// //                                   image: AssetImage(
// //                                     'assets/images/light-2.png',
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Positioned(
// //                           right: 40,
// //                           top: 40,
// //                           width: 80,
// //                           height: 150,
// //                           child: FadeInUp(
// //                             duration: Duration(milliseconds: 1300),
// //                             child: Container(
// //                               decoration: BoxDecoration(
// //                                 image: DecorationImage(
// //                                   image: AssetImage('assets/images/clock.png'),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Positioned(
// //                           child: FadeInUp(
// //                             duration: Duration(milliseconds: 1600),
// //                             child: Container(
// //                               margin: EdgeInsets.only(top: 50),
// //                               child: Center(
// //                                 child: Text(
// //                                   "Login",
// //                                   style: GoogleFonts.poppins(
// //                                     color: Colors.white,
// //                                     fontSize: 40,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   Padding(
// //                     padding: EdgeInsets.all(30.0),
// //                     child: Column(
// //                       children: <Widget>[
// //                         FadeInUp(
// //                           duration: Duration(milliseconds: 1800),
// //                           child: Column(
// //                             children: <Widget>[
// //                               // Email or Phone Number TextField
// //                               Container(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 8.0,
// //                                   vertical: 4.0,
// //                                 ),
// //                                 child: TextField(
// //                                   controller: _emailController,
// //                                   focusNode: _emailFocusNode,
// //                                   textInputAction: TextInputAction.next,
// //                                   onSubmitted: (_) {
// //                                     FocusScope.of(
// //                                       context,
// //                                     ).requestFocus(_passwordFocusNode);
// //                                   },
// //                                   decoration: InputDecoration(
// //                                     hintText: "Email or Phone number",
// //                                     hintStyle: TextStyle(
// //                                       color: Colors.grey[700],
// //                                     ),
// //                                     border: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(143, 148, 251, 1),
// //                                       ),
// //                                     ),
// //                                     enabledBorder: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(
// //                                           143,
// //                                           148,
// //                                           251,
// //                                           0.5,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     focusedBorder: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(143, 148, 251, 1),
// //                                       ),
// //                                     ),
// //                                   ),
// //                                   keyboardType: TextInputType.emailAddress,
// //                                 ),
// //                               ),
// //                               SizedBox(height: 10),
// //                               // Password TextField
// //                               Container(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 8.0,
// //                                   vertical: 4.0,
// //                                 ),
// //                                 child: TextField(
// //                                   controller: _passwordController,
// //                                   focusNode: _passwordFocusNode,
// //                                   textInputAction: TextInputAction.done,
// //                                   obscureText: !_passwordVisible,
// //                                   decoration: InputDecoration(
// //                                     hintText: "Password",
// //                                     hintStyle: TextStyle(
// //                                       color: Colors.grey[700],
// //                                     ),
// //                                     border: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(143, 148, 251, 1),
// //                                       ),
// //                                     ),
// //                                     enabledBorder: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(
// //                                           143,
// //                                           148,
// //                                           251,
// //                                           0.5,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     focusedBorder: UnderlineInputBorder(
// //                                       borderSide: BorderSide(
// //                                         color: Color.fromRGBO(143, 148, 251, 1),
// //                                       ),
// //                                     ),
// //                                     suffixIcon: IconButton(
// //                                       icon: Icon(
// //                                         _passwordVisible
// //                                             ? Icons.visibility_off
// //                                             : Icons.visibility,
// //                                         color: Colors.grey[600],
// //                                       ),
// //                                       onPressed: () {
// //                                         setState(() {
// //                                           _passwordVisible = !_passwordVisible;
// //                                         });
// //                                       },
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         if (_error != null)
// //                           Padding(
// //                             padding: const EdgeInsets.symmetric(vertical: 10.0),
// //                             child: FadeInUp(
// //                               duration: Duration(milliseconds: 1800),
// //                               child: Container(
// //                                 padding: const EdgeInsets.all(12),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.red[50],
// //                                   borderRadius: BorderRadius.circular(8),
// //                                   border: Border.all(color: Colors.red[200]!),
// //                                 ),
// //                                 child: Row(
// //                                   children: [
// //                                     Icon(
// //                                       Icons.error_outline,
// //                                       color: Colors.red[700],
// //                                     ),
// //                                     const SizedBox(width: 8),
// //                                     Expanded(
// //                                       child: Text(
// //                                         _error!,
// //                                         style: TextStyle(
// //                                           color: Colors.red[700],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     if (_error!.contains(
// //                                       'Please verify your email',
// //                                     ))
// //                                       TextButton(
// //                                         onPressed: _resendVerificationEmail,
// //                                         child: Text(
// //                                           'Resend',
// //                                           style: TextStyle(
// //                                             color: Color.fromRGBO(
// //                                               143,
// //                                               148,
// //                                               251,
// //                                               1,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         SizedBox(height: 30),
// //                         FadeInUp(
// //                           duration: Duration(milliseconds: 1900),
// //                           child: GestureDetector(
// //                             onTap: _isLoading ? null : _login,
// //                             child: Container(
// //                               height: 50,
// //                               decoration: BoxDecoration(
// //                                 borderRadius: BorderRadius.circular(10),
// //                                 gradient: LinearGradient(
// //                                   colors: [
// //                                     Color(0xFF00A19A),
// //                                     Color(0x9900A19A),
// //                                   ],
// //                                 ),
// //                               ),
// //                               child: Center(
// //                                 child: Text(
// //                                   "Login",
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: FadeInUp(
// //                             duration: Duration(milliseconds: 2000),
// //                             child: TextButton(
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                     builder: (context) => ForgotPasswordPage(),
// //                                   ),
// //                                 );
// //                               },
// //                               child: Text(
// //                                 'Forgot Password',
// //                                 style: TextStyle(
// //                                   color: Color.fromRGBO(143, 148, 251, 1),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         FadeInUp(
// //                           duration: Duration(milliseconds: 2100),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               Text(
// //                                 "Don't have an account? ",
// //                                 style: TextStyle(color: Colors.black),
// //                               ),
// //                               TextButton(
// //                                 onPressed: () => Navigator.pushReplacementNamed(
// //                                   context,
// //                                   '/signup',
// //                                 ),
// //                                 child: Text(
// //                                   "Sign Up",
// //                                   style: TextStyle(
// //                                     color: Color.fromRGBO(143, 148, 251, 1),
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           if (_isLoading)
// //             Container(
// //               color: Colors.black54,
// //               child: Center(
// //                 child: SizedBox(
// //                   width: 100,
// //                   height: 100,
// //                   child: Lottie.asset('assets/animations/empty_gallery.json'),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:emerge_business/Authentication/forgotpassword.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutterSecureStorage;
// import 'package:uuid/uuid.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   final FocusNode _emailFocusNode = FocusNode();
//   final FocusNode _passwordFocusNode = FocusNode();

//   bool _isLoading = false;
//   bool _passwordVisible = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//     _animationController.forward();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });
//     _showLoadingDialog();

//     try {
//       final input = _emailController.text.trim();
//       final password = _passwordController.text.trim();
//       String? email;

//       final isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

//       if (isEmail) {
//         email = input;
//       } else {
//         final querySnapshot = await FirebaseFirestore.instance
//             .collection('vendor')
//             .where('phone', isEqualTo: input)
//             .limit(1)
//             .get();

//         if (querySnapshot.docs.isEmpty) {
//           throw Exception('No user found with this phone number or email');
//         }

//         final userData = querySnapshot.docs.first.data();
//         email = userData['email'];
//       }

//       final userQuerySnapshot = await FirebaseFirestore.instance
//           .collection('vendor')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (userQuerySnapshot.docs.isNotEmpty) {
//         final userData = userQuerySnapshot.docs.first.data();
//         final bool isLoggedInElsewhere = userData['isLoggedIn'] ?? false;
//         final String existingDeviceId = userData['deviceId'] ?? '';
//         final String currentDeviceId = await _getDeviceId();

//         if (isLoggedInElsewhere && existingDeviceId != currentDeviceId) {
//           final shouldForceLogout = await _showForceLogoutDialog(context);
//           if (!shouldForceLogout) {
//             throw Exception('Login cancelled by user.');
//           }
//           await FirebaseFirestore.instance
//               .collection('vendor')
//               .doc(userQuerySnapshot.docs.first.id)
//               .update({
//             'isLoggedIn': true,
//             'deviceId': currentDeviceId,
//             'lastLoginAt': FieldValue.serverTimestamp(),
//           });
//         }
//       }

//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email!, password: password);

//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('vendor')
//           .doc(userCredential.user!.uid)
//           .get();

//       if (!userDoc.exists) {
//         await FirebaseAuth.instance.signOut();
//         throw Exception('Account not found. Please contact support.');
//       }

//       final fullUserData = userDoc.data() as Map<String, dynamic>;
//       final String role = fullUserData['role'] ?? 'vendor';

//       if (role == 'admin') {
//         final String deviceId = await _getDeviceId();
//         await FirebaseFirestore.instance
//             .collection('vendor')
//             .doc(userCredential.user!.uid)
//             .update({
//           'isLoggedIn': true,
//           'deviceId': deviceId,
//           'lastLoginAt': FieldValue.serverTimestamp(),
//           'emailVerified': true,
//         });

//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
//         }
//         return;
//       }

//       final isActive = fullUserData['isActive'] ?? false;

//       if (!isActive) {
//         await FirebaseAuth.instance.signOut();
//         throw Exception('Your account has been disabled. Please contact support.');
//       }

//       final String deviceId = await _getDeviceId();
//       await FirebaseFirestore.instance
//           .collection('vendor')
//           .doc(userCredential.user!.uid)
//           .update({
//         'isLoggedIn': true,
//         'deviceId': deviceId,
//         'lastLoginAt': FieldValue.serverTimestamp(),
//         'emailVerified': true,
//       });

//       final userDoc1 = await FirebaseFirestore.instance
//           .collection('vendor')
//           .doc(userCredential.user!.uid)
//           .get();

//       String destination = '/';
//       if (!userDoc.exists || userDoc1.data()!['profile_status'] != true) {
//         destination = '/';
//       }

//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(context, destination, (route) => false);
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred during sign in';
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found with this email';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Incorrect password';
//           break;
//         case 'invalid-email':
//           errorMessage = 'Invalid email address';
//           break;
//         case 'too-many-requests':
//           errorMessage = 'Too many failed login attempts. Try again later';
//           break;
//         case 'invalid-credential':
//           errorMessage = 'Invalid credentials. Please check your email and password.';
//           break;
//         default:
//           errorMessage = 'Authentication failed. (${e.code})';
//       }
//       _showError(errorMessage);
//     } catch (e) {
//       _showError(e.toString());
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) Navigator.pop(context); // Close loading dialog
//     }
//   }

//   Future<void> _resendVerificationEmail() async {
//     if (_emailController.text.trim().isEmpty) {
//       _showError('Please enter your email to resend verification');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });
//     _showLoadingDialog();

//     try {
//       final input = _emailController.text.trim();
//       String? email;

//       final isEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(input);

//       if (isEmail) {
//         email = input;
//       } else {
//         final querySnapshot = await FirebaseFirestore.instance
//             .collection('vendor')
//             .where('phone', isEqualTo: input)
//             .limit(1)
//             .get();

//         if (querySnapshot.docs.isEmpty) {
//           throw Exception('No user found with this phone number or email');
//         }

//         final userData = querySnapshot.docs.first.data();
//         email = userData['email'];
//       }

//       await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//         email: email!,
//         password: _passwordController.text.trim(),
//       )
//           .then((userCredential) async {
//         if (!userCredential.user!.emailVerified) {
//           await userCredential.user!.sendEmailVerification();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                 'Verification email resent. Please check your inbox or spam folder.',
//               ),
//               backgroundColor: Colors.green,
//               action: SnackBarAction(
//                 label: 'OK',
//                 textColor: Colors.white,
//                 onPressed: () {},
//               ),
//             ),
//           );
//           await FirebaseAuth.instance.signOut();
//         }
//       });
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'Error resending verification email';
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Incorrect password';
//       }
//       _showError(errorMessage);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           action: message.contains('Please verify your email')
//               ? SnackBarAction(
//                   label: 'Resend',
//                   textColor: Colors.white,
//                   onPressed: _resendVerificationEmail,
//                 )
//               : null,
//         ),
//       );
//     }
//   }

//   void _showLoadingDialog() {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//   }

//   Future<bool> _showForceLogoutDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             title: const Text('Force Logout'),
//             content: const Text(
//               'This account is already logged in on another device. Do you want to log out from that device and continue?',
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Continue'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   Future<String> _getDeviceId() async {
//     try {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

//       if (Platform.isAndroid) {
//         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//         return androidInfo.id;
//       } else if (Platform.isIOS) {
//         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//         return iosInfo.identifierForVendor!;
//       } else if (kIsWeb) {
//         const storage = flutterSecureStorage.FlutterSecureStorage();
//         String? deviceId = await storage.read(key: 'device_id');

//         if (deviceId == null) {
//           deviceId = const Uuid().v4();
//           await storage.write(key: 'device_id', value: deviceId);
//         }

//         return deviceId;
//       }

//       return 'unknown_device';
//     } catch (e) {
//       return DateTime.now().millisecondsSinceEpoch.toString();
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _emailFocusNode.dispose();
//     _passwordFocusNode.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 400),
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Welcome Back',
//                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Sign in to continue',
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                               color: Colors.grey[600],
//                             ),
//                       ),
//                       const SizedBox(height: 32),
//                       TextFormField(
//                         controller: _emailController,
//                         focusNode: _emailFocusNode,
//                         textInputAction: TextInputAction.next,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Email or Phone Number',
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please enter your email or phone number';
//                           }
//                           return null;
//                         },
//                         onFieldSubmitted: (_) {
//                           FocusScope.of(context).requestFocus(_passwordFocusNode);
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _passwordController,
//                         focusNode: _passwordFocusNode,
//                         textInputAction: TextInputAction.done,
//                         obscureText: !_passwordVisible,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           border: const OutlineInputBorder(),
//                           prefixIcon: const Icon(Icons.lock),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _passwordVisible ? Icons.visibility_off : Icons.visibility,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _passwordVisible = !_passwordVisible;
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                         onFieldSubmitted: (_) => _login(),
//                       ),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const ForgotPasswordPage(),
//                               ),
//                             );
//                           },
//                           child: const Text('Forgot Password?'),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _login,
//                           style: ElevatedButton.styleFrom(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'Sign In',
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("Don't have an account? "),
//                           TextButton(
//                             onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
//                             child: const Text('Sign Up'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:emerge_business/Authentication/forgotpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    as flutterSecureStorage;
import 'package:uuid/uuid.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _passwordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog();

    try {
      final input = _emailController.text.trim();
      final password = _passwordController.text.trim();
      String? email;

      final isEmail = RegExp(
        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
      ).hasMatch(input);

      if (isEmail) {
        email = input;
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('vendor')
            .where('phone', isEqualTo: input)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('No user found with this phone number or email');
        }

        final userData = querySnapshot.docs.first.data();
        email = userData['email'];
      }

      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('vendor')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final userData = userQuerySnapshot.docs.first.data();
        final bool isLoggedInElsewhere = userData['isLoggedIn'] ?? false;
        final String existingDeviceId = userData['deviceId'] ?? '';
        final String currentDeviceId = await _getDeviceId();

        if (isLoggedInElsewhere && existingDeviceId != currentDeviceId) {
          final shouldForceLogout = await _showForceLogoutDialog(context);
          if (!shouldForceLogout) {
            throw Exception('Login cancelled by user.');
          }
          await FirebaseFirestore.instance
              .collection('vendor')
              .doc(userQuerySnapshot.docs.first.id)
              .update({
                'isLoggedIn': true,
                'deviceId': currentDeviceId,
                'lastLoginAt': FieldValue.serverTimestamp(),
              });
        }
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password);

      // Check verification status in vendor_profile
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('vendor_profile')
          .doc(userCredential.user!.uid)
          .get();

      if (!profileDoc.exists || profileDoc.data() == null) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Profile not found. Please complete your profile.');
      }

      final profileData = profileDoc.data() as Map<String, dynamic>;
      final bool isVerified = profileData['verification'] ?? false;

      if (!isVerified) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account is not verified. Please wait for admin approval.',
        );
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account not found. Please contact support.');
      }

      final fullUserData = userDoc.data() as Map<String, dynamic>;
      final String role = fullUserData['role'] ?? 'vendor';

      if (role == 'admin') {
        final String deviceId = await _getDeviceId();
        await FirebaseFirestore.instance
            .collection('vendor')
            .doc(userCredential.user!.uid)
            .update({
              'isLoggedIn': true,
              'deviceId': deviceId,
              'lastLoginAt': FieldValue.serverTimestamp(),
              'emailVerified': true,
            });

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin',
            (route) => false,
          );
        }
        return;
      }

      final isActive = fullUserData['isActive'] ?? false;

      if (!isActive) {
        await FirebaseAuth.instance.signOut();
        throw Exception(
          'Your account has been disabled. Please contact support.',
        );
      }

      final String deviceId = await _getDeviceId();
      await FirebaseFirestore.instance
          .collection('vendor')
          .doc(userCredential.user!.uid)
          .update({
            'isLoggedIn': true,
            'deviceId': deviceId,
            'lastLoginAt': FieldValue.serverTimestamp(),
            'emailVerified': true,
          });

      final userDoc1 = await FirebaseFirestore.instance
          .collection('vendor')
          .doc(userCredential.user!.uid)
          .get();

      String destination = '/';
      if (!userDoc.exists || userDoc1.data()!['profile_status'] != true) {
        destination = '/';
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          destination,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign in';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Try again later';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid credentials. Please check your email and password.';
          break;
        default:
          errorMessage = 'Authentication failed. (${e.code})';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (mounted) Navigator.pop(context); // Close loading dialog
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email to resend verification');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog();

    try {
      final input = _emailController.text.trim();
      String? email;

      final isEmail = RegExp(
        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
      ).hasMatch(input);

      if (isEmail) {
        email = input;
      } else {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('vendor')
            .where('phone', isEqualTo: input)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw Exception('No user found with this phone number or email');
        }

        final userData = querySnapshot.docs.first.data();
        email = userData['email'];
      }

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email!,
            password: _passwordController.text.trim(),
          )
          .then((userCredential) async {
            if (!userCredential.user!.emailVerified) {
              await userCredential.user!.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Verification email resent. Please check your inbox or spam folder.',
                  ),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
              await FirebaseAuth.instance.signOut();
            }
          });
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error resending verification email';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      }
      _showError(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (mounted) Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: message.contains('Please verify your email')
              ? SnackBarAction(
                  label: 'Resend',
                  textColor: Colors.white,
                  onPressed: _resendVerificationEmail,
                )
              : null,
        ),
      );
    }
  }

  void _showLoadingDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }
  }

  Future<bool> _showForceLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Force Logout'),
            content: const Text(
              'This account is already logged in on another device. Do you want to log out from that device and continue?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor!;
      } else if (kIsWeb) {
        const storage = flutterSecureStorage.FlutterSecureStorage();
        String? deviceId = await storage.read(key: 'device_id');

        if (deviceId == null) {
          deviceId = const Uuid().v4();
          await storage.write(key: 'device_id', value: deviceId);
        }

        return deviceId;
      }

      return 'unknown_device';
    } catch (e) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email or Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or phone number';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/signup',
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
