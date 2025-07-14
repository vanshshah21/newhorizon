import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/pages/quotation/test/service/qote_service.dart';

class EditItemPage extends StatefulWidget {
  final QuotationService service;
  final QuotationItem item;
  final List<RateStructure> rateStructures;
  final List<QuotationItem> existingItems;
  final bool isDuplicateAllowed;

  const EditItemPage({
    super.key,
    required this.service,
    required this.item,
    required this.rateStructures,
    required this.existingItems,
    required this.isDuplicateAllowed,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController basicRateController = TextEditingController();
  final TextEditingController discountPercentageController =
      TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();

  SalesItem? selectedItem;
  String discountType = "None";
  DiscountCode? selectedDiscountCode;
  List<DiscountCode> discountCodes = [];
  String? selectedRateStructure;
  List<Map<String, dynamic>> rateStructureRows = [];
  bool _isLoading = false;
  bool _formDirty = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() async {
    setState(() => _isLoading = true);

    // Load discount codes first
    await _loadDiscountCodes();

    // Initialize form with existing item data
    itemNameController.text = widget.item.itemName;
    qtyController.text = widget.item.qty.toString();
    basicRateController.text = widget.item.basicRate.toString();
    discountType = widget.item.discountType;
    selectedRateStructure = widget.item.rateStructure;

    // Set discount code if available - FIX: Better null safety and validation
    if (widget.item.discountCode != null &&
        widget.item.discountCode!.isNotEmpty &&
        discountCodes.isNotEmpty) {
      final matchingCode =
          discountCodes
              .where((code) => code.code == widget.item.discountCode)
              .toList();

      if (matchingCode.isNotEmpty) {
        selectedDiscountCode = matchingCode.first;
      } else if (discountCodes.isNotEmpty) {
        selectedDiscountCode = discountCodes.first;
      }
    } else if (discountCodes.isNotEmpty) {
      selectedDiscountCode = discountCodes.first;
    }

    // Set discount values based on type
    if (widget.item.discountType == "Percentage" &&
        widget.item.discountPercentage != null) {
      discountPercentageController.text =
          widget.item.discountPercentage!.toString();
    } else if (widget.item.discountType == "Value" &&
        widget.item.discountAmount != null) {
      discountAmountController.text = widget.item.discountAmount!.toString();
    }

    // Create a SalesItem object from the existing item data
    selectedItem = SalesItem(
      itemCode: widget.item.itemCode,
      itemName: widget.item.itemName,
      salesUOM: widget.item.uom,
      hsnCode: widget.item.hsnCode ?? '',
      salesItemFullName: '${widget.item.itemCode} - ${widget.item.itemName}',
    );

    // ALWAYS fetch fresh rate structure details to ensure we have the latest structure
    if (selectedRateStructure != null && selectedRateStructure!.isNotEmpty) {
      try {
        rateStructureRows = await widget.service.fetchRateStructureDetails(
          selectedRateStructure!,
        );
        print("Loaded fresh rate structure rows: $rateStructureRows");
      } catch (e) {
        print("Error loading rate structure details: $e");
        // Fallback to existing rate structure rows if fetch fails
        if (widget.item.rateStructureRows != null &&
            widget.item.rateStructureRows!.isNotEmpty) {
          rateStructureRows = List<Map<String, dynamic>>.from(
            widget.item.rateStructureRows!,
          );
        }
      }
    }

    setState(() => _isLoading = false);
  }

  // Future<void> _loadDiscountCodes() async {
  //   try {
  //     discountCodes = await widget.service.fetchDiscountCodes();
  //   } catch (e) {
  //     print("Error loading discount codes: $e");
  //     discountCodes = [];
  //   }
  // }
  Future<void> _loadDiscountCodes() async {
    try {
      discountCodes = await widget.service.fetchDiscountCodes();

      // Remove any potential duplicates based on code
      final Map<String, DiscountCode> uniqueCodes = {};
      for (final code in discountCodes) {
        uniqueCodes[code.code] = code;
      }
      discountCodes = uniqueCodes.values.toList();
    } catch (e) {
      print("Error loading discount codes: $e");
      discountCodes = [];
    }
  }

  @override
  void dispose() {
    itemNameController.dispose();
    qtyController.dispose();
    basicRateController.dispose();
    discountPercentageController.dispose();
    discountAmountController.dispose();
    super.dispose();
  }

  // bool _formIsDirty() {
  //   return _formDirty ||
  //       itemNameController.text != widget.item.itemName ||
  //       qtyController.text != widget.item.qty.toString() ||
  //       basicRateController.text != widget.item.basicRate.toString() ||
  //       discountType != widget.item.discountType ||
  //       selectedRateStructure != widget.item.rateStructure ||
  //       selectedDiscountCode?.code != widget.item.discountCode ||
  //       (discountType == "Percentage" &&
  //           discountPercentageController.text !=
  //               (widget.item.discountPercentage?.toString() ?? '')) ||
  //       (discountType == "Value" &&
  //           discountAmountController.text !=
  //               (widget.item.discountAmount?.toString() ?? ''));
  // }
  bool _formIsDirty() {
    return _formDirty ||
        itemNameController.text != widget.item.itemName ||
        qtyController.text != widget.item.qty.toString() ||
        basicRateController.text != widget.item.basicRate.toString() ||
        discountType != widget.item.discountType ||
        selectedRateStructure != widget.item.rateStructure ||
        (selectedDiscountCode?.code ?? '') !=
            (widget.item.discountCode ?? '') ||
        (discountType == "Percentage" &&
            discountPercentageController.text !=
                (widget.item.discountPercentage?.toString() ?? '')) ||
        (discountType == "Value" &&
            discountAmountController.text !=
                (widget.item.discountAmount?.toString() ?? ''));
  }

  void _setDirty() {
    if (!_formDirty) setState(() => _formDirty = true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formIsDirty()) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Discard changes?"),
                  content: const Text(
                    "You have unsaved changes. Do you want to discard them?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Discard"),
                    ),
                  ],
                ),
          );
          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Item")),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildItemNameField(),
                        const SizedBox(height: 16),
                        _buildQuantityField(),
                        const SizedBox(height: 16),
                        _buildBasicRateField(),
                        const SizedBox(height: 16),
                        _buildDiscountCodeField(),
                        const SizedBox(height: 16),
                        _buildDiscountTypeField(),
                        if (discountType == "Percentage") ...[
                          const SizedBox(height: 16),
                          _buildDiscountPercentageField(),
                        ],
                        if (discountType == "Value") ...[
                          const SizedBox(height: 16),
                          _buildDiscountAmountField(),
                        ],
                        const SizedBox(height: 16),
                        _buildRateStructureField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildDiscountCodeField() {
    return DropdownButtonFormField<DiscountCode>(
      value: selectedDiscountCode,
      decoration: const InputDecoration(
        labelText: "Discount Code",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items:
          discountCodes.map((discountCode) {
            return DropdownMenuItem<DiscountCode>(
              value: discountCode,
              child: Text(
                discountCode.codeFullName,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
      onChanged: (val) {
        setState(() {
          selectedDiscountCode = val;
          _formDirty = true;
        });
      },
      validator: (value) => value == null ? "Discount Code is required" : null,
    );
  }

  Widget _buildItemNameField() {
    return TypeAheadField<SalesItem>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: itemNameController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: "Item Name",
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _setDirty(),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Item Name is required" : null,
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length < 4) return [];
        try {
          final allItems = await widget.service.fetchSalesItemList(pattern);

          if (!widget.isDuplicateAllowed) {
            final addedItemCodes =
                widget.existingItems.map((item) => item.itemCode).toSet();
            return allItems
                .where((item) => !addedItemCodes.contains(item.itemCode))
                .toList();
          }

          return allItems;
        } catch (e) {
          return [];
        }
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.itemName),
          subtitle: Text(suggestion.itemCode),
        );
      },
      onSelected: (suggestion) async {
        if (!widget.isDuplicateAllowed) {
          final isDuplicate = widget.existingItems.any(
            (item) => item.itemCode == suggestion.itemCode,
          );
          if (isDuplicate) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This item is already added"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        setState(() {
          selectedItem = suggestion;
          itemNameController.text = suggestion.itemName;
          _formDirty = true;
        });
      },
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: false,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: qtyController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            selectedItem == null
                ? "Quantity (min 1)"
                : "Quantity (${selectedItem!.salesUOM})",
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (value == null || value.isEmpty) return "Quantity is required";
        final qty = double.tryParse(value);
        if (qty == null || qty < 1) return "Minimum quantity is 1";
        return null;
      },
    );
  }

  Widget _buildBasicRateField() {
    return TextFormField(
      controller: basicRateController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Basic Rate",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (value == null || value.isEmpty) return "Basic Rate is required";
        final rate = double.tryParse(value);
        if (rate == null || rate <= 0) {
          return "Basic Rate must be greater than 0";
        }
        return null;
      },
    );
  }

  Widget _buildDiscountTypeField() {
    return DropdownButtonFormField<String>(
      value: discountType,
      decoration: const InputDecoration(
        labelText: "Discount Type",
        border: OutlineInputBorder(),
      ),
      items:
          [
            "None",
            "Percentage",
            "Value",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            discountType = val;
            if (val == "None") {
              discountPercentageController.clear();
              discountAmountController.clear();
            }
            _formDirty = true;
          });
        }
      },
    );
  }

  Widget _buildDiscountPercentageField() {
    return TextFormField(
      controller: discountPercentageController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Discount Percentage (1-99)",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (discountType == "Percentage") {
          if (value == null || value.isEmpty) {
            return "Discount Percentage is required";
          }
          final perc = double.tryParse(value);
          if (perc == null || perc < 1 || perc >= 100) {
            return "Value must be between 1 and 99";
          }
        }
        return null;
      },
    );
  }

  Widget _buildDiscountAmountField() {
    return TextFormField(
      controller: discountAmountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Discount Amount (less than Basic Rate)",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (discountType == "Value") {
          if (value == null || value.isEmpty) {
            return "Discount Amount is required";
          }
          final disc = double.tryParse(value);
          final rate = double.tryParse(basicRateController.text) ?? 0;
          if (disc == null || disc >= rate) {
            return "Discount must be less than Basic Rate";
          }
        }
        return null;
      },
    );
  }

  Widget _buildRateStructureField() {
    return DropdownButtonFormField<String>(
      value: selectedRateStructure,
      decoration: const InputDecoration(
        labelText: "Rate Structure",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      selectedItemBuilder: (context) {
        return widget.rateStructures.map((rs) {
          return SizedBox(
            width: 200,
            child: Text(
              rs.rateStructFullName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black),
            ),
          );
        }).toList();
      },
      items:
          widget.rateStructures.map((rs) {
            return DropdownMenuItem<String>(
              value: rs.rateStructCode,
              child: Text(
                rs.rateStructFullName,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
      onChanged: (val) async {
        if (val != null) {
          setState(() {
            selectedRateStructure = val;
            _formDirty = true;
          });

          try {
            setState(() => _isLoading = true);
            final newRateStructureRows = await widget.service
                .fetchRateStructureDetails(val);
            setState(() {
              rateStructureRows = newRateStructureRows;
              _isLoading = false;
            });
            print("Loaded new rate structure rows: $rateStructureRows");
          } catch (e) {
            setState(() => _isLoading = false);
            print("Error loading rate structure details: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error loading rate structure: ${e.toString()}"),
              ),
            );
          }
        }
      },
      validator: (value) => value == null ? "Rate Structure is required" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateItem,
        child:
            _isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Update Item"),
      ),
    );
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(qtyController.text);
    final basicRate = double.parse(basicRateController.text);

    double discountAmount = 0;
    double? discountPercentage;

    if (discountType == "Percentage") {
      discountPercentage = double.parse(discountPercentageController.text);
      discountAmount = (basicRate * qty) * (discountPercentage / 100);
    } else if (discountType == "Value") {
      discountAmount = double.parse(discountAmountController.text);
      discountPercentage = (discountAmount / (basicRate * qty)) * 100;
    }

    setState(() => _isLoading = true);

    try {
      final discountedValue = (basicRate * qty) - discountAmount;

      // Build RateStructureDetails for this item - use the EXACT same logic as ad_itm.dart
      final rateStructureDetails = widget.service.buildRateStructureDetails(
        rateStructureRows,
        selectedItem?.itemCode ?? widget.item.itemCode,
        1, // itmModelRefNo - use 1 for consistency with ad_itm.dart
      );

      print("Original Rate Structure Details: $rateStructureDetails");

      // Calculate rate structure amount - use the EXACT same logic as ad_itm.dart
      final rateStructureResponse = await widget.service.calculateRateStructure(
        discountedValue,
        selectedRateStructure!,
        rateStructureDetails,
        selectedItem?.itemCode ?? widget.item.itemCode,
      );

      print("Rate Structure Response: $rateStructureResponse");

      // Check for success in the response - use the EXACT same logic as ad_itm.dart
      if (rateStructureResponse['success'] == true) {
        final data = rateStructureResponse['data'];

        // Get the updated rate structure details with calculated amounts
        final updatedRateStructureDetails =
            data['FinalrateStructureData'] ?? data['rateStructureDetails'];

        print("Updated Rate Structure Details: $updatedRateStructureDetails");

        // Calculate total tax amount from updated rate structure details
        double totalTax = 0.0;
        if (updatedRateStructureDetails != null) {
          for (final rateDetail in updatedRateStructureDetails) {
            final rateAmount = (rateDetail['rateAmount'] ?? 0.0).toDouble();
            totalTax += rateAmount;
            print(
              "Rate Code: ${rateDetail['rateCode']}, Rate Amount: $rateAmount",
            );
          }
        }

        print("Total Tax Amount: $totalTax");

        final totalAmount = discountedValue + totalTax;

        final updatedItem = QuotationItem(
          itemName: itemNameController.text,
          itemCode: selectedItem?.itemCode ?? widget.item.itemCode,
          qty: qty,
          basicRate: basicRate,
          uom: selectedItem?.salesUOM ?? widget.item.uom,
          discountType: discountType,
          discountPercentage:
              discountType == "Percentage" ? discountPercentage : null,
          discountAmount: discountAmount > 0 ? discountAmount : null,
          discountCode: selectedDiscountCode?.code, // Include discount code
          rateStructure: selectedRateStructure!,
          taxAmount: totalTax,
          totalAmount: totalAmount,
          rateStructureRows:
              updatedRateStructureDetails != null
                  ? List<Map<String, dynamic>>.from(updatedRateStructureDetails)
                  : rateStructureRows, // fallback to original if update failed
          lineNo: widget.item.lineNo,
          hsnCode: selectedItem?.hsnCode ?? widget.item.hsnCode,
          isFromInquiry: widget.item.isFromInquiry,
        );

        Navigator.pop(context, updatedItem);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${rateStructureResponse['errorMessage'] ?? 'Calculation failed'}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error in _updateItem: $e");
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error calculating item: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
