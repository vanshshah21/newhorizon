// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';
// import 'package:nhapp/pages/authorize_sales_order/widgets/auth_sales_order_card.dart';
// import 'package:nhapp/utils/paging_extensions.dart';
// import 'package:flutter/services.dart';

// class SalesOrderInfiniteList extends StatefulWidget {
//   final SalesOrderService service;
//   final void Function(SalesOrderData so) onPdfTap;
//   final Future<bool> Function(SalesOrderData so) onAuthorizeTap;

//   const SalesOrderInfiniteList({
//     required this.service,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<SalesOrderInfiniteList> createState() => _SalesOrderInfiniteListState();
// }

// class _SalesOrderInfiniteListState extends State<SalesOrderInfiniteList>
//     with AutomaticKeepAliveClientMixin<SalesOrderInfiniteList> {
//   static const _pageSize = 50;
//   final Set<SalesOrderData> _selectedSOs = {};

//   late final PagingController<int, SalesOrderData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   void _toggleSelection(SalesOrderData so) {
//     setState(() {
//       if (_selectedSOs.contains(so)) {
//         _selectedSOs.remove(so);
//         HapticFeedback.mediumImpact();
//       } else {
//         _selectedSOs.add(so);
//         HapticFeedback.lightImpact();
//       }
//     });
//   }

