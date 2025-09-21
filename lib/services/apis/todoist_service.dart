import 'dart:convert';
import 'package:gymvision/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodoistService {
  static const String url = 'https://api.todoist.com/api/v1/sync';
  static const List<String> uiTesterPhrases = [
    'ospuuq',
    'fzelzz',
  ];

  static Future<bool> createTask(String title, String description, String name, bool isBug) async {
    try {
      if (uiTesterPhrases.contains(title)) return true;

      final requestUuid = const Uuid().v4();
      final tempId = const Uuid().v4();

      final apiToken = dotenv.env['TODOIST_API_KEY'];
      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      if (name.isNotEmpty) {
        title = '${name.capitalize()} - $title';
      }

      request.body =
          'commands=[{"type": "item_add","uuid": "${requestUuid.toString()}","temp_id": "${tempId.toString()}","args": {"project_id": "6M54c44jm5c5P8p9","section_id": "6Xv7m8gpVG6CW24h","content": ${jsonEncode(title)},"description": ${jsonEncode(description)},"labels": ${isBug ? '["bug"]' : '[]'}}}]';

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
