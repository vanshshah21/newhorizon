import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nhapp/pages/ageing_of_receivable_overdue.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/authorize_labor_purchase_order_page.dart';
import 'package:nhapp/pages/authorize_purchase_order/authorize_purchase_order_page.dart';
import 'package:nhapp/pages/authorize_quotation/authorize_quotation_page.dart';
import 'package:nhapp/pages/authorize_sales_order/authorize_sales_order_page.dart';
import 'package:nhapp/pages/authorize_service_order/authorize_service_order.dart';
import 'package:nhapp/pages/best_selling_by_sales_amount.dart';
import 'package:nhapp/pages/customer_by_receivable_overdue.dart';
import 'package:nhapp/pages/customer_by_sales_amount.dart';
import 'package:nhapp/pages/delivery_overdue_item_wise.dart';
import 'package:nhapp/pages/dispatch_amount_by_months.dart';
import 'package:nhapp/pages/followup/followup.dart';
import 'package:nhapp/pages/followup/pages/add_follow_up.dart';
import 'package:nhapp/pages/leads/lead_list_page.dart';
import 'package:nhapp/pages/login/login_screen.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/porforma_invoice.dart';
import 'package:nhapp/pages/quotation/quotation.dart';
import 'package:nhapp/pages/recent_inquiries.dart';
import 'package:nhapp/pages/report_chart_page.dart';
import 'package:nhapp/pages/home_screen.dart';
import 'package:nhapp/pages/dashboard.dart';
import 'package:nhapp/pages/items_pending_for_delivery.dart';
import 'package:nhapp/pages/sales_analysis.dart';
import 'package:nhapp/pages/sales_order/sales_order_page.dart';
import 'package:nhapp/pages/upcoming_next_delivery.dart';
import 'package:nhapp/pages/labour_po/labour_po_page.dart';
import 'package:nhapp/pages/notifications/notification_page.dart';
import 'package:nhapp/pages/purchase_order/purchase_order_screen.dart';
import 'package:nhapp/pages/service_po/service_po_page.dart';
import 'package:nhapp/utils/theme.dart';
import 'dart:convert';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritePages(),
      child: const MyApp(),
    ),
    // const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NH Flutter App',
      theme: shadcnLightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const UserLoginScreen(),
        '/': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/purchase_orders': (context) => const POListPage(),
        '/service_orders': (context) => const ServiceOrdersScreen(),
        '/labour_po': (context) => const LabourPOScreen(),
        '/leads': (context) => const LeadListPage(),
        '/follow_up': (context) => FollowupListPage(),
        '/quotation': (context) => QuotationListPage(),
        '/sales_order': (context) => const SalesOrderListPage(),
        '/proforma_invoice': (context) => const ProformaInvoiceListPage(),
        '/my_notification': (context) => const NotificationListPage(),
        '/my_favourites': (context) => const MyFavouritesScreen(),
        '/dashboard_details':
            (context) => DashboardDetailsScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        // '/purchase_order_details':
        //     (context) => PurchaseOrderDetailsScreen(
        //       po: ModalRoute.of(context)?.settings.arguments as PurchaseOrder,
        //     ),
        '/service_order_details':
            (context) => ServiceOrderDetailsScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/labour_po_details':
            (context) => LabourPODetailsScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/add_lead': (context) => AddLeadScreen(),
        '/edit_lead':
            (context) => EditLeadScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/lead_detail':
            (context) => LeadDetailsScreen(
              item:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[0]
                      as String,
              iseditable:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[1]
                      as bool,
            ),
        '/follow_up_detail':
            (context) => FollowUpDetailsScreen(
              item:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[0]
                      as String,
              iseditable:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[1]
                      as bool,
            ),
        '/add_follow_up_detail': (context) => const AddFollowUpScreen(),
        '/edit_follow_up':
            (context) => EditFollowUpScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/quotation_detail':
            (context) => QuotationDetailsScreen(
              item:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[0]
                      as String,
              iseditable:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[1]
                      as bool,
            ),
        '/add_quotation': (context) => const AddQuotationScreen(),
        '/edit_quotation':
            (context) => EditQuotationScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/sales_order_detail':
            (context) => SalesOrderDetailsScreen(
              item:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[0]
                      as String,
              iseditable:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[1]
                      as bool,
            ),
        '/add_sales_order': (context) => const AddSalesOrderScreen(),
        '/edit_sales_order':
            (context) => EditSalesOrderScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/proforma_invoice_detail':
            (context) => ProformaInvoiceDetailsScreen(
              item:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[0]
                      as String,
              iseditable:
                  (ModalRoute.of(context)?.settings.arguments
                          as List<dynamic>)[1]
                      as bool,
            ),
        '/add_proforma_invoice': (context) => const AddProformaInvoiceForm(),
        '/edit_proforma_invoice':
            (context) => EditProformaInvoiceScreen(
              item: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/authorize_purchase_orders': (context) => const AuthorizePOListPage(),
        '/authorize_service_orders': (context) => const ServiceOrderListPage(),
        '/authorize_labour_purchase_orders':
            (context) => const LaborPOListPage(),

        '/authorize_quotations':
            (context) => const AuthorizeQuotationListPage(),
        '/authorize_sales_orders':
            (context) => const AuthorizeSalesOrderListPage(),
        '/items_pending_for_delivery':
            (context) => const ItemsForPendingDelivery(),
        '/upcoming_next_delivery': (context) => const UpcomingNextDelivery(),
        '/delivery_overdue': (context) => const DeliveryOverdue(),
        '/director_report_chart': (context) => const ReportChartPage(),
        '/customer_by_sales_amount':
            (context) => const CustomerBySalesAmountPage(),
        '/best_selling_items_by_sales_amount':
            (context) => const BestSellingBySalesAmountPage(),
        '/customers_by_receivable_overdue_chart':
            (context) => const CustomerByReceivableOverduePage(),
        '/sales_analysis': (context) => const SalesAnalysisPage(),
        '/ageing_of_receivable_overdue':
            (context) => const AgeingOfReceivableOverduePage(),
        '/dispatch_amount_by_months':
            (context) => const DispatchAmountByMonthsPage(),
        '/recent_inquiries': (context) => const RecentInquiryPage(),
        "/followup/create": (context) => const AddFollowUpForm(),
      },
    );
  }
}

