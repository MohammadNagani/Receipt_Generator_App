import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({Key? key}) : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final receiptNoController = TextEditingController();
  final payerNameController = TextEditingController();
  final amountController = TextEditingController();
  final paymentDateController = TextEditingController();
  final paymentMethodController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    receiptNoController.dispose();
    payerNameController.dispose();
    amountController.dispose();
    paymentDateController.dispose();
    paymentMethodController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller, IconData icon, TextInputType inputType,
      {List<TextInputFormatter>? formatters, TextCapitalization capitalization = TextCapitalization.none, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: formatters,
        textCapitalization: capitalization,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        paymentDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> submitReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text("Receipt: ${receiptNoController.text}\n"
              "Payer: ${payerNameController.text}\n"
              "Amount: ₹${amountController.text}\n"
              "Date: ${paymentDateController.text}\n"
              "Method: ${paymentMethodController.text}\n"
              "Desc: ${descriptionController.text}"),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    final userId = supabase.auth.currentUser?.id;
    final storagePath = "receipts/${file.uri.pathSegments.last}";

    final storageResponse = await supabase.storage.from("receipts").upload(
      storagePath,
      file,
      fileOptions: FileOptions(cacheControl: "3600", upsert: true),
    );

    final publicUrl = supabase.storage.from("receipts").getPublicUrl(storagePath);

    await supabase.from("receipts").insert({
      "user_id": userId,
      "bill_no": receiptNoController.text,
      "recipient_name": payerNameController.text,
      "date": paymentDateController.text,
      "account_name": paymentMethodController.text,
      "file_name": file.uri.pathSegments.last,
      "file_path": publicUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receipt uploaded successfully!")));
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Receipt No", receiptNoController, Icons.receipt_long, TextInputType.text),
              buildTextField("Payer Name", payerNameController, Icons.person, TextInputType.text),
              buildTextField("Amount", amountController, Icons.currency_rupee, TextInputType.number),
              buildTextField("Payment Date", paymentDateController, Icons.date_range, TextInputType.datetime,
                  readOnly: true, onTap: () => _selectDate(context)),
              buildTextField("Payment Method", paymentMethodController, Icons.payment, TextInputType.text),
              buildTextField("Description", descriptionController, Icons.description, TextInputType.text),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitReceipt,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text("Submit Receipt", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
