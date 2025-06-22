import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:receipt_generator/layouts/bill_data_model.dart';
import 'package:receipt_generator/layouts/preview_page.dart';
import 'package:receipt_generator/receipt/reciept_history.dart';
import 'package:receipt_generator/layouts/profilePage.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:receipt_generator/layouts/signaturePad.dart';
// import 'package:receiptdummy/layouts/preview_page.dart';
// import 'package:receiptdummy/layouts/profilePage.dart';
// import 'package:receiptdummy/layouts/signaturePad.dart';

class ProductDetails extends StatefulWidget {
  final BillData? billData; // ❗️ Make nullable
  final Map<String, dynamic>? metadata;

  const ProductDetails({super.key, this.billData, this.metadata});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String? selectedProduct;
  String? _signaturePath;
  List<Map<String, TextEditingController>> productList = [];
  List<bool> advanceCheckboxes = [false, false, false, false, false];

  final List<String> fieldLeft = [
    "Bill no.",
    "Sender Name and  Address",
    "Recipient Name and Address ",
    "Truck Owner Name",
    "Chassis no.",
  ];

  final List<String> fieldRight = [
    "dated",
    "Truck no.",
    "From Where",
    "Till Where",
  ];

  final List<String> banksField = [
    "Bank Name",
    "Account Name",
    "Account No.",
    "IFSC Code",
  ];

@override
void initState() {
  super.initState();

  if (widget.metadata != null) {
    // Edit mode: populate from Supabase metadata
    final dLeft = widget.metadata!['controllerLeft'] ?? {};
    final dRight = widget.metadata!['controllerRight'] ?? {};
    final bank = widget.metadata!['bankingData'] ?? {};
    final prod = widget.metadata!['productsData'] ?? {};
    final adv = widget.metadata!['advanceDetails'] ?? {};

    controllersLeft[0].text = "${dLeft['bilty'] ?? ''}";
    controllersLeft[1].text = dLeft['senderName'] ?? '';
    controllersLeft[2].text = dLeft['recipientName'] ?? '';
    controllersLeft[3].text = dLeft['truckOwner'] ?? '';
    controllersLeft[4].text = "${dLeft['chassis'] ?? ''}";

    driverController.text = widget.metadata!['driver'] ?? '';
    engineNoController.text = widget.metadata!['engine_no'] ?? '';

    controllersRight[0].text = "${dRight['dated'] ?? ''}";
    controllersRight[1].text = "${dRight['truckNo'] ?? ''}";
    controllersRight[2].text = dRight['fromWhere'] ?? '';
    controllersRight[3].text = dRight['tillWhere'] ?? '';

    bankListController[0].text = bank['bankName'] ?? '';
    bankListController[1].text = bank['accountName'] ?? '';
    bankListController[2].text = "${bank['accountNo'] ?? ''}";
    bankListController[3].text = "${bank['ifscCode'] ?? ''}";

    productListController[1].text = "${prod['weight'] ?? ''}";
    productListController[2].text = "${prod['quantity'] ?? ''}";
    productListController[3].text = "${prod['rate'] ?? ''}";
    productListController[4].text = "${prod['fare'] ?? ''}";
    productListController[6].text = "${prod['WhatHasToBeGiven'] ?? ''}";
    productListController[7].text = prod['remark'] ?? '';

    advanceList[0].text = "${adv['labour'] ?? ''}";
    advanceList[1].text = "${adv['merchant'] ?? ''}";
    advanceList[2].text = "${adv['fork'] ?? ''}";
    advanceList[3].text = "${adv['bridge'] ?? ''}";
    advanceList[4].text = "${adv['bilty'] ?? ''}";
  }

  else if (widget.billData != null) {
    // New mode: populate from BillData class
    final d = widget.billData!;
    controllersLeft[0].text = d.billNo;
    controllersLeft[1].text = "${d.senderName}\n${d.senderAddress}";
    controllersLeft[2].text = "${d.recipientName}\n${d.recipientAddress}";
    controllersLeft[3].text = d.truckOwnerName;
    controllersLeft[4].text = d.chassisNo;
    driverController.text = d.driver;
    engineNoController.text = d.engineNo;
    controllersRight[0].text = d.date;
    controllersRight[1].text = d.truckNo;
    controllersRight[2].text = d.fromWhere;
    controllersRight[3].text = d.tillWhere;
    bankListController[0].text = d.bankName;
    bankListController[1].text = d.accountName;
    bankListController[2].text = d.accountNo;
    bankListController[3].text = d.ifscCode;
  }
}


