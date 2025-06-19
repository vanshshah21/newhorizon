import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/helper/quotation_helper.dart';
import 'package:nhapp/pages/quotation/models/add_quotation.dart';
import 'package:nhapp/pages/quotation/service/add_quotation.dart';

class AddQuotationItemPage extends StatefulWidget {
  final Map<String, dynamic>? initialItem;

  const AddQuotationItemPage({this.initialItem, super.key});

  @override
  State<AddQuotationItemPage> createState() => _AddQuotationItemPageState();
}

class _AddQuotationItemPageState extends State<AddQuotationItemPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _itemName;
  String? _itemCode;
  String? _uom;
  double? _qty;
  double? _rate;
  String? _discountType;
  String? _discountCode;
  String? _rateStructure;
  double? _discountValue;

  // Controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _uomController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();

  // Dropdown data
  List<DiscountCode> _discountCodes = [];
  List<RateStructure> _rateStructures = [];
  final List<String> _discountTypes = ['None', 'Percentage', 'Value'];

  late final QuotationFormService _service;

  bool _loading = true;
  bool _submitting = false;

  // --- New variables to track selection state ---
  String? _selectedItemText;
  bool _itemSelected = false;

  @override
  void initState() {
    super.initState();
    _service = QuotationFormService();
    _loadDropdowns();

    // Listen for manual edits to item name (to clear dependent fields)
    _itemNameController.addListener(() {
      final currentText = _itemNameController.text;
      // If the text no longer exactly matches the selected value,
      // mark the item as not selected and clear dependent fields.
      if (_itemSelected && currentText != _selectedItemText) {
        setState(() {
          _itemCode = null;
          _uom = null;
          _rate = null;
          _itemSelected = false;
          _selectedItemText = null;
        });
      }
    });

    // If editing, prefill fields
    if (widget.initialItem != null) {
      final item = widget.initialItem!;
      _itemName = item['itemName'];
      _itemCode = item['itemCode'];
      _uom = item['uom'];
      _qty = item['qty'];
      _rate = item['rate'];
      _discountType = item['discountType'];
      _discountCode = item['discountCode'];
      _rateStructure = item['rateStructure'];
      _discountValue =
          (item['discountValue'] is int)
              ? (item['discountValue'] as int).toDouble()
              : (item['discountValue'] as double?) ?? 0.0;
      _itemNameController.text =
          widget.initialItem!['salesItemFullName'] ?? _itemName ?? '';
      _selectedItemText = _itemNameController.text;
      _itemSelected = true;
      _qtyController.text = _qty?.toString() ?? '';
      _uomController.text = _uom ?? '';
      _rateController.text = _rate?.toString() ?? '';
      if (_discountValue != null && _discountValue! > 0) {
        _discountValueController.text = _discountValue!.toString();
      }
    }
  }

  Future<void> _loadDropdowns() async {
    setState(() => _loading = true);
    try {
      final discountCodes = await _service.fetchDiscountCodes();
      final rateStructures = await _service.fetchRateStructures();
      setState(() {
        _discountCodes = discountCodes;
        _rateStructures = rateStructures;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _discountCodes = [];
        _rateStructures = [];
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load dropdowns: $e')));
      }
    }
  }

  void _onItemSelected(QuotationSalesItem item) {
    setState(() {
      _itemName = item.itemName;
      _itemCode = item.itemCode;
      _uom = item.salesUOM;
      _selectedItemText = item.salesItemFullName;
      _itemSelected = true;
      _itemNameController.text = item.salesItemFullName;
      _uomController.text = item.salesUOM;
      _rateController.text = '1.0';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itemCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item from the list')),
      );
      return;
    }
    setState(() => _submitting = true);

    double qty = double.tryParse(_qtyController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 1.0;
    // double itemAmount = qty * rate;
    double discountValue = 0;
    if (_discountType == 'Value' || _discountType == 'Percentage') {
      discountValue = double.tryParse(_discountValueController.text) ?? 0;
    }

    final calc = calculateDiscountedTotal(
      qty: qty,
      rate: rate,
      discountType: _discountType ?? "None",
      discountValue: discountValue,
    );

    // Prepare rateStructureDetails (empty for now, can be extended)
    List<Map<String, dynamic>> rateStructureDetails = [];

    try {
      final taxResult = await _service.calculateTax(
        rateStructureCode: _rateStructure ?? '',
        itemCode: _itemCode ?? '',
        itemAmount: calc.discountedAmount,
        basicRate: rate,
        discountType: _discountType ?? '',
        discountValue: discountValue,
        rateStructureDetails: rateStructureDetails,
      );

      final basicAmount =
          (taxResult['itemLandedInvCost'] ?? calc.discountedAmount).toDouble();
      final taxAmount =
          (taxResult['totalExclusiveDomCurrAmount'] ?? 0.0).toDouble();
      final totalAmount =
          (taxResult['itemLandedCost'] ?? (calc.discountedAmount + taxAmount))
              .toDouble();

      Navigator.of(context).pop({
        'itemName': _itemName,
        'itemCode': _itemCode,
        'uom': _uom,
        'qty': qty,
        'rate': rate,
        'discountType': _discountType,
        'discountCode': _discountCode,
        'rateStructure': _rateStructure,
        'discountValue': calc.discountValueApplied,
        'basicAmount': basicAmount,
        'taxAmount': taxAmount,
        'totalAmount': totalAmount,
      });
      // Navigator.of(context).pop({
      //   'itemName': _itemName,
      //   'itemCode': _itemCode,
      //   'uom': _uom,
      //   'qty': qty,
      //   'rate': rate,
      //   'discountType': _discountType,
      //   'discountCode': _discountCode,
      //   'rateStructure': _rateStructure,
      //   'discountValue': calc.discountValueApplied,
      //   'discountValueApplied': calc.discountValueApplied,
      //   'basicAmount': basicAmount,
      //   'taxAmount': taxAmount,
      //   'totalAmount': totalAmount,
      // });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to calculate tax: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialItem == null ? 'Add New Item' : 'Edit Item'),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Item Name (TypeAheadField)
                    TypeAheadField<QuotationSalesItem>(
                      controller: _itemNameController,
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 4) {
                          return [];
                        }
                        return await _service.searchItems(pattern);
                      },
                      builder:
                          (context, controller, focusNode) => TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Item Name',
                            ),
                            // Do not clear selection if text still matches the selected text
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Select an item';
                              }
                              if (_itemCode == null) {
                                return 'Select an item from the list';
                              }
                              return null;
                            },
                          ),
                      itemBuilder:
                          (context, suggestion) => ListTile(
                            title: Text(suggestion.salesItemFullName),
                            subtitle: Text(suggestion.itemCode),
                          ),
                      onSelected: (suggestion) {
                        _onItemSelected(suggestion);
                      },
                      emptyBuilder: (context) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    // Qty/UOM
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                            validator:
                                (val) =>
                                    (val == null ||
                                            val.isEmpty ||
                                            double.tryParse(val) == null ||
                                            double.parse(val) <= 0)
                                        ? 'Enter quantity'
                                        : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _uomController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'UOM'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Basic Rate
                    TextFormField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Basic Rate',
                      ),
                      validator:
                          (val) =>
                              (val == null ||
                                      val.isEmpty ||
                                      double.tryParse(val) == null)
                                  ? 'Enter rate'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Discount Type (Dropdown, static)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Discount Type',
                      ),
                      value: _discountType,
                      items:
                          _discountTypes
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) {
                        setState(() {
                          _discountType = v;
                          _discountValueController.clear();
                        });
                      },
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select discount type'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Discount Value Field (conditional)
                    if (_discountType == 'Value')
                      TextFormField(
                        controller: _discountValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Discount Value',
                          hintText: 'Enter discount amount',
                        ),
                        validator: (val) {
                          if (_discountType == 'Value') {
                            if (val == null ||
                                val.isEmpty ||
                                double.tryParse(val) == null ||
                                double.parse(val) < 0) {
                              return 'Enter a valid discount value';
                            }
                          }
                          return null;
                        },
                      ),
                    if (_discountType == 'Value') const SizedBox(height: 16),

                    if (_discountType == 'Percentage')
                      TextFormField(
                        controller: _discountValueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Discount Percentage',
                          hintText: 'Enter discount % (0-100)',
                        ),
                        validator: (val) {
                          if (_discountType == 'Percentage') {
                            final v = double.tryParse(val ?? '');
                            if (v == null || v < 0 || v > 100) {
                              return 'Enter a valid percentage (0-100)';
                            }
                          }
                          return null;
                        },
                      ),
                    if (_discountType == 'Percentage')
                      const SizedBox(height: 16),

                    // Discount Code (Dropdown, from API)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Discount Code',
                        isDense: true,
                      ),
                      value: _discountCode,
                      items:
                          _discountCodes
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.code,
                                  child: Text(e.codeFullName),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _discountCode = v),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select discount code'
                                  : null,
                      selectedItemBuilder: (context) {
                        return _discountCodes.map((e) {
                          return Text(
                            e.code,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          );
                        }).toList();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rate Structure (Dropdown, from API)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Rate Structure',
                        isDense: true,
                      ),
                      value: _rateStructure,
                      items:
                          _rateStructures
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.rateStructCode,
                                  child: Text(e.rateStructFullName),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _rateStructure = v),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select rate structure'
                                  : null,
                      selectedItemBuilder: (context) {
                        return _rateStructures.map((e) {
                          return Text(e.rateStructCode);
                        }).toList();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child:
                          _submitting
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save Item'),
                    ),
                  ],
                ),
              ),
    );
  }
}
