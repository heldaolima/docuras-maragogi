import 'package:docuras_maragogi/app/widgets/page_layout.dart';
import 'package:flutter/material.dart';
import 'package:docuras_maragogi/app/data/repository/product_repository.dart';
import 'package:docuras_maragogi/app/models/product.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:docuras_maragogi/app/utils/formatters.dart';
import 'package:docuras_maragogi/app/widgets/save_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

class ProductFormPage extends StatelessWidget {
  final int? productId;
  const ProductFormPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    final prefix = productId == null ? 'Adicionar' : 'Editar';
    return PageLayout(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$prefix produto', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ProductForm(productId: productId),
        ],
      ),
    );
  }
}

class ProductForm extends StatefulWidget {
  final int? productId;
  const ProductForm({super.key, this.productId});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _repo = ProductRepository();
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  ProductModel? _product;

  @override
  void initState() {
    super.initState();

    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _product = await _repo.findById(widget.productId!);
      if (!mounted) return;

      _formKey.currentState?.patchValue({
        ..._product!.toMap(),
        'unit_wholesale_price': parseIntToBrazilianCurrentFormat(
          _product!.unitWholesalePrice,
        ),
        'unit_retail_price': parseIntToBrazilianCurrentFormat(
          _product!.unitRetailPrice,
        ),
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
      final product = ProductModel.fromMap({
        ...values,
        'unit_retail_price': parseInputToBrazilianCurrency(values['unit_retail_price']),
        'unit_wholesale_price': parseInputToBrazilianCurrency(values['unit_wholesale_price']),
        'id': widget.productId,
      });

      if (widget.productId != null) {
        await _repo.update(product);
      } else {
        await _repo.create(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produto salvo')));

      await Future.delayed(const Duration(microseconds: 300));
      if (!mounted) return;

      context.pop();
    } catch (e, s) {
      debugPrint('Erro ao salvar o produto: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar produto'),
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
            decoration: const InputDecoration(labelText: 'Nome do produto'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'O campo Nome do produto é obrigatório',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'unit_retail_price',
            decoration: const InputDecoration(
              labelText: 'Preço de varejo (R\$)',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'O Campo Preço de varejo é obrigatório'
              )
            ]),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyPtBrInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'unit_wholesale_price',
            decoration: const InputDecoration(
              labelText: 'Preço de atacado (R\$)',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'O Campo Preço de varejo é obrigatório',
              ),
            ]),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyPtBrInputFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SaveButton(isLoading: _isLoading, onPressed: _onSubmit),
            ],
          ),
        ]
      )
    );
  }
}