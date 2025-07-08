import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/sales_order/pages/edit_so.dart';
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
      SalesOrderInfiniteListTabState();
}

class SalesOrderInfiniteListTabState extends State<SalesOrderInfiniteListTab>
    with AutomaticKeepAliveClientMixin<SalesOrderInfiniteListTab> {
  static const _pageSize = 50;

  late final PagingController<int, SalesOrder> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  void refreshList() {
    _pagingController.refresh();
  }

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

  Future<void> _handleEditTap(SalesOrder so) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (context) => EditSalesOrderPage(
              ioYear: so.ioYear,
              ioGroup: so.ioGroup,
              ioSiteCode: so.siteCode,
              ioNumber: so.ioNumber,
              locationId: so.siteId,
            ),
      ),
    );

    // If edit was successful, refresh the list
    if (result == true) {
      _pagingController.refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SO #${so.ioNumber} updated successfully')),
      );
    }
  }

  Future<void> _handleDeleteTap(SalesOrder so) async {
    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmationDialog(so);
    if (!confirmed) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text('Deleting SO #${so.ioNumber}...'),
              ],
            ),
            duration: const Duration(seconds: 30), // Long duration for loading
          ),
        );
      }

      // Call delete API
      final success = await widget.service.deleteSalesOrder(so.orderId);

      if (mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          // Remove item using the same method as notifications page
          final currentPages = List<List<SalesOrder>>.from(
            _pagingController.value.pages ?? [],
          );
          final allItems = currentPages.expand((page) => page).toList();
          final index = allItems.indexWhere(
            (item) => item.orderId == so.orderId,
          );

          if (index != -1) {
            allItems.removeAt(index);

            // Re-split into pages
            final newPages = <List<SalesOrder>>[];
            for (var i = 0; i < allItems.length; i += _pageSize) {
              newPages.add(
                allItems.sublist(
                  i,
                  i + _pageSize > allItems.length
                      ? allItems.length
                      : i + _pageSize,
                ),
              );
            }

            setState(() {
              _pagingController.value = _pagingController.value.copyWith(
                pages: newPages,
              );
            });
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SO #${so.ioNumber} deleted successfully'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Refresh',
                textColor: Colors.white,
                onPressed: () => _pagingController.refresh(),
              ),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete SO #${so.ioNumber}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _handleDeleteTap(so),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting SO #${so.ioNumber}: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _handleDeleteTap(so),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(SalesOrder so) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Confirm Delete'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to delete this sales order?',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SO #${so.ioNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(so.customerFullName),
                        const SizedBox(height: 4),
                        Text('Amount: ₹${so.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _waitForFirstPage() async {
    // Wait until the first page is loaded or an error occurs
    while (mounted &&
        _pagingController.value.status == PagingStatus.loadingFirstPage) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
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
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _onSearch();
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagingListener<int, SalesOrder>(
            controller: _pagingController,
            builder:
                (context, state, fetchNextPage) => RefreshIndicator(
                  onRefresh: () async {
                    _pagingController.refresh();
                    // Wait for the first page to load before completing the refresh
                    await _waitForFirstPage();
                  },
                  child: PagedListView<int, SalesOrder>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<SalesOrder>(
                      invisibleItemsThreshold: 10,
                      itemBuilder:
                          (context, so, index) => SalesOrderCard(
                            so: so,
                            onPdfTap: () => widget.onPdfTap(so),
                            onEditTap:
                                so.isEdit ? () => _handleEditTap(so) : null,
                            onDeleteTap:
                                so.isDelete ? () => _handleDeleteTap(so) : null,
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
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