  // void addProductRow() {
  //   setState(() {
  //     productList.add({
  //       "Description": TextEditingController(),
  //       "Weight": TextEditingController(),
  //       "Quantity": TextEditingController(),
  //       "Rate": TextEditingController(),
  //       "Fare": TextEditingController(),
  //       "advance": TextEditingController(),
  //       "what has to be given": TextEditingController(),
  //       "Remarks": TextEditingController(),
  //     });
  //   });
  // }
  // void deleteProduct(int index) {
  //   setState(() {
  //     productList.removeAt(index);
  //     selectedProduct = productList.isEmpty ? null : "0";
  //     // // Reset selectedProduct if the deleted item was selected
  //     // if (selectedProduct == index.toString()) {
  //     //   selectedProduct = null; // Reset the dropdown selection
  //     // } else {
  //     //   // Ensure selectedProduct is still valid (adjust index if needed)
  //     //   if (productList.isEmpty) {
  //     //     selectedProduct = null;
  //     //   } else if (int.parse(selectedProduct ?? "0") >= productList.length) {
  //     //     selectedProduct = (productList.length - 1).toString();
  //     //   }
  //     // }
  //   });
  // }

  final List<TextEditingController> controllersLeft = List.generate(
    5,
        (index) => TextEditingController(),
  );

  final List<TextEditingController> controllersRight = List.generate(
    4,
        (index) => TextEditingController(),
  );

  final List<TextEditingController> productListController = List.generate(
    8,
        (index) => TextEditingController(),
  );
  final List<TextEditingController> advanceList = List.generate(
    5,
        (index) => TextEditingController(),
  );
  final List<TextEditingController> bankListController = List.generate(
    4,
        (index) => TextEditingController(),
  );

