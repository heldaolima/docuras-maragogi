import 'package:docuras_maragogi/app/widgets/product_form.dart';
import 'package:flutter/material.dart';

class AddProductsPage extends StatelessWidget {
  const AddProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 300, vertical: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Adicionar produto', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ProductForm(),
            ],
          )
        ),
      ),
    );
  }
}