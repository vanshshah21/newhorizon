import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/widgets/Dashboard/Director/best_selling_by_sales.dart';

class BestSellingBySalesAmountPage extends StatefulWidget {
  const BestSellingBySalesAmountPage({super.key});

  @override
  State<BestSellingBySalesAmountPage> createState() =>
      _BestSellingBySalesAmountPageState();
}

class _BestSellingBySalesAmountPageState
    extends State<BestSellingBySalesAmountPage> {
  final List<Map<String, String?>> multiSelectOptions = [
    {'label': 'All', 'value': ''},
    {'label': 'Machines/ Spare', 'value': 'P'},
    {'label': 'Services', 'value': 'V'},
  ];

  final List<Map<String, String>> dropdownOptions = [
    {'label': 'Today', 'value': 'today'},
    {'label': 'Month', 'value': 'month'},
    {'label': 'Qtr', 'value': 'qtr'},
    {'label': 'Ytd', 'value': 'ytd'},
    {'label': 'Custom Dates', 'value': 'custom'},
  ];

  String? selectedType;
  String? selectedDropdown;
  DateTime? fromDate;
  DateTime? toDate;
  Future<Map<String, dynamic>>? apiFuture;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = fromDate;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: fromDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchChartData() async {
    String curtype = "A";
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Company not set")));
      }
      return {};
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session token not found")),
        );
      }
      return {};
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['companyid'] = companyId.toString();

    try {
      Response response = await dio.get(
        'http://$url/api/Login/dash_FetchItemSaleData',
        queryParameters: {
          'companyid': companyId,
          'curtype': curtype.toString(),
          'datetype': selectedDropdown,
          'fromdate':
              fromDate != null ? dateFormat.format(fromDate!) : "undefined",
          'todate': toDate != null ? dateFormat.format(toDate!) : "undefined",
          'invOf': selectedType == '' ? "null" : selectedType,
        },
      );

      if (response.statusCode == 200) {
        final responseData =
            response.data is String ? jsonDecode(response.data) : response.data;
        return responseData;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: fetching year ${response.statusCode}"),
            ),
          );
        }
        return {};
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Exception: $e")));
      }
      return {};
    }
  }

  void _submit() {
    if (selectedType == null ||
        selectedDropdown == null ||
        (selectedDropdown == 'custom' &&
            (fromDate == null || toDate == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
      return;
    } else {
      setState(() {
        apiFuture = _fetchChartData();
      });
    }
  }

  Widget _buildChart(List<Map<String, dynamic>> data) {
    return BestSellingBySalesAmountChart(chartData: data);
  }

  // Widget _buildList(List<Map<String, dynamic>> data) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           const Text(
  //             'Detailed Sales List',
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //           ),
  //           const SizedBox(height: 8),
  //           ...data.map(
  //             (e) => Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 4.0),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     flex: 2,
  //                     child: Text(
  //                       (e['customername'] ?? '').trim(),
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(fontWeight: FontWeight.w500),
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 2,
  //                     child: Text(
  //                       (e['itemname'] ?? '').trim(),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     flex: 1,
  //                     child: Text(
  //                       NumberFormat.compactCurrency(
  //                         decimalDigits: 2,
  //                         symbol: '',
  //                       ).format(e['amount'] ?? 0),
  //                       textAlign: TextAlign.right,
  //                       style: const TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Best Selling Items By Sales Amount")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-select input
            Text(
              'Select Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedType,
              items:
                  multiSelectOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Dropdown menu
            Text(
              'Select Period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDropdown,
              items:
                  dropdownOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option['value'],
                          child: Text(option['label']!),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDropdown = value;
                  if (value != 'custom') {
                    fromDate = null;
                    toDate = null;
                  }
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Date pickers (only if custom)
            if (selectedDropdown == 'custom') ...[
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickFromDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'From Date',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                fromDate == null
                                    ? ''
                                    : dateFormat.format(fromDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickToDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'To Date',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                toDate == null
                                    ? ''
                                    : dateFormat.format(toDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),

            // Chart and List (after API response)
            if (apiFuture != null)
              FutureBuilder<Map<String, dynamic>>(
                future: apiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  final response = snapshot.data;
                  if (response == null ||
                      response['success'] != true ||
                      response['data'] == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Failed to load chart data'),
                    );
                  }
                  final data = response['data'];
                  final List<Map<String, dynamic>> chartData =
                      data['chartData'] != null
                          ? List<Map<String, dynamic>>.from(data['chartData'])
                          : [];
                  if (chartData.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No chart data available.'),
                    );
                  }
                  return Column(children: [_buildChart(chartData)]);
                },
              ),
          ],
        ),
      ),
    );
  }
}
