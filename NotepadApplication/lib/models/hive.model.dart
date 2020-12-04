import 'package:hive/hive.dart';
part "hive.model.g.dart";

@HiveType(typeId : 1)
class HiveNote {

  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String date;

  @HiveField(3)
  int priority;

  @HiveField(4)
  String description;


  HiveNote(this.id, this.title, this.date, this.priority, [this.description]);

}