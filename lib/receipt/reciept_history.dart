import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:receipt_generator/layouts/productDetails.dart';

class ReceiptHistoryPage extends StatefulWidget {
  @override
  _ReceiptHistoryPageState createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  List<Map<String, dynamic>> allReceipts = [];
  List<Map<String, dynamic>> filteredReceipts = [];
  String searchQuery = '';
  bool isLoading = true;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchReceipts();
  }

  Future<void> fetchReceipts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('receipts')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        allReceipts = List<Map<String, dynamic>>.from(response);
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching receipts: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch receipts: ${e.toString()}')),
      );
    }
  }

  // JSONB to Metadat
  dynamic getMetadataValue(Map<String, dynamic> receipt, String path) {
    try {
      final metadata = receipt['metadata'] as Map<String, dynamic>?;
      if (metadata == null) return null;

      final pathParts = path.split('.');
      dynamic current = metadata;

      for (String part in pathParts) {
        if (current is Map<String, dynamic>) {
          current = current[part];
        } else {
          return null;
        }
      }

      return current;
    } catch (e) {
      return null;
    }
  }

  // recipient name from metadata
  String getRecipientName(Map<String, dynamic> receipt) {
    final recipientName =
        getMetadataValue(receipt, 'controllerLeft.recipientName');
    return recipientName?.toString() ?? 'No Name';
  }

  //   sender name from metadata
  String getSenderName(Map<String, dynamic> receipt) {
    final senderName = getMetadataValue(receipt, 'controllerLeft.senderName');
    return senderName?.toString() ?? 'No Sender';
  }


  String getBiltyNumber(Map<String, dynamic> receipt) {
    final bilty = getMetadataValue(receipt, 'controllerLeft.bilty');
    return bilty?.toString() ?? 'No Bilty';
  }

  String getFareAmount(Map<String, dynamic> receipt) {
    final fare = getMetadataValue(receipt, 'productsData.fare');
    return fare != null ? '₹${fare.toString()}' : 'No Amount';
  }

  String getRouteInfo(Map<String, dynamic> receipt) {
    final fromWhere = getMetadataValue(receipt, 'controllerRight.fromWhere');
    final tillWhere = getMetadataValue(receipt, 'controllerRight.tillWhere');

    String from = fromWhere?.toString() ?? 'Unknown';
    String to = tillWhere?.toString() ?? 'Unknown';

    return '$from → $to';
  }

  void applyFilters() {
    List<Map<String, dynamic>> temp = allReceipts.where((receipt) {
      // Search
      final searchableText = [
        getRecipientName(receipt),
        getSenderName(receipt),
        getBiltyNumber(receipt),
        getRouteInfo(receipt),
        receipt['id']?.toString() ?? '',
      ].join(' ').toLowerCase();

      final matchesSearch = searchableText.contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      // Date selec
      if (startDate != null && endDate != null) {
        final createdAt = DateTime.tryParse(receipt['created_at'] ?? '');
        if (createdAt == null ||
            createdAt.isBefore(startDate!) ||
            createdAt.isAfter(endDate!.add(Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();

    setState(() {
      filteredReceipts = temp;
    });
  }

  Future<void> selectDateRange() async {
    final now = DateTime.now();
    final initialStart = startDate ?? now.subtract(Duration(days: 30));
    final initialEnd = endDate ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        applyFilters();
      });
    }
  }

  void clearDateFilter() {
    setState(() {
      startDate = null;
      endDate = null;
      applyFilters();
    });
  }

  Future<void> downloadPDF(Map<String, dynamic> receipt) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Ge t the url
      final fileUrl = receipt['pdf_url'] as String?;
      if (fileUrl == null || fileUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF URL not found')),
        );
        return;
      }

      // dwnload and open the PDF
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${dir.path}/receipt_${timestamp}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download or open PDF: ${e.toString()}'),
        ),
      );
    }
  }

  void editReceipt(Map<String, dynamic> receipt) {
    final metadata = receipt['metadata'];

    if (metadata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No metadata found for this receipt.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(metadata: metadata),
      ),
    );
  }

  void deleteReceipt(Map<String, dynamic> receipt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Receipt'),
        content: Text(
            'Are you sure you want to delete this receipt? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final supabase = Supabase.instance.client;
      final filePath = receipt['file_path'];

      // Delete from database
      await supabase.from('receipts').delete().eq('id', receipt['id']);

      // Delete from storage (using file path exists)
      if (filePath != null && filePath.isNotEmpty) {
        try {
          await supabase.storage.from('pdf').remove([filePath]);
        } catch (storageError) {
          print('Storage deletion error (non-critical): $storageError');
        }
      }

      // Refresh
      await fetchReceipts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt deleted successfully')),
      );
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete receipt: ${e.toString()}')),
      );
    }
  }

  void showReceiptDetails(Map<String, dynamic> receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Bilty No:', getBiltyNumber(receipt)),
              _buildDetailRow('Recipient:', getRecipientName(receipt)),
              _buildDetailRow('Sender:', getSenderName(receipt)),
              _buildDetailRow('Route:', getRouteInfo(receipt)),
              _buildDetailRow('Fare:', getFareAmount(receipt)),
              _buildDetailRow(
                  'Truck Owner:',
                  getMetadataValue(receipt, 'controllerLeft.truckOwner')
                          ?.toString() ??
                      'N/A'),
              _buildDetailRow(
                  'Truck No:',
                  getMetadataValue(receipt, 'controllerRight.truckNo')
                          ?.toString() ??
                      'N/A'),
              _buildDetailRow('Weight:',
                  '${getMetadataValue(receipt, 'productsData.weight')?.toString() ?? 'N/A'} kg'),
              _buildDetailRow(
                  'Quantity:',
                  getMetadataValue(receipt, 'productsData.quantity')
                          ?.toString() ??
                      'N/A'),
              _buildDetailRow(
                  'Created:',
                  receipt['created_at'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(DateTime.parse(receipt['created_at']))
                      : 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt History'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: selectDateRange,
            tooltip: 'Select Date Range',
          ),
          if (startDate != null || endDate != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearDateFilter,
              tooltip: 'Clear Date Filter',
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchReceipts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search receipts...',
                hintText: 'Search by name, bilty, route, etc.',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                  applyFilters();
                });
              },
            ),
          ),

          if (startDate != null && endDate != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, color: Colors.teal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Filtered: ${DateFormat('MMM dd, yyyy').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}',
                    style: TextStyle(
                        color: Colors.teal[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

          // Results count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredReceipts.length} receipt${filteredReceipts.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Receipts list
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : filteredReceipts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty && startDate == null
                                  ? 'No receipts found'
                                  : 'No receipts match your search',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              searchQuery.isEmpty && startDate == null
                                  ? 'Create your first receipt to see it here'
                                  : 'Try adjusting your search criteria',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchReceipts,
                        color: Colors.teal,
                        child: ListView.builder(
                          itemCount: filteredReceipts.length,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final receipt = filteredReceipts[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal[100],
                                  child:
                                      Icon(Icons.receipt, color: Colors.teal),
                                ),
                                title: Text(
                                  getRecipientName(receipt),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text('Bilty: ${getBiltyNumber(receipt)}'),
                                    Text('Route: ${getRouteInfo(receipt)}'),
                                    Text('Fare: ${getFareAmount(receipt)}'),
                                    SizedBox(height: 4),
                                    Text(
                                      receipt['created_at'] != null
                                          ? 'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(receipt['created_at']))}'
                                          : 'Created: Unknown',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon:
                                      Icon(Icons.more_vert, color: Colors.teal),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view_details':
                                        showReceiptDetails(receipt);
                                        break;
                                      case 'download':
                                        downloadPDF(receipt);
                                        break;
                                      case 'edit':
                                        editReceipt(receipt);
                                        break;
                                      case 'delete':
                                        deleteReceipt(receipt);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'view_details',
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.teal),
                                          SizedBox(width: 12),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'download',
                                      child: Row(
                                        children: [
                                          Icon(Icons.download,
                                              color: Colors.teal),
                                          SizedBox(width: 12),
                                          Text('Download PDF'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.teal),
                                          SizedBox(width: 12),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 12),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => showReceiptDetails(receipt),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
