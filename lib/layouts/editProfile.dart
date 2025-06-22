import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  XFile? _profileImage;
  String? _imageUrl;

  final userId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        firstNameController.text = res['first_name'] ?? '';
        lastNameController.text = res['last_name'] ?? '';
        emailController.text = res['email'] ?? '';
        phoneController.text = res['phone'] ?? '';
        _imageUrl = res['profile_image'];
      });
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_profileImage == null) return _imageUrl;

    try {
      final fileBytes = await File(_profileImage!.path).readAsBytes();
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = Supabase.instance.client.storage;
      await storage
          .from('profile-images')
          .uploadBinary(fileName, fileBytes,
          fileOptions: FileOptions(contentType: 'image/jpeg'));

      final publicUrl = storage.from('profile-images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    String? imageUrl = await _uploadImage(userId);

    try {
      await Supabase.instance.client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'profile_image': imageUrl,
      }).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : (_imageUrl != null
                      ? NetworkImage(_imageUrl!)
                      : null) as ImageProvider?,
                  child: _profileImage == null && _imageUrl == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
                      : null,
                ),
              ),
              const SizedBox(height: 25),


              buildTextField("First Name", firstNameController),

              const SizedBox(height: 15),


              buildTextField("Last Name", lastNameController),

              const SizedBox(height: 15),


              buildTextField("Email", emailController, readOnly: true),

              const SizedBox(height: 15),


              buildPhoneField(),

              const SizedBox(height: 25),


              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: Icon(Icons.save),
                label: Text("Save Changes"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildPhoneField() {
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

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
