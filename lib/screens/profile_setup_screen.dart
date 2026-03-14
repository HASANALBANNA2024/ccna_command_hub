import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ccna_command_hub/services/database_service.dart';
class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _religionController = TextEditingController();
  String _birthday = "সিলেক্ট করুন";
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false; // ডাটা সেভ হওয়ার সময় লোডিং দেখাবে

  // ছবি নেওয়ার অপশন (ক্যামেরা/গ্যালারি)
  Future _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // জন্মদিন সিলেক্ট করার জন্য ডেট পিকার
  Future _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthday = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // হালকা কালারফুল ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: Text("প্রোফাইল সেটিংস"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // প্রোফাইল ছবির ওপর ক্লিক করলে ছবি পাল্টাবে
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.person, size: 70, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                  // ছবির সাইডে ছোট ক্যামেরা আইকন
                  Positioned(
                    bottom: 0,
                    right: 5,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ইনপুট বক্সগুলো
            _buildTextField(_nameController, "পুরো নাম", Icons.person),
            const SizedBox(height: 15),
            _buildTextField(_phoneController, "মোবাইল নম্বর", Icons.phone, inputType: TextInputType.phone),
            const SizedBox(height: 15),
            _buildTextField(_religionController, "ধর্ম", Icons.brightness_high),
            const SizedBox(height: 15),

            // জন্মদিন সিলেক্ট করার ডিজাইন
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("জন্মদিন: $_birthday", style: TextStyle(color: Colors.grey[700])),
                trailing: Icon(Icons.calendar_month, color: Colors.blueAccent),
                onTap: () => _selectDate(context),
              ),
            ),

            const SizedBox(height: 40),

            // সেভ বাটন
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // এখন আর রেড লাইন আসবে না
                  ),
                ),
                onPressed: () async {
                  if (_image != null && _nameController.text.isNotEmpty) {
                    setState(() { _isLoading = true; });
                    try {
                      String url = await DatabaseService().uploadImage(_image!);
                      await DatabaseService().updateUserData(
                          _nameController.text,
                          _phoneController.text,
                          url,
                          _birthday,
                          _religionController.text
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("প্রোফাইল আপডেট হয়েছে!")));
                    } catch (e) {
                      print(e);
                    }
                    setState(() { _isLoading = false; });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("অনুগ্রহ করে ছবি এবং নাম দিন!")));
                  }
                },
                child: Text("তথ্যগুলো সেভ করুন", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // টেক্সট ফিল্ড ডিজাইন ফাংশন
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  // ক্যামেরা না গ্যালারি তা বেছে নেওয়ার ডায়ালগ
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ছবি কোথা থেকে নিবেন?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sourceOption(Icons.camera_alt, "ক্যামেরা", ImageSource.camera),
                _sourceOption(Icons.photo_library, "গ্যালারি", ImageSource.gallery),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        _pickImage(source);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.blueAccent, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }


}