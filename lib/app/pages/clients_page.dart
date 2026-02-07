import 'package:docuras_maragogi/app/data/repository/client_repository.dart';
import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientRepository _repo = ClientRepository();
  bool _isLoading = false;

  Future<void> _deleteClient(int clientId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _repo.delete(clientId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente removido')));
    } catch (e, s) {
      debugPrint('Erro ao excluir o cliente: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir cliente'),
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
              Text('Clientes', style: TextStyle(fontSize: 24)),
              ElevatedButton.icon(
                onPressed: () => context.pushNamed('clientes-adicionar'),
                label: const Text('Adicionar Cliente'),
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
                  DataColumn(label: Expanded(child: const Text('Contato'))),
                  DataColumn(label: Expanded(child: const Text('Ações'))),
                ],
                rows: snapshot.data!
                    .map(
                      (client) => DataRow(
                        cells: [
                          DataCell(Text(client.name)),
                          DataCell(Text(client.contact ?? '-')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _deleteClient(client.id!),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => context.pushNamed(
                                    'clientes-editar',
                                    pathParameters: {
                                      'id': client.id!.toString(),
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
          ),
        ],
      ),
    );
  }
}