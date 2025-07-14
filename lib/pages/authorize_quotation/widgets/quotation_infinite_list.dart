// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
// import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';
// import 'package:nhapp/utils/paging_extensions.dart';
// import 'quotation_card.dart';
// import 'package:flutter/services.dart';

// class QuotationInfiniteList extends StatefulWidget {
//   final QuotationService service;
//   final void Function(QuotationData qtn) onPdfTap;
//   final Future<bool> Function(QuotationData qtn) onAuthorizeTap;

//   const QuotationInfiniteList({
//     required this.service,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<QuotationInfiniteList> createState() => _QuotationInfiniteListState();
// }

// class _QuotationInfiniteListState extends State<QuotationInfiniteList>
//     with AutomaticKeepAliveClientMixin<QuotationInfiniteList> {
//   static const _pageSize = 50;
//   final Set<QuotationData> _selectedQtns = {};

//   late final PagingController<int, QuotationData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   void _toggleSelection(QuotationData qtn) {
//     setState(() {
//       if (_selectedQtns.contains(qtn)) {
//         _selectedQtns.remove(qtn);
//         HapticFeedback.mediumImpact();
//       } else {
//         _selectedQtns.add(qtn);
//         HapticFeedback.lightImpact();
//       }
//     });
//   }

//   Future<void> _batchAuthorize() async {
//     if (_selectedQtns.isEmpty) return;
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Batch Authorize'),
//             content: Text(
//               'Authorize ${_selectedQtns.length} selected Quotations?',
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
//       final success = await widget.service.authorizeQuotationBatch(
//         _selectedQtns.toList(),
//       );
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Batch authorization successful!')),
//         );
//         _selectedQtns.clear();
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
//     _pagingController = PagingController<int, QuotationData>(
//       getNextPageKey:
//           (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
//       fetchPage: (pageKey) async {
//         final newItems = await widget.service.fetchQuotationList(
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
//           if (_selectedQtns.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   Text('${_selectedQtns.length} selected'),
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
//             child: PagingListener<int, QuotationData>(
//               controller: _pagingController,
//               builder:
//                   (
//                     context,
//                     state,
//                     fetchNextPage,
//                   ) => PagedListView<int, QuotationData>(
//                     state: state,
//                     fetchNextPage: fetchNextPage,
//                     builderDelegate: PagedChildBuilderDelegate<QuotationData>(
//                       invisibleItemsThreshold: 10,
//                       itemBuilder:
//                           (context, qtn, index) => GestureDetector(
//                             onLongPress: () => _toggleSelection(qtn),
//                             child: QuotationCard(
//                               qtn: qtn,
//                               onPdfTap: () => widget.onPdfTap(qtn),
//                               onAuthorizeTap: () async {
//                                 final authorized = await widget.onAuthorizeTap(
//                                   qtn,
//                                 );
//                                 if (authorized) {
//                                   _pagingController.refresh();
//                                 }
//                               },
//                               selected: _selectedQtns.contains(qtn),
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
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import 'quotation_card.dart';
import 'package:flutter/services.dart';

class QuotationInfiniteList extends StatefulWidget {
  final QuotationService service;
  final void Function(QuotationData qtn) onPdfTap;
  final Future<bool> Function(QuotationData qtn) onAuthorizeTap;

  const QuotationInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<QuotationInfiniteList> createState() => _QuotationInfiniteListState();
}

class _QuotationInfiniteListState extends State<QuotationInfiniteList>
    with AutomaticKeepAliveClientMixin<QuotationInfiniteList> {
  static const _pageSize = 50;
  final Set<QuotationData> _selectedQtns = {};
  bool _isSelectionMode = false;

  late final PagingController<int, QuotationData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void _toggleSelection(QuotationData qtn) {
    // Don't allow selection of already authorized quotations
    if (qtn.isAuthorized) return;

    setState(() {
      if (_selectedQtns.contains(qtn)) {
        _selectedQtns.remove(qtn);
        HapticFeedback.mediumImpact();
      } else {
        _selectedQtns.add(qtn);
        HapticFeedback.lightImpact();
      }

      // Exit selection mode if no items are selected
      if (_selectedQtns.isEmpty) {
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
      _selectedQtns.clear();
    });
  }

  void _selectAll() {
    final allItems = _pagingController.items ?? [];
    // Only select non-authorized quotations
    final selectableItems = allItems.where((qtn) => !qtn.isAuthorized).toList();
    setState(() {
      _selectedQtns.addAll(selectableItems);
    });
  }

  void _selectNone() {
    setState(() {
      _selectedQtns.clear();
    });
  }

  Future<void> _batchAuthorize() async {
    if (_selectedQtns.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batch Authorize'),
            content: Text(
              'Authorize ${_selectedQtns.length} selected Quotations?',
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
      final success = await widget.service.authorizeQuotationBatch(
        _selectedQtns.toList(),
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
    _pagingController = PagingController<int, QuotationData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchQuotationList(
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
                title: Text('${_selectedQtns.length} selected'),
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
              child: PagingListener<int, QuotationData>(
                controller: _pagingController,
                builder:
                    (
                      context,
                      state,
                      fetchNextPage,
                    ) => PagedListView<int, QuotationData>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<QuotationData>(
                        invisibleItemsThreshold: 10,
                        itemBuilder:
                            (context, qtn, index) => QuotationCard(
                              qtn: qtn,
                              onPdfTap: () => widget.onPdfTap(qtn),
                              onAuthorizeTap: () async {
                                final authorized = await widget.onAuthorizeTap(
                                  qtn,
                                );
                                if (authorized) {
                                  _pagingController.refresh();
                                }
                              },
                              selected: _selectedQtns.contains(qtn),
                              showCheckbox: _isSelectionMode,
                              onCheckboxChanged: () => _toggleSelection(qtn),
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
          _isSelectionMode && _selectedQtns.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _batchAuthorize,
                icon: const Icon(Icons.check_circle),
                label: Text('Authorize (${_selectedQtns.length})'),
              )
              : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
