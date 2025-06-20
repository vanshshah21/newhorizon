import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';

class AddItemPage extends StatefulWidget {
  final ProformaInvoiceService service;
  final List<RateStructure> rateStructures;

  const AddItemPage({
    super.key,
    required this.service,
    required this.rateStructures,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: "1");
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
        itemNameController.text.isNotEmpty ||
        qtyController.text != "1" ||
        basicRateController.text.isNotEmpty ||
        discountPercentageController.text.isNotEmpty ||
        discountAmountController.text.isNotEmpty;
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
        appBar: AppBar(title: const Text("Add Item")),
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
      onSelected: (suggestion) async {
        setState(() {
          selectedItem = suggestion;
          itemNameController.text = suggestion.itemName;
          basicRateController.text = "0";
          qtyController.text = "1";
          discountPercentageController.clear();
          discountAmountController.clear();
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
        setState(() {
          selectedRateStructure = val;
          _formDirty = true;
        });
        if (val != null) {
          rateStructureRows = await widget.service.fetchRateStructureDetails(
            val,
          );
        }
      },
      validator: (value) => value == null ? "Rate Structure is required" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addItem,
        child:
            _isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Add"),
      ),
    );
  }

  Future<void> _addItem() async {
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
        selectedItem?.itemCode ?? "TEMP",
        1, // itmModelRefNo, you can use 1 or the correct line number
      );

      // Calculate rate structure amount
      final rateStructureResponse = await widget.service.calculateRateStructure(
        discountedValue,
        selectedRateStructure!,
        rateStructureDetails,
        selectedItem?.itemCode ?? "TEMP",
      );

      if (rateStructureResponse['success'] == true) {
        final data = rateStructureResponse['data'];
        final totalTax = (data['totalExclusiveDomCurrAmount'] ?? 0.0) as double;
        final totalAmount =
            (data['totlaItemAmountRounded'] ?? discountedValue).toDouble();

        final item = ProformaItem(
          itemName: itemNameController.text,
          itemCode: selectedItem?.itemCode ?? "TEMP",
          qty: qty,
          basicRate: basicRate,
          uom: selectedItem?.salesUOM ?? "NOS",
          discountType: discountType,
          discountPercentage:
              discountType == "Percentage" ? discountPercentage : null,
          discountAmount: discountAmount > 0 ? discountAmount : null,
          rateStructure: selectedRateStructure!,
          taxAmount: totalTax,
          totalAmount: totalAmount,
          rateStructureRows: rateStructureRows,
          lineNo: 0, // will be set in main form
          hsnAccCode: selectedItem?.hsnCode,
        );

        Navigator.pop(context, item);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: Calculation failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error calculating item: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
