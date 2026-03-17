import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'state.dart';
import 'pdf_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => InvoiceState(),
      child: const PandaInvoiceApp(),
    ),
  );
}

class PandaInvoiceApp extends StatelessWidget {
  const PandaInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PandaForge Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          surface: Colors.grey[50]!,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: const InvoiceDashboard(),
    );
  }
}

class InvoiceDashboard extends StatelessWidget {
  const InvoiceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InvoiceState>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Panda Invoice Generator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => PdfService.generateAndDownload(state),
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          if (isMobile) {
            // Stacked Mobile Layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPreviewPane(context, state),
                  const SizedBox(height: 24),
                  _buildOrgForm(context, state),
                  const SizedBox(height: 24),
                  _buildClientForm(context, state),
                  const SizedBox(height: 24),
                  _buildLineItemsForm(context, state),
                ],
              ),
            );
          }

          // Side-by-side Desktop Layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildOrgForm(context, state),
                          const SizedBox(height: 24),
                          _buildClientForm(context, state),
                          const SizedBox(height: 24),
                          _buildLineItemsForm(context, state),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildPreviewPane(context, state)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrgForm(BuildContext context, InvoiceState state) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Organization (Auto-saved)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    try {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 300,
                        maxHeight: 300,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        final base64String = base64Encode(bytes);
                        if (context.mounted) {
                          context.read<InvoiceState>().updateOrg(
                            base64Logo: base64String,
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                      image: state.logoBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(
                                base64Decode(state.logoBase64!),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: state.logoBase64 == null
                        ? const Center(
                            child: Icon(Icons.add_a_photo, color: Colors.grey),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextFormField(
                    initialValue: state.orgName,
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateOrg(name: val),
                  ),
                ),
                if (state.logoBase64 != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        context.read<InvoiceState>().updateOrg(base64Logo: ''),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.orgEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateOrg(email: val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: state.upiId,
                    decoration: const InputDecoration(
                      labelText: 'UPI ID for Payment',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateOrg(upi: val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.orgAddress,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
              onChanged: (val) =>
                  context.read<InvoiceState>().updateOrg(address: val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientForm(BuildContext context, InvoiceState state) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.invoiceNumber,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateInvoice(invNum: val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        '${state.dueDate.day}/${state.dueDate.month}/${state.dueDate.year}',
                    decoration: const InputDecoration(labelText: 'Due Date'),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        context.read<InvoiceState>().updateInvoice(date: date);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.clientName,
                    decoration: const InputDecoration(
                      labelText: 'Billed To (Client Name)',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateInvoice(cName: val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: state.clientEmail,
                    decoration: const InputDecoration(
                      labelText: 'Client Email',
                    ),
                    onChanged: (val) =>
                        context.read<InvoiceState>().updateInvoice(cEmail: val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.projectName,
              decoration: const InputDecoration(
                labelText: 'Project Name (Optional)',
              ),
              onChanged: (val) =>
                  context.read<InvoiceState>().updateInvoice(pName: val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsForm(BuildContext context, InvoiceState state) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Line Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => context.read<InvoiceState>().addLineItem(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(state.items.length, (index) {
              final item = state.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        initialValue: item.description,
                        decoration: const InputDecoration(
                          hintText: 'Description',
                        ),
                        onChanged: (val) => context
                            .read<InvoiceState>()
                            .updateLineItem(index, desc: val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: item.quantity.toString(),
                        decoration: const InputDecoration(hintText: 'Qty'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context
                            .read<InvoiceState>()
                            .updateLineItem(index, qty: int.tryParse(val) ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.rate == 0
                            ? ''
                            : item.rate.toString(),
                        decoration: const InputDecoration(
                          hintText: 'Rate',
                          prefixText: '₹',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            context.read<InvoiceState>().updateLineItem(
                              index,
                              rate: double.tryParse(val) ?? 0,
                            ),
                      ),
                    ),
                    IconButton(
                      color: Colors.red[300],
                      icon: const Icon(Icons.delete_outline),
                      onPressed: state.items.length > 1
                          ? () => context.read<InvoiceState>().removeLineItem(
                              index,
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewPane(BuildContext context, InvoiceState state) {
    return Card(
      elevation: 0,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PAYMENT OVERVIEW',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '₹${state.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_2,
                    size: 160,
                    color: Colors.black26,
                  ), // Placeholder for actual QR
                  const SizedBox(height: 16),
                  Text(
                    'Dynamic QR Code will be embedded in the final PDF for ₹${state.grandTotal.toStringAsFixed(0)} routing to ${state.upiId}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => PdfService.generateAndDownload(state),
                child: const Text(
                  'Export Invoice PDF',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
