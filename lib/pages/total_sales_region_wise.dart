// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:graphic/graphic.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class TotalSalesRegionWisePage extends StatefulWidget {
//   const TotalSalesRegionWisePage({super.key});

//   @override
//   State<TotalSalesRegionWisePage> createState() =>
//       _TotalSalesRegionWisePageState();
// }

// class _TotalSalesRegionWisePageState extends State<TotalSalesRegionWisePage> {
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   bool _loading = false;
//   Map<String, dynamic>? _data;

//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     final initialDate =
//         isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
//     final firstDate = DateTime(2020);
//     final lastDate = DateTime(2100);

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _loading = true;
//       _data = null;
//     });

//     final url = await StorageUtils.readValue('url');

//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Company not set")));
//       }
//       return;
//     }

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Location not set")));
//       }
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Session token not found")));
//       }
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final dio = Dio();

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     final response = await dio.get(
//       'http://$url/api/Login/dash_TotalSalesRegionwise_ChartData',
//       queryParameters: {
//         'companyid': companyId,
//         'siteid': locationId,
//         'fromdate':
//             _fromDate != null ? _dateFormat.format(_fromDate!) : 'undefined',
//         'todate': _toDate != null ? _dateFormat.format(_toDate!) : 'undefined',
//       },
//     );

//     final apiResponse = response.data;
//     final decoded = jsonDecode(apiResponse);
//     setState(() {
//       _data = decoded['data'];
//       _loading = false;
//     });
//   }

//   Widget _buildDateField({
//     required String label,
//     required DateTime? value,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AbsorbPointer(
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: label,
//               border: const OutlineInputBorder(),
//               suffixIcon: const Icon(Icons.calendar_today),
//             ),
//             controller: TextEditingController(
//               text: value != null ? _dateFormat.format(value) : '',
//             ),
//             readOnly: true,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final regionList =
//         (_data?['regionlist'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//     final salespersonList =
//         (_data?['salespersonlist'] as List?)?.cast<Map<String, dynamic>>() ??
//         [];
//     final customerList =
//         (_data?['customerlist'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//     final currencyList =
//         (_data?['currencylist'] as List?)?.cast<Map<String, dynamic>>() ?? [];

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 _buildDateField(
//                   label: 'From Date',
//                   value: _fromDate,
//                   onTap: () => _pickDate(context, true),
//                 ),
//                 const SizedBox(width: 12),
//                 _buildDateField(
//                   label: 'To Date',
//                   value: _toDate,
//                   onTap: () => _pickDate(context, false),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _fetchData,
//                 child:
//                     _loading
//                         ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child:
//                   _loading
//                       ? const Center(child: CircularProgressIndicator())
//                       : _data == null
//                       ? const Center(child: Text('No data'))
//                       : ListView(
//                         children: [
//                           const Text(
//                             'Region List (Pie Chart)',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           AspectRatio(
//                             aspectRatio: 1.5,
//                             child: RegionPieChart(regionList: regionList),
//                           ),
//                           const SizedBox(height: 24),
//                           const Text(
//                             'Salesperson List (Pie Chart)',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(
//                             height: 250,
//                             child: SalesPersonPieChart(
//                               salespersonList: salespersonList,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           const Text(
//                             'Customer List (Grouped Bar Chart)',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           AspectRatio(
//                             aspectRatio: 0.8,
//                             child: CustomerGroupedBarChart(
//                               customerList: customerList,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           const Text(
//                             'Currency List (Grouped Bar Chart)',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           AspectRatio(
//                             aspectRatio: 1.2,
//                             child: CurrencyGroupedBarChart(
//                               currencyList: currencyList,
//                             ),
//                           ),
//                         ],
//                       ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RegionPieChart extends StatelessWidget {
//   final List<Map<String, dynamic>> regionList;
//   const RegionPieChart({super.key, required this.regionList});

//   @override
//   Widget build(BuildContext context) {
//     // Combine regions with the same name (e.g., "Other")
//     final Map<String, double> regionTotals = {};
//     for (final item in regionList) {
//       final region = item['region'] as String? ?? '';
//       final value = (item['totalinvoicevalue'] as num?)?.toDouble() ?? 0.0;
//       if (region.isNotEmpty && value > 0) {
//         regionTotals[region] = (regionTotals[region] ?? 0) + value;
//       }
//     }
//     final List<Map<String, dynamic>> chartData =
//         regionTotals.entries
//             .map((e) => {'region': e.key, 'totalinvoicevalue': e.value})
//             .toList();

//     if (chartData.isEmpty) {
//       return const Center(child: Text('No data'));
//     }

//     return Center(
//       child: SizedBox(
//         width: 350,
//         height: 350,
//         child: Chart(
//           data: chartData,
//           variables: {
//             'region': Variable(accessor: (Map map) => map['region'] as String),
//             'value': Variable(
//               accessor: (Map map) => map['totalinvoicevalue'] as num,
//             ),
//           },
//           transforms: [Proportion(variable: 'value', as: 'percent')],
//           marks: [
//             IntervalMark(
//               position: Varset('percent') / Varset('region'),
//               label: LabelEncode(
//                 encoder:
//                     (tuple) => Label(
//                       '${tuple['region']} (${tuple['value'].toString()})',
//                     ),
//               ),
//               color: ColorEncode(
//                 variable: 'region',
//                 values: List<Color>.generate(
//                   chartData.length,
//                   (i) => Defaults.colors10[i % Defaults.colors10.length],
//                 ),
//               ),
//               modifiers: [StackModifier()],
//             ),
//           ],
//           coord: PolarCoord(transposed: true, dimCount: 1, dimFill: 1.05),
//           selections: {
//             'tap': PointSelection(on: {GestureType.tap}, dim: Dim.x),
//           },
//           tooltip: TooltipGuide(
//             variables: ['region', 'value'],
//             align: Alignment.topCenter,
//             offset: const Offset(0, -10),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SalesPersonPieChart extends StatelessWidget {
//   final List<Map<String, dynamic>> salespersonList;
//   const SalesPersonPieChart({super.key, required this.salespersonList});

//   @override
//   Widget build(BuildContext context) {
//     // Combine salespersons with the same name
//     final Map<String, double> salesTotals = {};
//     for (final item in salespersonList) {
//       final salesperson = item['salesperson'] as String? ?? '';
//       final value = (item['totalinvoicevalue'] as num?)?.toDouble() ?? 0.0;
//       if (salesperson.isNotEmpty && value > 0) {
//         salesTotals[salesperson] = (salesTotals[salesperson] ?? 0) + value;
//       }
//     }
//     final List<Map<String, dynamic>> chartData =
//         salesTotals.entries
//             .map((e) => {'salesperson': e.key, 'totalinvoicevalue': e.value})
//             .toList();

//     if (chartData.isEmpty) {
//       return const Center(child: Text('No data'));
//     }

//     return Center(
//       child: SizedBox(
//         width: 350,
//         height: 350,
//         child: Chart(
//           data: chartData,
//           variables: {
//             'salesperson': Variable(
//               accessor: (Map map) => map['salesperson'] as String,
//             ),
//             'value': Variable(
//               accessor: (Map map) => map['totalinvoicevalue'] as num,
//             ),
//           },
//           transforms: [Proportion(variable: 'value', as: 'percent')],
//           marks: [
//             IntervalMark(
//               position: Varset('percent') / Varset('salesperson'),
//               label: LabelEncode(
//                 encoder:
//                     (tuple) => Label(
//                       '${tuple['salesperson']} (${tuple['value'].toStringAsFixed(2)})',
//                       LabelStyle(
//                         textStyle: const TextStyle(
//                           fontSize: 10,
//                           color: Colors.black,
//                         ),
//                         align: Alignment.center,
//                         offset: const Offset(20, 0),
//                       ),
//                     ),
//               ),
//               color: ColorEncode(
//                 variable: 'salesperson',
//                 values: List<Color>.generate(
//                   chartData.length,
//                   (i) => Defaults.colors10[i % Defaults.colors10.length],
//                 ),
//               ),
//               modifiers: [StackModifier()],
//             ),
//           ],
//           coord: PolarCoord(transposed: true, dimCount: 1, dimFill: 1.05),
//           selections: {
//             'tap': PointSelection(on: {GestureType.tap}, dim: null),
//           },
//           tooltip: TooltipGuide(
//             variables: ['salesperson', 'value'],
//             align: Alignment.topCenter,
//             offset: const Offset(0, -10),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomerGroupedBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> customerList;
//   const CustomerGroupedBarChart({super.key, required this.customerList});

//   @override
//   Widget build(BuildContext context) {
//     // Filter out zero or null values for better display
//     final filtered =
//         customerList
//             .where(
//               (e) =>
//                   (e['totalinvoicevalue'] as num?) != null &&
//                   (e['totalinvoicevalue'] as num) > 0,
//             )
//             .toList();

//     // Optionally, sort by value descending and take top N
//     filtered.sort(
//       (a, b) => (b['totalinvoicevalue'] as num).compareTo(
//         a['totalinvoicevalue'] as num,
//       ),
//     );
//     final chartData = filtered.take(15).toList(); // Top 15 for readability

//     if (chartData.isEmpty) {
//       return const Center(child: Text('No data'));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Chart(
//         data: chartData,
//         variables: {
//           'customerName': Variable(
//             accessor: (Map map) => map['customerName']?.toString() ?? '',
//           ),
//           'customer': Variable(
//             accessor: (Map map) => map['customer']?.toString() ?? '',
//           ),
//           'value': Variable(
//             accessor: (Map map) => map['totalinvoicevalue'] as num,
//           ),
//         },
//         marks: [
//           IntervalMark(
//             position: Varset('customerName') * Varset('value'),
//             color: ColorEncode(
//               variable: 'customerName',
//               values: List<Color>.generate(
//                 chartData.length,
//                 (i) => Defaults.colors20[i % Defaults.colors20.length],
//               ),
//             ),
//             size: SizeEncode(value: 18),
//             label: LabelEncode(
//               encoder:
//                   (tuple) => Label(
//                     tuple['value'].toStringAsFixed(2),
//                     LabelStyle(
//                       textStyle: const TextStyle(
//                         fontSize: 10,
//                         color: Colors.black,
//                       ),
//                       align: Alignment.centerLeft,
//                       offset: const Offset(8, 0),
//                     ),
//                   ),
//             ),
//           ),
//         ],
//         coord: RectCoord(transposed: true),
//         axes: [Defaults.horizontalAxis..line = null, Defaults.verticalAxis],
//         selections: {
//           'tap': PointSelection(on: {GestureType.tap}, dim: Dim.x),
//         },
//         tooltip: TooltipGuide(
//           variables: ['customerName', 'value'],
//           align: Alignment.topCenter,
//           offset: const Offset(0, -10),
//         ),
//       ),
//     );
//   }
// }

// class CurrencyGroupedBarChart extends StatelessWidget {
//   final List<Map<String, dynamic>> currencyList;
//   const CurrencyGroupedBarChart({super.key, required this.currencyList});

//   @override
//   Widget build(BuildContext context) {
//     // Filter out zero or null values for better display
//     final filtered =
//         currencyList
//             .where(
//               (e) =>
//                   (e['totalinvoicevalue'] as num?) != null &&
//                   (e['totalinvoicevalue'] as num) > 0,
//             )
//             .toList();

//     if (filtered.isEmpty) {
//       return const Center(child: Text('No data'));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Chart(
//         data: filtered,
//         variables: {
//           'currency': Variable(
//             accessor: (Map map) => map['currency']?.toString() ?? '',
//           ),
//           'currencycode': Variable(
//             accessor: (Map map) => map['currencycode']?.toString() ?? '',
//           ),
//           'value': Variable(
//             accessor: (Map map) => map['totalinvoicevalue'] as num,
//           ),
//         },
//         marks: [
//           IntervalMark(
//             position: Varset('currency') * Varset('value'),
//             color: ColorEncode(
//               variable: 'currency',
//               values: List<Color>.generate(
//                 filtered.length,
//                 (i) => Defaults.colors10[i % Defaults.colors10.length],
//               ),
//             ),
//             size: SizeEncode(value: 30),
//             label: LabelEncode(
//               encoder:
//                   (tuple) => Label(
//                     tuple['value'].toStringAsFixed(2),
//                     LabelStyle(
//                       textStyle: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.black,
//                       ),
//                       align: Alignment.topCenter,
//                       offset: const Offset(0, -8),
//                     ),
//                   ),
//             ),
//           ),
//         ],
//         coord: RectCoord(transposed: false),
//         axes: [Defaults.horizontalAxis..line = null, Defaults.verticalAxis],
//         selections: {
//           'tap': PointSelection(on: {GestureType.tap}, dim: Dim.x),
//         },
//         tooltip: TooltipGuide(
//           variables: ['currency', 'value'],
//           align: Alignment.topCenter,
//           offset: const Offset(0, -10),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/currency.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/customer_wise.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/region_wise.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/sales_person.dart';

// class TotalSalesRegionWisePage extends StatefulWidget {
//   const TotalSalesRegionWisePage({super.key});

//   @override
//   State<TotalSalesRegionWisePage> createState() =>
//       _TotalSalesRegionWisePageState();
// }

// class _TotalSalesRegionWisePageState extends State<TotalSalesRegionWisePage> {
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   bool _loading = false;
//   Map<String, dynamic>? _data;

//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     final initialDate =
//         isFrom ? (_fromDate ?? DateTime.now()) : (_toDate ?? DateTime.now());
//     final firstDate = DateTime(2020);
//     final lastDate = DateTime(2100);

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           _fromDate = picked;
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _loading = true;
//       _data = null;
//     });

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Location not set")));
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final dio = Dio();

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     final response = await dio.get(
//       'http://$url/api/Login/dash_TotalSalesRegionwise_ChartData',
//       queryParameters: {
//         'companyid': companyId,
//         'siteid': locationId,
//         'fromdate':
//             _fromDate != null ? _dateFormat.format(_fromDate!) : 'undefined',
//         'todate': _toDate != null ? _dateFormat.format(_toDate!) : 'undefined',
//       },
//     );

//     final apiResponse = response.data;
//     final decoded = jsonDecode(apiResponse);
//     setState(() {
//       _data = decoded['data'];
//       _loading = false;
//     });
//   }

//   Widget _buildDateField({
//     required String label,
//     required DateTime? value,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AbsorbPointer(
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: label,
//               border: const OutlineInputBorder(),
//               suffixIcon: const Icon(Icons.calendar_today),
//             ),
//             controller: TextEditingController(
//               text: value != null ? _dateFormat.format(value) : '',
//             ),
//             readOnly: true,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Convert regionlist and salespersonlist to model objects
//     final regionList =
//         (_data?['regionlist'] as List?)
//             ?.map((e) => RegionData.fromMap(e as Map<String, dynamic>))
//             .toList() ??
//         [];
//     final salespersonList =
//         (_data?['salespersonlist'] as List?)
//             ?.map((e) => SalespersonData.fromMap(e as Map<String, dynamic>))
//             .toList() ??
//         [];
//     final customerList =
//         (_data?['customerlist'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//     final currencyList =
//         (_data?['currencylist'] as List?)?.cast<Map<String, dynamic>>() ?? [];

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   _buildDateField(
//                     label: 'From Date',
//                     value: _fromDate,
//                     onTap: () => _pickDate(context, true),
//                   ),
//                   const SizedBox(width: 12),
//                   _buildDateField(
//                     label: 'To Date',
//                     value: _toDate,
//                     onTap: () => _pickDate(context, false),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _fetchData,
//                   child:
//                       _loading
//                           ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                           : const Text('Submit'),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child:
//                     _loading
//                         ? const Center(child: CircularProgressIndicator())
//                         : _data == null
//                         ? const Center(child: Text('No data'))
//                         : ListView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           children: [
//                             RepaintBoundary(
//                               child: RegionPieChartCard(regions: regionList),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: SalespersonPieChartCard(
//                                 salespeople: salespersonList,
//                               ),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: CustomerPurchaseBarChartCard(
//                                 customerData: customerList,
//                               ),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: CurrencyBarChartCard(
//                                 currencyData: currencyList,
//                               ),
//                             ),
//                           ],
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/currency.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/customer_wise.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/region_wise.dart';
// import 'package:nhapp/widgets/Dashboard/RegionWiseSales/sales_person.dart';

// class TotalSalesRegionWisePage extends StatefulWidget {
//   const TotalSalesRegionWisePage({super.key});

//   @override
//   State<TotalSalesRegionWisePage> createState() =>
//       _TotalSalesRegionWisePageState();
// }

// class _TotalSalesRegionWisePageState extends State<TotalSalesRegionWisePage> {
//   DateTime? _fromDate;
//   DateTime? _toDate;
//   bool _loading = false;
//   Map<String, dynamic>? _data;

//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   Future<void> _pickDate(BuildContext context, bool isFrom) async {
//     DateTime? initialDate;
//     DateTime firstDate;
//     final lastDate = DateTime(2100);

//     if (isFrom) {
//       initialDate = _fromDate ?? DateTime.now();
//       firstDate = DateTime(2020);
//     } else {
//       // For 'to date', set initial date and first date based on 'from date'
//       initialDate = _toDate ?? _fromDate ?? DateTime.now();
//       firstDate = _fromDate ?? DateTime(2020);
//     }

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );

//     if (picked != null) {
//       setState(() {
//         if (isFrom) {
//           _fromDate = picked;
//           // Clear to date if it's before the new from date
//           if (_toDate != null && _toDate!.isBefore(picked)) {
//             _toDate = null;
//           }
//         } else {
//           _toDate = picked;
//         }
//       });
//     }
//   }

//   bool _isFormValid() {
//     return _fromDate != null && _toDate != null;
//   }

//   void _showValidationError() {
//     String message;
//     if (_fromDate == null && _toDate == null) {
//       message = "Please select both from date and to date";
//     } else if (_fromDate == null) {
//       message = "Please select from date";
//     } else {
//       message = "Please select to date";
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   Future<void> _fetchData() async {
//     if (!_isFormValid()) {
//       _showValidationError();
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _data = null;
//     });

//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Company not set")));
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Location not set")));
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Session token not found")),
//         );
//       }
//       setState(() => _loading = false);
//       return;
//     }

//     final companyId = companyDetails['id'];
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final dio = Dio();

//     dio.options.headers['Content-Type'] = 'application/json';
//     dio.options.headers['Authorization'] = 'Bearer $token';
//     final response = await dio.get(
//       'http://$url/api/Login/dash_TotalSalesRegionwise_ChartData',
//       queryParameters: {
//         'companyid': companyId,
//         'siteid': locationId,
//         'fromdate': _dateFormat.format(_fromDate!),
//         'todate': _dateFormat.format(_toDate!),
//       },
//     );

//     final apiResponse = response.data;
//     final decoded = jsonDecode(apiResponse);
//     setState(() {
//       _data = decoded['data'];
//       _loading = false;
//     });
//   }

//   Widget _buildDateField({
//     required String label,
//     required DateTime? value,
//     required VoidCallback onTap,
//     bool enabled = true,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: enabled ? onTap : null,
//         child: AbsorbPointer(
//           child: TextFormField(
//             decoration: InputDecoration(
//               labelText: label,
//               border: const OutlineInputBorder(),
//               suffixIcon: Icon(
//                 Icons.calendar_today,
//                 color: enabled ? null : Colors.grey,
//               ),
//               filled: !enabled,
//               fillColor: !enabled ? Colors.grey[100] : null,
//             ),
//             controller: TextEditingController(
//               text: value != null ? _dateFormat.format(value) : '',
//             ),
//             readOnly: true,
//             enabled: enabled,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Convert regionlist and salespersonlist to model objects
//     final regionList =
//         (_data?['regionlist'] as List?)
//             ?.map((e) => RegionData.fromMap(e as Map<String, dynamic>))
//             .toList() ??
//         [];
//     final salespersonList =
//         (_data?['salespersonlist'] as List?)
//             ?.map((e) => SalespersonData.fromMap(e as Map<String, dynamic>))
//             .toList() ??
//         [];
//     final customerList =
//         (_data?['customerlist'] as List?)?.cast<Map<String, dynamic>>() ?? [];
//     final currencyList =
//         (_data?['currencylist'] as List?)?.cast<Map<String, dynamic>>() ?? [];

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   _buildDateField(
//                     label: 'From Date',
//                     value: _fromDate,
//                     onTap: () => _pickDate(context, true),
//                   ),
//                   const SizedBox(width: 12),
//                   _buildDateField(
//                     label: 'To Date',
//                     value: _toDate,
//                     onTap: () => _pickDate(context, false),
//                     enabled:
//                         _fromDate !=
//                         null, // Enable only if from date is selected
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _fetchData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _isFormValid() ? null : Colors.grey,
//                   ),
//                   child:
//                       _loading
//                           ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                           : const Text('Submit'),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Expanded(
//                 child:
//                     _loading
//                         ? const Center(child: CircularProgressIndicator())
//                         : _data == null
//                         ? const Center(child: Text('No data'))
//                         : ListView(
//                           physics: const AlwaysScrollableScrollPhysics(),
//                           children: [
//                             RepaintBoundary(
//                               child: RegionPieChartCard(regions: regionList),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: SalespersonPieChartCard(
//                                 salespeople: salespersonList,
//                               ),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: CustomerPurchaseBarChartCard(
//                                 customerData: customerList,
//                               ),
//                             ),
//                             const SizedBox(height: 18),
//                             RepaintBoundary(
//                               child: CurrencyBarChartCard(
//                                 currencyData: currencyList,
//                               ),
//                             ),
//                           ],
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/widgets/Dashboard/RegionWiseSales/currency.dart';
import 'package:nhapp/widgets/Dashboard/RegionWiseSales/customer_wise.dart';
import 'package:nhapp/widgets/Dashboard/RegionWiseSales/region_wise.dart';
import 'package:nhapp/widgets/Dashboard/RegionWiseSales/sales_person.dart';

class TotalSalesRegionWisePage extends StatefulWidget {
  const TotalSalesRegionWisePage({super.key});

  @override
  State<TotalSalesRegionWisePage> createState() =>
      _TotalSalesRegionWisePageState();
}

class _TotalSalesRegionWisePageState extends State<TotalSalesRegionWisePage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = false;
  Map<String, dynamic>? _data;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    DateTime? initialDate;
    DateTime firstDate;
    final lastDate = DateTime(2100);

    if (isFrom) {
      initialDate = _fromDate ?? DateTime.now();
      firstDate = DateTime(2020);
    } else {
      // For 'to date', set initial date and first date based on 'from date'
      initialDate = _toDate ?? _fromDate ?? DateTime.now();
      firstDate = _fromDate ?? DateTime(2020);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          // Clear to date if it's before the new from date
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  bool _isFormValid() {
    return _fromDate != null && _toDate != null;
  }

  void _showValidationError() {
    String message;
    if (_fromDate == null && _toDate == null) {
      message = "Please select both from date and to date";
    } else if (_fromDate == null) {
      message = "Please select from date";
    } else {
      message = "Please select to date";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  bool _hasData() {
    if (_data == null) return false;

    final regionList = (_data?['regionlist'] as List?) ?? [];
    final salespersonList = (_data?['salespersonlist'] as List?) ?? [];
    final customerList = (_data?['customerlist'] as List?) ?? [];
    final currencyList = (_data?['currencylist'] as List?) ?? [];

    return regionList.isNotEmpty ||
        salespersonList.isNotEmpty ||
        customerList.isNotEmpty ||
        currencyList.isNotEmpty;
  }

  Future<void> _fetchData() async {
    if (!_isFormValid()) {
      _showValidationError();
      return;
    }

    setState(() {
      _loading = true;
      _data = null;
    });

    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Company not set")));
      }
      setState(() => _loading = false);
      return;
    }

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Location not set")));
      }
      setState(() => _loading = false);
      return;
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session token not found")),
        );
      }
      setState(() => _loading = false);
      return;
    }

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];
    final dio = Dio();

    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await dio.get(
      'http://$url/api/Login/dash_TotalSalesRegionwise_ChartData',
      queryParameters: {
        'companyid': companyId,
        'siteid': locationId,
        'fromdate': _dateFormat.format(_fromDate!),
        'todate': _dateFormat.format(_toDate!),
      },
    );

    final apiResponse = response.data;
    final decoded = jsonDecode(apiResponse);
    setState(() {
      _data = decoded['data'];
      _loading = false;
    });
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: enabled ? null : Colors.grey,
              ),
              filled: !enabled,
              fillColor: !enabled ? Colors.grey[100] : null,
            ),
            controller: TextEditingController(
              text: value != null ? _dateFormat.format(value) : '',
            ),
            readOnly: true,
            enabled: enabled,
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No sales data found for the selected date range.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert regionlist and salespersonlist to model objects
    final regionList =
        (_data?['regionlist'] as List?)
            ?.map((e) => RegionData.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    final salespersonList =
        (_data?['salespersonlist'] as List?)
            ?.map((e) => SalespersonData.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    final customerList =
        (_data?['customerlist'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final currencyList =
        (_data?['currencylist'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  _buildDateField(
                    label: 'From Date',
                    value: _fromDate,
                    onTap: () => _pickDate(context, true),
                  ),
                  const SizedBox(width: 12),
                  _buildDateField(
                    label: 'To Date',
                    value: _toDate,
                    onTap: () => _pickDate(context, false),
                    enabled: _fromDate != null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _fetchData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid() ? null : Colors.grey,
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _data == null
                        ? const Center(child: Text('No data'))
                        : !_hasData()
                        ? _buildNoDataMessage()
                        : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            if (regionList.isNotEmpty)
                              RepaintBoundary(
                                child: RegionPieChartCard(regions: regionList),
                              ),
                            if (regionList.isNotEmpty &&
                                (salespersonList.isNotEmpty ||
                                    customerList.isNotEmpty ||
                                    currencyList.isNotEmpty))
                              const SizedBox(height: 18),
                            if (salespersonList.isNotEmpty)
                              RepaintBoundary(
                                child: SalespersonPieChartCard(
                                  salespeople: salespersonList,
                                ),
                              ),
                            if (salespersonList.isNotEmpty &&
                                (customerList.isNotEmpty ||
                                    currencyList.isNotEmpty))
                              const SizedBox(height: 18),
                            if (customerList.isNotEmpty)
                              RepaintBoundary(
                                child: CustomerPurchaseBarChartCard(
                                  customerData: customerList,
                                ),
                              ),
                            if (customerList.isNotEmpty &&
                                currencyList.isNotEmpty)
                              const SizedBox(height: 18),
                            if (currencyList.isNotEmpty)
                              RepaintBoundary(
                                child: CurrencyBarChartCard(
                                  currencyData: currencyList,
                                ),
                              ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
