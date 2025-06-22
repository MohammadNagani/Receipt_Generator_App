import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receipt_generator/layouts/productDetails.dart';
import 'bill_data_model.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  final billNoController = TextEditingController();
  final senderNameController = TextEditingController();
  final senderAddressController = TextEditingController();
  final recipientNameController = TextEditingController();
  final recipientAddressController = TextEditingController();
  final truckOwnerNameController = TextEditingController();
  final chassisNoController = TextEditingController();
  final driverController = TextEditingController();
  final engineNoController = TextEditingController();
  final dateController = TextEditingController();
  final truckNoController = TextEditingController();
  final fromWhereController = TextEditingController();
  final tillWhereController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNameController = TextEditingController();
  final accountNoController = TextEditingController();
  final ifscCodeController = TextEditingController();

  @override
  void dispose() {
    billNoController.dispose();
    senderNameController.dispose();
    senderAddressController.dispose();
    recipientNameController.dispose();
    recipientAddressController.dispose();
    truckOwnerNameController.dispose();
    chassisNoController.dispose();
    driverController.dispose();
    engineNoController.dispose();
    dateController.dispose();
    truckNoController.dispose();
    fromWhereController.dispose();
    tillWhereController.dispose();
    bankNameController.dispose();
    accountNameController.dispose();
    accountNoController.dispose();
    ifscCodeController.dispose();
    super.dispose();
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      TextInputType inputType, {
        List<TextInputFormatter>? formatters,
        TextCapitalization capitalization = TextCapitalization.none,
        bool readOnly = false,
        VoidCallback? onTap,
      }) {
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
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
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
        dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter Bill Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Bill no", billNoController, Icons.receipt, TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]),
              buildTextField("Sender name", senderNameController, Icons.person, TextInputType.name),
              buildTextField("Sender address", senderAddressController, Icons.location_on, TextInputType.text),
              buildTextField("Recipient name", recipientNameController, Icons.person_outline, TextInputType.name),
              buildTextField("Recipient address", recipientAddressController, Icons.home, TextInputType.text),
              buildTextField("Truck owner name", truckOwnerNameController, Icons.directions_bus, TextInputType.name),
              buildTextField("Chassis no", chassisNoController, Icons.confirmation_number, TextInputType.text,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                  capitalization: TextCapitalization.characters),
              buildTextField("Driver", driverController, Icons.drive_eta, TextInputType.name),
              buildTextField("Engine no", engineNoController, Icons.build, TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]),
              buildTextField("Date", dateController, Icons.date_range, TextInputType.datetime,
                  readOnly: true, onTap: () => _selectDate(context)),
              buildTextField("Truck no", truckNoController, Icons.local_shipping, TextInputType.text,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                  capitalization: TextCapitalization.characters),
              buildTextField("From where", fromWhereController, Icons.place, TextInputType.text),
              buildTextField("Till where", tillWhereController, Icons.map, TextInputType.text),
              buildTextField("Bank name", bankNameController, Icons.account_balance, TextInputType.name),
              buildTextField("Account name", accountNameController, Icons.person_pin, TextInputType.name),
              buildTextField("Account no", accountNoController, Icons.account_box, TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly]),
              buildTextField("IFSC Code", ifscCodeController, Icons.code, TextInputType.text,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
                  capitalization: TextCapitalization.characters),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () {
                  final billData = BillData(
                    billNo: billNoController.text,
                    senderName: senderNameController.text,
                    senderAddress: senderAddressController.text,
                    recipientName: recipientNameController.text,
                    recipientAddress: recipientAddressController.text,
                    truckOwnerName: truckOwnerNameController.text,
                    chassisNo: chassisNoController.text,
                    driver: driverController.text,
                    engineNo: engineNoController.text,
                    date: dateController.text,
                    truckNo: truckNoController.text,
                    fromWhere: fromWhereController.text,
                    tillWhere: tillWhereController.text,
                    bankName: bankNameController.text,
                    accountName: accountNameController.text,
                    accountNo: accountNoController.text,
                    ifscCode: ifscCodeController.text,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetails(billData: billData),
                    ),
                  );
                },
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
