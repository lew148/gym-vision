import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodoistService {
  static const String url = 'https://api.todoist.com/api/v1/sync';
  static const List<String> uiTesterPhrases = [
    'ospuuq',
    'fzelzz',
    'akqndp',
  ];

  static const String _projectId = '6f4676JVMm8w5Xvp';
  static const String _bugTag = 'Bug';

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

      if (name.isNotEmpty) description = description.isEmpty ? name : '$name: $description';

      request.body =
          'commands=[{"type": "item_add","uuid": "${requestUuid.toString()}","temp_id": "${tempId.toString()}","args": {"project_id": "$_projectId","content": ${jsonEncode(title)},"description": ${jsonEncode(description)},"labels": ${isBug ? '["$_bugTag"]' : '[]'}}}]';

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
