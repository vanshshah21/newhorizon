import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/pages/authorize_quotation/services/quotation_service.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import 'quotation_card.dart';

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
  static const _pageSize = 100;

  late final PagingController<int, QuotationData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

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
