import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailsScreen extends StatefulWidget
{
  final String moduleId;
  final String subId;
  final String title;

  const DetailsScreen({
    super.key,
    required this.moduleId,
    required this.subId,
    required this.title,
});

@override
_DetailsScreenState createState() => _DetailsScreenState();

}
class _DetailsScreenState extends State<DetailsScreen>
{
  Map<String, dynamic>? details;
  bool isLoading = true;

  @override
  void initState()
  {
    super.initState();
    loadDetails();
  }

  // data base json call
  Future<void> loadDetails() async{
    try{
      final String response = await rootBundle.loadString("assets/data/details.json");
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        details = data[widget.moduleId]?[widget.subId];
        isLoading = false;
      });
    } catch (e)
    {
      setState(() {
        isLoading = false;
      });
    }

  }



  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      // appbar
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
      ),
      // body
      body: isLoading ?
      const Center(child: CircularProgressIndicator()) :
      details == null ?
      const Center(child: Text("Data not found!"),)
          : ListView(
        padding:  const EdgeInsets.all(16),
        children: [
          // ১. থিওরি সেকশন
          if (details!['theory'] != null)
            _buildExpandableSection("Theory", Icons.book_rounded, details!['theory'], isDark, false),

          // ২. টাইপস/ডিভাইস/টপোলজি লিস্ট (যদি থাকে)
          if (details!['types'] != null) _buildListSection("Network Types", details!['types'], isDark),
          if (details!['devices'] != null) _buildListSection("Devices", details!['devices'], isDark),
          if (details!['topologies'] != null) _buildListSection("Topologies", details!['topologies'], isDark),
          if (details!['media'] != null) _buildListSection("Transmission Media", details!['media'], isDark),
          if (details!['details'] != null) _buildListSection("Key Details", details!['details'], isDark),

          // ৩. এক্সাম্পল সেকশন
          if (details!['example'] != null && details!['example'] != "")
            _buildExpandableSection("Example", Icons.lightbulb_rounded, details!['example'], isDark, false),
        ],
      )
    );
  }

  // কাস্টম লিস্ট সেকশন (Types, Devices, etc.)
  
  Widget _buildListSection(String title, List<dynamic> list, bool isDark)
  {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color:  isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.list_alt_rounded, color: Colors.orangeAccent,),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold,),),
        children: list.map((item) => ListTile(
          title: Text(item['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          subtitle: Text(item['desc'] ?? ""),
        )).toList(),
      )
    );
  }
  // custom widget
  Widget _buildExpandableSection(String title, IconData icon, String content, bool isDark, bool isCode)
  {
    return Card(
      margin:  const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,

      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blueAccent,),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold,)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
          ),
        ],
      )
    );
    }
  }









