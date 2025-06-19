import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
import '../models/sales_order.dart';
import 'sales_order_card.dart';

class SalesOrderInfiniteListTab extends StatefulWidget {
  final SalesOrderService service;
  final void Function(SalesOrder so) onPdfTap;

  const SalesOrderInfiniteListTab({
    required this.service,
    required this.onPdfTap,
    super.key,
  });

  @override
  State<SalesOrderInfiniteListTab> createState() =>
      _SalesOrderInfiniteListTabState();
}

class _SalesOrderInfiniteListTabState extends State<SalesOrderInfiniteListTab>
    with AutomaticKeepAliveClientMixin<SalesOrderInfiniteListTab> {
  static const _pageSize = 10;

  late final PagingController<int, SalesOrder> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, SalesOrder>(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) async {
        try {
          final newItems = await widget.service.fetchSalesOrderPaged(
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
                  onSubmitted: (_) => _onSearch(),
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _onSearch, child: const Text('Search')),
            ],
          ),
        ),
        Expanded(
          child: PagingListener<int, SalesOrder>(
            controller: _pagingController,
            builder:
                (context, state, fetchNextPage) =>
                    PagedListView<int, SalesOrder>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<SalesOrder>(
                        itemBuilder:
                            (context, so, index) => SalesOrderCard(
                              so: so,
                              onPdfTap: () => widget.onPdfTap(so),
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
