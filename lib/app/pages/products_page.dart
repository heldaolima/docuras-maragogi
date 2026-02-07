import 'package:docuras_maragogi/app/data/repository/product_repository.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _repo = ProductRepository();
  bool _isLoading = false;

  Future<void> _deleteProduct(int productId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repo.delete(productId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produto removido')));
    } catch (e, s) {
      debugPrint('Erro ao excluir o produto: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir produto'),
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
                  Text('Produtos', style: TextStyle(fontSize: 24)),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('produtos-adicionar');
                    },
                    label: const Text('Adicionar Produto'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: _repo.getAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return DataTable(
                    showBottomBorder: true,
                    sortAscending: true,
                    sortColumnIndex: 0,
                    columns: [
                      DataColumn(label: Expanded(child: const Text('Nome'))),
                      DataColumn(
                        label: Expanded(
                          child: const Text('Preço de Varejo (unidade)'),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: const Text('Preço de Atacado (unidade)'),
                        ),
                      ),
                      DataColumn(label: Expanded(child: const Text('Ações'))),
                    ],
                    rows: snapshot.data!
                        .map(
                          (product) => DataRow(
                            cells: [
                              DataCell(Text(product.name)),
                              DataCell(
                                Text(parseIntToBrazilianCurrentFormat(product.unitRetailPrice)),
                              ),
                              DataCell(
                                Text(parseIntToBrazilianCurrentFormat(product.unitWholesalePrice)),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _deleteProduct(product.id!),
                                      icon: Icon(Icons.delete),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.pushNamed(
                                          'produtos-editar',
                                          pathParameters: {
                                            'id': product.id!.toString(),
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
