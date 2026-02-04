import 'package:docuras_maragogi/app/widgets/company_form.dart';
import 'package:flutter/material.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 200, vertical: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dados da Empresa', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              CompanyForm(),
            ],
          ),
        ),
      ),
    );
  }
}