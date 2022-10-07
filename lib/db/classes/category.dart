class Category {
  int? id;
  final String name;
  String? emoji;

  Category({this.id, required this.name, this.emoji});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'emoji': emoji};

  String getDisplayName() => emoji == null ? name : '$emoji $name';
}