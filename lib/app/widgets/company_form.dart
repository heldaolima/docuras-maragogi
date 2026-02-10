import 'dart:io';

import 'package:docuras_maragogi/app/data/repository/company_repository.dart';
import 'package:docuras_maragogi/app/data/repository/file_repository.dart';
import 'package:docuras_maragogi/app/models/company.dart';
import 'package:docuras_maragogi/app/models/file.dart' as app_file;
import 'package:docuras_maragogi/app/utils/formatters.dart';
import 'package:docuras_maragogi/app/widgets/save_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CompanyForm extends StatefulWidget {
  const CompanyForm({super.key});

  @override
  State<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends State<CompanyForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Future<void> _companyFuture;
  final _repo = CompanyRepository();
  bool _isLoading = false;

  File? _pickedImage; // user's chosen image (not yet saved to app dir)
  app_file.FileModel? _existingLogo; // existing logo stored in app files dir

  @override
  void initState() {
    super.initState();
    _companyFuture = _loadCompany();
  }

  Future<void> _loadCompany() async {
    final company = await _repo.getCompany();
    final logo = await _repo.getCompanyLogoFile();

    setState(() {
      _existingLogo = logo;
    });

    // Patch form values after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (company != null) {
        _formKey.currentState?.patchValue(company.toMap());
      }
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null &&
        result.files.isNotEmpty &&
        result.files.first.path != null) {
      setState(() {
        _pickedImage = File(result.files.first.path!);
      });
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

      final company = CompanyModel.fromMap(values);
      app_file.FileModel? toSaveLogo;
      if (_pickedImage != null) {
        toSaveLogo = await FileRepository.saveFileToAppDir(_pickedImage!);
      }

      await _repo.saveCompany(company, toSaveLogo);

      // Update state to reflect saved logo
      if (toSaveLogo != null) {
        // We don't have the DB id here, but CompanyRepository will insert it.
        // Reload the company logo from DB so we have correct id/path.
        final logo = await _repo.getCompanyLogoFile();
        setState(() {
          _existingLogo = logo;
          _pickedImage = null;
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informações salva')));
    } catch (e, s) {
      debugPrint('Erro ao salvar empresa: $e');
      debugPrintStack(stackTrace: s);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar empresa'),
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

  Widget _buildImagePreview() {
    final previewFile =
        _pickedImage ??
        (_existingLogo != null ? File(_existingLogo!.path) : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo da marca'),
        const SizedBox(height: 8),
        Container(
          width: 320,
          height: 160,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: previewFile != null
              ? Image.file(previewFile, fit: BoxFit.contain)
              : const Center(child: Text('Nenhuma imagem')),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Escolher'),
            ),
            const SizedBox(width: 8),
            if (_pickedImage != null)
              ElevatedButton.icon(
                onPressed: () => setState(() => _pickedImage = null),
                icon: const Icon(Icons.clear),
                label: const Text('Cancelar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _companyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));
        }

        return FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'company_name',
                decoration: const InputDecoration(labelText: 'Nome da empresa'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Nome da empresa é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'brand_name',
                decoration: const InputDecoration(labelText: 'Nome da marca'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Nome da marca é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'cnpj',
                decoration: const InputDecoration(labelText: 'CNPJ da empresa'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo CNPJ da empresa é obrigatório',
                  ),
                ]),
                inputFormatters: [cnpjFormatter],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'address',
                decoration: const InputDecoration(
                  labelText: 'Endereço da empresa',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo endereço da empresa é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'phone_number_1',
                decoration: const InputDecoration(labelText: 'Telefone (1)'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Telefone (1) é obrigatório',
                  ),
                ]),
                inputFormatters: [phoneFormatter],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'phone_number_2',
                decoration: const InputDecoration(labelText: 'Telefone (2)'),
                inputFormatters: [phoneFormatter],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'pix_key',
                decoration: const InputDecoration(labelText: 'Chave Pix'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Chave Pix é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'deposit_agency',
                decoration: const InputDecoration(
                  labelText: 'Agência para depósito',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Agência para depósito é obrigatório',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'deposit_account',
                decoration: const InputDecoration(
                  labelText: 'Conta para depósito',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'O campo Conta para depósito é obrigatório',
                  ),
                ]),
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
