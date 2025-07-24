import 'package:flutter/material.dart';
import 'package:nhapp/pages/purchase_order/model/po_data.dart';
import 'package:nhapp/pages/purchase_order/pages/pdf_viewer_page.dart';
import 'package:nhapp/pages/purchase_order/services/po_service.dart';
import 'package:nhapp/pages/purchase_order/widgets/po_infinite_list_tab.dart';
import 'package:url_launcher/url_launcher.dart';

class POListPage extends StatefulWidget {
  const POListPage({super.key});

  @override
  State<POListPage> createState() => POListPageState();
}

class POListPageState extends State<POListPage> {
  final POService service = POService();

  Future<void> handlePdfTap(POData po, bool isRegular) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => POPdfLoaderPage(po: po, isRegular: isRegular),
      ),
    );
  }

  Future<void> handleCallTap(POData po) async {
    if (po.mobile.isNotEmpty) {
      final uri = Uri.parse('tel:${po.mobile}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot launch dialer')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Purchase Orders'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Regular'), Tab(text: 'Capital')],
          ),
        ),
        body: TabBarView(
          children: [
            POInfiniteListTab(
              isRegular: true,
              service: service,
              onPdfTap: (po) => handlePdfTap(po, true),
              onCallTap: handleCallTap,
            ),
            POInfiniteListTab(
              isRegular: false,
              service: service,
              onPdfTap: (po) => handlePdfTap(po, false),
              onCallTap: handleCallTap,
            ),
          ],
        ),
      ),
    );
  }
}
