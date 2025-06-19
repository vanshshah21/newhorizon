import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/labour_po_data.dart';
import '../services/labour_po_service.dart';
import 'labour_po_card.dart';

class LabourPOInfiniteListTab extends StatefulWidget {
  final LabourPOService service;
  final void Function(LabourPOData po) onPdfTap;
  final void Function(LabourPOData po) onCallTap;

  const LabourPOInfiniteListTab({
    required this.service,
    required this.onPdfTap,
    required this.onCallTap,
    super.key,
  });

  @override
  State<LabourPOInfiniteListTab> createState() =>
      _LabourPOInfiniteListTabState();
}

class _LabourPOInfiniteListTabState extends State<LabourPOInfiniteListTab>
    with AutomaticKeepAliveClientMixin<LabourPOInfiniteListTab> {
  static const _pageSize = 10;

  late final PagingController<int, LabourPOData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, LabourPOData>(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) async {
        try {
          final newItems = await widget.service.fetchLabourPOListPaged(
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
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _onSearch;
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagingListener<int, LabourPOData>(
            controller: _pagingController,
            builder:
                (context, state, fetchNextPage) =>
                    PagedListView<int, LabourPOData>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<LabourPOData>(
                        itemBuilder:
                            (context, po, index) => LabourPOCard(
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
