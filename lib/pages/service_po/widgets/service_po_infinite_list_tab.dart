// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/pages/service_po/service/service_po_service.dart';

// import 'service_po_card.dart';

// class ServicePOInfiniteListTab extends StatefulWidget {
//   final ServicePOService service;
//   final void Function(ServicePOData po) onPdfTap;
//   final void Function(ServicePOData po) onCallTap;

//   const ServicePOInfiniteListTab({
//     required this.service,
//     required this.onPdfTap,
//     required this.onCallTap,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<ServicePOInfiniteListTab> createState() =>
//       _ServicePOInfiniteListTabState();
// }

// class _ServicePOInfiniteListTabState extends State<ServicePOInfiniteListTab>
//     with AutomaticKeepAliveClientMixin<ServicePOInfiniteListTab> {
//   static const _pageSize = 20;

//   late final PagingController<int, ServicePOData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, ServicePOData>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         try {
//           final newItems = await widget.service.fetchServicePOListPaged(
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
//                   onSubmitted: (_) => _onSearch(),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton.filled(
//                 onPressed: _onSearch,
//                 icon: const Icon(Icons.search),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: PagingListener<int, ServicePOData>(
//             controller: _pagingController,
//             builder:
//                 (context, state, fetchNextPage) =>
//                     PagedListView<int, ServicePOData>(
//                       state: state,
//                       fetchNextPage: fetchNextPage,
//                       builderDelegate: PagedChildBuilderDelegate<ServicePOData>(
//                         itemBuilder:
//                             (context, po, index) => ServicePOCard(
//                               po: po,
//                               onCallTap: () => widget.onCallTap(po),
//                               onPdfTap: () => widget.onPdfTap(po),
//                             ),
//                         noItemsFoundIndicatorBuilder:
//                             (context) =>
//                                 const Center(child: Text('No data found.')),
//                         firstPageErrorIndicatorBuilder:
//                             (context) => const Center(
//                               child: Text('Error loading data.'),
//                             ),
//                       ),
//                     ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/pages/service_po/service/service_po_service.dart';
// import 'service_po_card.dart';

// class ServicePOInfiniteListTab extends StatefulWidget {
//   final ServicePOService service;
//   final void Function(ServicePOData po) onPdfTap;
//   final void Function(ServicePOData po) onCallTap;

//   const ServicePOInfiniteListTab({
//     required this.service,
//     required this.onPdfTap,
//     required this.onCallTap,
//     super.key,
//   });

//   @override
//   State<ServicePOInfiniteListTab> createState() =>
//       _ServicePOInfiniteListTabState();
// }

// class _ServicePOInfiniteListTabState extends State<ServicePOInfiniteListTab>
//     with AutomaticKeepAliveClientMixin<ServicePOInfiniteListTab> {
//   static const _pageSize = 20;

//   late final PagingController<int, ServicePOData> _pagingController;
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, ServicePOData>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         debugPrint('fetchPage called with pageKey: $pageKey');
//         try {
//           final newItems = await widget.service.fetchServicePOListPaged(
//             page: pageKey,
//             pageSize: _pageSize,
//             searchValue: _currentSearchValue,
//           );
//           debugPrint('Fetched ${newItems.length} items');
//           if (!mounted) return [];
//           return newItems;
//         } catch (error, st) {
//           debugPrint('fetchPage error: $error\n$st');
//           if (!mounted) return [];
//           rethrow;
//         }
//       },
//     );
//   }

//   void _onSearch() {
//     final trimmed = _searchController.text.trim();
//     if (_currentSearchValue == trimmed ||
//         (_currentSearchValue == null && trimmed.isEmpty)) {
//       // No change, do not refresh
//       return;
//     }
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       setState(() {
//         _currentSearchValue = trimmed.isEmpty ? null : trimmed;
//         _pagingController.refresh();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
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
//                   onSubmitted: (_) {
//                     _onSearch();
//                   },
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton.filled(
//                 onPressed: () {
//                   FocusScope.of(context).unfocus();
//                   _onSearch();
//                 },
//                 icon: const Icon(Icons.search),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: PagingListener<int, ServicePOData>(
//             controller: _pagingController,
//             builder:
//                 (context, state, fetchNextPage) =>
//                     PagedListView<int, ServicePOData>(
//                       state: state,
//                       fetchNextPage: fetchNextPage,
//                       builderDelegate: PagedChildBuilderDelegate<ServicePOData>(
//                         itemBuilder:
//                             (context, po, index) => ServicePOCard(
//                               po: po,
//                               onCallTap: () => widget.onCallTap(po),
//                               onPdfTap: () => widget.onPdfTap(po),
//                             ),
//                         noItemsFoundIndicatorBuilder:
//                             (context) =>
//                                 const Center(child: Text('No data found.')),
//                         firstPageErrorIndicatorBuilder:
//                             (context) => const Center(
//                               child: Text('Error loading data.'),
//                             ),
//                       ),
//                     ),
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
import 'package:nhapp/pages/service_po/models/service_po_data.dart';
import 'package:nhapp/pages/service_po/service/service_po_service.dart';
import 'service_po_card.dart';

class ServicePOInfiniteListTab extends StatefulWidget {
  final ServicePOService service;
  final void Function(ServicePOData po) onPdfTap;
  final void Function(ServicePOData po) onCallTap;

  const ServicePOInfiniteListTab({
    required this.service,
    required this.onPdfTap,
    required this.onCallTap,
    super.key,
  });

  @override
  State<ServicePOInfiniteListTab> createState() =>
      _ServicePOInfiniteListTabState();
}

class _ServicePOInfiniteListTabState extends State<ServicePOInfiniteListTab>
    with AutomaticKeepAliveClientMixin<ServicePOInfiniteListTab> {
  static const _pageSize = 20;

  late final PagingController<int, ServicePOData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, ServicePOData>(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) async {
        try {
          final newItems = await widget.service.fetchServicePOListPaged(
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
    });
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
                  _onSearch(); // Call the function properly
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagingListener<int, ServicePOData>(
            controller: _pagingController,
            builder:
                (context, state, fetchNextPage) =>
                    PagedListView<int, ServicePOData>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<ServicePOData>(
                        itemBuilder:
                            (context, po, index) => ServicePOCard(
                              po: po,
                              onCallTap: () => widget.onCallTap(po),
                              onPdfTap: () => widget.onPdfTap(po),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
