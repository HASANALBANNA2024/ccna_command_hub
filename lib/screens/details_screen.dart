import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:ccna_command_hub/services/share_service.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';

class DetailsScreen extends StatefulWidget {
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

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? details;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDetails();
    UnlockService.markSubAsRead(widget.subId);
  }

  Future<void> loadDetails() async {
    try {
      final String response = await rootBundle.loadString("assets/data/details.json");
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        details = data[widget.moduleId]?[widget.subId];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => ShareService.shareSubModule(widget.title, details),
          ),
          _buildFullBookmarkBtn(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : details == null
          ? const Center(child: Text("Data not found!"))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: _buildDynamicBody(isDark),
      ),
    );
  }

  // --- মেইন বডি জেনারেটর ---
  List<Widget> _buildDynamicBody(bool isDark) {
    List<Widget> widgets = [];
    if (details == null) return widgets;

    // ১. টেক্সট এবং লিস্ট কন্টেন্ট (লুপ)
    details!.forEach((key, value) {
      if (key == 'image' || key == 'id' || key == 'title' || value == null || value == "") return;

      String sectionTitle = key[0].toUpperCase() + key.substring(1);

      if (value is List) {
        widgets.add(_buildDynamicListSection(sectionTitle, value, isDark));
      } else {
        widgets.add(_buildTextSection(sectionTitle, value.toString(), isDark));
      }
    });

    // ২. ইমেজ সেকশন (ক্লিকযোগ্য কার্ডের ভেতর)
    if (details!.containsKey('image') && details!['image'] != null && details!['image'] != "") {
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: false, // প্রথমে বন্ধ থাকবে, ক্লিক করলে খুলবে
            leading: const Icon(Icons.image_search_rounded, color: Colors.blueAccent),
            title: const Text(
              "Reference Diagram",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  height: 180, // কম্প্যাক্ট হাইট
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      details!['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  // --- টেক্সট কার্ড ডিজাইন ---
  Widget _buildTextSection(String title, String content, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.book_rounded, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
                const Divider(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildStyleBookmark(title, content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ডাইনামিক লিস্ট কার্ড ডিজাইন ---
  Widget _buildDynamicListSection(String title, List<dynamic> list, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.list_alt_rounded, color: Colors.orangeAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: list.map((item) {
          if (item is Map) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...item.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
                          children: [
                            TextSpan(
                                text: "${entry.key[0].toUpperCase() + entry.key.substring(1)}: ",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)
                            ),
                            TextSpan(text: "${entry.value}"),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildStyleBookmark(item.values.first.toString(), item.toString()),
                  ),
                ],
              ),
            );
          } else {
            return ListTile(title: Text(item.toString()));
          }
        }).toList(),
      ),
    );
  }

  // --- বুকমার্ক বাটন (Save/Saved টেক্সটসহ) ---
  Widget _buildStyleBookmark(String bTitle, String bContent) {
    return FutureBuilder<bool>(
      future: BookmarkService.isBookmarked(bTitle),
      builder: (context, snapshot) {
        bool isSaved = snapshot.data ?? false;
        return StatefulBuilder(builder: (context, setLocalState) {
          return InkWell(
            onTap: () async {
              await BookmarkService.toggleBookmark({'title': bTitle, 'theory': bContent});
              setLocalState(() => isSaved = !isSaved);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSaved ? Colors.amber.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSaved ? Colors.amber : Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isSaved ? Icons.bookmark : Icons.bookmark_add_outlined, size: 16, color: isSaved ? Colors.amber.shade800 : Colors.grey),
                  const SizedBox(width: 6),
                  Text(isSaved ? "Bookmarked" : "Bookmark", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSaved ? Colors.amber.shade900 : Colors.grey)),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // --- অ্যাপবার এর মেইন বুকমার্ক বাটন ---
  Widget _buildFullBookmarkBtn() {
    return FutureBuilder<bool>(
      future: BookmarkService.isBookmarked(widget.title),
      builder: (context, snapshot) {
        bool isSaved = snapshot.data ?? false;
        return StatefulBuilder(builder: (context, setLocalState) {
          return IconButton(
            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border_rounded, color: isSaved ? Colors.amber : Colors.white),
            onPressed: () async {
              if (details == null) return;
              await BookmarkService.toggleBookmark({
                'id': widget.subId,
                'title': widget.title,
                'theory': details!['theory'] ?? "Full Module Content",
              });
              setLocalState(() => isSaved = !isSaved);
            },
          );
        });
      },
    );
  }
}