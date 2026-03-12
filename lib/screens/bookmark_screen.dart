import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:ccna_command_hub/screens/home_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

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
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        // Home e back jawar jonno button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()), // আপনার হোম স্ক্রিন ক্লাসের নাম দিন
            );
          },
        ),
        actions: [
          // All clear korar button
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: () => _showClearAllDialog(),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: BookmarkService.getBookmarks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookmarks = snapshot.data ?? [];

          if (bookmarks.isEmpty) {
            return const Center(child: Text("বুকমার্কে কিছু নেই!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final item = bookmarks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: const Icon(Icons.bookmark, color: Colors.amber),
                  title: Text(item['title'] ?? "No Title", style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Expansion tile use korle bhetorer content (theory) dekha jabe
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['theory'] ?? item['desc'] ?? "No Content Available"),
                          const Divider(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () async {
                                await BookmarkService.toggleBookmark(item);
                                setState(() {}); // Individual clear hobe
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text("Remove", style: TextStyle(color: Colors.red)),
                            ),
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

  // All clear dialog
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("সব মুছুন?"),
        content: const Text("আপনি কি সব বুকমার্ক ডিলিট করতে চান?"),
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