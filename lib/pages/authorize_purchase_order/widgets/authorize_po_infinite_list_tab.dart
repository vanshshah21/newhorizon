import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../services/authorize_po_service.dart';
import 'authorize_po_card.dart';
import 'package:flutter/services.dart';

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
  static const _pageSize = 50;
  final Set<POData> _selectedPOs = {};

  late final PagingController<int, POData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void _toggleSelection(POData po) {
    setState(() {
      if (_selectedPOs.contains(po)) {
        _selectedPOs.remove(po);
        HapticFeedback.mediumImpact();
      } else {
        _selectedPOs.add(po);
        HapticFeedback.lightImpact();
      }
    });
  }

  Future<void> _batchAuthorize() async {
    if (_selectedPOs.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batch Authorize'),
            content: Text('Authorize ${_selectedPOs.length} selected POs?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Authorize'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      final success = await widget.service.authorizePOBatch(
        _selectedPOs.toList(),
        widget.isRegular,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch authorization successful!')),
        );
        _selectedPOs.clear();
        _pagingController.refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch authorization failed!')),
        );
      }
    }
  }

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
          if (_selectedPOs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('${_selectedPOs.length} selected'),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _batchAuthorize,
                    icon: const Icon(Icons.check),
                    label: const Text('Batch Authorize'),
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
                          (context, po, index) => GestureDetector(
                            onLongPress: () => _toggleSelection(po),
                            child: AuthorizePOCard(
                              po: po,
                              onPdfTap: () => widget.onPdfTap(po),
                              onAuthorizeTap: () async {
                                final authorized = await widget.onAuthorizeTap(
                                  po,
                                );
                                if (authorized) {
                                  _pagingController.refresh();
                                }
                              },
                              selected: _selectedPOs.contains(po),
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
