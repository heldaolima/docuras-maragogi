import 'dart:io';

import 'package:docuras_maragogi/app/data/repository/company_repository.dart';
import 'package:docuras_maragogi/app/models/file.dart';
import 'package:docuras_maragogi/app/models/order.dart';
import 'package:docuras_maragogi/app/utils/converters.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  final _companyRepo = CompanyRepository();

  Future<pw.Document?> generateOrderDocument(OrderModel order) async {
    final company = await _companyRepo.getCompany();
    if (company == null) {
      return null;
    }

    debugPrint(company.toMap().toString());

    final FileModel? logo = await _companyRepo.getCompanyLogoFile();
    Uint8List? logoBytes;
    if (logo != null) {
      logoBytes = await File(logo.path).readAsBytes();
    }

    final pdf = pw.Document(
      title: 'Pedido ${order.numberPerClient} - ${order.client!.name}',
      author: company.companyName,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                // header
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoBytes != null)
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      height: 150,
                      width: 300,
                    ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(company.companyName),
                      pw.SizedBox(width: 5),
                      pw.Text(
                        'CNPJ: ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(company.cnpj),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(company.address),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(company.phoneNumber1),
                      if (company.phoneNumber2 != null)
                        pw.Text(' / ${company.phoneNumber2}'),
                    ],
                  ),
                  pw.SizedBox(height: 50),
                ],
              ),

              pw.Row(
                children: [
                  pw.Text('Pedido'),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    'Nº ${order.numberPerClient}',
                    style: pw.TextStyle(
                      color: PdfColors.blue,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                'Cliente: ${order.client!.name}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Produto',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Qtd Caixas',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Un/Caixa',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Data',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Valor',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...order.orderProducts!.map(
                    (product) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(product.productBox!.product!.name),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(product.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            product.productBox!.unitsPerBox.toString(),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(datetimeToBrString(order.orderDate)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            parseIntToBrazilianCurrentFormat(product.price * product.quantity),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          order.orderProducts!
                              .fold<int>(0, (sum, p) => sum + p.quantity)
                              .toString(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(''),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          parseIntToBrazilianCurrentFormat(
                            order.orderProducts!.fold(
                              0,
                              (sum, p) => sum + p.price * p.quantity,
                            ),
                          ),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 50),

              pw.Row(
                children: [
                  pw.Text(
                    'Pagamento via Pix: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(company.pixKey),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Pagamento via Depósito: ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Row(
                children: [
                  pw.Text(
                    'Agência: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    company.depositAgency,
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text(
                    'Conta Corrente: ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    company.depositAccount,
                  ),
                ],
              ),
              pw.Text(company.companyName),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Maragogi, ${datetimeToText(DateTime.now())}'),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(company.brandName, style: pw.TextStyle(fontSize: 16)),
                  pw.Divider(),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
