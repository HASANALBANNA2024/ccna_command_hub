import 'package:flutter/material.dart';
import 'package:ccna_command_hub/models/module_model.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';
import 'package:ccna_command_hub/services/search_service.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final List<ModuleModel> allModules;

  GlobalSearchDelegate(this.allModules);

  @override
  ThemeData appBarTheme(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade700,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (query.isEmpty) {
      return StatefulBuilder(
        builder: (context, setState) {
          return FutureBuilder<Map<String, List<String>>>(
            future: SearchService.getSearchData(),
            builder: (context, snapshot) {
              final recent = snapshot.data?['recent'] ?? [];
              final popular = snapshot.data?['popular'] ?? [];

              return Container(
                color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // --- Recent Searches Section ---
                    if (recent.isNotEmpty) ...[
                      _sectionHeader("Recent Searches", Icons.history_rounded, Colors.blueAccent, () async {
                        await SearchService.clearRecent();
                        setState(() {});
                      }),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: recent.map((s) => _customChip(s, Colors.blue.shade100, Colors.blue.shade800, () {
                          query = s;
                          showResults(context);
                        })).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // --- Popular Topics Section (With Clear Option) ---
                    _sectionHeader("Popular Topics", Icons.auto_awesome_rounded, Colors.orangeAccent, () async {
                      await SearchService.clearPopular();
                      setState(() {});
                    }),
                    const SizedBox(height: 12),
                    if (popular.isEmpty)
                      _emptyState("No Popular Search!")
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: popular.map((s) => _customChip(s, Colors.orange.shade100, Colors.orange.shade900, () {
                          query = s;
                          showResults(context);
                        })).toList(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
    return _buildSearchResults(context);
  }

  // --- UI Helper Widgets ---
  Widget _sectionHeader(String title, IconData icon, Color color, VoidCallback? onClear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
        if (onClear != null)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.redAccent),
            label: const Text("Clear", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          )
      ],
    );
  }

  Widget _customChip(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    List<Map<String, dynamic>> results = [];
    for (var module in allModules) {
      for (var sub in module.subModules) {
        String title = sub['title']?.toString() ?? "";
        if (title.toLowerCase().contains(query.toLowerCase()) ||
            module.name.toLowerCase().contains(query.toLowerCase())) {
          results.add({'module': module, 'sub': sub});
        }
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final res = results[index];
        final String fullName = res['sub']['title'] ?? "Untitled";

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withOpacity(0.1),
              child: Icon(Icons.terminal_rounded, color: Colors.indigo.shade700),
            ),
            title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text("Module: ${res['module'].name}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {
              SearchService.saveSearch(fullName);
              close(context, null);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubModuleScreen(
                    moduleId: res['module'].id,
                    moduleName: res['module'].name,
                    subModules: res['module'].subModules,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}