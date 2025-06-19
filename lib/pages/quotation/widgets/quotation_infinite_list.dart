import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/quotation/models/quotation_list_item.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import 'package:nhapp/pages/quotation/widgets/quotation_card.dart';
import 'package:nhapp/utils/paging_extensions.dart';

class QuotationInfiniteList extends StatefulWidget {
  final QuotationService service;
  final void Function(QuotationListItem quotation) onPdfTap;
  final Future<void> Function()? onRefresh;

  const QuotationInfiniteList({
    required this.service,
    required this.onPdfTap,
    this.onRefresh,
    super.key,
  });

  @override
  State<QuotationInfiniteList> createState() => QuotationInfiniteListState();
}

class QuotationInfiniteListState extends State<QuotationInfiniteList>
    with AutomaticKeepAliveClientMixin<QuotationInfiniteList> {
  static const _pageSize = 20;

  late final PagingController<int, QuotationListItem> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void refresh() {
    _pagingController.refresh();
  }

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, QuotationListItem>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchQuotationList(
          pageNumber: pageKey,
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
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
            child: PagingListener<int, QuotationListItem>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) =>
                      PagedListView<int, QuotationListItem>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate:
                            PagedChildBuilderDelegate<QuotationListItem>(
                              itemBuilder:
                                  (context, quotation, index) => QuotationCard(
                                    quotation: quotation,
                                    onPdfTap: () => widget.onPdfTap(quotation),
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
