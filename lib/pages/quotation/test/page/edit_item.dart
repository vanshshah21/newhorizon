import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/pages/quotation/test/service/qote_service.dart';

class EditItemPage extends StatefulWidget {
  final QuotationService service;
  final QuotationItem item;
  final List<RateStructure> rateStructures;

  const EditItemPage({
    super.key,
    required this.service,
    required this.item,
    required this.rateStructures,
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
  String? selectedRateStructure;
  List<Map<String, dynamic>> rateStructureRows = [];
  bool _isLoading = false;
  bool _formDirty = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize form with existing item data
    itemNameController.text = widget.item.itemName;
    qtyController.text = widget.item.qty.toString();
    basicRateController.text = widget.item.basicRate.toString();
    // discountType = widget.item.discountType;
    // selectedRateStructure = widget.item.rateStructure;
    // rateStructureRows = widget.item.rateStructureRows ?? [];

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

  bool _formIsDirty() {
    return _formDirty ||
        itemNameController.text != widget.item.itemName ||
        qtyController.text != widget.item.qty.toString() ||
        basicRateController.text != widget.item.basicRate.toString() ||
        discountType != widget.item.discountType ||
        selectedRateStructure != widget.item.rateStructure ||
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
                      children: [
                        _buildItemNameField(),
                        const SizedBox(height: 16),
                        _buildQuantityField(),
                        const SizedBox(height: 16),
                        _buildBasicRateField(),
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

  Widget _buildItemNameField() {
    return TypeAheadField<SalesItem>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: itemNameController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !widget.item.isFromInquiry, // Disable if from inquiry
          decoration: InputDecoration(
            labelText: "Item Name",
            border: const OutlineInputBorder(),
            helperText:
                widget.item.isFromInquiry
                    ? "Item from inquiry cannot be changed"
                    : null,
          ),
          onChanged: (_) => _setDirty(),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Item Name is required" : null,
        );
      },
      suggestionsCallback:
          widget.item.isFromInquiry
              ? (pattern) async => []
              : (pattern) async {
                if (pattern.length < 4) return [];
                try {
                  return await widget.service.fetchSalesItemList(pattern);
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
      onSelected:
          widget.item.isFromInquiry
              ? null
              : (suggestion) async {
                setState(() {
                  selectedItem = suggestion;
                  itemNameController.text = suggestion.itemName;
                  _formDirty = true;
                });
              },
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
            discountPercentageController.clear();
            discountAmountController.clear();
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
        labelText: "Discount Amount (less than total)",
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
          final qty = double.tryParse(qtyController.text) ?? 0;
          final total = rate * qty;
          if (disc == null || disc >= total) {
            return "Discount must be less than total amount";
          }
        }
        return null;
      },
    );
  }

  // Widget _buildRateStructureField() {
  //   return DropdownButtonFormField<String>(
  //     value: selectedRateStructure,
  //     decoration: const InputDecoration(
  //       labelText: "Rate Structure",
  //       border: OutlineInputBorder(),
  //     ),
  //     isExpanded: true,
  //     selectedItemBuilder: (context) {
  //       return widget.rateStructures.map((rs) {
  //         return SizedBox(
  //           width: 200,
  //           child: Text(
  //             rs.rateStructFullName,
  //             overflow: TextOverflow.ellipsis,
  //             style: const TextStyle(color: Colors.black),
  //           ),
  //         );
  //       }).toList();
  //     },
  //     items:
  //         widget.rateStructures.map((rs) {
  //           return DropdownMenuItem<String>(
  //             value: rs.rateStructCode,
  //             child: Text(
  //               rs.rateStructFullName,
  //               style: const TextStyle(fontSize: 14),
  //             ),
  //           );
  //         }).toList(),
  //     onChanged: (val) async {
  //       setState(() {
  //         selectedRateStructure = val;
  //         _formDirty = true;
  //       });
  //       if (val != null) {
  //         rateStructureRows = await widget.service.fetchRateStructureDetails(
  //           val,
  //         );
  //       }
  //     },
  //     validator: (value) => value == null ? "Rate Structure is required" : null,
  //   );
  // }

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

          // Fetch new rate structure details
          try {
            final newRateStructureRows = await widget.service
                .fetchRateStructureDetails(val);
            setState(() {
              rateStructureRows = newRateStructureRows;
            });
            print(
              "Loaded new rate structure rows: $rateStructureRows",
            ); // Debug log
          } catch (e) {
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

  // Future<void> _updateItem() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final qty = double.parse(qtyController.text);
  //   final basicRate = double.parse(basicRateController.text);

  //   double discountAmount = 0;
  //   double? discountPercentage;

  //   if (discountType == "Percentage") {
  //     discountPercentage = double.parse(discountPercentageController.text);
  //     discountAmount = (basicRate * qty) * (discountPercentage / 100);
  //   } else if (discountType == "Value") {
  //     discountAmount = double.parse(discountAmountController.text);
  //     discountPercentage = (discountAmount / (basicRate * qty)) * 100;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final discountedValue = (basicRate * qty) - discountAmount;

  //     // Build RateStructureDetails for this item
  //     final rateStructureDetails = widget.service.buildRateStructureDetails(
  //       rateStructureRows,
  //       selectedItem?.itemCode ?? widget.item.itemCode,
  //       widget.item.lineNo,
  //     );

  //     // Calculate rate structure amount
  //     final rateStructureResponse = await widget.service.calculateRateStructure(
  //       discountedValue,
  //       selectedRateStructure!,
  //       rateStructureDetails,
  //       selectedItem?.itemCode ?? widget.item.itemCode,
  //     );

  //     if (rateStructureResponse['success'] == true) {
  //       final data = rateStructureResponse['data'];
  //       final totalTax = (data['totalExclusiveDomCurrAmount'] ?? 0.0) as double;
  //       final totalAmount =
  //           (data['totlaItemAmountRounded'] ?? discountedValue).toDouble();

  //       final updatedItem = QuotationItem(
  //         itemName: itemNameController.text,
  //         itemCode: selectedItem?.itemCode ?? widget.item.itemCode,
  //         qty: qty,
  //         basicRate: basicRate,
  //         uom: selectedItem?.salesUOM ?? widget.item.uom,
  //         discountType: discountType,
  //         discountPercentage:
  //             discountType == "Percentage" ? discountPercentage : null,
  //         discountAmount: discountAmount > 0 ? discountAmount : null,
  //         rateStructure: selectedRateStructure!,
  //         taxAmount: totalTax,
  //         totalAmount: totalAmount,
  //         rateStructureRows: rateStructureRows,
  //         lineNo: widget.item.lineNo,
  //         hsnCode: selectedItem?.hsnCode ?? widget.item.hsnCode,
  //         isFromInquiry: widget.item.isFromInquiry,
  //       );

  //       Navigator.pop(context, updatedItem);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Error: Rate structure calculation failed"),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error updating item: ${e.toString()}")),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }
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

      // Build RateStructureDetails for this item
      final rateStructureDetails = widget.service.buildRateStructureDetails(
        rateStructureRows,
        selectedItem?.itemCode ?? widget.item.itemCode,
        widget.item.lineNo,
      );

      print(
        "Original Rate Structure Details: $rateStructureDetails",
      ); // Debug log

      // Calculate rate structure amount
      final rateStructureResponse = await widget.service.calculateRateStructure(
        discountedValue,
        selectedRateStructure!,
        rateStructureDetails,
        selectedItem?.itemCode ?? widget.item.itemCode,
      );

      print("Rate Structure Response: $rateStructureResponse"); // Debug log

      // Check for success in the response
      if (rateStructureResponse['success'] == true) {
        final data = rateStructureResponse['data'];

        // Get the updated rate structure details with calculated amounts
        final updatedRateStructureDetails =
            data['FinalrateStructureData'] ?? data['rateStructureDetails'];

        print(
          "Updated Rate Structure Details: $updatedRateStructureDetails",
        ); // Debug log

        // Calculate total tax amount from updated rate structure details
        double totalTax = 0.0;
        if (updatedRateStructureDetails != null) {
          for (final rateDetail in updatedRateStructureDetails) {
            final rateAmount = (rateDetail['rateAmount'] ?? 0.0).toDouble();
            totalTax += rateAmount;
            print(
              "Rate Code: ${rateDetail['rateCode']}, Rate Amount: $rateAmount",
            ); // Debug log
          }
        }

        print("Total Tax Amount: $totalTax"); // Debug log

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
              "Error: ${rateStructureResponse['errorMessage'] ?? 'Rate structure calculation failed'}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error in _updateItem: $e"); // Debug log
      print("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating item: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
