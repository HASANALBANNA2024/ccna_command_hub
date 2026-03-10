class ModuleModel {
  final String id;
  final String name;
  final bool isUnlocked;
  final String desc;
  final List<dynamic> subModules;

  ModuleModel({
    required this.id,
    required this.name,
    required this.isUnlocked,
    required this.desc,
    required this.subModules,
});
  
  factory ModuleModel.fromJson(Map<String,dynamic> json)
  {
    return ModuleModel(
        id: json['id'],
        name: json['name'],
        isUnlocked: json['isUnlocked'] ?? false,
        desc: json['desc'] ?? "",
      subModules: json['subModules'] as List<dynamic>? ?? [],

    );
  }
}