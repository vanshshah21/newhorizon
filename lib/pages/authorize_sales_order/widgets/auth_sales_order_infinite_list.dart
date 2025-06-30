import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/pages/authorize_sales_order/service/auth_sales_order_service.dart';
import 'package:nhapp/pages/authorize_sales_order/widgets/auth_sales_order_card.dart';
import 'package:nhapp/utils/paging_extensions.dart';

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
  static const _pageSize = 10;

  late final PagingController<int, SalesOrderData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

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
                    builderDelegate: PagedChildBuilderDelegate<SalesOrderData>(
                      itemBuilder:
                          (context, so, index) => SalesOrderCard(
                            so: so,
                            onPdfTap: () => widget.onPdfTap(so),
                            onAuthorizeTap: () async {
                              final authorized = await widget.onAuthorizeTap(
                                so,
                              );
                              if (authorized) {
                                _pagingController.refresh();
                              }
                            },
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
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