class DashboardDetailsScreen extends StatelessWidget {
  final String item;

  const DashboardDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(child: Text('Details of $item')),
    );
  }
}

class ServiceOrdersScreen extends StatelessWidget {
  const ServiceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Service Orders')),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ServicePOListPage(),
        ),
      ),
    );
  }
}

class ServiceOrderDetailsScreen extends StatelessWidget {
  final String item;

  const ServiceOrderDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(child: Text('Details of Service Order $item')),
    );
  }
}

class LabourPOScreen extends StatelessWidget {
  const LabourPOScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Labour PO')),
      body: LabourPOListPage(),
    );
  }
}

class LabourPODetailsScreen extends StatelessWidget {
  final String item;

  const LabourPODetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: Center(child: Text('Details of Labour PO $item')),
    );
  }
}

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leads')),
      body: LeadListPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_lead');
        },
        tooltip: 'Add Lead',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddLeadScreen extends StatelessWidget {
  const AddLeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Lead')),
      body: Center(child: Text('Add Lead')),
    );
  }
}

class LeadDetailsScreen extends StatelessWidget {
  final String item;
  final bool iseditable;

  const LeadDetailsScreen({
    super.key,
    required this.item,
    required this.iseditable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Lead')),
      body: Center(
        child: Column(
          children: [
            Text('Details of Lead $item, Editable: $iseditable'),
            iseditable
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text("Follow up"),
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_follow_up_detail');
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(child: Text("Quotation"), onPressed: () {}),
                    SizedBox(width: 10),
                    ElevatedButton(
                      child: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_lead',
                          arguments: item,
                        );
                      },
                    ),
                  ],
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class EditLeadScreen extends StatelessWidget {
  final String item;

  const EditLeadScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Lead')),
      body: Center(child: Text('Edit Details of Lead $item')),
    );
  }
}

class FollowUpScreen extends StatelessWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Follow Up')),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              String item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/follow_up_detail',
                    arguments: [item, index % 2 == 0 ? false : true],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_follow_up_detail');
        },
        tooltip: 'Add Lead',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddFollowUpScreen extends StatelessWidget {
  const AddFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Follow Up')),
      body: Center(child: Text('Add Follow Up')),
    );
  }
}

class FollowUpDetailsScreen extends StatelessWidget {
  final String item;
  final bool iseditable;

