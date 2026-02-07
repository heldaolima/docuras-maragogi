import 'package:docuras_maragogi/app/data/repository/product_box_repository.dart';
import 'package:docuras_maragogi/app/data/repository/product_repository.dart';
import 'package:docuras_maragogi/app/models/product_box.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/utils/formatters.dart';
import 'package:docuras_maragogi/app/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class ProductBoxForm extends StatefulWidget {
  final int? boxId;
  const ProductBoxForm({super.key, this.boxId});

  @override
  State<ProductBoxForm> createState() => _ProductBoxFormState();
}

class _ProductBoxFormState extends State<ProductBoxForm> {
  final _repo = ProductBoxRepository();
  final _productRepo = ProductRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  ProductBoxModel? _box;

  @override
  void initState() {
    super.initState();

    if (widget.boxId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _box = await _repo.findById(widget.boxId!);
      if (!mounted) return;

      _formKey.currentState?.patchValue({
        ..._box!.toMap(),
        'price': parseIntToBrazilianCurrentFormat(_box!.price),
        'units_per_box': _box!.unitsPerBox.toString(),
      });
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
      debugPrint(values.toString());
      final product = ProductBoxModel.fromMap({
        ...values,
        'price': parseInputToBrazilianCurrency(values['price']),
        'units_per_box': int.tryParse(values['units_per_box']),
        'id': widget.boxId,
      });

      if (widget.boxId != null) {
        await _repo.update(product);
      } else {
        await _repo.create(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Caixa de produto salva')));

      await Future.delayed(const Duration(microseconds: 300));
      if (!mounted) return;

      context.pop();
    } catch (e, s) {
      debugPrint('Erro ao salvar caixa: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar caixa de produto'),
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
    return FutureBuilder(
      future: _productRepo.getAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final products = snapshot.data!;

        return FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderDropdown<int>(
                name: 'product_id',
                decoration: const InputDecoration(labelText: 'Produto'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo produto é obrigatório',
                  ),
                ]),
                items: products
                    .map(
                      (product) => DropdownMenuItem(
                        value: product.id,
                        child: Text(product.name),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'price',
                decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O Campo Preço é obrigatório',
                  ),
                ]),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyPtBrInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'units_per_box',
                decoration: const InputDecoration(
                  labelText: 'Número de produtos em uma caixa',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O Campo é obrigatório',
                  ),
                ]),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      },
    );
  }
}
