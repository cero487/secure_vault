import 'package:hive/hive.dart';


part 'notes.g.dart';

@HiveType(typeId: 1)
class Notes {
  Notes({
    required this.title,
    required this.content,
  });
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;
}