  final TextEditingController driverController = TextEditingController();
  final TextEditingController engineNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Receipt App",style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.teal,
        actions: [Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(onPressed: profileBtn, icon: Icon(Icons.person,color: Colors.white,))
        )],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // headlines
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            "assets/truck.jpg",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            Center(
                              child: Text(
                                "Ariba RoadLines",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                "Opposite Prakash Pipe Factory ,Moradabad Road, Kashipur-244713( Ardham Singh nagar) Uttarakhand",
                                //   textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    // Row Tables ans fields
                    SizedBox(
                      width: 1000,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: fieldLeft.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(fieldLeft[index])),
                                      Expanded(
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          controller: controllersLeft[index],
                                          // decoration: const InputDecoration(
                                          //   border: OutlineInputBorder(),
                                          // ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ), // Space between ListView and Table
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text("Driver        "),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: TextField(
                                        controller: driverController,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Text("Engine no."),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: TextFormField(
                                        controller: engineNoController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          //  Tables for Right Fields
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1,color: Colors.teal),

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    fieldRight.length * 2 -
                                        1, // To accommodate dividers
                                        (index) {
                                      if (index.isOdd) {
                                        return Divider(); // Add divider after each row
                                      }
                                      int fieldIndex = index ~/ 2;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: SizedBox(
                                          width: 300,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  fieldRight[fieldIndex],
                                                ),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  controller: controllersRight[
                                                  fieldIndex],
                                                  // decoration:
                                                  //     const InputDecoration(
                                                  //       border:
                                                  //           OutlineInputBorder(),
                                                  //     ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Product Table
                    SizedBox(
                      width: 1000,
                      child: Table(
                        border: TableBorder.all(color: Colors.teal, width: 1),
                        columnWidths: {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                          5: FlexColumnWidth(1.5),
                          6: FlexColumnWidth(1),
                          7: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              tableCell("Description"),
                              tableCell("Weight"),
                              tableCell("Quantity"),
                              tableCell("Rate"),
                              tableCell("Fare"),
                              tableCell("advance"),
                              tableCell("what has to be given"),
                              tableCell("Remarks"),
                            ],
                          ),
                          // ...List.generate(productList.length, (index) {
                          //   return
                          TableRow(
                            children: [
                              tableInput(
                                "Description",
                                productListController[0],
                                false,
                              ), // Text input for product name
                              tableInput(
                                "Weight",
                                productListController[1],
                                false,
                              ), // Text input for weight
                              tableInput(
                                "Quantity",
                                productListController[2],
                                true,
                              ), // Numeric input for quantity
                              tableInput(
                                "Rate",
                                productListController[3],
                                true,
                              ), // Numeric input for rate
                              tableInput(
                                "Fare",
                                productListController[4],
                                false,
                              ), // Numeric input for fare
                              tableInput(
                                "advance",
                                productListController[5],
                                false,
                              ), // Numeric input for fare
                              tableInput(
                                "what has to be given",
                                productListController[6],
                                false,
                              ), // Numeric input for fare
                              tableInput(
                                "Remarks",
                                productListController[7],
                                false,
                              ), // Numeric input for fare
                            ],
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                    // Product Deletion Dropdown
                    // SizedBox(
                    //   width: 1000,
                    //   child: DropdownButton<String>(
                    //     value: productList.isEmpty ? null : selectedProduct,// ENsure its valid
                    //     hint: Text("Select Product to Delete"),
                    //     isExpanded: true,
                    //     items: List.generate(productList.length, (index) {
                    //       return DropdownMenuItem<String>(
                    //         value: index.toString(), // Ensure each value is unique
                    //         child: Text(productList[index]['Description']!.text),
                    //       );
                    //     }),
                    //     onChanged: (value) {
                    //       setState(() {
                    //         selectedProduct = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    // add and Delete Buttons
                    // SizedBox(
                    //   width: 1000,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12)
                    //           ),
                    //           padding: EdgeInsets.symmetric(vertical: 14,horizontal: 30)
                    //         ),
                    //         onPressed: addProductRow,
                    //         child: Text("Add Product Row"),
                    //       ),
                    //       ElevatedButton(
                    //         onPressed: selectedProduct == null
                    //             ? null // Disable delete if no product is selected
                    //             : () {
                    //           int index = int.parse(selectedProduct!);
                    //           deleteProduct(index); // Delete the selected product
                    //         },
                    //         style: ElevatedButton.styleFrom(
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //             padding: EdgeInsets.symmetric(vertical: 14,horizontal: 30),
                    //             backgroundColor: Colors.teal),
                    //         child: Text("Delete Selected Product",
                    //             style: TextStyle(color: Colors.white)),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    // divider
                    SizedBox(
                      width: 1000, // Adjust this width to match your layout
                      child: Divider(thickness: 1, color: Colors.black),
                    ),
                    //  Footer (Terms and Conditions + Bank Fields)
                    SizedBox(
                      width: 1000,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Terms and Conditions :",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "1. The trader should load the goods only after completing all the vehicle documents.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "2. Insurance of goods more than Rs. 0.10,000/- is a must. The rest of the responsibility will be of the trader.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "3. The sender of the goods will himself be responsible for the illegal goods.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "4. The loaded goods must be insured, other responsibilities will be of the trader.",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bank Details :",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: banksField.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 3.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(banksField[index]),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              keyboardType: TextInputType.text,
                                              controller:
                                              bankListController[index],
                                              // decoration: const InputDecoration(
                                              //   border: OutlineInputBorder(),
                                              // ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    // Signature
                    SizedBox(
                      width: 1000,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "neck Signature",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "driver's Signature",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " booking clerk",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left Signature box
                              Container(
                                width: 150,
                                height: 10,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 2)),
                                ),
                              ),
                              SizedBox(width: 10,),
                              //Middle signature with upload option
                              Container(
                                width: 150,
                                //height: 120,
                                // decoration: BoxDecoration(
                                //   border: Border(bottom: BorderSide(width: 2)),
                                // ),
                                child: Column(
                                  children: [
                                    //Show signature if Available
                                    if (_signaturePath != null)
                                      Container(
                                        width: 150,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        child:_signaturePath!=null
                                            ?Image.file(File(_signaturePath!),
                                            key: ValueKey(_signaturePath),//To avoid image caching issues (if it still shows the old image)
                                            fit: BoxFit.contain)
                                            :Center(child :Text("No Signature")),
                                      ),
                                    SizedBox(height: 15,),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 2)),
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(),
                                        //   padding: EdgeInsets.symmetric(vertical: 12,horizontal: 20)
                                      ),
                                      onPressed: _pickSignature,
                                      child: Text('Choose'),
                                    ),
                                  ],
                                ),
                              ),
                              //Right signature Box
                              SizedBox(height: 10),
                              Container(
                                width: 150,
                                height: 10,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(width: 2)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Submit Btn
                    SizedBox(
                      width: 1000,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.teal[300],
                              padding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 100,
                              ),
                            ),
                            onPressed: _submitBtn,
                            child: Text("Submit",style: TextStyle(color: Colors.white,fontSize: 16),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget tableInput(
      String columnName,
      TextEditingController controller,
      bool isNumeric, [
        int? index,
        bool isReadOnly = false,
      ]) {
    if (columnName == "Description") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextFormField(
              controller: productListController[0],
              textAlign: TextAlign.center,
              minLines: 1,
              maxLines: null,
              readOnly: isReadOnly,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                "assets/truck.jpg",
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            maxLines: null,
            minLines: 1,
            textAlign: TextAlign.center,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            ),
            keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
            onChanged: (value) {
              if (!isReadOnly) {
                // calculateFare(index);
              }
            },
          ),
          if (columnName == 'advance')
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final labels = [
                      "labour charge",
                      "merchant expenses",
                      "fork expense",
                      "bridge expenses",
                      "bilty charge"
                    ];
                    return Row(
                      children: [
                        Checkbox(
                          value: advanceCheckboxes[index],
                          onChanged: (value) {
                            setState(() {
                              advanceCheckboxes[index] = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          if (columnName == "what has to be given")
            Column(
              children: List.generate(
                5,
                    (index) {
                  return Visibility(
                    visible: advanceCheckboxes[index],
                    child: TextFormField(
                      controller: advanceList[index],
                      decoration: InputDecoration(
                        labelText: [
                          "labour charge",
                          "merchant expenses",
                          "fork expense",
                          "bridge expenses",
                          "bilty charge"
                        ][index],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitBtn() async {
    try {
      // Check if any required fields are empty
      if (controllersRight[0].text.isEmpty ||
          controllersRight[1].text.isEmpty ||
          controllersRight[2].text.isEmpty ||
          controllersRight[3].text.isEmpty ||
          controllersLeft[0].text.isEmpty ||
          controllersLeft[1].text.isEmpty ||
          controllersLeft[2].text.isEmpty ||
          controllersLeft[3].text.isEmpty ||
          controllersLeft[4].text.isEmpty ||
          bankListController[0].text.isEmpty ||
          bankListController[1].text.isEmpty ||
          bankListController[2].text.isEmpty ||
          bankListController[3].text.isEmpty ||
          driverController.text.isEmpty ||
          engineNoController.text.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Please fill all fields")));
        return;
      }

      if (productListController[1].text.isEmpty ||
          productListController[2].text.isEmpty ||
          productListController[3].text.isEmpty ||
          productListController[4].text.isEmpty ||
          productListController[6].text.isEmpty ||
          productListController[7].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill in all required fields.")),
        );
        return;
      }

      double? weight = double.tryParse(productListController[1].text);
      int? quantity = int.tryParse(productListController[2].text);
      double? rate = double.tryParse(productListController[3].text);
      double? fare = double.tryParse(productListController[4].text);
      double? whatHasToBeGiven = double.tryParse(productListController[6].text);
      String remark = productListController[7].text;

      int? bilty = int.tryParse(controllersLeft[0].text);
      String senderName = controllersLeft[1].text;
      String recipientName = controllersLeft[2].text;
      String truckOwner = controllersLeft[3].text;
      int? chassis = int.tryParse(controllersLeft[4].text);

      int? dated = int.tryParse(controllersRight[0].text);
      int? truckNo = int.tryParse(controllersRight[1].text);
      String fromWhere = controllersRight[2].text;
      String tillWhere = controllersRight[3].text;

      String bankName = bankListController[0].text;
      String accountName = bankListController[1].text;
      int? accountNo = int.tryParse(bankListController[2].text);
      int? ifscCode = int.tryParse(bankListController[3].text);

      if (weight == null || quantity == null || rate == null || fare == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid numbers.')),
        );
        return;
      }

      // Advance details
      Map<String, double> advanceDetails = {
        'labour': double.tryParse(advanceList[0].text) ?? 0,
        'merchant': double.tryParse(advanceList[1].text) ?? 0,
        'fork': double.tryParse(advanceList[2].text) ?? 0,
        'bridge': double.tryParse(advanceList[3].text) ?? 0,
        'bilty': double.tryParse(advanceList[4].text) ?? 0,
      };

      Map<String, dynamic> controllerLeft = {
        'bilty': bilty,
        'senderName': senderName,
        'recipientName': recipientName,
        'truckOwner': truckOwner,
        'chassis': chassis,
      };

      Map<String, dynamic> controllerRight = {
        'dated': dated,
        'truckNo': truckNo,
        'fromWhere': fromWhere,
        'tillWhere': tillWhere,
      };

      Map<String, dynamic> bankingData = {
        'bankName': bankName,
        'accountName': accountName,
        'accountNo': accountNo,
        'ifscCode': ifscCode,
      };

      Map<String, dynamic> productsData = {
        "weight": weight,
        "quantity": quantity,
        "rate": rate,
        "fare": fare,
        "remark": remark,
        "WhatHasToBeGiven": whatHasToBeGiven,
      };

      final pdfFile = await generateReceiptPDF();


      final Map<String, dynamic> allMetadata = {
        "productsData": productsData,
        "advanceDetails": advanceDetails,
        "controllerLeft": controllerLeft,
        "controllerRight": controllerRight,
        "bankingData": bankingData,
        // add anything else needed
      };


      // Upload PDF to Supabase
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
        return;
      }


      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final fileBytes = await pdfFile.readAsBytes();

      try {
        final uploadedPath = await supabase.storage
            .from('pdf')
            .uploadBinary(fileName, fileBytes);

        if (uploadedPath == null || uploadedPath.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload receipt.')),
          );
          return;
        }

        final publicUrl = supabase.storage.from('pdf').getPublicUrl(fileName);
        print('Uploaded receipt URL: $publicUrl');

        // Insert record into 'receipts' table
        await supabase.from('receipts').insert({
          'user_id': userId,
          'metadata': allMetadata,
          'pdf_url': publicUrl,
        });

        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PdfPreviewPage(
                  pdfFile: pdfFile,
                  //metadata: allMetadata,
                )),
      );


      } catch (e) {
        print('Error uploading or inserting: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred during upload.')),
        );
      }
    } catch (e) {
      print('Error submitting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong.')),
      );
    }
  }


  Future<File> generateReceiptPDF() async {
    final pdf = pw.Document();
    // Loading assets image
    Uint8List truckImageBytes = await rootBundle.load('assets/truck.jpg').then((data) => data.buffer.asUint8List());
    final truckImage = pw.MemoryImage(truckImageBytes);

    // Load company logo
    final ByteData bytes = await rootBundle.load('assets/truck.jpg');
    final Uint8List byteList = bytes.buffer.asUint8List();

    // Loading the driver signature
    Uint8List? signatureImageBytes;
    if(_signaturePath!=null){
      signatureImageBytes=await File(_signaturePath!).readAsBytes();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          // Header
          pw.Row(
            children: [
              pw.Container(
                width: 100,
                height: 100,
                child: pw.Image(pw.MemoryImage(byteList)),
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Ariba RoadLines",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Opposite Prakash Pipe Factory, Moradabad Road, Kashipur-244713",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          pw.Divider(),
          pw.SizedBox(height: 10),

          // Row with Driver, Engine, Left/Right fields
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: List.generate(fieldLeft.length, (index) {
                    return pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(fieldLeft[index] + ": "),
                        ),
                        pw.Expanded(
                          child: pw.Container(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(controllersLeft[index].text),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 60),
                    pw.Row(
                      children: [
                        pw.Text("Driver        "),
                        pw.SizedBox(width: 20),
                        pw.Expanded(child: pw.Text(driverController.text)),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Text("Engine no."),
                        pw.SizedBox(width: 20),
                        pw.Expanded(
                          child: pw.Text(engineNoController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(width: 1.0, color: PdfColors.teal),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1), // For field labels
                    1: pw.FlexColumnWidth(2), // For field values
                  },
                  children: List.generate(fieldRight.length, (index) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(fieldRight[index] + ": "),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(controllersRight[index].text),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // 🧾 Product Table
          buildProductTablePdf(
            tableHeaders: [],
            productListController: productListController,
            advanceList: advanceList,
            truckImage: truckImage,
          ),

          pw.SizedBox(height: 20),

          // 📜 Terms and Conditions & Bank Details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Terms and Conditions:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "1. The trader should load the goods only after completing all the vehicle documents.",
                    ),
                    pw.Text(
                      "2. Insurance of goods above Rs. 10,000/- is a must.",
                    ),
                    pw.Text(
                      "3. The sender is responsible for illegal goods.",
                    ),
                    pw.Text("4. Loaded goods must be insured."),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Bank Details:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    ...List.generate(banksField.length, (index) {
                      return pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Text(banksField[index] + ": "),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              child: pw.Text(
                                bankListController[index].text,
                              ), // You can fill this dynamically if needed
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // ✍ Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text("Neck Signature"),
                  pw.Container(
                    width: 150,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 2)),
                    ),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text("Driver's Signature"),
                  pw.SizedBox(height: 10),
                  if(signatureImageBytes!=null)
                    pw.Container(
                      width: 150,
                      height: 40,
                      decoration: pw.BoxDecoration(
                        // border: pw.Border(bottom: pw.BorderSide(width: 2)),
                        border: pw.Border.all(width: 2),
                      ),
                      child: pw.Image(
                        pw.MemoryImage(signatureImageBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    )else
                    pw.Container(
                      width: 150,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 2)),
                      ),
                    ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text("Booking Clerk"),
                  pw.Container(
                    width: 150,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 2)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'receipt.pdf');
    return file;
  }

  pw.Widget buildProductTablePdf({
    required List<pw.Widget> tableHeaders,
    required List<TextEditingController> productListController,
    required List<TextEditingController> advanceList,
    required truckImage,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.teal, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1.5),
        6: const pw.FlexColumnWidth(1),
        7: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          children: [
            for (var header in [
              "Description",
              "Weight",
              "Quantity",
              "Rate",
              "Fare",
              "Advance",
              "What has to be given",
              "Remarks",
            ])
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  header,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
          ],
        ),

        // Data row
        pw.TableRow(
          children: [
            // Description image placeholder
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Column(
                    children:[
                      pw.Text(productListController[0].text),
                      pw.SizedBox(height: 5),
                      pw.Image(
                        truckImage,
                        fit: pw.BoxFit.cover,
                        height: 100,
                      ),
                    ]
                ),
              ),
            ), // Replace with actual image logic
            // Weight
            pw.Center(child: pw.Text(productListController[1].text)),

            // Quantity
            pw.Center(child: pw.Text(productListController[2].text)),

            // Rate
            pw.Center(child: pw.Text(productListController[3].text)),

            // Fare
            pw.Center(child: pw.Text(productListController[4].text)),

            // Advance (with labels)
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text(productListController[5].text),
                pw.Divider(thickness: 1, color: PdfColors.teal),
                pw.Text("Labour charge:"),
                pw.Text("Merchant expenses:"),
                pw.Text("Fork expense:"),
                pw.Text("Bridge expenses: "),
                pw.Text("Bilty charge:"),
              ],
            ),

            // What has to be given
            pw.Column(
              children: [
                pw.Text(productListController[6].text),
                pw.Divider(thickness: 1, color: PdfColors.teal),
                for (var c in advanceList)
                  pw.Text(c.text),
              ],
            ),

            // Remarks
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(6.0),
                child: pw.Text(productListController[7].text),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Future<void> saveDataFirestore({
  //   required Map< String, dynamic> productsData,
  //
  //   required Map<String,double> advanceDetails,
  //
  //   //required double WhatHasToBeGiven,
  //
  //   required Map<String,dynamic> controllerLeft,
  //   required Map<String,dynamic> controllerRight,
  //   required Map<String,dynamic> bankingData,
  // }) async{
  //   CollectionReference products =FirebaseFirestore.instance.collection('Users');
  //
  //   String id = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   await products.doc(id).set({
  //     'id' :id,
  //     'productsData': productsData,
  //     'advance': advanceDetails,
  //     //'what_has_to_be_given': WhatHasToBeGiven,
  //     'controllerLeft': controllerLeft,
  //     'controllerRight': controllerRight,
  //     'bankingData': bankingData,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });
  // }
  Future<void> _pickSignature() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignaturePad()),
    );

    if (result != null && result is File) {
      setState(() {
        _signaturePath = result.path;
      });
      print("updated signautre path :$_signaturePath");
    }
  }

  void profileBtn() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
  }
}