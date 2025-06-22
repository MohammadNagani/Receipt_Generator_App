import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../layouts/home.dart';

class RegisterDetailsPage extends StatefulWidget {
  final String userId; // Passed from sign-up screen

  RegisterDetailsPage({required this.userId});

  @override
  _RegisterDetailsPageState createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  XFile? _pickedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _prefillEmailIfPossible();
  }

  // If user is logged in, prefill email
  void _prefillEmailIfPossible() {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email != null) {
      // Save email to profiles
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_pickedImage == null) return null;

    try {
      final fileBytes = await File(_pickedImage!.path).readAsBytes();
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = Supabase.instance.client.storage;
      await storage
          .from('profile-images')
          .uploadBinary(fileName, fileBytes, fileOptions: FileOptions(contentType: 'image/jpeg'));

      final publicUrl = storage.from('profile-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  Future<void> _submitDetails() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = Supabase.instance.client.auth.currentUser?.email;
    final userId = widget.userId;

    if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    final uploadedUrl = await _uploadImage(userId);

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'profile_image': uploadedUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile created successfully!')),
      );

      // Navigate to home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      print("Profile creation failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _pickedImage != null
                      ? FileImage(File(_pickedImage!.path))
                      : null,
                  child: _pickedImage == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
                      : null,
                ),
              ),
              const SizedBox(height: 25),

              _buildTextField("First Name", firstNameController),
              const SizedBox(height: 15),

              _buildTextField("Last Name", lastNameController),
              const SizedBox(height: 15),

              _buildPhoneField(),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: _submitDetails,
                icon: Icon(Icons.check),
                label: Text("Submit"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixText: '+91 ',
        border: OutlineInputBorder(),
      ),
    );
  }
}
