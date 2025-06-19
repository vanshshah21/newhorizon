// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/followup/service/followup_service.dart';
// import '../models/followup_list_item.dart';
// import '../models/followup_detail.dart';

// class FollowupDetailPage extends StatefulWidget {
//   final FollowupListItem followup;
//   const FollowupDetailPage({required this.followup, super.key});

//   @override
//   State<FollowupDetailPage> createState() => _FollowupDetailPageState();
// }

// class _FollowupDetailPageState extends State<FollowupDetailPage> {
//   List<FollowupDetail>? details;
//   String? error;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       final service = FollowupService();
//       final result = await service.fetchFollowupDetails(widget.followup);
//       if (!mounted) return;
//       setState(() {
//         details = result;
//         loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = 'Error: $e';
//         loading = false;
//       });
//     }
//   }

//   String formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return '-';
//     try {
//       final dt = DateTime.parse(dateStr);
//       return DateFormat('dd/MM/yyyy').format(dt);
//     } catch (_) {
//       return dateStr;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Followup Details')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Followup Details')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (details == null || details!.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Followup Details')),
//         body: const Center(child: Text('No data found.')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Followup Details')),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: details!.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 16),
//         itemBuilder: (context, idx) {
//           final d = details![idx];
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: BorderSide(color: theme.dividerColor, width: 1.5),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Followup #${d.autoId}',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Customer: ${d.custCode}',
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                   const Divider(height: 24),
//                   _infoRow('Base On', d.baseOn),
//                   _infoRow('Followup Date', formatDate(d.followUpDate)),
//                   _infoRow('Expected Response', formatDate(d.expeResDate)),
//                   _infoRow('Sales Person', d.salesManFullName),
//                   _infoRow('Method', d.method),
//                   _infoRow('Remark', d.remark),
//                   _infoRow('Agenda', d.followUpAgenda),
//                   _infoRow('Description', d.description),
//                   _infoRow('Followup Cost', d.followUpCost.toStringAsFixed(2)),
//                   _infoRow('Followup Time', d.followUpTime),
//                   _infoRow('Next Sales Person', d.newSalesManFullName),
//                   _infoRow('Next Followup Date', d.nxtFollowUpDate ?? '-'),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(label, style: const TextStyle(color: Colors.grey)),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/followup/service/followup_service.dart';
// import '../models/followup_list_item.dart';
// import '../models/followup_detail.dart';

// class FollowupDetailPage extends StatefulWidget {
//   final FollowupListItem followup;
//   const FollowupDetailPage({required this.followup, super.key});

//   @override
//   State<FollowupDetailPage> createState() => _FollowupDetailPageState();
// }

// class _FollowupDetailPageState extends State<FollowupDetailPage> {
//   List<FollowupDetail>? details;
//   String? error;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       final service = FollowupService();
//       final result = await service.fetchFollowupDetails(widget.followup);
//       if (!mounted) return;
//       setState(() {
//         details = result;
//         loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = 'Error: $e';
//         loading = false;
//       });
//     }
//   }

//   String formatDate(String? dateStr) {
//     if (dateStr == null || dateStr.isEmpty) return '-';
//     try {
//       final dt = DateTime.parse(dateStr);
//       return DateFormat('dd/MM/yyyy').format(dt);
//     } catch (_) {
//       return dateStr;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Followup Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Followup Details')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (details == null || details!.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Followup Details')),
//         body: const Center(child: Text('No data found.')),
//       );
//     }

//     // Show followup number and customer number at the top
//     return Scaffold(
//       appBar: AppBar(title: const Text('Followup Details')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Header section
//           Card(
//             margin: const EdgeInsets.only(bottom: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: BorderSide(color: theme.dividerColor, width: 1.5),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Followup Number: ${widget.followup.autoId}',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Customer Number: ${widget.followup.custCode}',
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Details cards
//           ...details!.map(
//             (d) => Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 side: BorderSide(color: theme.dividerColor, width: 1.5),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Card header: Followup Base and Followup Count
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Base: ${d.baseOn}',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Count: ${d.followUpCount}',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 24),
//                     // Card body: all other info
//                     _infoRow('Followup Date', formatDate(d.followUpDate)),
//                     _infoRow('Expected Response', formatDate(d.expeResDate)),
//                     _infoRow('Sales Person', d.salesManFullName),
//                     _infoRow('Method', d.method),
//                     _infoRow('Remark', d.remark),
//                     _infoRow('Agenda', d.followUpAgenda),
//                     _infoRow('Description', d.description),
//                     _infoRow(
//                       'Followup Cost',
//                       d.followUpCost.toStringAsFixed(2),
//                     ),
//                     _infoRow('Followup Time', d.followUpTime),
//                     _infoRow('Next Sales Person', d.newSalesManFullName),
//                     _infoRow(
//                       'Next Followup Date',
//                       formatDate(d.nxtFollowUpDate),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(label, style: const TextStyle(color: Colors.grey)),
//           ),
//           Expanded(
//             child: Text(
//               value == null || value.isEmpty ? '-' : value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/followup/pages/edit_follow_up.dart';
import 'package:nhapp/pages/followup/service/followup_service.dart';
import '../models/followup_list_item.dart';
import '../models/followup_detail.dart';

