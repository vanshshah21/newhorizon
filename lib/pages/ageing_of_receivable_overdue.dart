import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/widgets/Dashboard/Director/aging_receivable_overdue.dart';

class AgeingOfReceivableOverduePage extends StatefulWidget {
  const AgeingOfReceivableOverduePage({super.key});

  @override
  State<AgeingOfReceivableOverduePage> createState() =>
      _AgeingOfReceivableOverduePageState();
}

class _AgeingOfReceivableOverduePageState
    extends State<AgeingOfReceivableOverduePage> {
  Future<List<Map<String, dynamic>>>? _chartFuture;

  Future<List<Map<String, dynamic>>> _fetchChartData() async {
    String curtype = "A";
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Company not set")));
      }
      return [];
    }

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session token not found")),
        );
      }
      return [];
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['companyid'] = companyId.toString();
    dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await dio.get(
        'http://$url/api/Login/dash_FetchCustomerReceivableOverdue',
        queryParameters: {'curtype': curtype, 'companyid': companyId},
      );

      if (response.statusCode == 200) {
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;

        // Extract and transform the agingReceivableOverdue list
        final List aging = data['data']?['agingReceivableOverdue'] ?? [];
        // Transform to the format expected by AgingReceivableStackedBarChartCard
        final List<Map<String, dynamic>> chartData = [];
        for (final item in aging) {
          final Map<String, dynamic> row = {};
          row['dayrange'] = item['dayrange'];
          // Copy all keys except 'dayrange'
          item.forEach((key, value) {
            if (key != 'dayrange') {
              row[key] = double.tryParse(value.toString()) ?? 0.0;
            }
          });
          chartData.add(row);
        }
        return chartData;
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  Widget _buildChart(List<Map<String, dynamic>> data) {
    return AgingReceivableStackedBarChartCard(chartData: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aging Receivable Overdue (Grouped Bar)'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _chartFuture = _fetchChartData();
                    });
                  },
                  child: const Text('Load Chart'),
                ),
              ),
              const SizedBox(height: 24),
              if (_chartFuture != null)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _chartFuture,
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
                    final data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No data to display'),
                      );
                    }
                    return _buildChart(data);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
