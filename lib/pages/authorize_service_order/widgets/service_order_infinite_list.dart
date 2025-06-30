import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../models/service_order_data.dart';
import '../services/service_order_service.dart';
import 'service_order_card.dart';

class ServiceOrderInfiniteList extends StatefulWidget {
  final ServiceOrderService service;
  final void Function(ServiceOrderData so) onPdfTap;
  final Future<bool> Function(ServiceOrderData so) onAuthorizeTap;

  const ServiceOrderInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<ServiceOrderInfiniteList> createState() =>
      _ServiceOrderInfiniteListState();
}

class _ServiceOrderInfiniteListState extends State<ServiceOrderInfiniteList>
    with AutomaticKeepAliveClientMixin<ServiceOrderInfiniteList> {
  static const _pageSize = 50;

  late final PagingController<int, ServiceOrderData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, ServiceOrderData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchServiceOrderList(
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
    super.build(context); // for AutomaticKeepAliveClientMixin
    return RefreshIndicator(
      onRefresh: () async {
        _pagingController.refresh();
      },
      child: Column(
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
          ),
          Expanded(
            child: PagingListener<int, ServiceOrderData>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) =>
                      PagedListView<int, ServiceOrderData>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate:
                            PagedChildBuilderDelegate<ServiceOrderData>(
                              itemBuilder:
                                  (context, so, index) => ServiceOrderCard(
                                    so: so,
                                    onPdfTap: () => widget.onPdfTap(so),
                                    onAuthorizeTap: () async {
                                      final authorized = await widget
                                          .onAuthorizeTap(so);
                                      if (authorized) {
                                        _pagingController.refresh();
                                      }
                                    },
                                  ),
                              noItemsFoundIndicatorBuilder:
                                  (context) => const Center(
                                    child: Text('No data found.'),
                                  ),
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
