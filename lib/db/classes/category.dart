class Category {
  int? id;
  final String name;

  Category({this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
