import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/main.dart';
import 'package:nhapp/utils/rightsChecker.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:provider/provider.dart';
import 'package:nhapp/utils/token_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  List<Map<String, dynamic>> pendingAuthList = [];
  bool isLoading = false;
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeDefaultData();

    // Load data immediately when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRights();
      _loadPendingAuthenticationCount();
    });
  }

  void _initializeDefaultData() {
    pendingAuthList = [
      {'title': 'Purchase Orders', 'count': 0},
      {'title': 'Service Orders', 'count': 0},
      {'title': 'Labour PO', 'count': 0},
      {'title': 'Quotation', 'count': 0},
      {'title': 'Sales Order', 'count': 0},
    ];

    // Filter based on authorize rights (since this is for pending authorizations)
    pendingAuthList =
        pendingAuthList.where((item) {
          final title = item['title'] as String;
          return _canAuthorizeFeature(title);
        }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always refresh when dependencies change (page becomes visible)
    if (_isPageVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPendingAuthenticationCount();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _loadPendingAuthenticationCount();
    }
  }

  // Called when page becomes visible after navigation
  void _onPageResumed() {
    _isPageVisible = true;
    if (mounted) {
      _loadPendingAuthenticationCount();
    }
  }

  // Called when page becomes hidden (navigating away)
  void _onPagePaused() {
    _isPageVisible = false;
  }

  Future<void> _initializeRights() async {
    await RightsChecker.initializeRights();
    if (mounted) {
      setState(() {}); // Refresh UI after rights are loaded
    }
  }

  bool _canAuthorizeFeature(String title) {
    switch (title) {
      case 'Purchase Orders':
        return RightsChecker.hasRight(
          'Purchase Order',
          RightsChecker.AUTHORIZE,
        );
      case 'Service Orders':
        return RightsChecker.hasRight('Service Order', RightsChecker.AUTHORIZE);
      case 'Labour PO':
        return RightsChecker.hasRight('Labour PO', RightsChecker.AUTHORIZE);
      case 'Quotation':
        return RightsChecker.hasRight('Quotation', RightsChecker.AUTHORIZE);
      case 'Sales Order':
        return RightsChecker.hasRight('Sales Order', RightsChecker.AUTHORIZE);
      default:
        return false;
    }
  }

  // Future<void> _loadPendingAuthenticationCount() async {
  //   if (!mounted || !_isPageVisible) return;

  //   // Validate token before proceeding
  //   final isValid = await TokenUtils.isTokenValid(context);
  //   if (!isValid) {
  //     if (mounted) {
  //       setState(() {
  //         _initializeDefaultData();
  //       });
  //     }
  //     return;
  //   }

  //   try {
  //     final url = await StorageUtils.readValue('url');
  //     final companyDetails = await StorageUtils.readJson('selected_company');
  //     final locationDetails = await StorageUtils.readJson('selected_location');
  //     final tokenDetails = await StorageUtils.readJson('session_token');

  //     if (companyDetails == null ||
  //         companyDetails.isEmpty ||
  //         locationDetails == null ||
  //         locationDetails.isEmpty ||
  //         tokenDetails == null ||
  //         tokenDetails.isEmpty) {
  //       if (mounted) {
  //         setState(() {
  //           _initializeDefaultData();
  //         });
  //       }
  //       return;
  //     }

  //     final companyId = companyDetails['id'];
  //     final locationId = locationDetails['id'];
  //     final token = tokenDetails['token']['value'];

  //     Dio dio = Dio();
  //     dio.options.headers = {
  //       "Content-Type": "application/json; charset=utf-8",
  //       "Authorization": "Bearer $token",
  //     };
  //     dio.options.connectTimeout = const Duration(seconds: 10);
  //     dio.options.receiveTimeout = const Duration(seconds: 10);

  //     final response = await dio.get(
  //       'http://$url/api/Login/pendDashBoardCount',
  //       queryParameters: {'companyid': companyId, 'siteid': locationId},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = await compute(_parseJson, response.data);

  //       if (data['success'] == true && data['data'] is List) {
  //         if (mounted && _isPageVisible) {
  //           setState(() {
  //             pendingAuthList = List<Map<String, dynamic>>.from(data['data']);
  //           });
  //         }
  //       } else {
  //         if (mounted) {
  //           _showSnackBar(data['message'] ?? 'Unknown error');
  //         }
  //       }
  //     } else {
  //       if (mounted) {
  //         _showSnackBar('Error: ${response.statusCode}');
  //       }
  //     }
  //   } on DioException catch (e) {
  //     String message = 'Network error';
  //     if (e.response != null) {
  //       message = 'Failed: ${e.response?.statusCode}';
  //       if (e.response?.data is Map) {
  //         message += ' - ${e.response?.data['message']}';
  //       }
  //     } else {
  //       switch (e.type) {
  //         case DioExceptionType.connectionError:
  //           message = 'No internet connection';
  //           break;
  //         case DioExceptionType.receiveTimeout:
  //         case DioExceptionType.sendTimeout:
  //           message = 'Server timeout';
  //           break;
  //         case DioExceptionType.connectionTimeout:
  //           message = 'Connection timeout';
  //           break;
  //         default:
  //           message = 'Network error: ${e.message}';
  //       }
  //     }
  //     if (mounted) {
  //       _showSnackBar(message);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       _showSnackBar('Error loading data: $e');
  //     }
  //   }
  // }

  Future<void> _loadPendingAuthenticationCount() async {
    if (!mounted || !_isPageVisible) return;

    // Validate token before proceeding
    final isValid = await TokenUtils.isTokenValid(context);
    if (!isValid) {
      if (mounted) {
        setState(() {
          _initializeDefaultData();
        });
      }
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
        if (mounted) {
          setState(() {
            _initializeDefaultData();
          });
        }
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
        final data = await compute(_parseJson, response.data);

        if (data['success'] == true && data['data'] is List) {
          if (mounted && _isPageVisible) {
            // Filter the API response based on user rights
            final apiData = List<Map<String, dynamic>>.from(data['data']);
            final filteredData =
                apiData.where((item) {
                  final title = item['title'] as String;
                  return _canAuthorizeFeature(title);
                }).toList();

            setState(() {
              pendingAuthList = filteredData;
            });
          }
        } else {
          if (mounted) {
            _showSnackBar(data['message'] ?? 'Unknown error');
          }
        }
      } else {
        if (mounted) {
          _showSnackBar('Error: ${response.statusCode}');
        }
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
      if (mounted) {
        _showSnackBar(message);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading data: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    await _loadPendingAuthenticationCount();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
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

  Future<void> _navigateAndRefresh(String route) async {
    _onPagePaused(); // Mark page as not visible
    final result = await Navigator.pushNamed(context, route);
    _onPageResumed(); // Mark page as visible and refresh data
  }

  @override
  Widget build(BuildContext context) {
    final favoritePages = Provider.of<FavoritePages>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              await _navigateAndRefresh('/my_notification');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/img_new_horizon_logo.svg',
                    height: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New Horizon ERP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (_hasDashboardRights())
              ListTile(
                title: const Text('Dashboard'),
                onTap: () async {
                  Navigator.pop(context);
                  await _navigateAndRefresh('/dashboard');
                },
              ),
            if (_hasPurchaseRights())
              ExpansionTile(
                title: const Text('Purchase'),
                children: [
                  if (RightsChecker.canView('Purchase Orders') ||
                      RightsChecker.canPrint('Purchase Order Print'))
                    ListTile(
                      title: const Text('Purchase Order'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/purchase_orders');
                      },
                    ),
                  if (RightsChecker.canView('Service Order') ||
                      RightsChecker.canPrint('Service Order Print'))
                    ListTile(
                      title: const Text('Service Orders'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/service_orders');
                      },
                    ),
                  if (RightsChecker.canView('Labour PO') ||
                      RightsChecker.canPrint('Labour PO Print'))
                    ListTile(
                      title: const Text('Labour PO'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/labour_po');
                      },
                    ),
                ],
              ),
            if (_hasSalesRights())
              ExpansionTile(
                title: const Text('Sales'),
                children: [
                  if (RightsChecker.canView('Lead') ||
                      RightsChecker.canPrint('Inquiry Print'))
                    ListTile(
                      title: const Text('Leads'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/leads');
                      },
                    ),
                  if (RightsChecker.canView('Follow Up'))
                    ListTile(
                      title: const Text('Follow Up'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/follow_up');
                      },
                    ),
                  if (RightsChecker.canView('Quotation') ||
                      RightsChecker.canPrint('Quotation Print'))
                    ListTile(
                      title: const Text('Quotation'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/quotation');
                      },
                    ),
                  if (RightsChecker.canView('Sales Order') ||
                      RightsChecker.canPrint('Sales Order Print'))
                    ListTile(
                      title: const Text('Sales Order'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/sales_order');
                      },
                    ),
                  if (RightsChecker.canView('Proforma Invoice') ||
                      RightsChecker.canPrint('Proforma Invoice Print'))
                    ListTile(
                      title: const Text('Proforma Invoice'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _navigateAndRefresh('/proforma_invoice');
                      },
                    ),
                ],
              ),
            ExpansionTile(
              title: const Text('Settings'),
              children: [
                ListTile(
                  title: const Text('My Notification'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/my_notification');
                  },
                ),
                ListTile(
                  title: const Text('My Favourites'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateAndRefresh('/my_favourites');
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                if (await StorageUtils.readBool('remember_me')) {
                  await StorageUtils.deleteValue('session_token');
                  await StorageUtils.deleteValue('selected_company');
                  await StorageUtils.deleteValue('selected_location');
                  await StorageUtils.deleteValue('finance_period');
                } else {
                  await StorageUtils.clearAll();
                }
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending Authorizations:'),
                  if (isLoading) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AuthTile(
                    title: pendingAuthList[index]['title'] ?? '',
                    count: pendingAuthList[index]['count'] ?? 0,
                    onTap: () async {
                      final route =
                          titleToRoute[pendingAuthList[index]['title']];
                      if (route != null) {
                        await _navigateAndRefresh(route);
                      }
                    },
                  ),
                  childCount: pendingAuthList.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      'Favorite Pages:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    favoritePages.favoriteRoutes.isEmpty
                        ? Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No favorites yet.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.center,
                          children:
                              favoritePages.favoriteRoutes.map((route) {
                                final pageName =
                                    routeToPageName[route] ?? route;
                                return Card(
                                  elevation: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      await _navigateAndRefresh(route);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_border_outlined,
                                            size: 16,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            pageName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      'Quick Links:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.9,
                      children: [
                        if (RightsChecker.canView('Purchase Orders') ||
                            RightsChecker.canPrint('Purchase Order Print'))
                          _QuickLinkTile(
                            title: 'Purchase Orders',
                            icon: Icons.shopping_cart,
                            onTap:
                                () => _navigateAndRefresh('/purchase_orders'),
                          ),
                        if (RightsChecker.canView('Service Order') ||
                            RightsChecker.canPrint('Service Order Print'))
                          _QuickLinkTile(
                            title: 'Service Orders',
                            icon: Icons.build,
                            onTap: () => _navigateAndRefresh('/service_orders'),
                          ),
                        if (RightsChecker.canView('Labour PO') ||
                            RightsChecker.canPrint('Purchase Order Print'))
                          _QuickLinkTile(
                            title: 'Labour PO',
                            icon: Icons.person_outline,
                            onTap: () => _navigateAndRefresh('/labour_po'),
                          ),
                        if (RightsChecker.canView('Lead') ||
                            RightsChecker.canPrint('Inquiry Print'))
                          _QuickLinkTile(
                            title: 'Leads',
                            icon: Icons.track_changes,
                            onTap: () => _navigateAndRefresh('/leads'),
                          ),
                        if (RightsChecker.canView('Follow Up'))
                          _QuickLinkTile(
                            title: 'Follow Up',
                            icon: Icons.follow_the_signs,
                            onTap: () => _navigateAndRefresh('/follow_up'),
                          ),
                        if (RightsChecker.canView('Quotation') ||
                            RightsChecker.canPrint('Quotation Print'))
                          _QuickLinkTile(
                            title: 'Quotation',
                            icon: Icons.description,
                            onTap: () => _navigateAndRefresh('/quotation'),
                          ),
                        if (RightsChecker.canView('Sales Order') ||
                            RightsChecker.canPrint('Sales Order Print'))
                          _QuickLinkTile(
                            title: 'Sales Order',
                            icon: Icons.receipt_long,
                            onTap: () => _navigateAndRefresh('/sales_order'),
                          ),
                        if (RightsChecker.canView('Proforma Invoice') ||
                            RightsChecker.canPrint('Proforma Invoice Print'))
                          _QuickLinkTile(
                            title: 'Proforma Invoice',
                            icon: Icons.article,
                            onTap:
                                () => _navigateAndRefresh('/proforma_invoice'),
                          ),
                      ],
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

class _QuickLinkTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLinkTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

bool _hasPurchaseRights() {
  return RightsChecker.canView('Purchase Orders') ||
      RightsChecker.canView('Service Orders') ||
      RightsChecker.canView('Labour PO');
}

bool _hasSalesRights() {
  return RightsChecker.canView('Lead') ||
      RightsChecker.canView('Follow Up') ||
      RightsChecker.canView('Quotation') ||
      RightsChecker.canView('Sales Order') ||
      RightsChecker.canView('Proforma Invoice');
}

bool _hasDashboardRights() {
  return RightsChecker.canPrint('Functional Dashboard') ||
      RightsChecker.canPrint('Director Dashboard') ||
      RightsChecker.canPrint('Total Sales Region wise');
}
