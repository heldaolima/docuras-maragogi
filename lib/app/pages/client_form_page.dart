import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:docuras_maragogi/app/data/repository/client_repository.dart';
import 'package:docuras_maragogi/app/models/client.dart';
import 'package:docuras_maragogi/app/widgets/save_button.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class ClientFormPage extends StatelessWidget {
  final int? clientId;
  const ClientFormPage({super.key, this.clientId});

  @override
  Widget build(BuildContext context) {
  final prefix = clientId == null ? 'Adicionar' : 'Editar';

    return PageLayout(child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('$prefix cliente', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ClientForm(clientId: clientId),
      ],
    ));
  }
}

class ClientForm extends StatefulWidget {
  final int? clientId;
  const ClientForm({super.key, this.clientId});

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _repo = ClientRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  ClientModel? _client;

  @override
  void initState() {
    super.initState();

    if (widget.clientId != null) {
      _loadClient();
    }
  }

  Future<void> _loadClient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _client = await _repo.findById(widget.clientId!);

      if (!mounted) return;
      _formKey.currentState?.patchValue(_client!.toMap());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final values = _formKey.currentState!.value;
      final client = ClientModel.fromMap({
        ...values,
        'id': widget.clientId,
      });

      if (widget.clientId != null) {
        await _repo.update(client);
      } else {
        await _repo.create(client);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente salvo')));

      await Future.delayed(const Duration(microseconds: 300));
      if (!mounted) return;

      context.pop();
    } catch (e, s) {
      debugPrint('Erro ao salvar o cliente: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar cliente'),
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
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Nome do cliente'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'O campo Nome do cliente é obrigatório',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'contact',
            decoration: const InputDecoration(
              labelText: 'Contato do cliente (email, telefone etc.)',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SaveButton(isLoading: _isLoading, onPressed: _onSubmit),
            ],
          ),
        ],
      ),
    );
  }
}