  const FollowUpDetailsScreen({
    super.key,
    required this.item,
    required this.iseditable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Followup')),
      body: Center(
        child: Column(
          children: [
            Text('Details of Lead $item, Editable: $iseditable'),
            iseditable
                ? ElevatedButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_follow_up',
                      arguments: item,
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class EditFollowUpScreen extends StatelessWidget {
  final String item;

  const EditFollowUpScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Followup')),
      body: Center(child: Column(children: [Text('Details of Lead $item')])),
    );
  }
}

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotation')),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              String item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/quotation_detail',
                    arguments: [item, index % 2 == 0 ? false : true],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_quotation');
        },
        tooltip: 'Add Quotation',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class QuotationDetailsScreen extends StatelessWidget {
  final String item;
  final bool iseditable;

  const QuotationDetailsScreen({
    super.key,
    required this.item,
    required this.iseditable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Quotation')),
      body: Center(
        child: Column(
          children: [
            Text('Details of Quotation $item, Editable: $iseditable'),
            iseditable
                ? ElevatedButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_quotation',
                      arguments: item,
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class AddQuotationScreen extends StatelessWidget {
  const AddQuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Quotation')),
      body: Center(child: Text('Add Quotation')),
    );
  }
}

class EditQuotationScreen extends StatelessWidget {
  final String item;

  const EditQuotationScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Quotation')),
      body: Center(
        child: Column(children: [Text('Details of Quotation $item')]),
      ),
    );
  }
}

class SalesOrderScreen extends StatelessWidget {
  const SalesOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Order')),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              String item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/sales_order_detail',
                    arguments: [item, index % 2 == 0 ? false : true],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_sales_order');
        },
        tooltip: 'Add Sales Order',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SalesOrderDetailsScreen extends StatelessWidget {
  final String item;
  final bool iseditable;

  const SalesOrderDetailsScreen({
    super.key,
    required this.item,
    required this.iseditable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Sales Order')),
      body: Center(
        child: Column(
          children: [
            Text('Details of Sales Order $item, Editable: $iseditable'),
            iseditable
                ? ElevatedButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_sales_order',
                      arguments: item,
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class AddSalesOrderScreen extends StatelessWidget {
  const AddSalesOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Sales Order')),
      body: Center(child: Text('Add Sales Order')),
    );
  }
}

class EditSalesOrderScreen extends StatelessWidget {
  final String item;

  const EditSalesOrderScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Sales Order')),
      body: Center(
        child: Column(children: [Text('Details of Sales Order $item')]),
      ),
    );
  }
}

class ProformaInvoiceScreen extends StatelessWidget {
  const ProformaInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proforma Invoice')),
      body: Scrollbar(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              String item = 'Item ${index + 1}';
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/proforma_invoice_detail',
                    arguments: [item, index % 2 == 0 ? false : true],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_proforma_invoice');
        },
        tooltip: 'Add Proforma Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProformaInvoiceDetailsScreen extends StatelessWidget {
  final String item;
  final bool iseditable;

  const ProformaInvoiceDetailsScreen({
    super.key,
    required this.item,
    required this.iseditable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Proforma Invoice')),
      body: Center(
        child: Column(
          children: [
            Text('Details of Proforma Invoice $item, Editable: $iseditable'),
            iseditable
                ? ElevatedButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_proforma_invoice',
                      arguments: item,
                    );
                  },
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class AddProformaInvoiceScreen extends StatelessWidget {
  const AddProformaInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Proforma Invoice')),
      body: Center(child: Text('Add Proforma Invoice')),
    );
  }
}

class EditProformaInvoiceScreen extends StatelessWidget {
  final String item;

  const EditProformaInvoiceScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Proforma Invoice')),
      body: Center(
        child: Column(children: [Text('Details of Proforma Invoice $item')]),
      ),
    );
  }
}

class MyNotificationScreen extends StatelessWidget {
  const MyNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notification')),
      body: Center(child: Text('My Notification Content')),
    );
  }
}

class FavoritePages extends ChangeNotifier {
  List<String> favoriteRoutes = [];

  FavoritePages() {
    _loadFavorites();
  }

  bool isFavorite(String routeName) {
    return favoriteRoutes.contains(routeName);
  }

  void addFavorite(String routeName) async {
    if (!favoriteRoutes.contains(routeName)) {
      favoriteRoutes.add(routeName);
      await _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(String routeName) async {
    if (favoriteRoutes.contains(routeName)) {
      favoriteRoutes.remove(routeName);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteRoutes = prefs.getStringList('favoriteRoutes') ?? [];
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteRoutes', favoriteRoutes);
  }
}

class MyFavouritesScreen extends StatefulWidget {
  const MyFavouritesScreen({super.key});

  @override
  MyFavouritesScreenState createState() => MyFavouritesScreenState();
}

class MyFavouritesScreenState extends State<MyFavouritesScreen> {
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

  @override
  Widget build(BuildContext context) {
    final favoritePages = Provider.of<FavoritePages>(context);

    return Scaffold(
      appBar: AppBar(title: Text('My Favourites')),
      body: ListView.builder(
        itemCount: routeToPageName.length,
        itemBuilder: (context, index) {
          final routeName = routeToPageName.keys.elementAt(index);
          final pageName = routeToPageName[routeName] ?? routeName;

          return ListTile(
            title: Text(pageName),
            trailing: IconButton(
              icon: Icon(
                favoritePages.isFavorite(routeName)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoritePages.isFavorite(routeName) ? Colors.red : null,
              ),
              onPressed: () {
                if (favoritePages.isFavorite(routeName)) {
                  favoritePages.removeFavorite(routeName);
                } else {
                  favoritePages.addFavorite(routeName);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class AuthorizeQuotationScreen extends StatefulWidget {
  const AuthorizeQuotationScreen({super.key});

  @override
  AuthorizeQuotationScreenState createState() =>
      AuthorizeQuotationScreenState();
}

class AuthorizeQuotationScreenState extends State<AuthorizeQuotationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchControllerTab1 = TextEditingController();
  final TextEditingController _searchControllerTab2 = TextEditingController();
  String _searchTextTab1 = '';
  String _searchTextTab2 = '';
  final List<int> _selectedItemsTab1 = [];
  final List<int> _selectedItemsTab2 = [];
  late Future<List<String>> futureItemsTab1;
  late Future<List<String>> futureItemsTab2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureItemsTab1 = _fetchItems();
    futureItemsTab2 = _fetchItems();
  }

  Future<List<String>> _fetchItems() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return List.generate(20, (index) => 'Item ${index + 1}');
    } catch (e) {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _refreshItems(int tabIndex) async {
    setState(() {
      if (tabIndex == 0) {
        futureItemsTab1 = _fetchItems();
      } else {
        futureItemsTab2 = _fetchItems();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllerTab1.dispose();
    _searchControllerTab2.dispose();
    super.dispose();
  }

  void _toggleSelection(int index, int tabIndex) {
    setState(() {
      final selectedItems =
          tabIndex == 0 ? _selectedItemsTab1 : _selectedItemsTab2;
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorize Quotation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
          onTap: (index) {
            if (index == 0) {
              _searchControllerTab2.clear();
              setState(() {
                _searchTextTab2 = '';
              });
            } else {
              _searchControllerTab1.clear();
              setState(() {
                _searchTextTab1 = '';
              });
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildTabContent(
                  0,
                  _searchControllerTab1,
                  _searchTextTab1,
                  _selectedItemsTab1,
                ),
                _buildTabContent(
                  1,
                  _searchControllerTab2,
                  _searchTextTab2,
                  _selectedItemsTab2,
                ),
              ],
            ),
          ),
          if (_selectedItemsTab1.isNotEmpty || _selectedItemsTab2.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // authorization logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      content: Text(
                        '${_selectedItemsTab1.isNotEmpty ? _selectedItemsTab1 : ''} ${_selectedItemsTab2.isNotEmpty ? _selectedItemsTab2 : ''} Authorized successfully! ',
                      ),
                    ),
                  );
                },
                child: Text('Authorize'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    TextEditingController searchController,
    String searchText,
    List<int> selectedItems,
  ) {
    final futureItems = tabIndex == 0 ? futureItemsTab1 : futureItemsTab2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    if (tabIndex == 0) {
                      _searchTextTab1 = '';
                    } else {
                      _searchTextTab2 = '';
                    }
                  });
                },
              ),
            ),
            onChanged: (text) {
              setState(() {
                if (tabIndex == 0) {
                  _searchTextTab1 = text;
                } else {
                  _searchTextTab2 = text;
                }
              });
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshItems(tabIndex),
            child: FutureBuilder<List<String>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _refreshItems(tabIndex),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final items =
                      snapshot.data!
                          .where(
                            (item) => item.toLowerCase().contains(
                              searchText.toLowerCase(),
                            ),
                          )
                          .toList();

                  if (items.isEmpty) {
                    return Center(child: Text('No items found.'));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CheckboxListTile(
                        title: Text(item),
                        value: selectedItems.contains(index),
                        onChanged: (_) => _toggleSelection(index, tabIndex),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AuthorizeSalesOrderScreen extends StatefulWidget {
  const AuthorizeSalesOrderScreen({super.key});

  @override
  AuthorizeSalesOrderScreenState createState() =>
      AuthorizeSalesOrderScreenState();
}

class AuthorizeSalesOrderScreenState extends State<AuthorizeSalesOrderScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchControllerTab1 = TextEditingController();
  final TextEditingController _searchControllerTab2 = TextEditingController();
  String _searchTextTab1 = '';
  String _searchTextTab2 = '';
  final List<int> _selectedItemsTab1 = [];
  final List<int> _selectedItemsTab2 = [];
  late Future<List<String>> futureItemsTab1;
  late Future<List<String>> futureItemsTab2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureItemsTab1 = _fetchItems();
    futureItemsTab2 = _fetchItems();
  }

  Future<List<String>> _fetchItems() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      return List.generate(20, (index) => 'Item ${index + 1}');
    } catch (e) {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _refreshItems(int tabIndex) async {
    setState(() {
      if (tabIndex == 0) {
        futureItemsTab1 = _fetchItems();
      } else {
        futureItemsTab2 = _fetchItems();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllerTab1.dispose();
    _searchControllerTab2.dispose();
    super.dispose();
  }

  void _toggleSelection(int index, int tabIndex) {
    setState(() {
      final selectedItems =
          tabIndex == 0 ? _selectedItemsTab1 : _selectedItemsTab2;
      if (selectedItems.contains(index)) {
        selectedItems.remove(index);
      } else {
        selectedItems.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorize Sales Order'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
          onTap: (index) {
            if (index == 0) {
              _searchControllerTab2.clear();
              setState(() {
                _searchTextTab2 = '';
              });
            } else {
              _searchControllerTab1.clear();
              setState(() {
                _searchTextTab1 = '';
              });
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildTabContent(
                  0,
                  _searchControllerTab1,
                  _searchTextTab1,
                  _selectedItemsTab1,
                ),
                _buildTabContent(
                  1,
                  _searchControllerTab2,
                  _searchTextTab2,
                  _selectedItemsTab2,
                ),
              ],
            ),
          ),
          if (_selectedItemsTab1.isNotEmpty || _selectedItemsTab2.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // authorization logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      content: Text(
                        '${_selectedItemsTab1.isNotEmpty ? _selectedItemsTab1 : ''} ${_selectedItemsTab2.isNotEmpty ? _selectedItemsTab2 : ''} Authorized successfully! ',
                      ),
                    ),
                  );
                },
                child: Text('Authorize'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    TextEditingController searchController,
    String searchText,
    List<int> selectedItems,
  ) {
    final futureItems = tabIndex == 0 ? futureItemsTab1 : futureItemsTab2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    if (tabIndex == 0) {
                      _searchTextTab1 = '';
                    } else {
                      _searchTextTab2 = '';
                    }
                  });
                },
              ),
            ),
            onChanged: (text) {
              setState(() {
                if (tabIndex == 0) {
                  _searchTextTab1 = text;
                } else {
                  _searchTextTab2 = text;
                }
              });
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshItems(tabIndex),
            child: FutureBuilder<List<String>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _refreshItems(tabIndex),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final items =
                      snapshot.data!
                          .where(
                            (item) => item.toLowerCase().contains(
                              searchText.toLowerCase(),
                            ),
                          )
                          .toList();

                  if (items.isEmpty) {
                    return Center(child: Text('No items found.'));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CheckboxListTile(
                        title: Text(item),
                        value: selectedItems.contains(index),
                        onChanged: (_) => _toggleSelection(index, tabIndex),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _urlController = TextEditingController(text: "192.168.0.172:9001");
//   final _usernameController = TextEditingController(text: "su");
//   final _passwordController = TextEditingController(text: "us");
//   Map<String, dynamic>? _selectedCompany;
//   Map<String, dynamic>? _selectedLocation;
//   bool success = false;
//   int _step = 1;
//   bool _rememberMe = false;
//   bool isLoading = false;
//   final _storage = FlutterSecureStorage();
//   List<Map<String, dynamic>> _companies = [];
//   List<Map<String, dynamic>> _locations = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   Future<void> _loadSavedCredentials() async {
//     final url = await _storage.read(key: 'url');
//     final username = await _storage.read(key: 'username');
//     final password = await _storage.read(key: 'password');
//     if (url != null && username != null && password != null) {
//       setState(() {
//         _urlController.text = url;
//         _usernameController.text = username;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   Future<void> _getCompanyAndLocation() async {
//     final dio = Dio();
//     try {
//       final username = await _storage.read(key: 'username');
//       final url = await _storage.read(key: 'url');
//       if (username == null || url == null) {
//         print("Error: Username or URL not found in storage.");
//         return;
//       }
//       Response response = await dio.get(
//         'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//         queryParameters: {'UserName': username},
//       );
//       if (response.statusCode == 200) {
//         print('API Response Data Type: ${response.data.runtimeType}');
//         print('API Response Data: ${response.data}');
//         Map<String, dynamic> decodedJson = jsonDecode(response.data);

//         List<Map<String, dynamic>> companyObjects = [];
//         List<Map<String, dynamic>> locationObjects = [];

//         final responseMap = decodedJson;
//         final data = responseMap['data'];
//         if (data is Map<String, dynamic>) {
//           final companiesData = data['companies'];
//           if (companiesData is List) {
//             companyObjects = companiesData.cast<Map<String, dynamic>>();
//           } else {
//             print("Warning: 'companies' data is not a List or is null.");
//           }

//           final locationsData = data['locations'];
//           if (locationsData is List) {
//             locationObjects = locationsData.cast<Map<String, dynamic>>();
//           } else {
//             print("Warning: 'locations' data is not a List or is null.");
//           }
//         } else {
//           print(
//             "Error: The 'data' field within the response is not a Map or is null.",
//           );
//         }

//         if (mounted) {
//           setState(() {
//             _companies =
//                 companyObjects.isNotEmpty
//                     ? companyObjects
//                     : [
//                       {'name': 'Default Company'},
//                     ];
//             _locations =
//                 locationObjects.isNotEmpty
//                     ? locationObjects
//                     : [
//                       {'name': 'Default Location'},
//                     ];

//             _selectedCompany =
//                 companyObjects.length == 1 ? companyObjects[0] : null;
//             _selectedLocation =
//                 locationObjects.length == 1 ? locationObjects[0] : null;
//           });
//         }
//       } else {
//         print(
//           "Error fetching company/location: Status code ${response.statusCode}",
//         );
//       }
//     } catch (e) {
//       print("Exception during _getCompanyAndLocation: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching company/location data: $e')),
//         );

//         setState(() {
//           _companies = [
//             {'name': 'Default Company'},
//           ];
//           _locations = [
//             {'name': 'Default Location'},
//           ];
//           _selectedCompany = null;
//           _selectedLocation = null;
//         });
//       }
//     }
//   }

//   Future<void> _login() async {
//     final String url = _urlController.text.trim();
//     final String username = _usernameController.text.trim();
//     final String password = _passwordController.text.trim();
//     if (url.isEmpty || username.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
//       return;
//     }
//     try {
//       if (_rememberMe) {
//         await _storage.write(key: 'url', value: url);
//         await _storage.write(key: 'username', value: username);
//         await _storage.write(key: 'password', value: password);
//       } else {
//         await _storage.deleteAll();
//       }
//       final dio = Dio();
//       dio.options.connectTimeout = const Duration(seconds: 5);
//       // dio.options.receiveTimeout = const Duration(seconds: 5);
//       Response response = await dio.post(
//         'http://$url/api/Login/LoginCall',
//         data: {'userName': username, 'password': password},
//       );
//       print(response);
//       print(response.runtimeType);
//       if (response.statusCode == 200) {
//         await _storage.write(
//           key: 'session_token',
//           value: jsonEncode(response.data['data']),
//         );

//         success = true;
//         await _getCompanyAndLocation();
//         // Navigator.pushReplacementNamed(context, '/');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login failed: ${response.statusCode}')),
//         );
//       }
//     } on DioException catch (e) {
//       // Handle Dio-specific errors
//       if (e.response != null) {
//         // Server responded with non-2xx status (e.g., 401, 404)
//         String errorMessage = 'Login failed: ${e.response?.statusCode}';
//         if (e.response?.data is Map) {
//           errorMessage += ' - ${e.response?.data['message']}';
//         }
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(errorMessage)));
//       } else {
//         // Network error (e.g., timeout, no internet)
//         switch (e.type) {
//           case DioExceptionType.connectionError:
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('No internet connection')));
//             break;
//           case DioExceptionType.receiveTimeout:
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Server didn\'t send data in time!')),
//             );
//             break;
//           case DioExceptionType.connectionTimeout:
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   'Connection Timeout: Please check your connection and try again.',
//                 ),
//               ),
//             );
//             break;
//           default:
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
//             break;
//         }
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
//     }
//   }

//   void _handleNextStep() async {
//     if (_urlController.text.isNotEmpty &&
//         _usernameController.text.isNotEmpty &&
//         _passwordController.text.isNotEmpty) {
//       setState(() {
//         isLoading = true;
//       });
//       await _login();
//       setState(() {
//         if (success) {
//           _step = 2;
//         } else {
//           _step = 1;
//         }
//         isLoading = false;
//       });
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Please fill all fields')));
//     }
//   }

//   void _handleLogin() async {
//     if (_selectedCompany != null && _selectedLocation != null) {
//       // Save selected company/location if needed for the session
//       await _storage.write(
//         key: 'selected_company',
//         value: jsonEncode(_selectedCompany),
//       );
//       await _storage.write(
//         key: 'selected_location',
//         value: jsonEncode(_selectedLocation!),
//       );

//       Navigator.pushReplacementNamed(context, '/');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Logged in successfully!')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select both company and location')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF4F4F4),
//       appBar: AppBar(
//         title: Text('Login'),
//         automaticallyImplyLeading: _step != 1,
//         leading:
//             _step != 1
//                 ? IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: () {
//                     setState(() {
//                       _step = 1; // Go back to step 1
//                     });
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
//               if (_step == 1) ...[
//                 TextField(
//                   decoration: InputDecoration(hintText: "URL"),
//                   controller: _urlController,
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(hintText: "Username"),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(hintText: "Password"),
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _rememberMe,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           _rememberMe =
//                               value ?? false; // Handle null explicitly
//                         });
//                       },
//                     ),
//                     Text('Remember Me'),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: isLoading ? null : _handleNextStep,
//                   child:
//                       isLoading
//                           ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                           : Text('Next'),
//                 ),
//                 SizedBox(height: 10),
//               ] else if (_step == 2) ...[
//                 DropdownButtonFormField<Map<String, dynamic>>(
//                   value: _selectedCompany,
//                   items:
//                       _companies
//                           .map<DropdownMenuItem<Map<String, dynamic>>>(
//                             (company) => DropdownMenuItem<Map<String, dynamic>>(
//                               value: company,
//                               child: Text(company['name']),
//                             ),
//                           )
//                           .toList(),
//                   onChanged: (Map<String, dynamic>? value) {
//                     setState(() {
//                       _selectedCompany = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Company',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 DropdownButtonFormField<Map<String, dynamic>>(
//                   value: _selectedLocation,
//                   items:
//                       _locations
//                           .map<DropdownMenuItem<Map<String, dynamic>>>(
//                             (location) =>
//                                 DropdownMenuItem<Map<String, dynamic>>(
//                                   value: location,
//                                   child: Text(location['name']),
//                                 ),
//                           )
//                           .toList(),
//                   onChanged: (Map<String, dynamic>? value) {
//                     setState(() {
//                       _selectedLocation = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Select Location',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(onPressed: _handleLogin, child: Text('Login')),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _urlController = TextEditingController(text: "192.168.0.172:9001");
  final _usernameController = TextEditingController(text: "su");
  final _passwordController = TextEditingController(text: "us");

  Map<String, dynamic>? _selectedCompany;
  Map<String, dynamic>? _selectedLocation;

  int _step = 1;
  bool _rememberMe = false;
  bool isLoading = false;

  late final FlutterSecureStorage _storage;
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final url = await _storage.read(key: 'url');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');

    if (url != null && username != null && password != null) {
      setState(() {
        _urlController.text = url;
        _usernameController.text = username;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  Future<void> _getCompanyAndLocation() async {
    final dio = Dio();

    try {
      final username = await _storage.read(key: 'username');
      final url = await _storage.read(key: 'url');

      if (username == null || url == null) {
        showSnackBar('Username or URL not found.');
        return;
      }

      final response = await dio.get(
        'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
        queryParameters: {'UserName': username},
      );
      debugPrint("API Response: ${response.data}");
      debugPrint("API Response Type: ${response.data.runtimeType}");
      if (response.statusCode == 200 && response.data["success"]) {
        final data = response.data['data'] as Map<String, dynamic>;
        final companyData = data['companies'];
        final locationData = data['locations'];

        final companies = companyData;
        final locations = locationData;

        setState(() {
          _companies = companies ?? [defaultCompany];
          _locations = locations ?? [defaultLocation];

          _selectedCompany = companies.length == 1 ? companies[0] : null;
          _selectedLocation = locations.length == 1 ? locations[0] : null;
        });
      } else {
        showSnackBar(
          'Failed to fetch company/location: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Exception during _getCompanyAndLocation: $e");
      showSnackBar('Error fetching company/location: $e');

      setState(() {
        _companies = [defaultCompany];
        _locations = [defaultLocation];
        _selectedCompany = null;
        _selectedLocation = null;
      });
    }
  }

  Future<void> _login() async {
    final url = _urlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (url.isEmpty || username.isEmpty || password.isEmpty) {
      showSnackBar('Please fill all fields.');
      return;
    }

    if (_rememberMe) {
      await _storage.write(key: 'url', value: url);
      await _storage.write(key: 'username', value: username);
      await _storage.write(key: 'password', value: password);
    } else {
      await _storage.deleteAll();
    }

    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 5);

    try {
      final response = await dio.post(
        'http://$url/api/Login/LoginCall',
        data: {'userName': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await _storage.write(
          key: 'session_token',
          value: jsonEncode(response.data['data']),
        );
        await _getCompanyAndLocation();
      } else {
        showSnackBar('Login failed: ${response.statusCode}');
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
    } catch (e) {
      showSnackBar('Login failed: $e');
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

    await _login();

    if (mounted) {
      setState(() {
        _step = 2;
        isLoading = false;
      });
    }
  }

  void _handleLogin() async {
    if (_selectedCompany != null && _selectedLocation != null) {
      await _storage.write(
        key: 'selected_company',
        value: jsonEncode(_selectedCompany),
      );
      await _storage.write(
        key: 'selected_location',
        value: jsonEncode(_selectedLocation),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
        showSnackBar('Logged in successfully!');
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

  static final defaultCompany = {'name': 'Default Company'};
  static final defaultLocation = {'name': 'Default Location'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: _step != 1,
        leading:
            _step != 1
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _step = 1;
                      });
                    }
                  },
                )
                : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_step == 1)
                Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(hintText: "URL"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(hintText: "Username"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "Password"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            }
                          },
                        ),
                        const Text('Remember Me'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleNextStep,
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Next'),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              else if (_step == 2)
                Column(
                  children: [
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedCompany,
                      items:
                          _companies.map((company) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: company,
                              child: Text(company['name']),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedCompany = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Company',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedLocation,
                      items:
                          _locations.map((location) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: location,
                              child: Text(location['name']),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedLocation = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login'),
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

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Future.delayed(Duration(seconds: 3));
//       final storage = FlutterSecureStorage();
//       final value = await storage.read(key: 'session_token');
//       if (value != null) {
//         Navigator.of(
//           context,
//         ).pushNamedAndRemoveUntil('/', (Route route) => false);
//       } else {
//         Navigator.of(
//           context,
//         ).pushNamedAndRemoveUntil('/login', (Route route) => false);
//       }
//     });

//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.align_vertical_center_rounded,
//               size: 100,
//               color: Colors.blue,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Welcome to NewHorizon',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Move async logic to initState (more idiomatic than addPostFrameCallback)
//     _checkLoginStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _buildSplashUI();
//   }

//   Widget _buildSplashUI() {
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.align_vertical_center_rounded,
//               size: 100,
//               color: Colors.blue,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Welcome to NewHorizon',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _checkLoginStatus() async {
//     final storage = const FlutterSecureStorage(); // Use const if possible
//     final sessionToken = await storage.read(key: 'session_token');

//     if (mounted) {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         sessionToken != null ? '/' : '/login',
//         (Route<dynamic> route) => false,
//       );
//     }
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.align_vertical_center_rounded,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to NewHorizon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    final storage = const FlutterSecureStorage();
    final sessionToken = await storage.read(key: 'session_token');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      sessionToken != null ? '/' : '/login',
      (Route<dynamic> route) => false,
    );
  }
}
