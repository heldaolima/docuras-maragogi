import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:flutter/material.dart';

class OrderItemData {
  int? id; // ID do item no banco (null se novo)
  int? boxId;
  int quantity = 1;
  String unitPrice; // Valor em centavos
  String totalPrice; // Valor em centavos

  bool get isNew => id == null;

  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final TextEditingController totalPriceController;

  OrderItemData({
    this.id,
    this.boxId,
    this.quantity = 0,
    this.unitPrice = '0',
    this.totalPrice = '0',
  }) : quantityController = TextEditingController(text: quantity.toString()),
       unitPriceController = TextEditingController(
         text: unitPrice,
       ),
       totalPriceController = TextEditingController(
         text: totalPrice,
       );

  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    totalPriceController.dispose();
  }

  static void validateItems(BuildContext context, List<OrderItemData> items) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.boxId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Selecione uma caixa')),
        );
        return;
      }
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Quantidade deve ser maior que 0')),
        );
        return;
      }

      final unitPrice = parseInputToBrazilianCurrency(item.unitPrice);
      if (unitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Preço unitário deve ser maior que 0')),
        );
        return;
      }
      final totalPrice = parseInputToBrazilianCurrency(item.totalPrice);
      if (totalPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Total deve ser maior que 0')),
        );
        return;
      }
    }

  }
}