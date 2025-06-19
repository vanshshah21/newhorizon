import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/followup/models/followup_list_item.dart';
import 'package:nhapp/pages/followup/service/followup_service.dart';
import 'package:nhapp/pages/followup/widgets/followup_card.dart';
import 'package:nhapp/utils/paging_extensions.dart';

class FollowupInfiniteList extends StatefulWidget {
  final void Function(FollowupListItem followup) onTap;
  final Future<void> Function()? onRefresh;

  const FollowupInfiniteList({required this.onTap, this.onRefresh, super.key});

  @override
  State<FollowupInfiniteList> createState() => FollowupInfiniteListState();
}

class FollowupInfiniteListState extends State<FollowupInfiniteList>
    with AutomaticKeepAliveClientMixin<FollowupInfiniteList> {
  static const _pageSize = 20;
  final FollowupService service = FollowupService();
  late final PagingController<int, FollowupListItem> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void refresh() {
    _pagingController.refresh();
  }

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, FollowupListItem>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await service.fetchFollowupList(
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
            child: PagingListener<int, FollowupListItem>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) =>
                      PagedListView<int, FollowupListItem>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate:
                            PagedChildBuilderDelegate<FollowupListItem>(
                              itemBuilder:
                                  (context, followup, index) => FollowupCard(
                                    followup: followup,
                                    onTap: () => widget.onTap(followup),
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
