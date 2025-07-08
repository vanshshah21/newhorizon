// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/purchase_order/model/po_data.dart';
// import '../services/po_service.dart';
// import 'po_card.dart';

// class POInfiniteListTab extends StatefulWidget {
//   final bool isRegular;
//   final POService service;
//   final void Function(POData po) onPdfTap;
//   final void Function(POData po) onCallTap;

//   const POInfiniteListTab({
//     required this.isRegular,
//     required this.service,
//     required this.onPdfTap,
//     required this.onCallTap,
//     super.key,
//   });

//   @override
//   State<POInfiniteListTab> createState() => _POInfiniteListTabState();
// }

// class _POInfiniteListTabState extends State<POInfiniteListTab>
//     with AutomaticKeepAliveClientMixin<POInfiniteListTab> {
//   static const _pageSize = 20;

//   late final PagingController<int, POData> _pagingController;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, POData>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         try {
//           final newItems = await widget.service.fetchPOListPaged(
//             isRegular: widget.isRegular,
//             page: pageKey,
//             pageSize: _pageSize,
//           );
//           if (!mounted) return [];
//           return newItems;
//         } catch (error) {
//           if (!mounted) return [];
//           rethrow;
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Required for AutomaticKeepAliveClientMixin
//     return PagingListener<int, POData>(
//       controller: _pagingController,
//       builder:
//           (context, state, fetchNextPage) => PagedListView<int, POData>(
//             state: state,
//             fetchNextPage: fetchNextPage,
//             builderDelegate: PagedChildBuilderDelegate<POData>(
//               itemBuilder:
//                   (context, po, index) => POCard(
//                     po: po,
//                     isRegular: widget.isRegular,
//                     onCallTap: () => widget.onCallTap(po),
//                     onPdfTap: () => widget.onPdfTap(po),
//                   ),
//               noItemsFoundIndicatorBuilder:
//                   (context) => const Center(child: Text('No data found.')),
//               firstPageErrorIndicatorBuilder:
//                   (context) => const Center(child: Text('Error loading data.')),
//             ),
//           ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/purchase_order/model/po_data.dart';
// import '../services/po_service.dart';
// import 'po_card.dart';

// class POInfiniteListTab extends StatefulWidget {
//   final bool isRegular;
//   final POService service;
//   final void Function(POData po) onPdfTap;
//   final void Function(POData po) onCallTap;

//   const POInfiniteListTab({
//     required this.isRegular,
//     required this.service,
//     required this.onPdfTap,
//     required this.onCallTap,
//     super.key,
//   });

//   @override
//   State<POInfiniteListTab> createState() => _POInfiniteListTabState();
// }

// class _POInfiniteListTabState extends State<POInfiniteListTab>
//     with AutomaticKeepAliveClientMixin<POInfiniteListTab> {
//   static const _pageSize = 20;

//   late final PagingController<int, POData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, POData>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         try {
//           final newItems = await widget.service.fetchPOListPaged(
//             isRegular: widget.isRegular,
//             page: pageKey,
//             pageSize: _pageSize,
//             searchValue: _currentSearchValue,
//           );
//           if (!mounted) return [];
//           return newItems;
//         } catch (error) {
//           if (!mounted) return [];
//           rethrow;
//         }
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
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: const InputDecoration(
//                     labelText: 'Search',
//                     border: OutlineInputBorder(),
//                   ),
//                   onTapOutside: (event) {
//                     FocusScope.of(context).unfocus();
//                   },
//                   onSubmitted: (_) => _onSearch(),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // IconButton.filled(
//               //   onPressed: _onSearch,
//               //   icon: const Icon(Icons.search),
//               // ),
//               IconButton.filled(
//                 onPressed: () {
//                   _onSearch(); // Add parentheses to call the function
//                   FocusScope.of(context).unfocus();
//                 },
//                 icon: const Icon(Icons.search),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: PagingListener<int, POData>(
//             controller: _pagingController,
//             builder:
//                 (context, state, fetchNextPage) => PagedListView<int, POData>(
//                   state: state,
//                   fetchNextPage: fetchNextPage,
//                   builderDelegate: PagedChildBuilderDelegate<POData>(
//                     itemBuilder:
//                         (context, po, index) => POCard(
//                           po: po,
//                           isRegular: widget.isRegular,
//                           onCallTap: () => widget.onCallTap(po),
//                           onPdfTap: () => widget.onPdfTap(po),
//                         ),
//                     noItemsFoundIndicatorBuilder:
//                         (context) =>
//                             const Center(child: Text('No data found.')),
//                     firstPageErrorIndicatorBuilder:
//                         (context) =>
//                             const Center(child: Text('Error loading data.')),
//                   ),
//                 ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/purchase_order/model/po_data.dart';
import '../services/po_service.dart';
import 'po_card.dart';

class POInfiniteListTab extends StatefulWidget {
  final bool isRegular;
  final POService service;
  final void Function(POData po) onPdfTap;
  final void Function(POData po) onCallTap;

  const POInfiniteListTab({
    required this.isRegular,
    required this.service,
    required this.onPdfTap,
    required this.onCallTap,
    super.key,
  });

  @override
  State<POInfiniteListTab> createState() => _POInfiniteListTabState();
}

class _POInfiniteListTabState extends State<POInfiniteListTab>
    with AutomaticKeepAliveClientMixin<POInfiniteListTab> {
  static const _pageSize = 20;

  late final PagingController<int, POData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, POData>(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) async {
        try {
          final newItems = await widget.service.fetchPOListPaged(
            isRegular: widget.isRegular,
            page: pageKey,
            pageSize: _pageSize,
            searchValue: _currentSearchValue,
          );
          if (!mounted) return [];
          return newItems;
        } catch (error) {
          if (!mounted) return [];
          rethrow;
        }
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

  Future<void> _onRefresh() async {
    _pagingController.refresh();
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
    return Column(
      children: [
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
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  _onSearch();
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: PagingListener<int, POData>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) => PagedListView<int, POData>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<POData>(
                      itemBuilder:
                          (context, po, index) => POCard(
                            po: po,
                            isRegular: widget.isRegular,
                            onCallTap: () => widget.onCallTap(po),
                            onPdfTap: () => widget.onPdfTap(po),
                          ),
                      noItemsFoundIndicatorBuilder:
                          (context) =>
                              const Center(child: Text('No data found.')),
                      firstPageErrorIndicatorBuilder:
                          (context) =>
                              const Center(child: Text('Error loading data.')),
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