//   Future<void> _batchAuthorize() async {
//     if (_selectedSOs.isEmpty) return;
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Batch Authorize'),
//             content: Text(
//               'Authorize ${_selectedSOs.length} selected Sales Orders?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Authorize'),
//               ),
//             ],
//           ),
//     );
//     if (confirm == true) {
//       final success = await widget.service.authorizeSalesOrderBatch(
//         _selectedSOs.toList(),
//       );
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Batch authorization successful!')),
//         );
//         _selectedSOs.clear();
//         _pagingController.refresh();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Batch authorization failed!')),
//         );
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, SalesOrderData>(
//       getNextPageKey:
//           (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
//       fetchPage: (pageKey) async {
//         final newItems = await widget.service.fetchSalesOrderList(
//           page: pageKey,
//           pageSize: _pageSize,
//           searchValue: _currentSearchValue,
//         );
//         return newItems;
//       },
//     );
//   }

//   void _onSearch() {
//     setState(() {
//       _currentSearchValue =
//           _searchController.text.trim().isEmpty
//               ? null
//               : _searchController.text.trim();
//       _pagingController.refresh();
//     });
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return RefreshIndicator(
//       onRefresh: () async {
//         _pagingController.refresh();
//       },
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       labelText: 'Search',
//                       border: OutlineInputBorder(),
//                     ),
//                     onSubmitted: (_) => _onSearch(),
//                     onTapOutside: (event) {
//                       FocusScope.of(context).unfocus();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton.filled(
//                   onPressed: _onSearch,
//                   icon: const Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),
//           if (_selectedSOs.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Text('${_selectedSOs.length} selected'),
//                   const Spacer(),
//                   ElevatedButton.icon(
//                     onPressed: _batchAuthorize,
//                     icon: const Icon(Icons.check),
//                     label: const Text('Batch Authorize'),
//                   ),
//                 ],
//               ),
//             ),
//           Expanded(
//             child: PagingListener<int, SalesOrderData>(
//               controller: _pagingController,
//               builder:
//                   (
//                     context,
//                     state,
//                     fetchNextPage,
//                   ) => PagedListView<int, SalesOrderData>(
//                     state: state,
//                     fetchNextPage: fetchNextPage,
//                     builderDelegate: PagedChildBuilderDelegate<SalesOrderData>(
//                       itemBuilder:
//                           (context, so, index) => GestureDetector(
//                             onLongPress: () => _toggleSelection(so),
//                             child: SalesOrderCard(
//                               so: so,
//                               onPdfTap: () => widget.onPdfTap(so),
//                               onAuthorizeTap: () async {
//                                 final authorized = await widget.onAuthorizeTap(
//                                   so,
//                                 );
//                                 if (authorized) {
//                                   _pagingController.refresh();
//                                 }
//                               },
//                               selected: _selectedSOs.contains(so),
//                             ),
//                           ),
//                       noItemsFoundIndicatorBuilder:
//                           (context) =>
//                               const Center(child: Text('No data found.')),
//                       firstPageErrorIndicatorBuilder:
//                           (context) =>
//                               const Center(child: Text('Error loading data.')),
//                     ),
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';
import 'package:nhapp/pages/authorize_sales_order/widgets/auth_sales_order_card.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import 'package:flutter/services.dart';

class SalesOrderInfiniteList extends StatefulWidget {
  final SalesOrderService service;
  final void Function(SalesOrderData so) onPdfTap;
  final Future<bool> Function(SalesOrderData so) onAuthorizeTap;

  const SalesOrderInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<SalesOrderInfiniteList> createState() => _SalesOrderInfiniteListState();
}

class _SalesOrderInfiniteListState extends State<SalesOrderInfiniteList>
    with AutomaticKeepAliveClientMixin<SalesOrderInfiniteList> {
  static const _pageSize = 50;
  final Set<SalesOrderData> _selectedSOs = {};
  bool _isSelectionMode = false;

  late final PagingController<int, SalesOrderData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void _toggleSelection(SalesOrderData so) {
    // Don't allow selection of already authorized sales orders
    if (so.isAuthorized) return;

    setState(() {
      if (_selectedSOs.contains(so)) {
        _selectedSOs.remove(so);
        HapticFeedback.mediumImpact();
      } else {
        _selectedSOs.add(so);
        HapticFeedback.lightImpact();
      }

      // Exit selection mode if no items are selected
      if (_selectedSOs.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedSOs.clear();
    });
  }

  void _selectAll() {
    final allItems = _pagingController.items ?? [];
    // Only select non-authorized and non-deleted sales orders
    final selectableItems =
        allItems
            .where((so) => !so.isAuthorized && so.orderStatus != "DELETED")
            .toList();
    setState(() {
      _selectedSOs.addAll(selectableItems);
    });
  }

  void _selectNone() {
    setState(() {
      _selectedSOs.clear();
    });
  }

  Future<void> _batchAuthorize() async {
    if (_selectedSOs.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batch Authorize'),
            content: Text(
              'Authorize ${_selectedSOs.length} selected Sales Orders?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Authorize'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await widget.service.authorizeSalesOrderBatch(
        _selectedSOs.toList(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch authorization successful!')),
        );
        _exitSelectionMode();
        _pagingController.refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch authorization failed!')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, SalesOrderData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchSalesOrderList(
          page: pageKey,
          pageSize: _pageSize,
          searchValue: _currentSearchValue,
        );
        return newItems;
      },
    );
  }

  void _onSearch() {
    setState(() {
      _currentSearchValue =
          _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim();
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar:
          _isSelectionMode
              ? AppBar(
                title: Text('${_selectedSOs.length} selected'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.checklist_rounded),
                    onPressed: _selectAll,
                    tooltip: 'Select All',
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_done),
                    onPressed: _selectNone,
                    tooltip: 'Select None',
                  ),
                ],
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: Column(
          children: [
            // Search bar - only show when not in selection mode
            if (!_isSelectionMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _onSearch(),
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _enterSelectionMode,
                      icon: const Icon(Icons.checklist),
                      tooltip: 'Select Mode',
                    ),
                  ],
                ),
              ),

            Expanded(
              child: PagingListener<int, SalesOrderData>(
                controller: _pagingController,
                builder:
                    (
                      context,
                      state,
                      fetchNextPage,
                    ) => PagedListView<int, SalesOrderData>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate:
                          PagedChildBuilderDelegate<SalesOrderData>(
                            itemBuilder:
                                (context, so, index) => SalesOrderCard(
                                  so: so,
                                  onPdfTap: () => widget.onPdfTap(so),
                                  onAuthorizeTap: () async {
                                    final authorized = await widget
                                        .onAuthorizeTap(so);
                                    if (authorized) {
                                      _pagingController.refresh();
                                    }
                                  },
                                  selected: _selectedSOs.contains(so),
                                  showCheckbox: _isSelectionMode,
                                  onCheckboxChanged: () => _toggleSelection(so),
                                ),
                            noItemsFoundIndicatorBuilder:
                                (context) =>
                                    const Center(child: Text('No data found.')),
                            firstPageErrorIndicatorBuilder:
                                (context) => const Center(
                                  child: Text('Error loading data.'),
                                ),
                          ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _isSelectionMode && _selectedSOs.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _batchAuthorize,
                icon: const Icon(Icons.check_circle),
                label: Text('Authorize (${_selectedSOs.length})'),
              )
              : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
