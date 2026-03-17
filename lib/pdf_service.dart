import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'state.dart';

class PdfService {
  static Future<void> generateAndDownload(InvoiceState state) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(state),
              pw.SizedBox(height: 48),
              _buildBillToSection(state),
              pw.SizedBox(height: 48),
              _buildLineItemsTable(state),
              pw.Spacer(),
              _buildFooter(state),
            ],
          );
        },
      ),
    );

    // This triggers the browser download / print dialog automatically
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${state.invoiceNumber}.pdf',
    );
  }

  static pw.Widget _buildHeader(InvoiceState state) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (state.logoBase64 != null && state.logoBase64!.isNotEmpty)
              pw.Container(
                width: 60,
                height: 60,
                margin: const pw.EdgeInsets.only(right: 16),
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  image: pw.DecorationImage(
                    image: pw.MemoryImage(base64Decode(state.logoBase64!)),
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  state.orgName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  state.orgAddress,
                  style: const pw.TextStyle(color: PdfColors.grey700),
                ),
                pw.Text(
                  state.orgEmail,
                  style: const pw.TextStyle(color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '#${state.invoiceNumber}',
              style: const pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Due: ${state.dueDate.day}/${state.dueDate.month}/${state.dueDate.year}',
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildBillToSection(InvoiceState state) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILLED TO',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                state.clientName.isEmpty ? 'Client Name' : state.clientName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (state.clientEmail.isNotEmpty)
                pw.Text(
                  state.clientEmail,
                  style: const pw.TextStyle(color: PdfColors.grey800),
                ),
            ],
          ),
        ),
        if (state.projectName.isNotEmpty)
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PROJECT',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  state.projectName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildLineItemsTable(InvoiceState state) {
    return pw.Column(
      children: [
        // Table Header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: PdfColors.grey200,
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Text(
                  'DESCRIPTION',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Text(
                  'QTY',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'RATE',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'AMOUNT',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        // Table Rows
        ...state.items.map((item) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    item.description.isEmpty ? '-' : item.description,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    item.quantity.toString(),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Rs. ${item.rate.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Rs. ${item.total.toStringAsFixed(2)}',
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        pw.Divider(color: PdfColors.grey300),
        // Total
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'TOTAL DUE',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 32),
              pw.Text(
                'Rs. ${state.grandTotal.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(InvoiceState state) {
    // Generate UPI string: upi://pay?pa=UPI_ID&pn=PAYEE_NAME&am=AMOUNT&cu=INR
    final upiString =
        'upi://pay?pa=${state.upiId}&pn=${Uri.encodeComponent(state.orgName)}&am=${state.grandTotal.toStringAsFixed(2)}&cu=INR';

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PAYMENT DETAILS',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('UPI ID: ${state.upiId}'),
            pw.SizedBox(height: 4),
            pw.Text(
              'Scan the QR code to pay instantly via any UPI app.',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
            ),
          ],
        ),
        pw.Container(
          height: 100,
          width: 100,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: upiString,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}
