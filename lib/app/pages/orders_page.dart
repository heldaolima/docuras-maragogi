import 'dart:io';

import 'package:docuras_maragogi/app/data/repository/order_repository.dart';
import 'package:docuras_maragogi/app/models/order.dart';
import 'package:docuras_maragogi/app/services/pdf_service.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _repo = OrderRepository();
  final _pdfService = PdfService();

  bool _isLoading = false;

  Future<void> _deleteOrder(int orderId) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _repo.delete(orderId);

      if (!mounted) return;
    } catch (e, s) {
      debugPrint('Erro ao excluir o pedido: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir pedido'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generatePdf(OrderModel order) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });
    debugPrint(order.toMap().toString());
    final pdf = await _pdfService.generateOrderDocument(order);
    if (pdf == null) {
      debugPrint('pdf veio null');
        return;
      }

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar PDF do Pedido',
        fileName:
            'pedido_${order.client?.name.toLowerCase() ?? ''}_${order.numberPerClient}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (path == null) {
        debugPrint('path veio null');
        return;
      }

      final bytes = await pdf.save();
      final file = File(path);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF salvo com sucesso!')));
    } catch (e, s) {
      debugPrint('Erro ao criar o pdf: ${e.toString()}');
      debugPrintStack(stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar PDF'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            future: _repo.getAllWithClientAndProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao buscar pedidos: ${snapshot.error!.toString()}",
                  ),
                );
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
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.pushNamed(
                                          'pedidos-editar',
                                          pathParameters: {
                                            'id': order.id!.toString(),
                                          },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.picture_as_pdf),
                                  tooltip: 'Gerar PDF do pedido',
                                  onPressed: _isLoading
                                      ? null
                                      : () => _generatePdf(order),
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
