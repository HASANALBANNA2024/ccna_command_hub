// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:ccna_command_hub/services/database_service.dart';
//
// class ProfileSetupScreen extends StatefulWidget {
//   @override
//   _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
// }
//
// class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//
//   String _birthday = "Select Date";
//   String? _existingImageUrl;
//   String _selectedReligion = "Islam";
//   String _selectedGender = "Male"; // Default gender
//   File? _image;
//   final picker = ImagePicker();
//
//   bool _isLoading = true;
//   bool _isEditing = false;
//   bool _isNewUser = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkUserStatus();
//   }
//
//   _checkUserStatus() async {
//     try {
//       String uid = FirebaseAuth.instance.currentUser!.uid;
//       _emailController.text = FirebaseAuth.instance.currentUser!.email ?? "";
//
//       var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//
//       if (userDoc.exists) {
//         var data = userDoc.data()!;
//         setState(() {
//           _nameController.text = data['name'] ?? "";
//           _phoneController.text = data['phone'] ?? "";
//           _emailController.text = data['email'] ?? _emailController.text;
//           _selectedReligion = data['religion'] ?? "Islam";
//           _selectedGender = data['gender'] ?? "Male";
//           _birthday = data['birthday'] ?? "Select Date";
//           _existingImageUrl = data['image'];
//           _isNewUser = false;
//           _isEditing = false;
//         });
//       } else {
//         setState(() {
//           _isNewUser = true;
//           _isEditing = true;
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future _pickImage(ImageSource source) async {
//     final pickedFile = await picker.pickImage(source: source, imageQuality: 25);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _birthday = DateFormat('dd-MM-yyyy').format(picked);
//       });
//     }
//   }
//
//   ImageProvider? _getImageProvider() {
//     if (_image != null) return FileImage(_image!);
//     if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
//       try {
//         String base64Data = _existingImageUrl!.contains(',')
//             ? _existingImageUrl!.split(',').last
//             : _existingImageUrl!;
//         return MemoryImage(base64Decode(base64Data));
//       } catch (e) {
//         return null;
//       }
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isNewUser ? "Complete Profile" : "My Profile",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           if (!_isNewUser)
//             IconButton(
//               icon: Icon(_isEditing ? Icons.cancel : Icons.edit_note, size: 30),
//               onPressed: () => setState(() => _isEditing = !_isEditing),
//             )
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile Image
//             Center(
//               child: Stack(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.blueAccent, width: 3),
//                     ),
//                     child: CircleAvatar(
//                       radius: 60,
//                       backgroundColor: isDark ? Colors.grey[800] : Colors.blueAccent.withOpacity(0.1),
//                       backgroundImage: _getImageProvider(),
//                       child: _getImageProvider() == null
//                           ? Icon(Icons.person, size: 60, color: Colors.blueAccent)
//                           : null,
//                     ),
//                   ),
//                   if (_isEditing)
//                     Positioned(
//                       bottom: 0,
//                       right: 4,
//                       child: CircleAvatar(
//                         backgroundColor: Colors.blueAccent,
//                         radius: 18,
//                         child: IconButton(
//                           icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
//                           onPressed: () => _showImageSourceDialog(),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             // Input Fields
//             _buildSectionTitle("Account Information", isDark),
//             _buildTextField(_emailController, "Email Address", Icons.email_outlined, enabled: false),
//             const SizedBox(height: 15),
//             _buildTextField(_nameController, "Full Name", Icons.person_outline, enabled: _isEditing),
//             const SizedBox(height: 15),
//             _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, inputType: TextInputType.phone, enabled: _isEditing),
//
//             const SizedBox(height: 25),
//             _buildSectionTitle("Personal Details", isDark),
//
//             // Gender Section
//             Text("Gender", style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
//             Row(
//               children: [
//                 _buildGenderRadio("Male"),
//                 _buildGenderRadio("Female"),
//                 _buildGenderRadio("Other"),
//               ],
//             ),
//
//             const SizedBox(height: 15),
//
//             // Religion Section
//             Text("Religion", style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
//             Wrap(
//               spacing: 0,
//               children: [
//                 _buildReligionRadio("Islam"),
//                 _buildReligionRadio("Hindu"),
//                 _buildReligionRadio("Buddhist"),
//                 _buildReligionRadio("Christian"),
//                 _buildReligionRadio("Other"),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Birthday
//             InkWell(
//               onTap: _isEditing ? () => _selectDate(context) : null,
//               child: InputDecorator(
//                 decoration: InputDecoration(
//                   labelText: "Birthday",
//                   prefixIcon: Icon(Icons.cake_outlined, color: Colors.blueAccent),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   filled: true,
//                   fillColor: isDark ? Colors.grey[900] : Colors.blueAccent.withOpacity(0.05),
//                 ),
//                 child: Text(_birthday, style: TextStyle(fontSize: 16)),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//
//             if (_isEditing)
//               Container(
//                 width: double.infinity,
//                 height: 55,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   gradient: LinearGradient(colors: [Colors.blueAccent, Colors.blue.shade800]),
//                 ),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   onPressed: _handleSave,
//                   child: Text("SAVE CHANGES", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, left: 5),
//       child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
//     );
//   }
//
//   Widget _buildGenderRadio(String value) {
//     return Expanded(
//       child: RadioListTile<String>(
//         title: Text(value, style: TextStyle(fontSize: 13)),
//         value: value,
//         groupValue: _selectedGender,
//         activeColor: Colors.blueAccent,
//         contentPadding: EdgeInsets.zero,
//         onChanged: _isEditing ? (val) => setState(() => _selectedGender = val!) : null,
//       ),
//     );
//   }
//
//   Widget _buildReligionRadio(String value) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * 0.4,
//       child: RadioListTile<String>(
//         title: Text(value, style: TextStyle(fontSize: 13)),
//         value: value,
//         groupValue: _selectedReligion,
//         activeColor: Colors.blueAccent,
//         contentPadding: EdgeInsets.zero,
//         onChanged: _isEditing ? (val) => setState(() => _selectedReligion = val!) : null,
//       ),
//     );
//   }
//
//   void _handleSave() async {
//     if (_nameController.text.isEmpty || (_image == null && _existingImageUrl == null)) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Name and Photo are required!")));
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       String? imageUrl = _existingImageUrl;
//       if (_image != null) {
//         imageUrl = await DatabaseService().uploadImage(_image!);
//       }
//
//       // Update DatabaseService to include Gender
//       await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
//         'name': _nameController.text,
//         'phone': _phoneController.text,
//         'email': _emailController.text,
//         'image': imageUrl,
//         'birthday': _birthday,
//         'religion': _selectedReligion,
//         'gender': _selectedGender,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated Successfully!")));
//       setState(() {
//         _isEditing = false;
//         _isNewUser = false;
//         _existingImageUrl = imageUrl;
//         _image = null;
//       });
//     } catch (e) {
//       print("Update Error: $e");
//     }
//     setState(() => _isLoading = false);
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon,
//       {TextInputType inputType = TextInputType.text, bool enabled = true}) {
//     return TextField(
//       controller: controller,
//       enabled: enabled,
//       keyboardType: inputType,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.blueAccent),
//         filled: true,
//         fillColor: enabled ? Colors.transparent : Colors.grey.withOpacity(0.1),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.blueAccent, width: 2),
//         ),
//       ),
//     );
//   }
//
//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (context) => Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("Change Profile Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _sourceOption(Icons.camera_alt_outlined, "Camera", ImageSource.camera),
//                 _sourceOption(Icons.image_outlined, "Gallery", ImageSource.gallery),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _sourceOption(IconData icon, String label, ImageSource source) {
//     return InkWell(
//       onTap: () {
//         _pickImage(source);
//         Navigator.pop(context);
//       },
//       child: Column(
//         children: [
//           CircleAvatar(radius: 30, backgroundColor: Colors.blueAccent.withOpacity(0.1), child: Icon(icon, color: Colors.blueAccent, size: 30)),
//           const SizedBox(height: 10),
//           Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
// }