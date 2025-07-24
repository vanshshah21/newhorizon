import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:nhapp/utils/rights.dart';
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

  Future<Map<String, dynamic>> getSalesPolicy() async {
    final dio = Dio();
    try {
      final url = await StorageUtils.readValue("url");
      final companyDetails = await StorageUtils.readJson("selected_company");
      if (url == null || companyDetails == null) {
        throw Exception("URL or company details not found");
      }

      final tokenDetails = await StorageUtils.readJson("session_token");
      if (tokenDetails == null) {
        throw Exception("Session token not found");
      }

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final companyCode = companyDetails['code'];
      const endpoint = "/api/Login/GetSalesPolicyDetails";

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['CompanyId'] = companyId.toString();

      final response = await dio.get(
        'http://$url$endpoint',
        queryParameters: {"companyCode": companyCode},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        await StorageUtils.writeJson(
          'sales_policy',
          response.data['data']['salesPolicyResultModel'][0],
        );
        return response.data['data']['salesPolicyResultModel'][0]
            as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchUserRights() async {
    final dio = Dio();
    try {
      final url = await StorageUtils.readValue('url');
      if (url == null) {
        showSnackBar('Base URL not found.');
        return;
      }
      final companyId = _selectedCompany['id'];
      final companyCode = _selectedCompany['code'];
      final siteCode = _selectedLocation['code'];

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) {
        showSnackBar('Session token not found.');
        return;
      }

      final userCode = tokenDetails['user']['userName'];
      final token = tokenDetails['token']['value'];
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['companyid'] = companyId;

      final body = {
        "usercode": userCode,
        "companycode": companyCode,
        "locationcode": siteCode,
      };

      final response = await dio.post(
        'http://$url/api/Login/GetMenuInfo',
        data: body,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Import the rights utility
        final parsedRights = parseMobileRights(response.data);

        if (parsedRights['success'] == true) {
          debugPrint('User rights fetched successfully: ${parsedRights} items');
          await StorageUtils.writeJson('user_rights', parsedRights);
        } else {
          showSnackBar(
            'Failed to parse user rights: ${parsedRights['message']}',
          );
        }
      } else {
        showSnackBar('Failed to fetch user rights: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error fetching user rights: $e');
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
      setState(() {
        isLoading = true; // Set loading state
      });

      // await StorageUtils.writeJson('selected_company', _selectedCompany);
      // await StorageUtils.writeJson('selected_location', _selectedLocation);

      // await _fetchAndSaveFinancePeriod();
      // await _fetchDomesticCurrency();

      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/');
      // showSnackBar('Logged in successfully!');
      try {
        await StorageUtils.writeJson('selected_company', _selectedCompany);
        await StorageUtils.writeJson('selected_location', _selectedLocation);

        await _fetchAndSaveFinancePeriod();
        await _fetchDomesticCurrency();
        await getSalesPolicy();
        await _fetchUserRights();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
        showSnackBar('Logged in successfully!');
      } catch (e) {
        if (!mounted) return;
        showSnackBar('Login failed: $e');
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false; // Reset loading state
          });
        }
      }
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
          enabled: !isLoading,
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
          onChanged: isLoading ? null : onChanged,
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
