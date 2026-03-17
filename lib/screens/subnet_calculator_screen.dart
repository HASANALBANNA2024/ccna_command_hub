import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ccna_command_hub/services/subnet_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';


class SubnetCalculatorScreen extends StatefulWidget {
  const SubnetCalculatorScreen({super.key});
  @override
  State<SubnetCalculatorScreen> createState() => _SubnetCalculatorScreenState();
}

class _SubnetCalculatorScreenState extends State<SubnetCalculatorScreen> with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  late AnimationController _controller;
  final TextEditingController _ipController = TextEditingController(text: "192.168.1.1");
  int _cidr = 24;
  bool isIPv4 = true;
  SubnetResult? result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _calculate();
  }

  void _calculate() {
    if (_ipController.text.isEmpty) return; // খালি থাকলে ক্যালকুলেট করবে না

    setState(() {
      if (isIPv4) {
        result = SubnetLogic.calculateIPv4(_ipController.text, _cidr);
      } else {
        // অবশ্যই calculateIPv6 কল করতে হবে
        result = SubnetLogic.calculateIPv6(_ipController.text, _cidr);
      }
    });
  }

  void _checkIfSaved() async {
    // আপনার টাইটেল ফরম্যাট অনুযায়ী এটি চেক করবে
    String currentTitle = "Subnet: ${_ipController.text}/$_cidr";
    bool saved = await BookmarkService.isBookmarked(currentTitle);

    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }


  @override
  void dispose()
  {
    _controller.dispose();
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color scaffoldBg = isDark ? const Color(0xFF0F172A) : Colors.blue.shade50;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.blue.shade900, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Subnet Calculator", style: TextStyle(color: isDark ? Colors.white : Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  _buildProtocolToggle(isDark),
                  const SizedBox(height: 15),
                  _buildInputCard(isDark),
                  const SizedBox(height: 15),
                  if (result != null) _buildResultCard(isDark),
                  const SizedBox(height: 15),
                  _buildActionButtons(isDark),
                  if (isIPv4)
                      _buildBlockListToggle(isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolToggle(bool isDark) {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _toggleBtn("IPv4", isIPv4, isDark, () {
            setState(() {
              isIPv4 = true;
              _cidr = 24;
              _ipController.text = "192.168.1.1"; // ডিফল্ট IPv4
              _calculate();
            });
          }),
          _toggleBtn("IPv6", !isIPv4, isDark, () {
            setState(() {
              isIPv4 = false;
              _cidr = 64;
              _ipController.text = "2001:db8::1"; // ডিফল্ট IPv6 উদাহরণ
              _calculate();
            });
          }),
        ],
      ),
    );
  }

  Widget _toggleBtn(String title, bool active, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: active ? Colors.blueAccent : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Text(title, style: TextStyle(color: active ? Colors.white : (isDark ? Colors.white54 : Colors.blue.shade700), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.blue.shade100),
      ),
      child: Column(
        children: [
          TextField(
            controller: _ipController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: "IP Address / CIDR",
              labelStyle: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
              isDense: true,
            ),
            onChanged: (v) => _calculate(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Prefix", style: TextStyle(color: isDark ? Colors.white70 : Colors.blueGrey, fontSize: 14)),
              Text("/$_cidr", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
            child: Slider(
              value: _cidr.toDouble(), min: 1, max: isIPv4 ? 32 : 128, divisions: isIPv4 ? 31 : 127,
              activeColor: Colors.blueAccent,
              onChanged: (v) { setState(() => _cidr = v.toInt()); _calculate(); },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black45 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.blue.shade50),
      ),
      child: Column(
        children: [
          _resRow("Network Address", result!.networkAddress, isDark ? Colors.white : Colors.black),
          _resRow("Broadcast Address", result!.broadcastAddress, isDark ? Colors.orangeAccent : Colors.black),
          _resRow("Usable Range", result!.hostRange, isDark ? Colors.greenAccent : Colors.black),
          const Divider(height: 15, thickness: 1),
          _resRow("Subnet Mask", result!.subnetMask, isDark ? Colors.blueGrey : Colors.black),
          _resRow("Block Size", "${result!.blockSize}", isDark ? Colors.purpleAccent : Colors.black),
          _resRow("Total Hosts", result!.totalHosts, isDark ? Colors.white : Colors.black),
          _resRow("Usable Hosts", result!.usableHosts, isDark ? Colors.white70 : Colors.black87),
        ],
      ),
    );
  }

  Widget _resRow(String label, String val, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          Expanded(child: Text(val, textAlign: TextAlign.right, style: TextStyle(color: valColor, fontWeight: FontWeight.w900, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        // শেয়ার বাটন
        Expanded(
          child: _actionBtn(
            Icons.share_rounded,
            "Share",
            isDark,
            _shareSubnetData,
            color: Colors.blueAccent, // শেয়ার বাটনের জন্য ডিফল্ট নীল
          ),
        ),
        const SizedBox(width: 10),
        // বুকমার্ক বাটন
        Expanded(
          child: _actionBtn(
            _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            _isSaved ? "Bookmarked" : "Bookmark",
            isDark,
                () async {
              if (result == null) return;

              // ডাটা গোছানো (সুন্দর ফরম্যাট)
              Map<String, dynamic> subnetData = {
                "title": "Subnet: ${_ipController.text}/$_cidr",
                "IP Address": _ipController.text,
                "Network ID": "➜ ${result!.networkAddress}",
                "Broadcast IP": "➜ ${result!.broadcastAddress}",
                "Usable Range": "➜ ${result!.hostRange}",
                "Subnet Mask": "➜ ${result!.subnetMask}",
                "Total Hosts": "➜ ${result!.totalHosts}",
                "Protocol": isIPv4 ? "IPv4" : "IPv6",
              };

              if (isIPv4) {
                var blocks = SubnetLogic.getAllBlocks(_ipController.text, _cidr);
                String formattedBlocks = "";
                for (int i = 0; i < blocks.length; i++) {
                  formattedBlocks += "📍 Block-${(i + 1).toString().padLeft(2, '0')}:\n"
                      "   • Net: ${blocks[i]['net']}\n"
                      "   • Broad: ${blocks[i]['broad']}\n\n";
                }
                if (formattedBlocks.isNotEmpty) {
                  subnetData["--- ALL SUBNET BLOCKS ---"] = "\n$formattedBlocks";
                }
              }

              // সেভ বা রিমুভ টগল করা
              await BookmarkService.toggleBookmark(subnetData);

              // স্টেট চেক করে বাটন আপডেট করা
              _checkIfSaved();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isSaved ? "বুকমার্ক থেকে সরানো হয়েছে!" : "বুকমার্কে সেভ করা হয়েছে!"),
                    backgroundColor: _isSaved ? Colors.redAccent : Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            // বুকমার্ক করা থাকলে কমলা (Orange), না থাকলে নীল (Blue) দেখাবে
            color: _isSaved ? Colors.orange.shade700 : Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, bool isDark, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
        ),
        style: ElevatedButton.styleFrom(
          // যদি বাইরে থেকে কালার দেওয়া হয় তবে সেটি নিবে, না হলে ডিফল্ট blueAccent
          backgroundColor: color ?? Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // একটু অ্যানিমেশন ইফেক্ট যোগ করা হয়েছে
          shadowColor: (color ?? Colors.blueAccent).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildBlockListToggle(bool isDark) {
    var blocks = isIPv4 ? SubnetLogic.getAllBlocks(_ipController.text, _cidr) : [];
    return Container(
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(isDark ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        iconColor: Colors.blueAccent,
        title: const Text("VIEW ALL SUBNET BLOCKS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)),
        children: blocks.map((b) => Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.black38 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _blockCol("NETWORK", b['net'] ?? "-", Colors.blueAccent),
                  _blockCol("BROADCAST", b['broad'] ?? "-", Colors.orangeAccent),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Subnet Mask: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(b['mask'] ?? "-", style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _blockCol(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _shareSubnetData() {
    if (result == null) return;
    var blocks = isIPv4 ? SubnetLogic.getAllBlocks(_ipController.text, _cidr) : [];

    String blockText = "";
    for (var i = 0; i < (blocks.length > 20 ? 20 : blocks.length); i++) {
      blockText += "\nBlock ${i+1}: Net: ${blocks[i]['net']} | Broad: ${blocks[i]['broad']}";
    }

    String report = "📊 Subnetting Report: ${_ipController.text}/$_cidr\n"
        "--------------------------\n"
        "Net ID: ${result!.networkAddress}\n"
        "Broadcast: ${result!.broadcastAddress}\n"
        "Mask: ${result!.subnetMask}\n"
        "Range: ${result!.hostRange}\n"
        "Total Hosts: ${result!.totalHosts}\n"
        "--------------------------\n"
        "🌐 ALL SUBNET BLOCKS:$blockText\n"
        "--------------------------\n"
        "Generated by CCNA Command Hub";
    Share.share(report);
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(painter: WaterPainter(_controller.value, isDark), child: Container()),
    );
  }
}

class WaterPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  WaterPainter(this.animationValue, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent.withOpacity(isDark ? 0.12 : 0.08)..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.88);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, size.height * 0.88 + math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 8);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: isDark ? [const Color(0xFF0F172A), Colors.blue.shade900.withOpacity(0.6)] : [Colors.blue.shade50, Colors.blue.shade100],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}