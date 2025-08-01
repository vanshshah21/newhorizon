import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/quotation/models/quotation_list_item.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import 'package:nhapp/pages/quotation/widgets/quotation_card.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import 'package:nhapp/utils/error_handler.dart';

class QuotationInfiniteList extends StatefulWidget {
  final QuotationService service;
  final void Function(QuotationListItem quotation) onPdfTap;
  final Future<void> Function()? onRefresh;
  final void Function(QuotationListItem quotation) onEditTap;

  const QuotationInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onEditTap,
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
        try {
          final newItems = await widget.service.fetchQuotationList(
            pageNumber: pageKey,
            pageSize: _pageSize,
            searchValue: _currentSearchValue,
          );
          return newItems;
        } catch (e) {
          // Let the PagingController handle the error
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
                  (
                    context,
                    state,
                    fetchNextPage,
                  ) => PagedListView<int, QuotationListItem>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<
                      QuotationListItem
                    >(
                      itemBuilder:
                          (context, quotation, index) => QuotationCard(
                            quotation: quotation,
                            onPdfTap: () => widget.onPdfTap(quotation),
                            onEditTap: () => widget.onEditTap(quotation),
                          ),
                      noItemsFoundIndicatorBuilder:
                          (context) => ErrorHandler.buildNoDataWidget(
                            message: 'No quotations found.',
                          ),
                      firstPageErrorIndicatorBuilder:
                          (context) => ErrorHandler.buildErrorWidget(
                            'Failed to load quotations. Please check your connection and try again.',
                            onRetry: () => _pagingController.refresh(),
                          ),
                      newPageErrorIndicatorBuilder:
                          (context) => Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Failed to load more quotations',
                                  style: TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _pagingController.refresh(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
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
