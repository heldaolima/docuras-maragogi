import 'package:docuras_maragogi/app/models/product_box.dart';
import 'package:docuras_maragogi/app/types/order_item_data.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderItemsTable extends StatefulWidget {
  final List<OrderItemData> items;
  final List<ProductBoxModel> boxes;
  final void Function() onItemsChange;

  const OrderItemsTable({
    super.key,
    required this.items,
    required this.boxes,
    required this.onItemsChange,
  });

  @override
  State<OrderItemsTable> createState() => _OrderItemsTableState();
}

class _OrderItemsTableState extends State<OrderItemsTable> {
  void _handleRemoveItem(int index) {
    final item = widget.items[index];
    item.dispose();

    setState(() {
      widget.items.removeAt(index);
      widget.onItemsChange();
    });
  }

  void _handleBoxChange(ProductBoxModel? box, int index) {
    if (box == null) return;

    setState(() {
      widget.items[index].boxId = box.id;
      widget.items[index].unitPrice = parseIntToBrazilianCurrentFormat(box.price);
      widget.items[index].totalPrice = parseIntToBrazilianCurrentFormat(box.price * widget.items[index].quantity);

      widget.items[index].unitPriceController.text =widget.items[index].unitPrice;
      widget.items[index].totalPriceController.text = widget.items[index].totalPrice;

      widget.onItemsChange();
    });
  }

  void _handleQuantityChange(int index, String strQuantity) {
    final quantity = int.tryParse(strQuantity) ?? 0;
    setState(() {
      widget.items[index].quantity = quantity;
      widget.items[index].totalPrice = parseIntToBrazilianCurrentFormat(
        parseInputToBrazilianCurrency(widget.items[index].unitPrice) * quantity,
      );

      widget.items[index].totalPriceController.text =
          widget.items[index].totalPrice;

      widget.onItemsChange();
    });
  }

  void _handleUnitPriceChange(int index, String strUnitPrice) {
    final unitPrice = parseInputToBrazilianCurrency(strUnitPrice);
    setState(() {
      widget.items[index].unitPrice = strUnitPrice;
      widget.items[index].totalPrice = parseIntToBrazilianCurrentFormat(unitPrice * widget.items[index].quantity);

      widget.items[index].totalPriceController.text =
          (widget.items[index].totalPrice);

      widget.onItemsChange();
    });
  }

  void _handleTotalPriceChange(int index, String strTotalPrice) {
    setState(() {
      widget.items[index].totalPrice = strTotalPrice;
    });

    widget.onItemsChange();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        showBottomBorder: true,
        columns: [
          DataColumn(label: const Text('Caixa')),
          DataColumn(label: const Text('Quantidade')),
          DataColumn(label: const Text('Preço da Caixa')),
          DataColumn(label: const Text('Total (R\$)')),
          DataColumn(label: const Text('Ações')),
        ],
        rows: List.generate(widget.items.length, (index) => _buildOrderItemRow(index)),
      ),
    );
  }

  DataRow _buildOrderItemRow(int index) {
    final item = widget.items[index];

    return DataRow(
      cells: [
        DataCell(
          DropdownButton<int>(
            hint: const Text('Selecione'),
            value: item.boxId,
            items: widget.boxes
                .map(
                  (box) => DropdownMenuItem(
                    value: box.id,
                    child: Text('${box.product?.name} [${box.unitsPerBox} un.]'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final box = widget.boxes.firstWhere((box) => box.id == value);
              _handleBoxChange(box, index);
            },
          ),
        ),
        DataCell(
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _handleQuantityChange(index, value),
            controller: item.quantityController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        DataCell(
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyPtBrInputFormatter(),
            ],
            onChanged: (value) => _handleUnitPriceChange(index, value),
            controller: item.unitPriceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        DataCell(
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyPtBrInputFormatter(),
            ],
            onChanged: (value) => _handleTotalPriceChange(index, value),
            controller: item.totalPriceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _handleRemoveItem(index),
          ),
        ),
      ],
    );
  }
}
