import 'package:ccna_command_hub/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:ccna_command_hub/services/share_service.dart';
import 'package:ccna_command_hub/screens/home_screen.dart';

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
            tooltip: "Clear All",
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final item = bookmarks[index];
              final dynamic fullContent = item['full_content'];

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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ১. যদি AppBar থেকে পুরো মডিউল সেভ করা হয় (এটি List হবে)
                          if (fullContent != null && fullContent is List)
                            ...fullContent.map((section) {
                              return _buildContentBlock(
                                  section['title'] ?? "",
                                  section['content'] ?? "",
                                  Colors.blueAccent
                              );
                            }).toList()

                          // ২. যদি ইন্ডিভিজুয়াল সেভ করা হয় (theory/desc চেক করবে)
                          else ...[
                            if (item['theory'] != null || item['desc'] != null)
                              _buildContentBlock(
                                  "Content",
                                  item['theory'] ?? item['desc'] ?? "",
                                  Colors.blueAccent
                              ),
                            if (item['example'] != null && item['example'] != "")
                              _buildContentBlock("Example", item['example'], Colors.green),
                          ],

                          const Divider(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share_outlined, color: Colors.blueAccent),
                                onPressed: () {
                                  ShareService.shareBookmark(item);
                                },
                              ),
                              const Spacer(),
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

  Widget _buildContentBlock(String title, String text, Color titleColor) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor, fontSize: 15)),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            child: const Text("হ্যাঁ", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}