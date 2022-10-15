class FlavourText {
  int? id;
  String message;

  FlavourText({this.id, required this.message});

  Map<String, dynamic> toMap() => {
        'id': id,
        'message': message,
      };
}
