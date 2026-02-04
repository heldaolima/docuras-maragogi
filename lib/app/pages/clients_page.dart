import 'package:docuras_maragogi/app/data/repository/client_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientRepository _repo = ClientRepository();

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
                  Text('Clientes', style: TextStyle(fontSize: 24)),
                  ElevatedButton.icon(
                    onPressed: () => context.pushNamed('clientes-adicionar'),
                    label: const Text('Novo Cliente'),
                    icon: Icon(Icons.add)
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: _repo.getAll(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(),);
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
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => context.pushNamed('clientes-editar', pathParameters: { 'id': client.id!.toString() }),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  );
                }
              ),
            ],
          ),
          ),
      ),
    );
  }
}