import 'package:docuras_maragogi/app/data/repository/client_repository.dart';
import 'package:docuras_maragogi/app/data/repository/order_repository.dart';
import 'package:docuras_maragogi/app/data/repository/product_box_repository.dart';
import 'package:docuras_maragogi/app/models/client.dart';
import 'package:docuras_maragogi/app/models/order.dart';
import 'package:docuras_maragogi/app/models/order_product.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';
import 'package:docuras_maragogi/app/types/order_item_data.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/widgets/order_items_table.dart';
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
    if (widget.orderId != null) {
      _loadOrderData();
    }
  }

  Future<void> _loadOrderData() async {
    try {
      final order = await _repo.getByIdWithClientAndProducts(widget.orderId!);
      if (order != null && mounted) {
        setState(() {
          _order = order;
          debugPrint('order Products: ${_order!.orderProducts!.map((o) => o.toMap().toString())}');
          // Carregar itens existentes
          if (order.orderProducts != null) {
            addedItems = order.orderProducts!
                .map((op) => OrderItemData(
                  id: op.id,
                  boxId: op.productBoxId,
                  quantity: op.quantity,
                  unitPrice: parseIntToBrazilianCurrentFormat(op.price),
                  totalPrice: parseIntToBrazilianCurrentFormat(op.price * op.quantity),
                ))
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar pedido: $e');
    }
  }

  @override
  void dispose() {
    for (var item in addedItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _handleAddItem() {
    setState(() {
      addedItems.add(OrderItemData());
    });
  }

  int get _totalItems {
    return addedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _totalPrice {
    return addedItems.fold(
      0,
      (sum, item) => sum + parseInputToBrazilianCurrency(item.totalPrice),
    );
  }

  void _onItemsChange() {
    setState(() {});
  }

  Future<List<Object>> _loadBoxesAndClients() async {
    final result = await Future.wait([_clientRepo.getAll(), _boxRepo.getAllWithProduct()]);
    return result;
  }

  Future<void> _fetchOrderNumber(int? clientId) async {
    if (clientId == null) {
      return;
    }

    try {
      final lastOrderByClient = await _repo.getLastByClient(clientId);
      if (lastOrderByClient == null) {
        return;
      }

      debugPrint(lastOrderByClient.toMap().toString());
      _formKey.currentState?.patchValue({
        'number_per_client': (lastOrderByClient.numberPerClient + 1).toString(),
      });

    } catch (e, s) {
      debugPrint('Error when searching the last order by the client $clientId: $e');
      debugPrintStack(stackTrace: s);
    }
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
          initialValue: _order == null
              ? {}
              : {
                  ..._order!.toMap(),
                  'number_per_client': _order!.numberPerClient.toString(),
                  'order_date': _order!.orderDate,
                },
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
                onChanged: _fetchOrderNumber,
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
                format: DateFormat('dd/MM/yyyy'),
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
                OrderItemsTable(
                  items: addedItems,
                  boxes: boxes,
                  onItemsChange: _onItemsChange,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Total de itens: $_totalItems',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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

    OrderItemData.validateItems(context, addedItems);

    _formKey.currentState!.save();

    try {
      setState(() => _isLoading = true);
      final formData = _formKey.currentState!.value;

      if (widget.orderId == null) {
        await _createOrder(formData);
      } else {
        await _updateOrder(formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido salvo com sucesso!')),
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        context.pop();
      }
    } catch (e, s) {
      debugPrint('Erro ao salvar pedido: $e');
      debugPrintStack(stackTrace: s);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createOrder(Map<String, dynamic> formData) async {
    // Converter addedItems para OrderProductModel
    final orderProducts = addedItems
        .map(
          (item) => OrderProductModel(
            productBoxId: item.boxId!,
            quantity: item.quantity,
            price: parseInputToBrazilianCurrency(item.unitPrice),
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
  }

  Future<void> _updateOrder(Map<String, dynamic> formData) async {
    final order = OrderModel.fromMap({
      ...formData, 
      'id': widget.orderId,
      'number_per_client': int.parse(formData['number_per_client']),
      'order_date': (formData['order_date'] as DateTime).millisecondsSinceEpoch,
    });

    final orderProducts = addedItems
        .map(
          (item) => OrderProductModel(
            productBoxId: item.boxId!,
            quantity: item.quantity,
            price: parseInputToBrazilianCurrency(item.unitPrice),
          ),
        )
        .toList();
    await _repo.update(order, orderProducts);
  }
}