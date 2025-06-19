// widgets/proforma_invoice_infinite_list.dart
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/utils/paging_extensions.dart';
import '../service/proforma_invoice_service.dart';
import 'proforma_invoice_card.dart';

class ProformaInvoiceInfiniteList extends StatefulWidget {
  final ProformaInvoiceService service;
  final void Function(ProformaInvoice invoice) onPdfTap;

  const ProformaInvoiceInfiniteList({
    required this.service,
    required this.onPdfTap,
    super.key,
  });

  @override
  State<ProformaInvoiceInfiniteList> createState() =>
      _ProformaInvoiceInfiniteListState();
}

class _ProformaInvoiceInfiniteListState
    extends State<ProformaInvoiceInfiniteList>
    with AutomaticKeepAliveClientMixin<ProformaInvoiceInfiniteList> {
  static const _pageSize = 10;

  late final PagingController<int, ProformaInvoice> _pagingController;
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, ProformaInvoice>(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final newItems = await widget.service.fetchProformaInvoiceList(
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
    super.build(context);
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
          child: PagingListener<int, ProformaInvoice>(
            controller: _pagingController,
            builder:
                (
                  context,
                  state,
                  fetchNextPage,
                ) => PagedListView<int, ProformaInvoice>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<ProformaInvoice>(
                    itemBuilder:
                        (context, invoice, index) => ProformaInvoiceCard(
                          invoice: invoice,
                          onPdfTap: () => widget.onPdfTap(invoice),
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
