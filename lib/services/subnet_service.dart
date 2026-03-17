import 'dart:math';

class SubnetResult {
  final String networkAddress, broadcastAddress, hostRange, totalHosts, usableHosts, subnetMask, wildcardMask, cidr;
  final int blockSize, totalSubnets;

  SubnetResult({
    required this.networkAddress, required this.broadcastAddress, required this.hostRange,
    required this.totalHosts, required this.usableHosts, required this.subnetMask,
    required this.wildcardMask, required this.cidr, required this.blockSize, required this.totalSubnets,
  });

  factory SubnetResult.empty() => SubnetResult(
    networkAddress: "-", broadcastAddress: "-", hostRange: "-", totalHosts: "-",
    usableHosts: "-", subnetMask: "-", wildcardMask: "-", cidr: "-", blockSize: 0, totalSubnets: 0,
  );
}

class SubnetLogic {
  // IPv4 Calculation Logic
  static SubnetResult calculateIPv4(String input, int prefix) {
    try {
      String ip = input.contains('/') ? input.split('/')[0] : input;
      int finalPrefix = input.contains('/') ? (int.tryParse(input.split('/')[1]) ?? prefix) : prefix;

      List<int> ipParts = ip.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      if (ipParts.length != 4) return SubnetResult.empty();

      int ipInt = (ipParts[0] << 24) | (ipParts[1] << 16) | (ipParts[2] << 8) | ipParts[3];
      int mask = (finalPrefix == 0) ? 0 : (0xFFFFFFFF << (32 - finalPrefix)) & 0xFFFFFFFF;
      int networkInt = ipInt & mask;
      int numHosts = pow(2, 32 - finalPrefix).toInt();
      int broadcastInt = (networkInt + numHosts - 1) & 0xFFFFFFFF;

      return SubnetResult(
        networkAddress: _intToIp(networkInt),
        broadcastAddress: _intToIp(broadcastInt),
        hostRange: finalPrefix >= 31 ? "Point-to-Point" : "${_intToIp(networkInt + 1)} - ${_intToIp(broadcastInt - 1)}",
        totalHosts: "$numHosts",
        usableHosts: "${finalPrefix >= 31 ? (finalPrefix == 32 ? 1 : 2) : numHosts - 2}",
        subnetMask: _intToIp(mask),
        wildcardMask: _intToIp(~mask & 0xFFFFFFFF),
        cidr: "/$finalPrefix",
        blockSize: numHosts,
        totalSubnets: 0,
      );
    } catch (e) { return SubnetResult.empty(); }
  }

  // IPv6 Calculation Logic (নতুন যোগ করা হয়েছে)
  static SubnetResult calculateIPv6(String input, int prefix) {
    try {
      String ip = input.contains('/') ? input.split('/')[0].trim() : input.trim();
      int finalPrefix = input.contains('/') ? (int.tryParse(input.split('/')[1]) ?? prefix) : prefix;

      // IPv6 parsing using shorthand expansion
      String fullIP = _expandIPv6(ip);
      List<String> segments = fullIP.split(':');

      // Calculate Network Address
      List<String> networkSegments = [];
      int bitsToKeep = finalPrefix;

      for (String segment in segments) {
        int val = int.parse(segment, radix: 16);
        if (bitsToKeep >= 16) {
          networkSegments.add(segment);
          bitsToKeep -= 16;
        } else if (bitsToKeep > 0) {
          int mask = (0xFFFF << (16 - bitsToKeep)) & 0xFFFF;
          networkSegments.add((val & mask).toRadixString(16).padLeft(4, '0'));
          bitsToKeep = 0;
        } else {
          networkSegments.add("0000");
        }
      }

      String networkAddr = _compressIPv6(networkSegments.join(':'));

      return SubnetResult(
        networkAddress: networkAddr,
        broadcastAddress: "N/A (Multicast)",
        hostRange: "::1 to ffff:ffff:ffff:ffff",
        totalHosts: "2^${128 - finalPrefix}",
        usableHosts: "Huge (Interface ID)",
        subnetMask: "Prefix Length: /$finalPrefix",
        wildcardMask: "N/A",
        cidr: "/$finalPrefix",
        blockSize: 0,
        totalSubnets: 0,
      );
    } catch (e) {
      return SubnetResult.empty();
    }
  }

  static String _intToIp(int i) => "${(i >> 24) & 0xFF}.${(i >> 16) & 0xFF}.${(i >> 8) & 0xFF}.${i & 0xFF}";

  // IPv6 Expansion Helper
  static String _expandIPv6(String ip) {
    if (ip.contains('::')) {
      int count = 8 - ip.split(':').where((s) => s.isNotEmpty).length;
      ip = ip.replaceFirst('::', ':' + ('0000:' * count));
    }
    return ip.split(':').map((s) => s.isEmpty ? "0000" : s.padLeft(4, '0')).join(':');
  }

  // IPv6 Compression Helper
  static String _compressIPv6(String ip) {
    return ip.replaceAll(RegExp(r'(^|:)(0000(:0000)+)($|:)'), '::').replaceAll(RegExp(r'\b0{1,3}'), '');
  }

  static List<Map<String, String>> getAllBlocks(String input, int prefix) {
    List<Map<String, String>> blocks = [];
    try {
      String ip = input.contains('/') ? input.split('/')[0] : input;
      int finalPrefix = input.contains('/') ? (int.tryParse(input.split('/')[1]) ?? prefix) : prefix;

      List<int> ipParts = ip.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      int ipInt = (ipParts[0] << 24) | (ipParts[1] << 16) | (ipParts[2] << 8) | ipParts[3];
      int numHosts = pow(2, 32 - finalPrefix).toInt();
      int mask = (finalPrefix == 0) ? 0 : (0xFFFFFFFF << (32 - finalPrefix)) & 0xFFFFFFFF;
      int baseNetwork = ipInt & mask;

      for (int i = 0; i < 20; i++) {
        int net = (baseNetwork + (i * numHosts)) & 0xFFFFFFFF;
        blocks.add({
          "net": _intToIp(net),
          "broad": _intToIp((net + numHosts - 1) & 0xFFFFFFFF),
          "mask": _intToIp(mask),
        });
      }
    } catch (e) { }
    return blocks;
  }
}