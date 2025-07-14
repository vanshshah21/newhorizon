import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../services/labor_po_service.dart';
import 'labor_po_card.dart';
import 'package:flutter/services.dart';

class LaborPOInfiniteList extends StatefulWidget {
  final LaborPOService service;
  final void Function(LaborPOData po) onPdfTap;
  final Future<bool> Function(LaborPOData po) onAuthorizeTap;

  const LaborPOInfiniteList({
    required this.service,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<LaborPOInfiniteList> createState() => _LaborPOInfiniteListState();
}

class _LaborPOInfiniteListState extends State<LaborPOInfiniteList>
    with AutomaticKeepAliveClientMixin<LaborPOInfiniteList> {
  static const _pageSize = 50;
  final Set<LaborPOData> _selectedPOs = {};
  bool _isSelectionMode = false;

  late final PagingController<int, LaborPOData> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void _toggleSelection(LaborPOData po) {
    setState(() {
      if (_selectedPOs.contains(po)) {
        _selectedPOs.remove(po);
        HapticFeedback.mediumImpact();
      } else {
        _selectedPOs.add(po);
        HapticFeedback.lightImpact();
      }

      // Exit selection mode if no items are selected
      if (_selectedPOs.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPOs.clear();
    });
  }

  void _selectAll() {
    final allItems = _pagingController.items ?? [];
    setState(() {
      _selectedPOs.addAll(allItems);
    });
  }

  void _selectNone() {
    setState(() {
      _selectedPOs.clear();
    });
  }

  Future<void> _batchAuthorize() async {
    if (_selectedPOs.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batch Authorize'),
            content: Text(
              'Authorize ${_selectedPOs.length} selected Labor POs?',
            ),
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
      final success = await widget.service.authorizeLaborPOBatch(
        _selectedPOs.toList(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch authorization successful!')),
        );
        _exitSelectionMode();
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
    _pagingController = PagingController<int, LaborPOData>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchLaborPOList(
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

    return Scaffold(
      appBar:
          _isSelectionMode
              ? AppBar(
                title: Text('${_selectedPOs.length} selected'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelectionMode,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.checklist_rounded),
                    onPressed: _selectAll,
                    tooltip: 'Select All',
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_done),
                    onPressed: _selectNone,
                    tooltip: 'Select None',
                  ),
                ],
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: Column(
          children: [
            // Search bar - only show when not in selection mode
            if (!_isSelectionMode)
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
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _enterSelectionMode,
                      icon: const Icon(Icons.checklist),
                      tooltip: 'Select Mode',
                    ),
                  ],
                ),
              ),

            Expanded(
              child: PagingListener<int, LaborPOData>(
                controller: _pagingController,
                builder:
                    (
                      context,
                      state,
                      fetchNextPage,
                    ) => PagedListView<int, LaborPOData>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate<LaborPOData>(
                        itemBuilder:
                            (context, po, index) => LaborPOCard(
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
                              showCheckbox: _isSelectionMode,
                              onCheckboxChanged: () => _toggleSelection(po),
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
        ),
      ),
      floatingActionButton:
          _isSelectionMode && _selectedPOs.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _batchAuthorize,
                icon: const Icon(Icons.check_circle),
                label: Text('Authorize (${_selectedPOs.length})'),
              )
              : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
