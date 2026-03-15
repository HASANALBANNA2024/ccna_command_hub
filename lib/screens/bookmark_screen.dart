import 'package:ccna_command_hub/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:ccna_command_hub/services/share_service.dart';

class BookmarkScreen extends StatefulWidget {
  final List<dynamic> bookmarkedItems;
  const BookmarkScreen({super.key, required this.bookmarkedItems});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("My Bookmarks", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: () => _showClearAllDialog(),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: BookmarkService.getAllBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final item = bookmarks[index];
              // যদি AppBar থেকে সেভ করা হয়, তবে details ম্যাপটি থাকবে 'full_content' এ
              final Map<String, dynamic> dataToShow = item['full_content'] ?? item;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  iconColor: Colors.blueAccent,
                  collapsedIconColor: Colors.grey,
                  leading: const Icon(Icons.bookmark, color: Colors.amber),
                  title: Text(
                    item['title'] ?? "No Title",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ১. ডাইনামিক কন্টেন্ট রেন্ডারিং (ইমেজ, লিস্ট, থিওরি)
                          ..._buildExpandedContent(dataToShow, isDark),

                          const Divider(height: 30),

                          // ২. একশন বাটন (শেয়ার এবং রিমুভ)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_outlined, color: Colors.blueAccent),
                                onPressed: () => ShareService.shareSubModule(item['title'] ?? "CCNA", dataToShow),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  await BookmarkService.toggleBookmark(item);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                label: const Text("Remove", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ExpansionTile এর ভেতর সবকিছু দেখানোর লজিক
  List<Widget> _buildExpandedContent(Map<String, dynamic> data, bool isDark) {
    List<Widget> contentWidgets = [];

    data.forEach((key, value) {
      if (key == 'id' || key == 'title' || value == null || value == "") return;

      if (key == 'image') {
        // ইমেজ দেখানোর ব্যবস্থা
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                value.toString(),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      } else if (value is List) {
        // যদি লিস্ট হয় (যেমন OSI Layers)
        contentWidgets.add(Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)));
        for (var listItem in value) {
          if (listItem is Map) {
            listItem.forEach((k, v) => contentWidgets.add(Text("• $k: $v", style: const TextStyle(fontSize: 14))));
          } else {
            contentWidgets.add(Text("• ${listItem.toString()}", style: const TextStyle(fontSize: 14)));
          }
        }
        contentWidgets.add(const SizedBox(height: 10));
      } else {
        // সাধারণ টেক্সট বা থিওরি
        contentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(value.toString(), style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        );
      }
    });

    return contentWidgets;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text("বুকমার্কে কিছু নেই!", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("সব মুছুন?"),
        content: const Text("আপনি কি নিশ্চিতভাবে সব বুকমার্ক ডিলিট করতে চান?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("না")),
          TextButton(
            onPressed: () async {
              await BookmarkService.clearAllBookmarks();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("হ্যাঁ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}