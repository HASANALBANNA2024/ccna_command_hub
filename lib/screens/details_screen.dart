import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:ccna_command_hub/services/share_service.dart';

class DetailsScreen extends StatefulWidget
{
  final String moduleId;
  final String subId;
  final String title;
  final int? initialIndex;

  const DetailsScreen({
    super.key,
    required this.moduleId,
    required this.subId,
    required this.title,
    required this.initialIndex,
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
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share_rounded, color: Colors.white),
        //     onPressed: () {
        //       // শুধু এই লাইনটি কল করবেন
        //       ShareService.shareSubModule(widget.title, details);
        //     },
        //   ),
        // ],


        actions: [
          // Share Button (ShareService call kora hoyeche)
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {
              ShareService.shareSubModule(widget.title, details);
            },
          ),


          FutureBuilder<bool>(
            future: BookmarkService.isBookmarked(widget.title),
            builder: (context, snapshot) {
              bool isSaved = snapshot.data ?? false;

              return StatefulBuilder(
                builder: (context, setLocalState) {
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                      color: isSaved ? Colors.amber : Colors.white,
                      size: 26,
                    ),
                    // onPressed: () async {
                    //   // ১. চেক করা হচ্ছে ডাটা লোড হয়েছে কি না
                    //   if (details == null) {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("ডাটা এখনো লোড হচ্ছে, অপেক্ষা করুন..."))
                    //     );
                    //     return;
                    //   }
                    //
                    //   // ২. শেয়ার লজিকের মতো সব কন্টেন্ট প্যাকেজ করা
                    //   Map<String, dynamic> fullData = {
                    //     'id': widget.subId,
                    //     'moduleId': widget.moduleId,
                    //     'title': widget.title,
                    //     'full_content': Map<String, dynamic>.from(details!), // ম্যাপটি কপি করে নেওয়া হলো
                    //   };
                    //
                    //   // ৩. বুকমার্ক সার্ভিস কল করা
                    //   await BookmarkService.toggleBookmark(fullData);
                    //
                    //   // ৪. তৎক্ষণাৎ আইকন কালার পরিবর্তন
                    //   setLocalState(() {
                    //     isSaved = !isSaved;
                    //   });
                    //
                    //   // ৫. ফিডব্যাক মেসেজ
                    //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(isSaved ? "Full Module Bookmarked!" : "Removed from Bookmarks"),
                    //       duration: const Duration(milliseconds: 700),
                    //       backgroundColor: isSaved ? Colors.amber.shade900 : Colors.blueGrey,
                    //       behavior: SnackBarBehavior.floating,
                    //     ),
                    //   );
                    // },
                    onPressed: () async {
                      if (details == null) return;

                      // ১. সব কন্টেন্টকে একটি সুন্দর লিস্টে সাজানো (শেয়ার লজিকের মতো)
                      List<Map<String, dynamic>> allSections = [];

                      // থিওরি যোগ করা
                      if (details!['theory'] != null) {
                        allSections.add({'title': 'Theory', 'content': details!['theory']});
                      }

                      // ডিভাইস, টপোলজি ইত্যাদি লিস্টগুলো যোগ করা
                      List<String> keys = ['devices', 'topologies', 'types', 'media', 'details'];
                      for (var key in keys) {
                        if (details![key] != null && details![key] is List) {
                          String listContent = "";
                          for (var item in details![key]) {
                            listContent += "• ${item['name']}: ${item['desc']}\n";
                          }
                          allSections.add({'title': key.toUpperCase(), 'content': listContent});
                        }
                      }

                      // এক্সাম্পল যোগ করা
                      if (details!['example'] != null) {
                        allSections.add({'title': 'Example', 'content': details!['example']});
                      }

                      // ২. পুরো ডাটা প্যাকেজ তৈরি
                      Map<String, dynamic> fullData = {
                        'id': widget.subId,
                        'title': widget.title,
                        'full_content': allSections, // এখানে এখন সব সাজানো লিস্ট আছে
                        'is_full_module': true,      // এটি চেনার জন্য যে এটি পুরো মডিউল
                      };

                      // ৩. সেভ করা
                      await BookmarkService.toggleBookmark(fullData);

                      setLocalState(() {
                        isSaved = !isSaved;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Puro Module Bookmark kora hoyeche!")),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
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

  Widget _buildListSection(String title, List<dynamic> list, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.list_alt_rounded, color: Colors.orangeAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: list.map((item) => Container(
          width: double.infinity, // পুরো জায়গা নেওয়ার জন্য
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))), // প্রতিটা আইটেমের নিচে হালকা দাগ
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ১. নাম (Title)
              Text(
                  item['name'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16)
              ),
              const SizedBox(height: 4),

              // ২. বর্ণনা (Description)
              Text(
                item['desc'] ?? "",
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),

              const SizedBox(height: 8),

              // ৩. একদম নিচে ডান পাশে বুকমার্ক বাটন
              Align(
                alignment: Alignment.centerRight,
                child: _buildStyleBookmark({
                  'id': item['name'],
                  'title': item['name'],
                  'theory': item['desc'],
                  'category': title,
                }, context),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildExpandableSection(String title, IconData icon, String content, bool isDark, bool isCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // মূল টেক্সট (অপরিবর্তিত)
                Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),

                const SizedBox(height: 12), // টেক্সট থেকে বাটনের গ্যাপ
                const Divider(thickness: 0.5), // হালকা সেপারেটর

                // আপনার চাওয়া অনুযায়ী বক্সের ভেতর ডান পাশে বুকমার্ক বাটন
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildStyleBookmark({
                    'id': widget.subId,
                    'title': widget.title, // সাব-মডিউল + সেকশন নাম
                    'theory': content,
                  }, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBookmark(Map<String, dynamic> subModule, BuildContext context) {
    return FutureBuilder<bool>(
      future: BookmarkService.isBookmarked(subModule['title']),
      builder: (context, snapshot) {
        // Initial state load korbe
        bool isSaved = snapshot.data ?? false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return InkWell(
              onTap: () async {
                // Database update
                await BookmarkService.toggleBookmark(subModule);

                // UI sathe sathe update hobe (Quran app style)
                setLocalState(() {
                  isSaved = !isSaved;
                });

                // User ke feedback dewa
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isSaved ? "বুকমার্কে সেভ করা হয়েছে" : "বুকমার্ক থেকে সরানো হয়েছে"),
                    duration: const Duration(milliseconds: 700),
                    backgroundColor: isSaved ? Colors.amber.shade900 : Colors.blueGrey.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  // Select korle Amber color hobe, unselect korle transparent thakbe
                  color: isSaved ? Colors.amber.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSaved ? Colors.amber.shade700 : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon color switching
                    Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                      size: 22,
                      color: isSaved ? Colors.amber.shade800 : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    // Text color switching
                    Text(
                      isSaved ? "Bookmarked" : "Bookmark",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSaved ? Colors.amber.shade900 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}










