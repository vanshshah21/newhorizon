import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../services/authorize_po_service.dart';
import 'authorize_po_card.dart';

class AuthorizePOInfiniteList extends StatefulWidget {
  final AuthorizePOService service;
  final bool isRegular;
  final void Function(POData po) onPdfTap;
  final Future<bool> Function(POData po) onAuthorizeTap;

  const AuthorizePOInfiniteList({
    required this.service,
    required this.isRegular,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<AuthorizePOInfiniteList> createState() =>
      _AuthorizePOInfiniteListState();
}

class _AuthorizePOInfiniteListState extends State<AuthorizePOInfiniteList>
    with AutomaticKeepAliveClientMixin<AuthorizePOInfiniteList> {
  static const _pageSize = 20;

  late final PagingController<int, POData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, POData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchPendingAuthPOList(
          page: pageKey,
          pageSize: _pageSize,
          searchValue: _currentSearchValue,
          isRegular: widget.isRegular,
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
              IconButton.filled(
                onPressed: _onSearch,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagingListener<int, POData>(
            controller: _pagingController,
            builder:
                (context, state, fetchNextPage) => PagedListView<int, POData>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<POData>(
                    itemBuilder:
                        (context, po, index) => AuthorizePOCard(
                          po: po,
                          onPdfTap: () => widget.onPdfTap(po),
                          onAuthorizeTap: () async {
                            final authorized = await widget.onAuthorizeTap(po);
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
