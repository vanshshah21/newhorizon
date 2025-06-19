import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/main.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:provider/provider.dart';
import 'package:nhapp/utils/token_utils.dart'; // <-- Make sure this is imported

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> pendingAuthList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingAuthenticationCount();
    });
  }

  Future<void> _loadPendingAuthenticationCount() async {
    setState(() {
      isLoading = true;
    });

    // 1. Validate token before proceeding
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      _showSnackBar("Session expired. Please log in again.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final tokenDetails = await StorageUtils.readJson('session_token');

      if (companyDetails == null ||
          companyDetails.isEmpty ||
          locationDetails == null ||
          locationDetails.isEmpty ||
          tokenDetails == null ||
          tokenDetails.isEmpty) {
        _showSnackBar("Company, location, or session token not set");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final companyId = companyDetails['id'];
      final locationId = locationDetails['id'];
      final token = tokenDetails['token']['value'];

      Dio dio = Dio();
      dio.options.headers = {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $token",
      };
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await dio.get(
        'http://$url/api/Login/pendDashBoardCount',
        queryParameters: {'companyid': companyId, 'siteid': locationId},
      );

      if (response.statusCode == 200) {
        // Parse JSON in a background isolate for large responses
        final data = await compute(_parseJson, response.data);

        if (data['success'] == true && data['data'] is List) {
          if (!mounted) return; // Check if the widget is still mounted
          setState(() {
            pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          _showSnackBar(data['message'] ?? 'Unknown error');
        }
      } else {
        _showSnackBar('Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String message = 'Network error';
      if (e.response != null) {
        message = 'Failed: ${e.response?.statusCode}';
        if (e.response?.data is Map) {
          message += ' - ${e.response?.data['message']}';
        }
      } else {
        switch (e.type) {
          case DioExceptionType.connectionError:
            message = 'No internet connection';
            break;
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            message = 'Server timeout';
            break;
          case DioExceptionType.connectionTimeout:
            message = 'Connection timeout';
            break;
          default:
            message = 'Network error: ${e.message}';
        }
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  static Map<String, dynamic> _parseJson(dynamic data) {
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Invalid data for JSON parsing');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  final Map<String, String> routeToPageName = {
    '/purchase_orders': 'Purchase Orders',
    '/service_orders': 'Service Orders',
    '/labour_po': 'Labour PO',
    '/leads': 'Leads',
    '/follow_up': 'Follow Up',
    '/quotation': 'Quotation',
    '/sales_order': 'Sales Order',
    '/proforma_invoice': 'Proforma Invoice',
  };

  final Map<String, String> titleToRoute = {
    'Purchase Orders': '/authorize_purchase_orders',
    'Service Orders': '/authorize_service_orders',
    'Labour PO': '/authorize_labour_purchase_orders',
    'Quotation': '/authorize_quotations',
    'Sales Order': '/authorize_sales_orders',
  };

  @override
  Widget build(BuildContext context) {
    final favoritePages = Provider.of<FavoritePages>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/my_notification');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ExpansionTile(
              title: const Text('Purchase'),
              children: [
                ListTile(
                  title: const Text('Purchase Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/purchase_orders');
                  },
                ),
                ListTile(
                  title: const Text('Service Orders'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/service_orders');
                  },
                ),
                ListTile(
                  title: const Text('Labour PO'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/labour_po');
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Sales'),
              children: [
                ListTile(
                  title: const Text('Leads'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/leads');
                  },
                ),
                ListTile(
                  title: const Text('Follow Up'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/follow_up');
                  },
                ),
                ListTile(
                  title: const Text('Quotation'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/quotation');
                  },
                ),
                ListTile(
                  title: const Text('Sales Order'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sales_order');
                  },
                ),
                ListTile(
                  title: const Text('Proforma Invoice'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/proforma_invoice');
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Settings'),
              children: [
                ListTile(
                  title: const Text('My Notification'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my_notification');
                  },
                ),
                ListTile(
                  title: const Text('My Favourites'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/my_favourites');
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await StorageUtils.deleteValue('session_token');
                await StorageUtils.deleteValue('selected_company');
                await StorageUtils.deleteValue('selected_location');
                await StorageUtils.deleteValue('finance_period');
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (Route route) => false);
              },
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Pending Authorizations:')],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _AuthTile(
                          title: pendingAuthList[index]['title'] ?? '',
                          count: pendingAuthList[index]['count'] ?? 0,
                          onTap: () {
                            final route =
                                titleToRoute[pendingAuthList[index]['title']];
                            if (route != null) {
                              Navigator.pushNamed(context, route);
                            }
                          },
                        ),
                        childCount: pendingAuthList.length,
                      ),
                    ),
                  ),
                  // … your favorites section can go in another SliverToBoxAdapter
                ],
              ),
      // : SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       const Text('Pending Authorizations:'),
      //       const SizedBox(height: 20),
      //       Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: GridView.count(
      //           physics: const NeverScrollableScrollPhysics(),
      //           crossAxisCount: 3,
      //           crossAxisSpacing: 12.0,
      //           padding: const EdgeInsets.all(8.0),
      //           shrinkWrap: true,
      //           children:
      //               pendingAuthList.map((item) {
      //                 final title = item['title'] ?? '';
      //                 final count = item['count'] ?? 0;
      //                 return GestureDetector(
      //                   onTap: () {
      //                     final route = titleToRoute[title];
      //                     if (route != null) {
      //                       Navigator.pushNamed(context, route);
      //                     }
      //                   },
      //                   child: Card.filled(
      //                     child: Column(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       crossAxisAlignment:
      //                           CrossAxisAlignment.center,
      //                       children: [
      //                         Text(
      //                           title,
      //                           style: const TextStyle(
      //                             fontSize: 12,
      //                             overflow: TextOverflow.clip,
      //                           ),
      //                         ),
      //                         Text(
      //                           '$count',
      //                           style: const TextStyle(
      //                             fontSize: 20,
      //                             overflow: TextOverflow.clip,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               }).toList(),
      //         ),
      //       ),
      //       const SizedBox(height: 20),
      //       const Text('Favorite Pages:'),
      //       if (favoritePages.favoriteRoutes.isEmpty)
      //         const Text('No favorites yet.')
      //       else
      //         Column(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children:
      //               favoritePages.favoriteRoutes.map((route) {
      //                 final pageName = routeToPageName[route] ?? route;
      //                 return ActionChip(
      //                   label: Text(pageName),
      //                   onPressed: () {
      //                     Navigator.pushNamed(context, route);
      //                   },
      //                 );
      //               }).toList(),
      //         ),
      //     ],
      //   ),
      // ),
    );
  }
}

class _AuthTile extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;

  const _AuthTile({
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text('$count', style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
