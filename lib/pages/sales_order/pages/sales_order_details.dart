import 'package:flutter/material.dart';
import 'package:nhapp/pages/sales_order/models/sales_order_detail.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/sales_order.dart';
import '../service/sales_order_service.dart';

class SalesOrderDetailsPage extends StatefulWidget {
  final SalesOrder salesOrder;

  const SalesOrderDetailsPage({required this.salesOrder, super.key});

  @override
  State<SalesOrderDetailsPage> createState() => _SalesOrderDetailsPageState();
}

class _SalesOrderDetailsPageState extends State<SalesOrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late final SalesOrderService _service;
  late final TabController _tabController;
  SalesOrderDetailsResponse? _details;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = SalesOrderService();
    _tabController = TabController(length: 6, vsync: this);
    _loadDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final details = await _service.fetchSalesOrderDetails(widget.salesOrder);

      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SO #${widget.salesOrder.ioNumber}'),
        bottom:
            _isLoading || _error != null
                ? null
                : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Items'),
                    Tab(text: 'Taxes'),
                    Tab(text: 'Delivery'),
                    Tab(text: 'Terms'),
                    Tab(text: 'Contacts'),
                  ],
                ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetails, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_details == null || _details!.data.salesOrderDetails.isEmpty) {
      return const Center(child: Text('No details available'));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildItemsTab(),
        _buildTaxesTab(),
        _buildDeliveryTab(),
        _buildTermsTab(),
        _buildContactsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final detail = _details!.data.salesOrderDetails.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Sales Order Information', [
            _buildInfoRow('SO Number', '${detail.ioYear}/${detail.ioNumber}'),
            _buildInfoRow('Date', FormatUtils.formatDateForUser(detail.ioDate)),
            _buildInfoRow('Status', detail.orderStatus),
            _buildInfoRow('Currency', detail.currencyFullName),
            _buildInfoRow(
              'Total Amount',
              FormatUtils.formatAmount(
                detail.totalAmountAfterTaxCustomerCurrency,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Customer Information', [
            _buildInfoRow('Customer Code', detail.customerCode),
            _buildInfoRow('Customer Name', detail.customerFullName),
            _buildInfoRow('GST Number', detail.gstNo),
            _buildInfoRow('Address', detail.fullAddress),
          ]),
          const SizedBox(height: 16),
          if (detail.customerPONumber.isNotEmpty)
            _buildInfoCard('Purchase Order Information', [
              _buildInfoRow('PO Number', detail.customerPONumber),
              if (detail.customerPODate != null)
                _buildInfoRow(
                  'PO Date',
                  FormatUtils.formatDateForUser(detail.customerPODate!),
                ),
            ]),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    final items = _details!.data.modelDetails;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${item.itemLineNo}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.salesItemCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.salesItemDesc,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildItemDetail(
                        'Quantity',
                        '${FormatUtils.formatQuantity(item.qtyIUOM)} ${item.uom}',
                      ),
                    ),
                    Expanded(
                      child: _buildItemDetail(
                        'Unit Price',
                        FormatUtils.formatAmount(item.basicPriceIUOM),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildItemDetail('HSN Code', item.hsnCode)),
                    Expanded(
                      child: _buildItemDetail(
                        'Rate Structure',
                        item.rateStructureCode,
                      ),
                    ),
                  ],
                ),
                if (item.discountAmt > 0) ...[
                  const SizedBox(height: 8),
                  _buildItemDetail(
                    'Discount',
                    FormatUtils.formatAmount(item.discountAmt),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Basic Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        FormatUtils.formatAmount(item.basicPrice),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaxesTab() {
    final taxes = _details!.data.rateStructureDetails;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taxes.length,
      itemBuilder: (context, index) {
        final tax = taxes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(tax.rateDesc),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${tax.rateCode}'),
                Text('Item: ${tax.customerItemCode}'),
                Text(
                  'Type: ${tax.taxType} | ${tax.incOrExc} | ${tax.perOrVal}',
                ),
                if (tax.taxValue > 0) Text('Rate: ${tax.taxValue}%'),
              ],
            ),
            trailing: Text(
              FormatUtils.formatAmount(tax.rateAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryTab() {
    final deliveries = _details!.data.deliveryDetails;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Item Code', delivery.itemCode),
                _buildInfoRow(
                  'Quantity',
                  FormatUtils.formatQuantity(delivery.qtySUOM),
                ),
                _buildInfoRow(
                  'Delivery Date',
                  FormatUtils.formatDateForUser(delivery.deliveryDate),
                ),
                if (delivery.expectedInstallationDate != null)
                  _buildInfoRow(
                    'Installation Date',
                    FormatUtils.formatDateForUser(
                      delivery.expectedInstallationDate!,
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Delivery Address:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${delivery.address1}${delivery.address2.isNotEmpty ? '\n${delivery.address2}' : ''}${delivery.address3.isNotEmpty ? '\n${delivery.address3}' : ''}',
                ),
                Text(
                  '${delivery.cityName}, ${delivery.stateName}, ${delivery.countryName} - ${delivery.pincode}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsTab() {
    final terms = _details!.data.termDetails;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (term.termDesc.isNotEmpty)
                  Text(
                    term.termDesc,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (term.subTermOrChargeCode.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Code: ${term.subTermOrChargeCode}'),
                ],
                if (term.chargeDesc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(term.chargeDesc),
                ],
                if (term.subTermDescOrChargeValue.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    term.subTermDescOrChargeValue,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsTab() {
    final contacts = _details!.data.contactPersonList;
    final shipments = _details!.data.shipmentList;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contacts.isNotEmpty) ...[
            Text(
              'Contact Persons',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...contacts.map(
              (contact) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(contact.mcustmcontper),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact.destination.isNotEmpty)
                        Text('Designation: ${contact.destination}'),
                      if (contact.department.isNotEmpty)
                        Text('Department: ${contact.department}'),
                      if (contact.email.isNotEmpty)
                        Text('Email: ${contact.email}'),
                      if (contact.mobileNo.isNotEmpty)
                        Text('Mobile: ${contact.mobileNo}'),
                      if (contact.landLineNo.isNotEmpty)
                        Text('Landline: ${contact.landLineNo}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (shipments.isNotEmpty) ...[
            Text(
              'Shipment Locations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...shipments.map(
              (shipment) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.shipmentDescription,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Code: ${shipment.shipmentCode}'),
                      const SizedBox(height: 8),
                      Text(
                        '${shipment.address1}${shipment.address2.isNotEmpty ? '\n${shipment.address2}' : ''}${shipment.address3.isNotEmpty ? '\n${shipment.address3}' : ''}',
                      ),
                      Text(
                        '${shipment.cityName}, ${shipment.stateName}, ${shipment.countryName} - ${shipment.pinCode}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