class FollowupDetailPage extends StatefulWidget {
  final FollowupListItem followup;
  const FollowupDetailPage({required this.followup, super.key});

  @override
  State<FollowupDetailPage> createState() => _FollowupDetailPageState();
}

class _FollowupDetailPageState extends State<FollowupDetailPage> {
  List<FollowupDetail>? details;
  String? error;
  bool loading = true;
  Set<int> expandedCards = <int>{};

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final service = FollowupService();
      final result = await service.fetchFollowupDetails(widget.followup);
      if (!mounted) return;
      setState(() {
        details = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  void _toggleCard(int index) {
    setState(() {
      if (expandedCards.contains(index)) {
        expandedCards.remove(index);
      } else {
        expandedCards.add(index);
      }
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Followup Details'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading followup details...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Followup Details'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (details == null || details!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Followup Details'),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No followup details found.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followup Details'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (details != null && details!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Last Followup',
              onPressed: () {
                // Get the most recent (last) followup detail
                final lastDetail = details!.last;
                // Convert to Map<String, dynamic> if needed
                final lastDetailMap =
                    lastDetail.toJson(); // or use your own mapping
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditFollowUpForm(followup: widget.followup),
                  ),
                ).then((updated) {
                  if (updated == true) {
                    _fetchDetail(); // Refresh after edit
                  }
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Header section with pill-shaped containers
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _pillContainer(
                          'Followup Number',
                          widget.followup.number,
                          Icons.tag,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _pillContainer(
                          'Customer Code',
                          widget.followup.custCode,
                          Icons.business,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.followup.customerFullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable details section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: details!.length,
              itemBuilder: (context, idx) {
                final d = details![idx];
                final isExpanded = expandedCards.contains(idx);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    // elevation: 3,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(16),
                    // ),
                    child: Column(
                      children: [
                        // Card header - always visible
                        InkWell(
                          onTap: () => _toggleCard(idx),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft:
                                    isExpanded
                                        ? Radius.zero
                                        : const Radius.circular(16),
                                bottomRight:
                                    isExpanded
                                        ? Radius.zero
                                        : const Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    d.baseOn,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDate(d.followUpDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        d.salesManFullName,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Count: ${d.followUpCount}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.expand_more,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Expandable content
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _sectionTitle('Schedule Information'),
                                _infoRow(
                                  'Expected Response',
                                  formatDate(d.expeResDate),
                                  Icons.schedule,
                                ),
                                _infoRow(
                                  'Followup Time',
                                  d.followUpTime,
                                  Icons.access_time,
                                ),
                                _infoRow(
                                  'Method',
                                  d.method,
                                  Icons.contact_phone,
                                ),

                                const SizedBox(height: 16),
                                _sectionTitle('Details'),
                                _infoRow(
                                  'Agenda',
                                  d.followUpAgenda,
                                  Icons.list_alt,
                                ),
                                _infoRow(
                                  'Description',
                                  d.description,
                                  Icons.description,
                                ),
                                _infoRow('Remark', d.remark, Icons.note),

                                // Next followup section - only show if data exists
                                if (d.newSalesManFullName.isNotEmpty ||
                                    (d.nxtFollowUpDate?.isNotEmpty ??
                                        false)) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.next_plan,
                                              color: Colors.blue,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Next Followup',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _nextFollowupRow(
                                          'Sales Person',
                                          d.newSalesManFullName,
                                          Icons.person_outline,
                                        ),
                                        _nextFollowupRow(
                                          'Date',
                                          formatDate(d.nxtFollowUpDate),
                                          Icons.event,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          crossFadeState:
                              isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillContainer(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, IconData icon) {
    final displayValue = value == null || value.isEmpty ? '-' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextFollowupRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
