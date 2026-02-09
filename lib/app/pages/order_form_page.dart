import 'package:docuras_maragogi/app/data/repository/client_repository.dart';
import 'package:docuras_maragogi/app/data/repository/order_repository.dart';
import 'package:docuras_maragogi/app/data/repository/product_box_repository.dart';
import 'package:docuras_maragogi/app/models/client.dart';
import 'package:docuras_maragogi/app/models/order.dart';
import 'package:docuras_maragogi/app/models/order_product.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/utils/formatters.dart';
import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:docuras_maragogi/app/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrderFormPage extends StatelessWidget {
  final int? orderId;
  const OrderFormPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final prefix = orderId == null ? 'Criar' : 'Editar';
    return PageLayout(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$prefix pedido', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20,),
        OrderForm(orderId: orderId),
      ],
    ));
  }
}

class OrderItemData {
  int? boxId;
  int quantity = 1;
  int unitPrice = 0; // Valor em centavos
  int totalPrice = 0; // Valor em centavos

  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final TextEditingController totalPriceController;

  OrderItemData({
    this.boxId,
    this.quantity = 0,
    this.unitPrice = 0,
    this.totalPrice = 0,
  }) : quantityController = TextEditingController(text: quantity.toString()),
       unitPriceController = TextEditingController(
         text: parseIntToBrazilianCurrentFormat(unitPrice),
       ),
       totalPriceController = TextEditingController(
         text: parseIntToBrazilianCurrentFormat(totalPrice),
       );
}

class OrderForm extends StatefulWidget {
  final int? orderId;
  const OrderForm({super.key, this.orderId});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _repo = OrderRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  final _boxRepo = ProductBoxRepository();
  final _clientRepo = ClientRepository();
  late Future<List<Object>> _boxesAndClientsFuture;

  bool _isLoading = false;
  OrderModel? _order;
  List<OrderItemData> addedItems = [];

  @override
  void initState() {
    super.initState();
    _boxesAndClientsFuture = _loadBoxesAndClients();
  }

  void _handleAddItem() {
    setState(() {
      addedItems.add(OrderItemData());
    });
  }

  void _handleRemoveItem(int index) {
    final item = addedItems[index];

    item.quantityController.dispose();
    item.unitPriceController.dispose();
    item.totalPriceController.dispose();

    setState(() {
      addedItems.removeAt(index);
    });
  }

  void _handleBoxChange(ProductBoxModel? box, int index) {
    if (box == null) return;

    setState(() {
      addedItems[index].boxId = box.id;
      addedItems[index].unitPrice = box.price;
      addedItems[index].totalPrice = box.price * addedItems[index].quantity;

      addedItems[index].unitPriceController.text =
          parseIntToBrazilianCurrentFormat(addedItems[index].unitPrice);
      addedItems[index].totalPriceController.text =
          parseIntToBrazilianCurrentFormat(addedItems[index].totalPrice);
    });
  }

  void _handleQuantityChange(int index, String strQuantity) {
    final quantity = int.tryParse(strQuantity) ?? 0;
    setState(() {
      addedItems[index].quantity = quantity;
      addedItems[index].totalPrice = addedItems[index].unitPrice * quantity;

      addedItems[index].totalPriceController.text =
          parseIntToBrazilianCurrentFormat(addedItems[index].totalPrice);
    });
  }

  void _handleUnitPriceChange(int index, String strUnitPrice) {
    final unitPrice = parseInputToBrazilianCurrency(strUnitPrice);
    setState(() {
      addedItems[index].unitPrice = unitPrice;
      addedItems[index].totalPrice = unitPrice * addedItems[index].quantity;

      addedItems[index].totalPriceController.text = parseIntToBrazilianCurrentFormat(
        addedItems[index].totalPrice
      );
    });
  }

  void _handleTotalPriceChange(int index, String strTotalPrice) {
    final totalPrice = parseInputToBrazilianCurrency(strTotalPrice);
    setState(() {
      addedItems[index].totalPrice = totalPrice;
    });
  }

