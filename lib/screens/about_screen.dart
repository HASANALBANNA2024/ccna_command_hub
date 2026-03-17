import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/share_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ডার্ক মোড চেক
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ১. প্রিমিয়াম ডায়নামিক ব্যাকগ্রাউন্ড (Light/Dark adaptive)
          _buildAnimatedBackground(isDark),

          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // ২. প্রফেশনাল প্রোফাইল
                          _buildPremiumProfile(isDark),
                          const SizedBox(height: 30),

                          // ৩. মিশন এবং ভিশন
                          _buildSectionTitle("Our Mission & Vision", isDark),
                          _buildMissionVisionCard(isDark),
                          const SizedBox(height: 25),

                          // ৪. উদ্দেশ্য সেকশন
                          _buildSectionTitle("The Purpose", isDark),
                          _buildPurposeCard(isDark),
                          const SizedBox(height: 25),

                          // ৫. ফিউচার রোডম্যাপ
                          _buildSectionTitle("Future Roadmap", isDark),
                          _buildRoadmapCard(isDark),
                          const SizedBox(height: 30),

                          // ৬. অ্যাকশন বাটন গ্রিড
                          _buildActionGrid(isDark),

                          const SizedBox(height: 50),
                          // ৭. ডায়নামিক ফুটার এবং পার্সোনাল মেসেজ
                          _buildFooter(isDark),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI মডিউলসমূহ ---

  Widget _buildCustomAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // ১. ব্যাক বাটন (বামে থাকবে)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
          ),

          // ২. টাইটেলকে সেন্টারে আনার ম্যাজিক
          Expanded(
            child: Container(
              // ব্যাক বাটনের উইডথ অনুযায়ী ডানপাশে অফসেট দেওয়া হয়েছে
              // যাতে টাইটেলটি একদম স্ক্রিনের মাঝখানে থাকে
              margin: const EdgeInsets.only(right: 40),
              child: Text(
                "The Hub Info",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProfile(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 5,
                  )
                ],
              ),
            ),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white12,
              backgroundImage: AssetImage('assets/images/Developer_image.jpg'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          "MD. Hasan Al Banna",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          "Full-Stack Developer & Network Architect",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.blueAccent.shade200 : Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildMissionVisionCard(bool isDark) {
    return _glassContainer(
      isDark,
      child: Column(
        children: [
          _rowInfo(
            Icons.rocket_launch_rounded,
            "Our Mission",
            "To bridge the gap between complex networking theory and practical application for students globally.",
            isDark,
          ),
          Divider(height: 30, color: isDark ? Colors.white10 : Colors.black12),
          _rowInfo(
            Icons.visibility_rounded,
            "Our Vision",
            "Becoming the #1 decentralized learning hub for Cisco aspirants and networking enthusiasts.",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeCard(bool isDark) {
    return _glassContainer(
      isDark,
      child: Text(
        "CCNA Command Hub was born out of a necessity to simplify subnetting and command memorization. "
            "We focus on high-speed logic and interactive UI to make learning feel like a game, not a chore.",
        style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black87
        ),
      ),
    );
  }

  Widget _buildRoadmapCard(bool isDark) {
    return _glassContainer(
      isDark,
      child: Column(
        children: [
          _roadmapStep("Q3 2026", "AI-Powered Subnetting Tutor integration.", isDark),
          _roadmapStep("Q4 2026", "Multiplayer Quiz Battle Mode launch.", isDark),
          _roadmapStep("2027", "Expansion to CCNP and Security mastery modules.", isDark),
        ],
      ),
    );
  }

  Widget _roadmapStep(String date, String plan, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(5)),
            child: Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  plan,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  )
              )
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(bool isDark) {
    return Row(
      children: [
        Expanded(child: _actionCard(Icons.share_rounded, "Share App", isDark, () => ShareService.shareApp())),
        const SizedBox(width: 15),
        Expanded(child: _actionCard(Icons.alternate_email_rounded, "Contact Me", isDark, () {})),
      ],
    );
  }

  // --- হেল্পার উইজেটস ---

  Widget _glassContainer(bool isDark, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _rowInfo(IconData icon, String title, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  )
              ),
              const SizedBox(height: 5),
              Text(
                  desc,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.4
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionCard(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.blueAccent.withOpacity(0.1) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 28),
            const SizedBox(height: 8),
            Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF020617), const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD), const Color(0xFFF0F9FF)],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        // ১. আপনার পার্সোনাল ইংলিশ মেসেজ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "\"I built this tool to make your CCNA journey easier. Success is just one command away!\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 15),
        Icon(Icons.more_horiz, color: Colors.blueAccent.withOpacity(0.3)),
        const SizedBox(height: 15),

        // ২. আল-কুরআনের আয়াত
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                "\"নিশ্চয় কষ্টের সাথেই স্বস্তি রয়েছে।\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "— সূরা আল-ইনশিরাহ, আয়াত: ০৬",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // ৩. ডেভেলপার সিগনেচার (Handcrafted...)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code_rounded, size: 14, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(width: 6),
            Text(
              "Handcrafted with 🚀 by Hasan Al Banna",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ৪. অ্যাপ ভার্সন এবং বিল্ড ইনফো (যা আপনি খুঁজছিলেন)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Build 2026.03 • CCNA Hub",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white12 : Colors.black26,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}