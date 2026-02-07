import 'package:docuras_maragogi/app/data/repository/product_box_repository.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoxesPage extends StatefulWidget {
  const BoxesPage({super.key});

  @override
  State<BoxesPage> createState() => _BoxesPageState();
}

class _BoxesPageState extends State<BoxesPage> {
  final _repo = ProductBoxRepository();
  bool _isLoading = false;

  Future<void> deleteBox(int boxId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repo.delete(boxId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caixa de produto removida')),
      );
    } catch (e, s) {
      debugPrint('Erro ao excluir o caixa: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir caixa'),
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
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 100, vertical: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Caixas de Produtos', style: TextStyle(fontSize: 24)),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('caixas-adicionar');
                    },
                    label: const Text('Adicionar Caixa'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: _repo.getAllWithProduct(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint(snapshot.error!.toString());
                    return Center(child: Text(snapshot.error!.toString()));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return DataTable(
                    showBottomBorder: true,
                    sortAscending: true,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(label: Expanded(child: const Text('Produto'))),
                      DataColumn(label: Expanded(child: const Text('Preço'))),
                      DataColumn(
                        label: Expanded(child: const Text('Unidades na Caixa')),
                      ),
                      DataColumn(label: Expanded(child: const Text('Ações'))),
                    ],
                    rows: snapshot.data!
                        .map(
                          (box) => DataRow(
                            cells: [
                              DataCell(Text(box.product?.name ?? '-')),
                              DataCell(
                                Text(
                                  parseIntToBrazilianCurrentFormat(box.price),
                                ),
                              ),
                              DataCell(Text('${box.unitsPerBox}')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => deleteBox(box.id!),
                                      icon: Icon(Icons.delete),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.pushNamed(
                                          'caixas-editar',
                                          pathParameters: {
                                            'id': box.id!.toString(),
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.edit),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