  int get _totalItems {
    return addedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _totalPrice {
    return addedItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<List<Object>> _loadBoxesAndClients() async {
    final result = await Future.wait([_clientRepo.getAll(), _boxRepo.getAllWithProduct()]);
    return result;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _boxesAndClientsFuture,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (asyncSnapshot.hasError) {
          return Center(child: Text('Ocorreu um erro: ${asyncSnapshot.error}'));
        }

        final clients = asyncSnapshot.data?[0] as List<ClientModel>;
        final boxes = asyncSnapshot.data?[1] as List<ProductBoxModel>;

        return FormBuilder(
          key: _formKey,
          initialValue: _order == null ? {} : _order!.toMap(),
          child: Column(
            children: [
              FormBuilderDropdown<int>(
                name: 'client_id', 
                decoration: const InputDecoration(labelText: 'Cliente'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Cliente é obrigatório',
                  ),
                ]),
                items: clients
                    .map(
                      (client) => DropdownMenuItem(
                        value: client.id,
                        child: Text(client.name),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'order_date',
                inputType: InputType.date,
                format: DateFormat('dd-MM-yyyy'),
                decoration: const InputDecoration(labelText: 'Data do pedido'),
                initialDate: DateTime.now(),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'number_per_client',
                decoration: const InputDecoration(
                  labelText: 'Número do Pedido',
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'O campo é obrigatório',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _handleAddItem,
                    label: const Text('Adicionar item'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              if (addedItems.isNotEmpty) ...[
                const SizedBox(height: 24),
                SizedBox(
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
                    rows: List.generate(
                      addedItems.length,
                      (index) => _buildOrderItemRow(index, boxes),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total de itens: $_totalItems',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // const SizedBox(width: 30,),
                    Text(
                      'Total: ${parseIntToBrazilianCurrentFormat(_totalPrice)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SaveButton(isLoading: _isLoading, onPressed: _saveOrder),
                ],
              ),
            ],
          ),
        );
      }
    );
  }


  DataRow _buildOrderItemRow(int index, List<ProductBoxModel> boxes) {
    final item = addedItems[index];

    return DataRow(
      cells: [
        DataCell(
          DropdownButton<int>(
            hint: const Text('Selecione'),
            value: item.boxId,
            items: boxes
                .map(
                  (box) => DropdownMenuItem(
                    value: box.id,
                    child: Text(box.product?.name ?? '-'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final box = boxes.firstWhere((box) => box.id == value);
              _handleBoxChange(box, index);
            }
          ),
        ),
        DataCell(
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
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

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha os campos obrigatórios')),
      );
      return;
    }

    if (addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item')),
      );
      return;
    }

    // Validar itens
    for (int i = 0; i < addedItems.length; i++) {
      final item = addedItems[i];
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
      if (item.unitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Preço unitário deve ser maior que 0')),
        );
        return;
      }
      if (item.totalPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${i + 1}: Total deve ser maior que 0')),
        );
        return;
      }
    }

    _formKey.currentState!.save();

    try {
      setState(() => _isLoading = true);
      final formData = _formKey.currentState!.value;

      // Converter addedItems para OrderProductModel
      final orderProducts = addedItems
          .map(
            (item) => OrderProductModel(
              productBoxId: item.boxId!,
              quantity: item.quantity,
              price: item.unitPrice,
            ),
          )
          .toList();

      await _repo.createOrder(
        OrderModel.fromMap({
          ...formData,
          'number_per_client': int.parse(formData['number_per_client']),
          'order_date':
              (formData['order_date'] as DateTime).millisecondsSinceEpoch,
        }),
        orderProducts,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido salvo com sucesso!')),
      );

      await Future.delayed(const Duration(microseconds: 300));

      context.pop();
    } catch (e, s) {
      debugPrint('Erro ao criar pedido: $e');
      debugPrintStack(stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}