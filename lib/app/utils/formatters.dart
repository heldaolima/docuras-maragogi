import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final phoneFormatter = MaskTextInputFormatter(
  mask: '(##) #####-####',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy
);

final cnpjFormatter = MaskTextInputFormatter(
  mask: '##.###.###/####-##',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy
);