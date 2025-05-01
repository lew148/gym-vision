abstract class DatabaseObject {
  int? id;
  DateTime? updatedAt;
  DateTime? createdAt;

  DatabaseObject({
    this.id,
    this.updatedAt,
    this.createdAt,
  });

  Map<String, dynamic> toMap();
}
