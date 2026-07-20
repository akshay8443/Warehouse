import 'package:Lisofy/resources/app_theme.dart';
// import 'dart:convert';
// import 'package:Lisofy/Warehouse/User/getuserlocation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'add_warehouse.dart';
// class PartnerRegistrationScreen extends StatefulWidget {
//   final String phone;
//   const PartnerRegistrationScreen({super.key, required this.phone});
//   @override
//   State<PartnerRegistrationScreen> createState() =>
//       _PartnerRegistrationScreenState();
// }
//
// class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     Future<bool> showExitDialog(BuildContext context) {
//       return showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Exit"),
//           content: const Text("Do you want to exit the app?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text("No"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text("Yes"),
//             ),
//           ],
//         ),
//       ).then((value) => value ?? false);
//     }
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;
//         showExitDialog(context).then((exit) {
//           if (exit && context.mounted) {
//             Navigator.of(context).pop(result);
//           }
//         });
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Container(
//               color: AppTheme.primary,
//               width: double.infinity,
//               height: double.infinity,
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     Container(
//                       color: AppTheme.primary,
//                       height: screenHeight * 0.2,
//                       child: Stack(
//                         children: [
//                           Positioned(
//                             right: 0,
//                             left: 0,
//                             child: Image.asset(
//                               'assets/images/image1.png',
//                               height: screenHeight * 0.2,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(
//                               top: screenHeight * 0.015,
//                               left: screenWidth * 0.03,
//                             ),
//                             child: Column(
//                               children: [
//                                 Align(
//                                   alignment: Alignment.topLeft,
//                                   child: IconButton(
//                                     icon: const Icon(Icons.arrow_back_ios_sharp,
//                                         color: Colors.white),
//                                     onPressed: () {
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // White bottom section
//                     Expanded(
//                       child: Container(
//                         margin: EdgeInsets.only(right: screenWidth * 0.005),
//                         decoration:  BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: const Radius.circular(0),
//                             topRight: Radius.circular(screenWidth*0.1),
//                           ),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.all(
//                               screenWidth * 0.1),
//                           child: SingleChildScrollView(
//                             child: Form(
//                               key: _formKey,
//                               child: Column(
//                                 children: [
//                                    SizedBox(height: screenHeight*0.07),
//                                   SizedBox(
//                                     height: screenHeight*0.08,
//                                     child: TextFormField(
//                                       controller: _firstNameController,
//                                       keyboardType: TextInputType
//                                           .name,
//                                       maxLength:
//                                           30,
//                                       decoration: const InputDecoration(
//                                         labelText: 'First Name',
//                                         labelStyle:
//                                             TextStyle(color: Colors.black),
//                                         hintText: 'Enter your first name here',
//                                         hintStyle:
//                                             TextStyle(color: Colors.grey),
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.blueGrey),
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderSide:
//                                               BorderSide(color: Colors.grey),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.blueGrey),
//                                         ),
//                                       ),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'First Name is required';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ),
//                                    SizedBox( height: screenHeight*0.02,),
//                                   SizedBox(
//                                     height: screenHeight*0.08,
//                                     child: TextFormField(
//                                       controller: _lastNameController,
//                                       keyboardType: TextInputType
//                                           .name, // Set input type to name
//                                       maxLength:
//                                           30,
//                                       decoration: const InputDecoration(
//                                         labelText: 'Last Name',
//                                         labelStyle:
//                                             TextStyle(color: Colors.black),
//                                         hintText: 'Enter your last name here',
//                                         hintStyle:
//                                             TextStyle(color: Colors.grey),
//                                         border: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.blueGrey),
//                                         ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderSide:
//                                               BorderSide(color: Colors.grey),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                               color: Colors.blueGrey),
//                                         ),
//                                       ),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Last Name is required';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ),
//                                    SizedBox(height: screenHeight*0.07,),
//                                   SizedBox(
//                                     height: screenHeight*0.06,
//                                     child: ElevatedButton(
//                                       onPressed: () async {
//                                         if (_formKey.currentState!.validate()) {
//                                           String name = _firstNameController
//                                               .text
//                                               .trim()
//                                               .toString();
//                                           String urlName = Uri.encodeComponent(name);
//                                           //String apiUrl = "https://xpacesphere.com/api/Register/UPDRegistrDetails?mobile=${widget.phone} &Name=$name";
//                                           String apiUrl = "http://65.2.82.196:8080/api/v1/users?mobile=${widget.phone}&Name=$urlName";
//                                           try {
//                                             final response = await http
//                                                 .put(Uri.parse(apiUrl));
//                                             if (!context.mounted) return;
//                                             if (response.statusCode == 200) {
//                                               final responseData =
//                                                   jsonDecode(response.body);
//                                               if (responseData["status"] ==
//                                                   200) {
//                                                 SharedPreferences prefs =
//                                                     await SharedPreferences
//                                                         .getInstance();
//                                                 prefs.setString("name", name);
//                                                 prefs.setString(
//                                                     "mobile", widget.phone);
//                                                 if (!context.mounted) return;
//                                                 Navigator.pushAndRemoveUntil(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           const GetUserLocation()),
//                                                   (Route<dynamic> route) =>
//                                                       false,
//                                                 );
//                                               } else {
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(
//                                                   SnackBar(
//                                                       content: Text(
//                                                           "Error: ${responseData["message"]}")),
//                                                 );
//                                               }
//                                             } else {
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                     content: Text(
//                                                         "Server error. Please try again.")),
//                                               );
//                                             }
//                                           } catch (e) {
//                                             ScaffoldMessenger.of(context)
//                                                 .showSnackBar(
//                                               SnackBar(
//                                                   content: Text(
//                                                       "Failed to connect: $e")),
//                                             );
//                                           }
//                                         }
//                                       },
//                                       // onPressed: () async {
//                                       //   if (_formKey.currentState!.validate()) {
//                                       //     String name = _firstNameController.text.trim();
//                                       //     String urlName = Uri.encodeComponent(name); // name encode करना जरूरी है
//                                       //     String apiUrl = "http://65.2.82.196:8080/api/v1/users?mobile=${widget.phone}&Name=$urlName";
//                                       //
//                                       //     try {
//                                       //       final response = await http.put(Uri.parse(apiUrl));
//                                       //       if (!context.mounted) return;
//                                       //
//                                       //       if (response.statusCode == 200 || response.statusCode == 201) {
//                                       //         final responseData = jsonDecode(response.body);
//                                       //
//                                       //         if (responseData["status"] == 200 || responseData["success"] == true) {
//                                       //           SharedPreferences prefs = await SharedPreferences.getInstance();
//                                       //           prefs.setString("name", name);
//                                       //           prefs.setString("mobile", widget.phone);
//                                       //
//                                       //           Navigator.pushAndRemoveUntil(
//                                       //             context,
//                                       //             MaterialPageRoute(builder: (context) => const AddWareHouse()), // 👈 next page
//                                       //                 (Route<dynamic> route) => false,
//                                       //           );
//                                       //         } else {
//                                       //           ScaffoldMessenger.of(context).showSnackBar(
//                                       //             SnackBar(content: Text("Error: ${responseData["message"] ?? "Unknown error"}")),
//                                       //           );
//                                       //         }
//                                       //       } else {
//                                       //         ScaffoldMessenger.of(context).showSnackBar(
//                                       //           const SnackBar(content: Text("Server error. Please try again.")),
//                                       //         );
//                                       //       }
//                                       //     } catch (e) {
//                                       //       ScaffoldMessenger.of(context).showSnackBar(
//                                       //         SnackBar(content: Text("Failed to connect: $e")),
//                                       //       );
//                                       //     }
//                                       //   }
//                                       // },
//                                       style: ElevatedButton.styleFrom(
//                                         foregroundColor: Colors.white,
//                                         backgroundColor: AppTheme.primary,
//                                         minimumSize:
//                                              Size(double.infinity,  screenHeight*0.06,),
//                                       ),
//                                       child: const Text('Confirm'),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:Lisofy/Warehouse/User/getuserlocation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PartnerRegistrationScreen extends StatefulWidget {
  final String phone;
  const PartnerRegistrationScreen({super.key, required this.phone});
  @override
  State<PartnerRegistrationScreen> createState() =>
      _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    Future<bool> showExitDialog(BuildContext context) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exit"),
          content: const Text("Do you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        ),
      ).then((value) => value ?? false);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitDialog(context).then((exit) {
          if (exit && context.mounted) {
            Navigator.of(context).pop(result);
          }
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: AppTheme.primary,
              width: double.infinity,
              height: double.infinity,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      color: AppTheme.primary,
                      height: screenHeight * 0.2,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            left: 0,
                            child: Image.asset(
                              'assets/images/image1.png',
                              height: screenHeight * 0.2,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.015,
                              left: screenWidth * 0.03,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_sharp,
                                        color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // White bottom section
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(0),
                            topRight: Radius.circular(screenWidth * 0.1),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.1),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.07),
                                  SizedBox(
                                    height: screenHeight * 0.08,
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      keyboardType: TextInputType.name,
                                      maxLength: 30,
                                      decoration: const InputDecoration(
                                        labelText: 'First Name',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: 'Enter your first name here',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'First Name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.08,
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      keyboardType: TextInputType
                                          .name, // Set input type to name
                                      maxLength: 30,
                                      decoration: const InputDecoration(
                                        labelText: 'Last Name',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: 'Enter your last name here',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blueGrey),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Last Name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.07,
                                  ),
                                  SizedBox(
                                    // onPressed: () async {
                                    //   if (_formKey.currentState!.validate()) {
                                    //     String name = _firstNameController
                                    //         .text
                                    //         .trim()
                                    //         .toString();
                                    //     String urlName = Uri.encodeComponent(name);
                                    //     //String apiUrl = "https://xpacesphere.com/api/Register/UPDRegistrDetails?mobile=${widget.phone} &Name=$name";
                                    //     String apiUrl = "http://65.2.82.196:8080/api/v1/users?mobile=${widget.phone}&Name=$urlName";
                                    //     try {
                                    //       final response = await http
                                    //           .put(Uri.parse(apiUrl));
                                    //       if (!context.mounted) return;
                                    //       if (response.statusCode == 200) {
                                    //         final responseData =
                                    //         jsonDecode(response.body);
                                    //         if (responseData["status"] ==
                                    //             200) {
                                    //           SharedPreferences prefs =
                                    //           await SharedPreferences
                                    //               .getInstance();
                                    //           prefs.setString("name", name);
                                    //           prefs.setString(
                                    //               "mobile", widget.phone);
                                    //           if (!context.mounted) return;
                                    //           Navigator.pushAndRemoveUntil(
                                    //             context,
                                    //             MaterialPageRoute(
                                    //                 builder: (context) =>
                                    //                 const GetUserLocation()),
                                    //                 (Route<dynamic> route) =>
                                    //             false,
                                    //           );
                                    //         } else {
                                    //           ScaffoldMessenger.of(context)
                                    //               .showSnackBar(
                                    //             SnackBar(
                                    //                 content: Text(
                                    //                     "Error: ${responseData["message"]}")),
                                    //           );
                                    //         }
                                    //       } else {
                                    //         ScaffoldMessenger.of(context)
                                    //             .showSnackBar(
                                    //           const SnackBar(
                                    //               content: Text(
                                    //                   "Server error. Please try again.")),
                                    //         );
                                    //       }
                                    //     } catch (e) {
                                    //       ScaffoldMessenger.of(context)
                                    //           .showSnackBar(
                                    //         SnackBar(
                                    //             content: Text(
                                    //                 "Failed to connect: $e")),
                                    //       );
                                    //     }
                                    //   }
                                    //
                                    // },
                                    height: screenHeight * 0.06,
                                    child: ElevatedButton(
                                      // onPressed: () async {
                                      //   if (_formKey.currentState!.validate()) {
                                      //     String firstName = _firstNameController.text.trim();
                                      //     String lastName = _lastNameController.text.trim();
                                      //     String phone = widget.phone;
                                      //
                                      //     final url = "http://15.206.189.22:8080/api/v1/users";
                                      //     final headers = {'Content-Type': 'application/json'};
                                      //     final body = jsonEncode({
                                      //       "firstName": firstName,
                                      //       "lastName": lastName,
                                      //       "phone": phone,
                                      //     });
                                      //
                                      //     print("📤 Sending Registration Request");
                                      //     print("🔗 URL: $url");
                                      //     print("📦 Body: $body");
                                      //
                                      //     try {
                                      //       final response = await http.post(
                                      //         Uri.parse(url),
                                      //         headers: headers,
                                      //         body: body,
                                      //       );
                                      //
                                      //       print("✅ Status Code: ${response.statusCode}");
                                      //       print("📥 Response Body: ${response.body}");
                                      //
                                      //       if (response.statusCode == 200) {
                                      //         final responseData = jsonDecode(response.body);
                                      //         // ✅✅ Save userId if it exists
                                      //         if (responseData["user"] != null && responseData["user"]["id"] != null) {
                                      //           SharedPreferences prefs = await SharedPreferences.getInstance();
                                      //           await prefs.setInt("userId", responseData["user"]["id"]);
                                      //           print("✅ Saved userId: ${responseData["user"]["id"]}");
                                      //         }
                                      //
                                      //         Navigator.pushReplacement(
                                      //           context,
                                      //           MaterialPageRoute(builder: (context) => GetUserLocation()),
                                      //         );
                                      //       } else if (response.statusCode == 409 &&
                                      //           response.body.contains("already registered")) {
                                      //         Navigator.pushReplacement(
                                      //           context,
                                      //           MaterialPageRoute(builder: (context) => GetUserLocation()),
                                      //         );
                                      //       } else {
                                      //         ScaffoldMessenger.of(context).showSnackBar(
                                      //           SnackBar(content: Text("Registration success: ${response.body}")),
                                      //         );
                                      //       }
                                      //     } catch (e) {
                                      //       print("❌ Exception: $e");
                                      //       ScaffoldMessenger.of(context).showSnackBar(
                                      //         SnackBar(content: Text("Something went wrong: $e")),
                                      //       );
                                      //     }
                                      //   }
                                      // },

                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          String firstName =
                                              _firstNameController.text.trim();
                                          String lastName =
                                              _lastNameController.text.trim();
                                          String phone = widget.phone;

                                          final url =
                                              "http://3.110.172.156:8083/api/v1/users";
                                          final headers = {
                                            'Content-Type': 'application/json'
                                          };
                                          final body = jsonEncode({
                                            "firstName": firstName,
                                            "lastName": lastName,
                                            "phone": phone,
                                          });

                                          try {
                                            final response = await http.post(
                                              Uri.parse(url),
                                              headers: headers,
                                              body: body,
                                            );

                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            if (!context.mounted) return;

                                            if (response.statusCode == 200) {
                                              final responseData =
                                                  jsonDecode(response.body);
                                              if (responseData["user"] !=
                                                      null &&
                                                  responseData["user"]["id"] !=
                                                      null) {
                                                await prefs.setInt("userId",
                                                    responseData["user"]["id"]);
                                                debugPrint(
                                                    "✅ Saved userId: ${responseData["user"]["id"]}");
                                                if (!context.mounted) return;
                                              }

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GetUserLocation()),
                                              );
                                            } else if (response.statusCode ==
                                                    409 &&
                                                response.body.contains(
                                                    "already registered")) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GetUserLocation()),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Error: ${response.body}")),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint("❌ Exception: $e");
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Something went wrong: $e")),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppTheme.primary,
                                        minimumSize: Size(
                                          double.infinity,
                                          screenHeight * 0.06,
                                        ),
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
