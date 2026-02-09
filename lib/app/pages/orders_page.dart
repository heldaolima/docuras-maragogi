import 'package:docuras_maragogi/app/data/repository/order_repository.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _repo = OrderRepository();

  bool _isLoading = false;

  Future<void> _deleteOrder(int orderId) async {

  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pedidos', style: TextStyle(fontSize: 24)),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed('pedidos-adicionar'),
                label: const Text('Novo Pedido'),
                icon: Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder(
            future: _repo.getAllWithClient(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return DataTable(
                showBottomBorder: true,
                sortAscending: true,
                columns: [
                  DataColumn(label: Expanded(child: const Text('Cliente'))),
                  DataColumn(label: Expanded(child: const Text('Número'))),
                  DataColumn(label: Expanded(child: const Text('Data'))),
                  DataColumn(label: Expanded(child: const Text('Ações'))),
                ],
                rows: snapshot.data!
                    .map(
                      (order) => DataRow(
                        cells: [
                          DataCell(Text(order.client?.name ?? '-')),
                          DataCell(Text(order.numberPerClient.toString())),
                          DataCell(Text(datetimeToBrString(order.orderDate))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _deleteOrder(order.id!),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => context.pushNamed(
                                    'pedidos-editar',
                                    pathParameters: {
                                      'id': order.id!.toString(),
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
