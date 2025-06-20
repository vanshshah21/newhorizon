import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
import 'package:nhapp/utils/format_utils.dart';

class ProformaInvoiceDetailsPage extends StatefulWidget {
  final ProformaInvoice invoice;

  const ProformaInvoiceDetailsPage({required this.invoice, super.key});

  @override
  State<ProformaInvoiceDetailsPage> createState() =>
      _ProformaInvoiceDetailsPageState();
}

class _ProformaInvoiceDetailsPageState
    extends State<ProformaInvoiceDetailsPage> {
  ProformaInvoiceDetails? details;
  final ProformaInvoiceService service = ProformaInvoiceService();
  String? error;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final d = await service.fetchProformaInvoiceDetails(
        invSiteId: widget.invoice.siteId,
        invYear: widget.invoice.year,
        invGroup: widget.invoice.groupCode,
        invNumber: widget.invoice.number,
        piOn: widget.invoice.piOn,
        fromLocationId: widget.invoice.fromLocationId,
        custCode: widget.invoice.custCode,
      );
      if (!mounted) return;
      setState(() {
        details = d;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Proforma Details'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // PDF functionality
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading details...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error loading details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                _fetchDetails();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (details == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No details found'),
          ],
        ),
      );
    }

    final header = details!.headerDetail;
    final salesOrder = details!.salesOrderDetail ?? {};
    final items = (details!.gridDetail['itemDetail'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _fetchDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, header, salesOrder),
            const SizedBox(height: 16),
            // Only show items section if there are items
            if (items.isNotEmpty) ...[
              _buildItemsSection(context, items),
              const SizedBox(height: 16),
            ],
            _buildSummaryCard(context, header, items),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    Map<String, dynamic> header,
    Map<String, dynamic> salesOrder,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        header['invNumber']?.toString() ?? 'N/A',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Name
            _buildDetailRow(
              'Customer Name',
              header['customerName']?.toString() ?? 'N/A',
              Icons.business,
            ),
            const SizedBox(height: 12),

            // Select Preference (using currency code as preference)
            _buildDetailRow(
              'Select Preference',
              header['invCurrCode']?.toString() ??
                  salesOrder['currCode']?.toString() ??
                  'N/A',
              Icons.tune,
            ),
            const SizedBox(height: 12),

            // Quotation Number (using SO number if available)
            _buildDetailRow(
              'Quotation Number',
              salesOrder['soNumber']?.toString().isNotEmpty == true
                  ? salesOrder['soNumber'].toString()
                  : 'N/A',
              Icons.description,
            ),
            const SizedBox(height: 12),

            // Customer PO Number
            _buildDetailRow(
              'Customer PO Number',
              header['customerPoNumber']?.toString().isNotEmpty == true
                  ? header['customerPoNumber'].toString()
                  : salesOrder['poCustomerNumber']?.toString() ?? 'N/A',
              Icons.receipt_long,
            ),
            const SizedBox(height: 12),

            // Date
            _buildDetailRow(
              'Date',
              _formatDate(header['invIssueDate']?.toString()),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context, List items) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Items (${items.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCard(context, item, index);
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final theme = Theme.of(context);
    final qty = item['invoiceQty'] ?? item['qty'] ?? 0;
    final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0.0;
    final amount =
        double.tryParse(item['totalValue']?.toString() ?? '0') ?? 0.0;
    final discountAmount =
        double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Code/Name header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['itemCode']?.toString() ?? 'N/A',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item['itemName']?.toString() ?? 'N/A',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Item details grid
          Row(
            children: [
              Expanded(
                child: _buildItemDetail(
                  'Quantity',
                  '$qty ${item['suom'] ?? ''}',
                ),
              ),
              Expanded(
                child: _buildItemDetail('Rate', FormatUtils.formatAmount(rate)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildItemDetail(
                  'Amount',
                  FormatUtils.formatAmount(amount),
                ),
              ),
              Expanded(
                child: _buildItemDetail(
                  'Discount',
                  FormatUtils.formatAmount(discountAmount),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, dynamic> header,
    List items,
  ) {
    final theme = Theme.of(context);

    // Get amounts from header based on API response structure
    double basicAmount =
        double.tryParse(header['invBacAmount']?.toString() ?? '0') ?? 0.0;
    double discountedAmount =
        double.tryParse(header['invDiscountValue']?.toString() ?? '0') ?? 0.0;
    double taxAmount =
        double.tryParse(header['invTax']?.toString() ?? '0') ?? 0.0;
    double totalAmount =
        double.tryParse(header['invAmount']?.toString() ?? '0') ?? 0.0;

    // If total amount is not available, calculate from items
    if (totalAmount == 0.0 && items.isNotEmpty) {
      for (var item in items) {
        totalAmount +=
            double.tryParse(item['totalValue']?.toString() ?? '0') ?? 0.0;
      }
    }

    // If basic amount is not available from header, calculate from items
    if (basicAmount == 0.0 && items.isNotEmpty) {
      for (var item in items) {
        basicAmount +=
            double.tryParse(item['totalBasicValue']?.toString() ?? '0') ?? 0.0;
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Amount Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSummaryRow(
              'Basic Amount',
              FormatUtils.formatAmount(basicAmount),
            ),
            const SizedBox(height: 8),

            _buildSummaryRow(
              'Discounted Amount',
              FormatUtils.formatAmount(discountedAmount),
            ),
            const SizedBox(height: 8),

            _buildSummaryRow('Tax Amount', FormatUtils.formatAmount(taxAmount)),

            const Divider(height: 24),

            _buildSummaryRow(
              'Total Amount',
              FormatUtils.formatAmount(totalAmount),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isTotal
                  ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                  : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
        ),
        Text(
          value,
          style:
              isTotal
                  ? theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                  : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return FormatUtils.formatDateForUser(date);
    } catch (e) {
      return dateString.split('T').first;
    }
  }
}
