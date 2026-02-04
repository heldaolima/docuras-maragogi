import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final void Function() onPressed;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text('Salvar'),
    );
  }
}