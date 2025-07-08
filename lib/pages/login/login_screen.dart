// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");

//   Map<String, dynamic>? _selectedCompany;
//   Map<String, dynamic>? _selectedLocation;

//   int _step = 1;
//   bool _rememberMe = false;
//   bool isLoading = false;

//   late final FlutterSecureStorage _storage;
//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     if (_rememberMe) {
//       await _storage.write(key: 'url', value: url);
//       await _storage.write(key: 'username', value: username);
//       await _storage.write(key: 'password', value: password);
//     } else {
//       await _storage.deleteAll();
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           // Save session token or other info as needed
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (mounted) {
//         setState(() {
//           _step = 2;
//         });
//       }
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       debugPrint("API Response: ${response.data}");
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           // Select default if only one, or if isDefault is true
//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );

//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       debugPrint("Exception during _getCompanyAndLocation: $e");
//       showSnackBar('Error fetching company/location: $e');

//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//         _selectedCompany = null;
//         _selectedLocation = null;
//       });
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedCompany != null && _selectedLocation != null) {
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/');
//         showSnackBar('Logged in successfully!');
//       }
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       appBar: AppBar(
//         title: const Text('Login'),
//         automaticallyImplyLeading: _step != 1,
//         leading:
//             _step != 1
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () {
//                     if (mounted) {
//                       setState(() {
//                         _step = 1;
//                       });
//                     }
//                   },
//                 )
//                 : null,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_step == 1)
//                 Column(
//                   children: [
//                     TextField(
//                       controller: _urlController,
//                       decoration: const InputDecoration(hintText: "URL"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _usernameController,
//                       decoration: const InputDecoration(hintText: "Username"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(hintText: "Password"),
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _rememberMe,
//                           onChanged: (value) {
//                             if (mounted) {
//                               setState(() {
//                                 _rememberMe = value ?? false;
//                               });
//                             }
//                           },
//                         ),
//                         const Text('Remember Me'),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: isLoading ? null : _handleNextStep,
//                       child:
//                           isLoading
//                               ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                               : const Text('Next'),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 )
//               else if (_step == 2)
//                 Column(
//                   children: [
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedCompany,
//                       items:
//                           _companies.map((company) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: company,
//                               child: Text(company['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedCompany = value;
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Company',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedLocation,
//                       items:
//                           _locations.map((location) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: location,
//                               child: Text(location['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedLocation = value;
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Location',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _handleLogin,
//                       child: const Text('Login'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");

//   Map<String, dynamic> _selectedCompany = {};
//   Map<String, dynamic> _selectedLocation = {};

//   int _step = 1;
//   bool _rememberMe = false;
//   bool isLoading = false;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       if (!mounted) return;
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     if (_rememberMe) {
//       await StorageUtils.writeValue('url', url);
//       await StorageUtils.writeValue('username', username);
//       await StorageUtils.writeValue('password', password);
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (!mounted) return;
//       setState(() {
//         _step = 2;
//       });
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         if (!mounted) return;
//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );
//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       showSnackBar('Error fetching company/location: $e');
//       if (!mounted) return;
//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//         // _selectedCompany = null;
//         // _selectedLocation = null;
//       });
//     }
//   }

//   Future<void> _fetchAndSaveFinancePeriod() async {
//     final url = await StorageUtils.readValue('url');
//     if (url == null) {
//       showSnackBar('Base URL not found.');
//       return;
//     }

//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null) {
//       showSnackBar('Session token not found.');
//       return;
//     }

//     final token = tokendetails['token']['value'];
//     final siteId = _selectedLocation['id'];
//     final companyId = _selectedCompany['id'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//         queryParameters: {"companyid": companyId},
//       );

//       if (response.statusCode == 200 &&
//           response.data != null &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         final financePeriods =
//             (data['financePeriodSetting'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         // Find the finance period for the selected siteId
//         final financePeriod = financePeriods.firstWhere(
//           (fp) => fp['siteId'] == siteId,
//           orElse: () => <String, dynamic>{},
//         );

//         if (financePeriod.isNotEmpty) {
//           await StorageUtils.writeJson('finance_period', financePeriod);
//         } else {
//           showSnackBar('Finance period not found for selected location.');
//         }
//       } else {
//         showSnackBar('Failed to fetch finance period data.');
//       }
//     } catch (e) {
//       showSnackBar('Error fetching finance period: $e');
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedLocation != null) {
//       // Save selected company and location in background
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       // Fetch and save finance period for selected location
//       await _fetchAndSaveFinancePeriod();

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/');
//       showSnackBar('Logged in successfully!');
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       appBar: AppBar(
//         title: const Text('Login'),
//         automaticallyImplyLeading: _step != 1,
//         leading:
//             _step != 1
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () {
//                     if (mounted) {
//                       setState(() {
//                         _step = 1;
//                       });
//                     }
//                   },
//                 )
//                 : null,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_step == 1)
//                 Column(
//                   children: [
//                     TextField(
//                       controller: _urlController,
//                       decoration: const InputDecoration(hintText: "URL"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _usernameController,
//                       decoration: const InputDecoration(hintText: "Username"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(hintText: "Password"),
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _rememberMe,
//                           onChanged: (value) {
//                             if (mounted) {
//                               setState(() {
//                                 _rememberMe = value ?? false;
//                               });
//                             }
//                           },
//                         ),
//                         const Text('Remember Me'),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: isLoading ? null : _handleNextStep,
//                       child:
//                           isLoading
//                               ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                               : const Text('Next'),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 )
//               else if (_step == 2)
//                 Column(
//                   children: [
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedCompany,
//                       items:
//                           _companies.map((company) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: company,
//                               child: Text(company['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedCompany = value ?? {};
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Company',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedLocation,
//                       items:
//                           _locations.map((location) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: location,
//                               child: Text(location['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedLocation = value ?? {};
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Location',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _handleLogin,
//                       child: const Text('Login'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.147:1134");
//   final _usernameController = TextEditingController(text: "super");
//   final _passwordController = TextEditingController(text: "Raja@112");

//   Map<String, dynamic> _selectedCompany = {};
//   Map<String, dynamic> _selectedLocation = {};

//   int _step = 1;
//   bool _rememberMe = false;
//   bool _obscurePassword = true;
//   bool isLoading = false;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       if (!mounted) return;
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     await StorageUtils.writeValue('url', url);

//     if (_rememberMe) {
//       await StorageUtils.writeBool('Remember', true);
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (!mounted) return;
//       setState(() {
//         _step = 2;
//       });
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         if (!mounted) return;
//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );
//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       showSnackBar('Error fetching company/location: $e');
//       if (!mounted) return;
//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//       });
//     }
//   }

//   Future<void> _fetchAndSaveFinancePeriod() async {
//     final url = await StorageUtils.readValue('url');
//     if (url == null) {
//       showSnackBar('Base URL not found.');
//       return;
//     }

//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null) {
//       showSnackBar('Session token not found.');
//       return;
//     }

//     final token = tokendetails['token']['value'];
//     final siteId = _selectedLocation['id'];
//     final companyId = _selectedCompany['id'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//         queryParameters: {"companyid": companyId},
//       );

//       if (response.statusCode == 200 &&
//           response.data != null &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         final financePeriods =
//             (data['financePeriodSetting'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         final financePeriod = financePeriods.firstWhere(
//           (fp) => fp['siteId'] == siteId,
//           orElse: () => <String, dynamic>{},
//         );

//         if (financePeriod.isNotEmpty) {
//           await StorageUtils.writeJson('finance_period', financePeriod);
//         } else {
//           showSnackBar('Finance period not found for selected location.');
//         }
//       } else {
//         showSnackBar('Failed to fetch finance period data.');
//       }
//     } catch (e) {
//       showSnackBar('Error fetching finance period: $e');
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedLocation != null) {
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       await _fetchAndSaveFinancePeriod();

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/');
//       showSnackBar('Logged in successfully!');
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final screenWidth = media.size.width;
//     final screenHeight = media.size.height;
//     final keyboardHeight = media.viewInsets.bottom;
//     final isKeyboardOpen = keyboardHeight > 0;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const ClampingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight:
//                   screenHeight - media.padding.top - media.padding.bottom,
//             ),
//             child: IntrinsicHeight(
//               child: Column(
//                 children: [
//                   // Header with Back Button (only for step 2)
//                   if (_step == 2)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 _step = 1;
//                               });
//                             },
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: Color(0xFF20AAE7),
//                               size: 28,
//                             ),
//                           ),
//                           const Text(
//                             'Back to Login',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF20AAE7),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // SVG Banner - adjust height when keyboard is open
//                   if (!isKeyboardOpen)
//                     // Container(
//                     //   width: screenWidth,
//                     //   height: 200,
//                     //   color: Colors.lightBlueAccent,
//                     //   child: SvgPicture.asset(
//                     //     'assets/img_login_banner_new.svg',
//                     //     fit: BoxFit.contain,
//                     //     width: screenWidth * 0.8,
//                     //     alignment: Alignment.center,
//                     //   ),
//                     // ),
//                     Container(
//                       width: screenWidth,
//                       color: Colors.lightBlueAccent,
//                       child: SvgPicture.asset(
//                         'assets/img_login_banner_new.svg',
//                         fit: BoxFit.cover,
//                         width: screenWidth * 0.8,
//                         alignment: Alignment.center,
//                       ),
//                     ),

//                   SizedBox(height: isKeyboardOpen ? 8 : 16),

//                   // Welcome Text
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Text(
//                       _step == 1 ? 'Sign In' : 'Select Workspace',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF20AAE7),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Form - takes remaining space
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   if (_step == 1) ...[
//                                     _buildTextField(
//                                       controller: _urlController,
//                                       label: 'Server URL',
//                                       hint: 'Enter server URL',
//                                       icon: Icons.dns_outlined,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _usernameController,
//                                       label: 'Username',
//                                       hint: 'Enter your username',
//                                       icon: Icons.person_outline,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _passwordController,
//                                       label: 'Password',
//                                       hint: 'Enter your password',
//                                       icon: Icons.lock_outline,
//                                       isPassword: true,
//                                       obscureText: _obscurePassword,
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                           color: Colors.grey[600],
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _obscurePassword =
//                                                 !_obscurePassword;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       children: [
//                                         Transform.scale(
//                                           scale: 1.2,
//                                           child: Checkbox(
//                                             value: _rememberMe,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 _rememberMe = value ?? false;
//                                               });
//                                             },
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                             activeColor: const Color(
//                                               0xFF20AAE7,
//                                             ),
//                                           ),
//                                         ),
//                                         const Text(
//                                           'Remember Me',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ] else ...[
//                                     // Step 2 - Company and Location dropdowns
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedCompany,
//                                       items: _companies,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedCompany = value ?? {};
//                                         });
//                                       },
//                                       label: 'Company',
//                                       icon: Icons.business,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedLocation,
//                                       items: _locations,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedLocation = value ?? {};
//                                         });
//                                       },
//                                       label: 'Location',
//                                       icon: Icons.location_on_outlined,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                   ],
//                                   const SizedBox(height: 24),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Login Button - always at bottom
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0,
//                             ),
//                             child: SizedBox(
//                               height: 56,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     isLoading
//                                         ? null
//                                         : (_step == 1
//                                             ? _handleNextStep
//                                             : _handleLogin),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF20AAE7),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   elevation: 4,
//                                 ),
//                                 child:
//                                     isLoading
//                                         ? const SizedBox(
//                                           width: 24,
//                                           height: 24,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                         : Text(
//                                           _step == 1 ? 'Continue' : 'Login',
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     bool obscureText = false,
//     Widget? suffixIcon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: isPassword ? obscureText : false,
//           style: const TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[400]),
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             suffixIcon: suffixIcon,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Widget _buildDropdown<T>({
//   //   required T value,
//   //   required List<T> items,
//   //   required ValueChanged<T?> onChanged,
//   //   required String label,
//   //   required IconData icon,
//   //   required String Function(T) displayText,
//   // }) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Text(
//   //         label,
//   //         style: const TextStyle(
//   //           fontSize: 16,
//   //           fontWeight: FontWeight.w600,
//   //           color: Colors.black87,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 8),
//   //       DropdownButtonFormField<T>(
//   //         value: value,
//   //         items:
//   //             items.map((item) {
//   //               return DropdownMenuItem<T>(
//   //                 value: item,
//   //                 child: Text(
//   //                   displayText(item),
//   //                   style: const TextStyle(fontSize: 16),
//   //                 ),
//   //               );
//   //             }).toList(),
//   //         onChanged: onChanged,
//   //         decoration: InputDecoration(
//   //           prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//   //           border: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(16),
//   //             borderSide: BorderSide.none,
//   //           ),
//   //           filled: true,
//   //           fillColor: const Color(0xFFF8F9FA),
//   //           contentPadding: const EdgeInsets.symmetric(
//   //             horizontal: 20,
//   //             vertical: 16,
//   //           ),
//   //           focusedBorder: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(16),
//   //             borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//   // ...existing code...

//   Widget _buildDropdown<T>({
//     required T value,
//     required List<T> items,
//     required ValueChanged<T?> onChanged,
//     required String label,
//     required IconData icon,
//     required String Function(T) displayText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<T>(
//           value: value,
//           isExpanded: true, // This prevents overflow
//           items:
//               items.map((item) {
//                 return DropdownMenuItem<T>(
//                   value: item,
//                   child: Text(
//                     displayText(item),
//                     style: const TextStyle(fontSize: 16),
//                     overflow: TextOverflow.ellipsis, // Handle long text
//                     maxLines: 1, // Limit to single line
//                   ),
//                 );
//               }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//           // Custom dropdown button styling
//           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF20AAE7)),
//           // Ensure dropdown menu fits properly
//           menuMaxHeight: 200, // Limit dropdown height
//           selectedItemBuilder: (BuildContext context) {
//             return items.map<Widget>((T item) {
//               return Container(
//                 alignment: Alignment.centerLeft,
//                 constraints: const BoxConstraints(minWidth: 100),
//                 child: Text(
//                   displayText(item),
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               );
//             }).toList();
//           },
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.147:1134");
//   final _usernameController = TextEditingController(text: "super");
//   final _passwordController = TextEditingController(text: "Raja@112");

//   Map<String, dynamic> _selectedCompany = {};
//   Map<String, dynamic> _selectedLocation = {};

//   int _step = 1;
//   bool _rememberMe = false;
//   bool _obscurePassword = true;
//   bool isLoading = false;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');
//     final remember = await StorageUtils.readBool('Remember');

//     if (url != null &&
//         username != null &&
//         password != null &&
//         remember == true) {
//       if (!mounted) return;
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     // Always save URL for next step
//     await StorageUtils.writeValue('url', url);
//     await StorageUtils.writeValue('username', username);

//     if (_rememberMe) {
//       await StorageUtils.writeValue('password', password);
//       await StorageUtils.writeBool('Remember', true);
//     } else {
//       await StorageUtils.deleteValue('password');
//       await StorageUtils.writeBool('Remember', false);
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           // Check if the data object has required token information
//           final sessionData = data['data'];
//           if (sessionData is Map && sessionData.isNotEmpty) {
//             await StorageUtils.writeJson('session_token', sessionData);
//             return true;
//           } else {
//             showSnackBar('Login failed: Invalid session data received');
//             return false;
//           }
//         } else {
//           showSnackBar(
//             'Login failed: ${data?['errorMessage'] ?? data?['message'] ?? 'Invalid credentials'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: Server error ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map && data['message'] != null) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });

//     if (loginSuccess) {
//       final hasCompanyData = await _getCompanyAndLocation();
//       if (!mounted) return;

//       if (hasCompanyData) {
//         setState(() {
//           _step = 2;
//         });
//       }
//     }
//   }

//   Future<bool> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return false;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );

//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>?;

//         if (data == null || data.isEmpty) {
//           showSnackBar('No company/location data available');
//           return false;
//         }

//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         if (companies.isEmpty && locations.isEmpty) {
//           showSnackBar('No companies or locations found for this user');
//           return false;
//         }

//         if (!mounted) return false;
//         setState(() {
//           _companies = companies.isNotEmpty ? companies : [defaultCompany];
//           _locations = locations.isNotEmpty ? locations : [defaultLocation];

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );
//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//         return true;
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.data?['message'] ?? 'Server error'}',
//         );
//         return false;
//       }
//     } catch (e) {
//       showSnackBar('Error fetching company/location: $e');
//       return false;
//     }
//   }

//   Future<void> _fetchAndSaveFinancePeriod() async {
//     final url = await StorageUtils.readValue('url');
//     if (url == null) {
//       showSnackBar('Base URL not found.');
//       return;
//     }

//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null || tokendetails['token'] == null) {
//       showSnackBar('Session token not found.');
//       return;
//     }

//     final token = tokendetails['token']['value'];
//     final siteId = _selectedLocation['id'];
//     final companyId = _selectedCompany['id'];

//     if (siteId == null || companyId == null) {
//       showSnackBar('Invalid company or location selected.');
//       return;
//     }

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';

//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//         queryParameters: {"companyid": companyId},
//       );

//       if (response.statusCode == 200 &&
//           response.data != null &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         final financePeriods =
//             (data['financePeriodSetting'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         final financePeriod = financePeriods.firstWhere(
//           (fp) => fp['siteId'] == siteId,
//           orElse: () => <String, dynamic>{},
//         );

//         if (financePeriod.isNotEmpty) {
//           await StorageUtils.writeJson('finance_period', financePeriod);
//         } else {
//           showSnackBar('Finance period not found for selected location.');
//         }
//       } else {
//         showSnackBar('Failed to fetch finance period data.');
//       }
//     } catch (e) {
//       showSnackBar('Error fetching finance period: $e');
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedLocation.isEmpty || _selectedCompany.isEmpty) {
//       showSnackBar('Please select both company and location.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       await _fetchAndSaveFinancePeriod();

//       if (!mounted) return;

//       Navigator.pushReplacementNamed(context, '/');
//       showSnackBar('Logged in successfully!');
//     } catch (e) {
//       showSnackBar('Error during login: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final screenWidth = media.size.width;
//     final screenHeight = media.size.height;
//     final keyboardHeight = media.viewInsets.bottom;
//     final isKeyboardOpen = keyboardHeight > 0;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const ClampingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight:
//                   screenHeight - media.padding.top - media.padding.bottom,
//             ),
//             child: IntrinsicHeight(
//               child: Column(
//                 children: [
//                   // Header with Back Button (only for step 2)
//                   if (_step == 2)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 _step = 1;
//                               });
//                             },
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: Color(0xFF20AAE7),
//                               size: 28,
//                             ),
//                           ),
//                           const Text(
//                             'Back to Login',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF20AAE7),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // SVG Banner - adjust height when keyboard is open
//                   if (!isKeyboardOpen)
//                     Container(
//                       width: screenWidth,
//                       color: Colors.lightBlueAccent,
//                       child: SvgPicture.asset(
//                         'assets/img_login_banner_new.svg',
//                         fit: BoxFit.cover,
//                         width: screenWidth * 0.8,
//                         alignment: Alignment.center,
//                       ),
//                     ),

//                   SizedBox(height: isKeyboardOpen ? 8 : 16),

//                   // Welcome Text
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Text(
//                       _step == 1 ? 'Sign In' : 'Select Workspace',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF20AAE7),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Form - takes remaining space
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   if (_step == 1) ...[
//                                     _buildTextField(
//                                       controller: _urlController,
//                                       label: 'Server URL',
//                                       hint: 'Enter server URL',
//                                       icon: Icons.dns_outlined,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _usernameController,
//                                       label: 'Username',
//                                       hint: 'Enter your username',
//                                       icon: Icons.person_outline,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _passwordController,
//                                       label: 'Password',
//                                       hint: 'Enter your password',
//                                       icon: Icons.lock_outline,
//                                       isPassword: true,
//                                       obscureText: _obscurePassword,
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                           color: Colors.grey[600],
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _obscurePassword =
//                                                 !_obscurePassword;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       children: [
//                                         Transform.scale(
//                                           scale: 1.2,
//                                           child: Checkbox(
//                                             value: _rememberMe,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 _rememberMe = value ?? false;
//                                               });
//                                             },
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                             activeColor: const Color(
//                                               0xFF20AAE7,
//                                             ),
//                                           ),
//                                         ),
//                                         const Text(
//                                           'Remember Me',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ] else ...[
//                                     // Step 2 - Company and Location dropdowns
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedCompany,
//                                       items: _companies,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedCompany = value ?? {};
//                                         });
//                                       },
//                                       label: 'Company',
//                                       icon: Icons.business,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedLocation,
//                                       items: _locations,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedLocation = value ?? {};
//                                         });
//                                       },
//                                       label: 'Location',
//                                       icon: Icons.location_on_outlined,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                   ],
//                                   const SizedBox(height: 24),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Login Button - always at bottom
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0,
//                             ),
//                             child: SizedBox(
//                               height: 56,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     isLoading
//                                         ? null
//                                         : (_step == 1
//                                             ? _handleNextStep
//                                             : _handleLogin),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF20AAE7),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   elevation: 4,
//                                 ),
//                                 child:
//                                     isLoading
//                                         ? const SizedBox(
//                                           width: 24,
//                                           height: 24,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                         : Text(
//                                           _step == 1 ? 'Continue' : 'Login',
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     bool obscureText = false,
//     Widget? suffixIcon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: isPassword ? obscureText : false,
//           style: const TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[400]),
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             suffixIcon: suffixIcon,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown<T>({
//     required T value,
//     required List<T> items,
//     required ValueChanged<T?> onChanged,
//     required String label,
//     required IconData icon,
//     required String Function(T) displayText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<T>(
//           value: value,
//           isExpanded: true,
//           items:
//               items.map((item) {
//                 return DropdownMenuItem<T>(
//                   value: item,
//                   child: Text(
//                     displayText(item),
//                     style: const TextStyle(fontSize: 16),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 );
//               }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF20AAE7)),
//           menuMaxHeight: 200,
//           selectedItemBuilder: (BuildContext context) {
//             return items.map<Widget>((T item) {
//               return Container(
//                 alignment: Alignment.centerLeft,
//                 constraints: const BoxConstraints(minWidth: 100),
//                 child: Text(
//                   displayText(item),
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               );
//             }).toList();
//           },
//         ),
//       ],
//     );
//   }
// }
//New UI ---------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");

//   Map<String, dynamic>? _selectedCompany;
//   Map<String, dynamic>? _selectedLocation;

//   int _step = 1;
//   bool _rememberMe = false;
//   bool isLoading = false;
//   bool _obscurePassword = true;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     if (_rememberMe) {
//       await StorageUtils.writeValue('url', url);
//       await StorageUtils.writeValue('username', username);
//       await StorageUtils.writeValue('password', password);
//     } else {
//       await StorageUtils.clearAll();
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (mounted) {
//         setState(() {
//           _step = 2;
//         });
//       }
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       debugPrint("API Response: ${response.data}");
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );

//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       debugPrint("Exception during _getCompanyAndLocation: $e");
//       showSnackBar('Error fetching company/location: $e');

//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//         _selectedCompany = null;
//         _selectedLocation = null;
//       });
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedCompany != null && _selectedLocation != null) {
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/');
//         showSnackBar('Logged in successfully!');
//       }
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar:
//           _step == 2
//               ? AppBar(
//                 title: const Text('Select Company & Location'),
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.black87),
//                   onPressed: () {
//                     if (mounted) {
//                       setState(() {
//                         _step = 1;
//                       });
//                     }
//                   },
//                 ),
//               )
//               : null,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 24.0,
//               vertical: 16.0,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 if (_step == 1) ...[
//                   const SizedBox(height: 40),
//                   // Logo or App Name
//                   Container(
//                     alignment: Alignment.center,
//                     margin: const EdgeInsets.only(bottom: 48),
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).primaryColor,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: const Icon(
//                             Icons.lock_outline,
//                             size: 40,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Welcome Back',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.headlineMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Sign in to your account',
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Login Form
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // URL Field
//                         TextFormField(
//                           controller: _urlController,
//                           decoration: InputDecoration(
//                             labelText: 'Server URL',
//                             hintText: 'Enter server URL',
//                             prefixIcon: const Icon(Icons.dns_outlined),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Username Field
//                         TextFormField(
//                           controller: _usernameController,
//                           decoration: InputDecoration(
//                             labelText: 'Username',
//                             hintText: 'Enter your username',
//                             prefixIcon: const Icon(Icons.person_outline),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Password Field
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             hintText: 'Enter your password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: Colors.grey[600],
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Remember Me Checkbox
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _rememberMe,
//                               onChanged: (value) {
//                                 if (mounted) {
//                                   setState(() {
//                                     _rememberMe = value ?? false;
//                                   });
//                                 }
//                               },
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             Text(
//                               'Remember Me',
//                               style: TextStyle(color: Colors.grey[700]),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: isLoading ? null : _handleNextStep,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child:
//                                 isLoading
//                                     ? const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                     : const Text(
//                                       'Continue',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ] else if (_step == 2) ...[
//                   const SizedBox(height: 20),

//                   // Step 2 Header
//                   Container(
//                     alignment: Alignment.center,
//                     margin: const EdgeInsets.only(bottom: 32),
//                     child: Column(
//                       children: [
//                         Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: Theme.of(
//                               context,
//                             ).primaryColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Icon(
//                             Icons.business_outlined,
//                             size: 30,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Select Your Workspace',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.headlineSmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Choose your company and location',
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Selection Form
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         // Company Dropdown
//                         DropdownButtonFormField<Map<String, dynamic>>(
//                           value: _selectedCompany,
//                           items:
//                               _companies.map((company) {
//                                 return DropdownMenuItem<Map<String, dynamic>>(
//                                   value: company,
//                                   child: Text(company['name']),
//                                 );
//                               }).toList(),
//                           onChanged: (value) {
//                             if (mounted) {
//                               setState(() {
//                                 _selectedCompany = value;
//                               });
//                             }
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Company',
//                             prefixIcon: const Icon(Icons.business),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Location Dropdown
//                         DropdownButtonFormField<Map<String, dynamic>>(
//                           value: _selectedLocation,
//                           items:
//                               _locations.map((location) {
//                                 return DropdownMenuItem<Map<String, dynamic>>(
//                                   value: location,
//                                   child: Text(location['name']),
//                                 );
//                               }).toList(),
//                           onChanged: (value) {
//                             if (mounted) {
//                               setState(() {
//                                 _selectedLocation = value;
//                               });
//                             }
//                           },
//                           decoration: InputDecoration(
//                             labelText: 'Location',
//                             prefixIcon: const Icon(Icons.location_on_outlined),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(color: Colors.grey[300]!),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide(
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 32),

//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _handleLogin,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).primaryColor,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");

//   Map<String, dynamic> _selectedCompany = {};
//   Map<String, dynamic> _selectedLocation = {};

//   int _step = 1;
//   bool _rememberMe = false;
//   bool isLoading = false;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       if (!mounted) return;
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     if (_rememberMe) {
//       await StorageUtils.writeValue('url', url);
//       await StorageUtils.writeValue('username', username);
//       await StorageUtils.writeValue('password', password);
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (!mounted) return;
//       setState(() {
//         _step = 2;
//       });
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         if (!mounted) return;
//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );
//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       showSnackBar('Error fetching company/location: $e');
//       if (!mounted) return;
//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//         // _selectedCompany = null;
//         // _selectedLocation = null;
//       });
//     }
//   }

//   Future<void> _fetchAndSaveFinancePeriod() async {
//     final url = await StorageUtils.readValue('url');
//     if (url == null) {
//       showSnackBar('Base URL not found.');
//       return;
//     }

//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null) {
//       showSnackBar('Session token not found.');
//       return;
//     }

//     final token = tokendetails['token']['value'];
//     final siteId = _selectedLocation['id'];
//     final companyId = _selectedCompany['id'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//         queryParameters: {"companyid": companyId},
//       );

//       if (response.statusCode == 200 &&
//           response.data != null &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         final financePeriods =
//             (data['financePeriodSetting'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         // Find the finance period for the selected siteId
//         final financePeriod = financePeriods.firstWhere(
//           (fp) => fp['siteId'] == siteId,
//           orElse: () => <String, dynamic>{},
//         );

//         if (financePeriod.isNotEmpty) {
//           await StorageUtils.writeJson('finance_period', financePeriod);
//         } else {
//           showSnackBar('Finance period not found for selected location.');
//         }
//       } else {
//         showSnackBar('Failed to fetch finance period data.');
//       }
//     } catch (e) {
//       showSnackBar('Error fetching finance period: $e');
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedLocation != null) {
//       // Save selected company and location in background
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       // Fetch and save finance period for selected location
//       await _fetchAndSaveFinancePeriod();

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/');
//       showSnackBar('Logged in successfully!');
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       appBar: AppBar(
//         title: const Text('Login'),
//         automaticallyImplyLeading: _step != 1,
//         leading:
//             _step != 1
//                 ? IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed: () {
//                     if (mounted) {
//                       setState(() {
//                         _step = 1;
//                       });
//                     }
//                   },
//                 )
//                 : null,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (_step == 1)
//                 Column(
//                   children: [
//                     TextField(
//                       controller: _urlController,
//                       decoration: const InputDecoration(hintText: "URL"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _usernameController,
//                       decoration: const InputDecoration(hintText: "Username"),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: const InputDecoration(hintText: "Password"),
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Checkbox(
//                           value: _rememberMe,
//                           onChanged: (value) {
//                             if (mounted) {
//                               setState(() {
//                                 _rememberMe = value ?? false;
//                               });
//                             }
//                           },
//                         ),
//                         const Text('Remember Me'),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: isLoading ? null : _handleNextStep,
//                       child:
//                           isLoading
//                               ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                               : const Text('Next'),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 )
//               else if (_step == 2)
//                 Column(
//                   children: [
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedCompany,
//                       items:
//                           _companies.map((company) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: company,
//                               child: Text(company['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedCompany = value ?? {};
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Company',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     DropdownButtonFormField<Map<String, dynamic>>(
//                       value: _selectedLocation,
//                       items:
//                           _locations.map((location) {
//                             return DropdownMenuItem<Map<String, dynamic>>(
//                               value: location,
//                               child: Text(location['name']),
//                             );
//                           }).toList(),
//                       onChanged: (value) {
//                         if (mounted) {
//                           setState(() {
//                             _selectedLocation = value ?? {};
//                           });
//                         }
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Select Location',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _handleLogin,
//                       child: const Text('Login'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:dio/dio.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class UserLoginScreen extends StatefulWidget {
//   const UserLoginScreen({super.key});

//   @override
//   UserLoginScreenState createState() => UserLoginScreenState();
// }

// class UserLoginScreenState extends State<UserLoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");

//   Map<String, dynamic> _selectedCompany = {};
//   Map<String, dynamic> _selectedLocation = {};

//   int _step = 1;
//   bool _rememberMe = false;
//   bool _obscurePassword = true;
//   bool isLoading = false;

//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   static final defaultCompany = {'name': 'Default Company'};
//   static final defaultLocation = {'name': 'Default Location'};

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   // --- LOGIC FROM YOUR SECOND FILE ---

//   Future<void> _loadSavedCredentials() async {
//     final url = await StorageUtils.readValue('url');
//     final username = await StorageUtils.readValue('username');
//     final password = await StorageUtils.readValue('password');

//     if (url != null && username != null && password != null) {
//       if (!mounted) return;
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<bool> _login() async {
//     final url = _urlController.text.trim();
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return false;
//     }

//     if (_rememberMe) {
//       await StorageUtils.writeValue('url', url);
//       await StorageUtils.writeValue('username', username);
//       await StorageUtils.writeValue('password', password);
//     }

//     final dio = Dio();
//     dio.options.connectTimeout = const Duration(seconds: 5);

//     try {
//       final response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data != null && data['success'] == true && data['data'] != null) {
//           await StorageUtils.writeJson('session_token', data['data']);
//           return true;
//         } else {
//           showSnackBar(
//             'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
//           );
//           return false;
//         }
//       } else {
//         showSnackBar('Login failed: ${response.statusCode}');
//         return false;
//       }
//     } on DioException catch (e) {
//       String message;
//       if (e.response != null) {
//         message = 'Server responded with error: ${e.response?.statusCode}';
//         final data = e.response?.data;
//         if (data is Map) {
//           message += ' - ${data['message']}';
//         }
//       } else {
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             message = 'No internet connection.';
//             break;
//           case DioExceptionType.receiveTimeout:
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection timed out. Please try again.';
//             break;
//           default:
//             message = 'An unknown error occurred.';
//         }
//       }
//       showSnackBar(message);
//       return false;
//     } catch (e) {
//       showSnackBar('Login failed: $e');
//       return false;
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isEmpty ||
//         _usernameController.text.isEmpty ||
//         _passwordController.text.isEmpty) {
//       showSnackBar('Please fill all fields.');
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final loginSuccess = await _login();

//     if (!mounted) return;
//     setState(() {
//       isLoading = false;
//     });

//     if (loginSuccess) {
//       await _getCompanyAndLocation();
//       if (!mounted) return;
//       setState(() {
//         _step = 2;
//       });
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();

//     try {
//       final username = await StorageUtils.readValue('username');
//       final url = await StorageUtils.readValue('url');

//       if (username == null || url == null) {
//         showSnackBar('Username or URL not found.');
//         return;
//       }

//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       if (response.statusCode == 200 && response.data["success"] == true) {
//         final data = response.data['data'] as Map<String, dynamic>;
//         final companies =
//             (data['companies'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultCompany];
//         final locations =
//             (data['locations'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [defaultLocation];

//         if (!mounted) return;
//         setState(() {
//           _companies = companies;
//           _locations = locations;

//           _selectedCompany =
//               companies.length == 1
//                   ? companies[0]
//                   : companies.firstWhere(
//                     (c) => c['isDefault'] == true,
//                     orElse:
//                         () =>
//                             companies.isNotEmpty
//                                 ? companies[0]
//                                 : defaultCompany,
//                   );
//           _selectedLocation =
//               locations.length == 1
//                   ? locations[0]
//                   : locations.firstWhere(
//                     (l) => l['isDefault'] == true,
//                     orElse:
//                         () =>
//                             locations.isNotEmpty
//                                 ? locations[0]
//                                 : defaultLocation,
//                   );
//         });
//       } else {
//         showSnackBar(
//           'Failed to fetch company/location: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       showSnackBar('Error fetching company/location: $e');
//       if (!mounted) return;
//       setState(() {
//         _companies = [defaultCompany];
//         _locations = [defaultLocation];
//       });
//     }
//   }

//   Future<void> _fetchAndSaveFinancePeriod() async {
//     final url = await StorageUtils.readValue('url');
//     if (url == null) {
//       showSnackBar('Base URL not found.');
//       return;
//     }

//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null) {
//       showSnackBar('Session token not found.');
//       return;
//     }

//     final token = tokendetails['token']['value'];
//     final siteId = _selectedLocation['id'];
//     final companyId = _selectedCompany['id'];

//     final dio = Dio();
//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Accept'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     try {
//       final response = await dio.get(
//         'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//         queryParameters: {"companyid": companyId},
//       );

//       if (response.statusCode == 200 &&
//           response.data != null &&
//           response.data['success'] == true &&
//           response.data['data'] != null) {
//         final data = response.data['data'];
//         final financePeriods =
//             (data['financePeriodSetting'] as List<dynamic>?)
//                 ?.cast<Map<String, dynamic>>() ??
//             [];

//         final financePeriod = financePeriods.firstWhere(
//           (fp) => fp['siteId'] == siteId,
//           orElse: () => <String, dynamic>{},
//         );

//         if (financePeriod.isNotEmpty) {
//           await StorageUtils.writeJson('finance_period', financePeriod);
//         } else {
//           showSnackBar('Finance period not found for selected location.');
//         }
//       } else {
//         showSnackBar('Failed to fetch finance period data.');
//       }
//     } catch (e) {
//       showSnackBar('Error fetching finance period: $e');
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedLocation != null) {
//       await StorageUtils.writeJson('selected_company', _selectedCompany);
//       await StorageUtils.writeJson('selected_location', _selectedLocation);

//       await _fetchAndSaveFinancePeriod();

//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, '/');
//       showSnackBar('Logged in successfully!');
//     } else {
//       showSnackBar('Please select both company and location.');
//     }
//   }

//   void showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   // --- UI FROM YOUR FIRST FILE ---

//   @override
//   Widget build(BuildContext context) {
//     final media = MediaQuery.of(context);
//     final screenWidth = media.size.width;
//     final screenHeight = media.size.height;
//     final keyboardHeight = media.viewInsets.bottom;
//     final isKeyboardOpen = keyboardHeight > 0;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F4F4),
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const ClampingScrollPhysics(),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight:
//                   screenHeight - media.padding.top - media.padding.bottom,
//             ),
//             child: IntrinsicHeight(
//               child: Column(
//                 children: [
//                   // Header with Back Button (only for step 2)
//                   if (_step == 2)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 _step = 1;
//                               });
//                             },
//                             icon: const Icon(
//                               Icons.arrow_back,
//                               color: Color(0xFF20AAE7),
//                               size: 28,
//                             ),
//                           ),
//                           const Text(
//                             'Back to Login',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF20AAE7),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // SVG Banner - adjust height when keyboard is open
//                   if (!isKeyboardOpen)
//                     Container(
//                       width: screenWidth,
//                       color: Colors.lightBlueAccent,
//                       child: SvgPicture.asset(
//                         'assets/img_login_banner_new.svg',
//                         fit: BoxFit.cover,
//                         width: screenWidth * 0.8,
//                         alignment: Alignment.center,
//                       ),
//                     ),

//                   SizedBox(height: isKeyboardOpen ? 8 : 16),

//                   // Welcome Text
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Text(
//                       _step == 1 ? 'Sign In' : 'Select Workspace',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF20AAE7),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Form - takes remaining space
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   if (_step == 1) ...[
//                                     _buildTextField(
//                                       controller: _urlController,
//                                       label: 'Server URL',
//                                       hint: 'Enter server URL',
//                                       icon: Icons.dns_outlined,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _usernameController,
//                                       label: 'Username',
//                                       hint: 'Enter your username',
//                                       icon: Icons.person_outline,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildTextField(
//                                       controller: _passwordController,
//                                       label: 'Password',
//                                       hint: 'Enter your password',
//                                       icon: Icons.lock_outline,
//                                       isPassword: true,
//                                       obscureText: _obscurePassword,
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _obscurePassword
//                                               ? Icons.visibility_off
//                                               : Icons.visibility,
//                                           color: Colors.grey[600],
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _obscurePassword =
//                                                 !_obscurePassword;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       children: [
//                                         Transform.scale(
//                                           scale: 1.2,
//                                           child: Checkbox(
//                                             value: _rememberMe,
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 _rememberMe = value ?? false;
//                                               });
//                                             },
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                             activeColor: const Color(
//                                               0xFF20AAE7,
//                                             ),
//                                           ),
//                                         ),
//                                         const Text(
//                                           'Remember Me',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ] else ...[
//                                     // Step 2 - Company and Location dropdowns
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedCompany,
//                                       items: _companies,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedCompany = value ?? {};
//                                         });
//                                       },
//                                       label: 'Company',
//                                       icon: Icons.business,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildDropdown<Map<String, dynamic>>(
//                                       value: _selectedLocation,
//                                       items: _locations,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedLocation = value ?? {};
//                                         });
//                                       },
//                                       label: 'Location',
//                                       icon: Icons.location_on_outlined,
//                                       displayText: (item) => item['name'],
//                                     ),
//                                   ],
//                                   const SizedBox(height: 24),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // Login Button - always at bottom
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0,
//                             ),
//                             child: SizedBox(
//                               height: 56,
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     isLoading
//                                         ? null
//                                         : (_step == 1
//                                             ? _handleNextStep
//                                             : _handleLogin),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF20AAE7),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   elevation: 4,
//                                 ),
//                                 child:
//                                     isLoading
//                                         ? const SizedBox(
//                                           width: 24,
//                                           height: 24,
//                                           child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                             strokeWidth: 2,
//                                           ),
//                                         )
//                                         : Text(
//                                           _step == 1 ? 'Continue' : 'Login',
//                                           style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     bool isPassword = false,
//     bool obscureText = false,
//     Widget? suffixIcon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           obscureText: isPassword ? obscureText : false,
//           style: const TextStyle(fontSize: 16),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[400]),
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             suffixIcon: suffixIcon,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown<T>({
//     required T value,
//     required List<T> items,
//     required ValueChanged<T?> onChanged,
//     required String label,
//     required IconData icon,
//     required String Function(T) displayText,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<T>(
//           value: value,
//           isExpanded: true,
//           items:
//               items.map((item) {
//                 return DropdownMenuItem<T>(
//                   value: item,
//                   child: Text(
//                     displayText(item),
//                     style: const TextStyle(fontSize: 16),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 );
//               }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: const Color(0xFFF8F9FA),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 20,
//               vertical: 16,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(16),
//               borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
//             ),
//           ),
//           icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF20AAE7)),
//           menuMaxHeight: 200,
//           selectedItemBuilder: (BuildContext context) {
//             return items.map<Widget>((T item) {
//               return Container(
//                 alignment: Alignment.centerLeft,
//                 constraints: const BoxConstraints(minWidth: 100),
//                 child: Text(
//                   displayText(item),
//                   style: const TextStyle(fontSize: 16, color: Colors.black87),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               );
//             }).toList();
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  UserLoginScreenState createState() => UserLoginScreenState();
}

class UserLoginScreenState extends State<UserLoginScreen> {
  final _urlController = TextEditingController(text: "192.168.0.147:1134");
  final _usernameController = TextEditingController(text: "super");
  final _passwordController = TextEditingController(text: "Raja@112");

  Map<String, dynamic> _selectedCompany = {};
  Map<String, dynamic> _selectedLocation = {};

  int _step = 1;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool isLoading = false;

  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _locations = [];

  static final defaultCompany = {'name': ''};
  static final defaultLocation = {'name': ''};

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final url = await StorageUtils.readValue('url');
    final username = await StorageUtils.readValue('username');
    final password = await StorageUtils.readValue('password');
    final rememberMe = await StorageUtils.readBool(
      'remember_me',
    ); // <-- read remember_me

    if (url != null &&
        username != null &&
        password != null &&
        rememberMe == true) {
      if (!mounted) return;
      setState(() {
        _urlController.text = url;
        _usernameController.text = username;
        _passwordController.text = password;
        _rememberMe = true;
      });
    } else {
      // If no saved credentials, ensure remember_me is false
      if (!mounted) return;
      setState(() {
        _urlController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _rememberMe = false;
      });
    }
  }

  Future<bool> _login() async {
    final url = _urlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (url.isEmpty || username.isEmpty || password.isEmpty) {
      showSnackBar('Please fill all fields.');
      return false;
    }

    // Always store the current remember_me state
    await StorageUtils.writeBool('remember_me', _rememberMe);

    await StorageUtils.writeValue('url', url);
    await StorageUtils.writeValue('username', username);
    await StorageUtils.writeValue('password', password);

    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);

    try {
      final response = await dio.post(
        'http://$url/api/Login/LoginCall',
        data: {'userName': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true && data['data'] != null) {
          await StorageUtils.writeJson('session_token', data['data']);
          return true;
        } else {
          showSnackBar(
            'Login failed: ${data['errorMessage'] ?? data['message'] ?? 'Unknown error'}',
          );
          return false;
        }
      } else {
        showSnackBar('Login failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      String message;
      if (e.response != null) {
        message = 'Server responded with error: ${e.response?.statusCode}';
        final data = e.response?.data;
        if (data is Map) {
          message += ' - ${data['message']}';
        }
      } else {
        switch (e.type) {
          case DioExceptionType.connectionError:
            message = 'No internet connection.';
            break;
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.connectionTimeout:
            message = 'Connection timed out. Please try again.';
            break;
          default:
            message = 'An unknown error occurred.';
        }
      }
      showSnackBar(message);
      return false;
    } catch (e) {
      showSnackBar('Login failed: $e');
      return false;
    }
  }

  void _handleNextStep() async {
    if (_urlController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showSnackBar('Please fill all fields.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final loginSuccess = await _login();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (loginSuccess) {
      await _getCompanyAndLocation();
      if (!mounted) return;
      setState(() {
        _step = 2;
      });
    }
  }

  Future<void> _getCompanyAndLocation() async {
    final dio = Dio();

    try {
      final username = await StorageUtils.readValue('username');
      final url = await StorageUtils.readValue('url');

      if (username == null || url == null) {
        showSnackBar('Username or URL not found.');
        return;
      }

      final response = await dio.get(
        'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
        queryParameters: {'UserName': username},
      );
      if (response.statusCode == 200 && response.data["success"] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final companies =
            (data['companies'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [defaultCompany];
        final locations =
            (data['locations'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [defaultLocation];

        if (!mounted) return;
        setState(() {
          _companies = companies;
          _locations = locations;

          _selectedCompany =
              companies.length == 1
                  ? companies[0]
                  : companies.firstWhere(
                    (c) => c['isDefault'] == true,
                    orElse:
                        () =>
                            companies.isNotEmpty
                                ? companies[0]
                                : defaultCompany,
                  );
          _selectedLocation =
              locations.length == 1
                  ? locations[0]
                  : locations.firstWhere(
                    (l) => l['isDefault'] == true,
                    orElse:
                        () =>
                            locations.isNotEmpty
                                ? locations[0]
                                : defaultLocation,
                  );
        });
      } else {
        showSnackBar(
          'Failed to fetch company/location: ${response.statusCode}',
        );
      }
    } catch (e) {
      showSnackBar('Error fetching company/location: $e');
      if (!mounted) return;
      setState(() {
        _companies = [defaultCompany];
        _locations = [defaultLocation];
      });
    }
  }

  Future<void> _fetchDomesticCurrency() async {
    final dio = Dio();

    try {
      final url = await StorageUtils.readValue('url');
      if (url == null) {
        showSnackBar('Base URL not found.');
        return;
      }

      final tokendetails = await StorageUtils.readJson('session_token');
      if (tokendetails == null) {
        showSnackBar('Session token not found.');
        return;
      }

      _selectedCompany =
          await StorageUtils.readJson('selected_company') ?? defaultCompany;

      final token = tokendetails['token']['value'];
      final companyId = _selectedCompany['id'];

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['companyid'] = companyId;

      final endpoint = '/api/Login/getDomesticCurrency';

      final response = await dio.get('http://$url$endpoint');

      if (response.statusCode == 200 && response.data["success"] == true) {
        final data = response.data['data'][0];
        await StorageUtils.writeJson('domestic_currency', data);
      } else {
        showSnackBar(
          'Failed to fetch domestic currency: ${response.statusCode}',
        );
      }
    } catch (e) {
      showSnackBar('Error fetching domestic currency: $e');
    }
  }

  Future<void> _fetchAndSaveFinancePeriod() async {
    final url = await StorageUtils.readValue('url');
    if (url == null) {
      showSnackBar('Base URL not found.');
      return;
    }

    final tokendetails = await StorageUtils.readJson('session_token');
    if (tokendetails == null) {
      showSnackBar('Session token not found.');
      return;
    }

    final token = tokendetails['token']['value'];
    final siteId = _selectedLocation['id'];
    final companyId = _selectedCompany['id'];

    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get(
        'http://$url/api/Login/GetCompanyCurrentYearDatesData',
        queryParameters: {"companyid": companyId},
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['success'] == true &&
          response.data['data'] != null) {
        final data = response.data['data'];
        final financePeriods =
            (data['financePeriodSetting'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            [];

        final financePeriod = financePeriods.firstWhere(
          (fp) => fp['siteId'] == siteId,
          orElse: () => <String, dynamic>{},
        );

        if (financePeriod.isNotEmpty) {
          await StorageUtils.writeJson('finance_period', financePeriod);
        } else {
          showSnackBar('Finance period not found for selected location.');
        }
      } else {
        showSnackBar('Failed to fetch finance period data.');
      }
    } catch (e) {
      showSnackBar('Error fetching finance period: $e');
    }
  }

  void _handleLogin() async {
    if (_selectedLocation != null) {
      await StorageUtils.writeJson('selected_company', _selectedCompany);
      await StorageUtils.writeJson('selected_location', _selectedLocation);

      await _fetchAndSaveFinancePeriod();
      await _fetchDomesticCurrency();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      showSnackBar('Logged in successfully!');
    } else {
      showSnackBar('Please select both company and location.');
    }
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final keyboardHeight = media.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight - media.padding.top - media.padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header with Back Button (only for step 2)
                  if (_step == 2)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _step = 1;
                              });
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF20AAE7),
                              size: 28,
                            ),
                          ),
                          const Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF20AAE7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // SVG Banner - adjust height when keyboard is open
                  if (!isKeyboardOpen)
                    Container(
                      width: screenWidth,
                      color: Colors.lightBlueAccent,
                      child: SvgPicture.asset(
                        'assets/img_login_banner_new.svg',
                        fit: BoxFit.cover,
                        width: screenWidth * 0.8,
                        alignment: Alignment.center,
                      ),
                    ),

                  SizedBox(height: isKeyboardOpen ? 8 : 16),

                  // Welcome Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _step == 1 ? 'Sign In' : 'Select Workspace',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20AAE7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form - takes remaining space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (_step == 1) ...[
                                    _buildTextField(
                                      controller: _urlController,
                                      label: 'Server URL',
                                      hint: 'Enter server URL',
                                      icon: Icons.dns_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _usernameController,
                                      label: 'Username',
                                      hint: 'Enter your username',
                                      icon: Icons.person_outline,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      hint: 'Enter your password',
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) async {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                              // Immediately update secure storage
                                              await StorageUtils.writeBool(
                                                'remember_me',
                                                _rememberMe,
                                              );
                                              if (!_rememberMe) {
                                                // Optionally clear username/password if unchecked
                                                await StorageUtils.deleteValue(
                                                  'username',
                                                );
                                                await StorageUtils.deleteValue(
                                                  'password',
                                                );
                                              }
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            activeColor: const Color(
                                              0xFF20AAE7,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'Remember Me',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    // Step 2 - Company and Location dropdowns
                                    _buildDropdown<Map<String, dynamic>>(
                                      value: _selectedCompany,
                                      items: _companies,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCompany = value ?? {};
                                        });
                                      },
                                      label: 'Company',
                                      icon: Icons.business,
                                      displayText: (item) => item['name'],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDropdown<Map<String, dynamic>>(
                                      value: _selectedLocation,
                                      items: _locations,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedLocation = value ?? {};
                                        });
                                      },
                                      label: 'Location',
                                      icon: Icons.location_on_outlined,
                                      displayText: (item) => item['name'],
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),

                          // Login Button - always at bottom
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : (_step == 1
                                            ? _handleNextStep
                                            : _handleLogin),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF20AAE7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child:
                                    isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          _step == 1 ? 'Continue' : 'Login',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String label,
    required IconData icon,
    required String Function(T) displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText(item),
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF20AAE7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF20AAE7), width: 2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF20AAE7)),
          menuMaxHeight: 200,
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((T item) {
              return Container(
                alignment: Alignment.centerLeft,
                constraints: const BoxConstraints(minWidth: 100),
                child: Text(
                  displayText(item),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
