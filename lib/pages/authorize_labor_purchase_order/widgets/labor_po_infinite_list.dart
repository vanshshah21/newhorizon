// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
// import 'package:nhapp/utils/paging_extensions.dart';
// import '../services/labor_po_service.dart';
// import 'labor_po_card.dart';

// class LaborPOInfiniteList extends StatefulWidget {
//   final LaborPOService service;
//   final void Function(LaborPOData po) onPdfTap;
//   final Future<bool> Function(LaborPOData po) onAuthorizeTap;

//   const LaborPOInfiniteList({
//     required this.service,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<LaborPOInfiniteList> createState() => _LaborPOInfiniteListState();
// }

// class _LaborPOInfiniteListState extends State<LaborPOInfiniteList>
//     with AutomaticKeepAliveClientMixin<LaborPOInfiniteList> {
//   static const _pageSize = 10;

//   late final PagingController<int, LaborPOData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, LaborPOData>(
//       getNextPageKey:
//           (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
//       fetchPage: (pageKey) async {
//         final newItems = await widget.service.fetchLaborPOList(
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
//     super.build(context); // for AutomaticKeepAliveClientMixin
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
//           Expanded(
//             child: PagingListener<int, LaborPOData>(
//               controller: _pagingController,
//               builder:
//                   (context, state, fetchNextPage) =>
//                       PagedListView<int, LaborPOData>(
//                         state: state,
//                         fetchNextPage: fetchNextPage,
//                         builderDelegate: PagedChildBuilderDelegate<LaborPOData>(
//                           itemBuilder:
//                               (context, po, index) => LaborPOCard(
//                                 po: po,
//                                 onPdfTap: () => widget.onPdfTap(po),
//                                 onAuthorizeTap: () async {
//                                   final authorized = await widget
//                                       .onAuthorizeTap(po);
//                                   if (authorized) {
//                                     _pagingController.refresh();
//                                   }
//                                 },
//                               ),
//                           noItemsFoundIndicatorBuilder:
//                               (context) =>
//                                   const Center(child: Text('No data found.')),
//                           firstPageErrorIndicatorBuilder:
//                               (context) => const Center(
//                                 child: Text('Error loading data.'),
//                               ),
//                         ),
//                       ),
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
import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../services/labor_po_service.dart';
import 'labor_po_card.dart';

class LaborPOInfiniteList extends StatefulWidget {
  final LaborPOService service;
  final bool isSelectionMode;
  final Set<LaborPOData> selectedPOs;
  final void Function(LaborPOData po) onPdfTap;
  final Future<bool> Function(LaborPOData po) onAuthorizeTap;
  final void Function(LaborPOData po) onToggleSelection;
  final void Function(LaborPOData po) onEnterSelectionMode;
  final VoidCallback onBulkAuthorizeRequested;

  const LaborPOInfiniteList({
    required this.service,
    required this.isSelectionMode,
    required this.selectedPOs,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    required this.onToggleSelection,
    required this.onEnterSelectionMode,
    required this.onBulkAuthorizeRequested,
    super.key,
  });

  @override
  State<LaborPOInfiniteList> createState() => _LaborPOInfiniteListState();
}

class _LaborPOInfiniteListState extends State<LaborPOInfiniteList>
    with AutomaticKeepAliveClientMixin<LaborPOInfiniteList> {
  static const _pageSize = 10;

  late final PagingController<int, LaborPOData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, LaborPOData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchLaborPOList(
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

  void _selectAll() {
    // Get all items from the controller's value
    final allItems = _getAllLoadedItems();
    for (final item in allItems) {
      if (!widget.selectedPOs.contains(item)) {
        widget.onToggleSelection(item);
      }
    }
  }

  List<LaborPOData> _getAllLoadedItems() {
    final value = _pagingController.value;
    // Try different property names based on the package version
    // if (value.items != null) {
    //   return value.items!;
    // } else if (value.items != null) {
    //   return value.items!;
    // }
    // If the above doesn't work, let's manually collect items
    return _pagingController.items ?? [];
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
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
                  ],
                ),
                if (widget.isSelectionMode) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectAll,
                          icon: const Icon(Icons.select_all),
                          label: const Text('Select All'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              widget.selectedPOs.isNotEmpty
                                  ? widget.onBulkAuthorizeRequested
                                  : null,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            'Authorize (${widget.selectedPOs.length})',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: PagingListener<int, LaborPOData>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) =>
                      PagedListView<int, LaborPOData>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate: PagedChildBuilderDelegate<LaborPOData>(
                          itemBuilder:
                              (context, po, index) => LaborPOCard(
                                po: po,
                                isSelectionMode: widget.isSelectionMode,
                                isSelected: widget.selectedPOs.contains(po),
                                onPdfTap: () => widget.onPdfTap(po),
                                onAuthorizeTap: () async {
                                  final authorized = await widget
                                      .onAuthorizeTap(po);
                                  if (authorized) {
                                    _pagingController.refresh();
                                  }
                                },
                                onTap: () {
                                  if (widget.isSelectionMode) {
                                    widget.onToggleSelection(po);
                                  }
                                },
                                onLongPress: () {
                                  if (!widget.isSelectionMode) {
                                    widget.onEnterSelectionMode(po);
                                  }
                                },
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
