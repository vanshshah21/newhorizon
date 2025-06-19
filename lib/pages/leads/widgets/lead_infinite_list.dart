import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../models/lead_data.dart';
import '../services/lead_service.dart';
import 'lead_card.dart';

class LeadInfiniteList extends StatefulWidget {
  final LeadService service;
  final void Function(LeadData lead) onPdfTap;
  final Future<bool> Function(LeadData lead) onDeleteTap;
  final Future<void> Function()? onRefresh;

  const LeadInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onDeleteTap,
    this.onRefresh,
    super.key,
  });

  @override
  State<LeadInfiniteList> createState() => LeadInfiniteListState();
}

class LeadInfiniteListState extends State<LeadInfiniteList>
    with AutomaticKeepAliveClientMixin<LeadInfiniteList> {
  static const _pageSize = 100;

  late final PagingController<int, LeadData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void refresh() {
    _pagingController.refresh();
  }

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, LeadData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchLeadsList(
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
            child: PagingListener<int, LeadData>(
              controller: _pagingController,
              builder:
                  (
                    context,
                    state,
                    fetchNextPage,
                  ) => PagedListView<int, LeadData>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<LeadData>(
                      invisibleItemsThreshold: 10,
                      itemBuilder:
                          (context, lead, index) => LeadCard(
                            lead: lead,
                            onPdfTap: () => widget.onPdfTap(lead),
                            onDeleteTap: () async {
                              final deleted = await widget.onDeleteTap(lead);
                              if (deleted) {
                                _pagingController.refresh();
                              }
                            },
                            // service: widget.service,
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
