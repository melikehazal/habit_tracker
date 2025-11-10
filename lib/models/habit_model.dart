import 'package:isar/isar.dart';

part 'habit_model.g.dart'; // isar için gerekli (otomatik üretilecek dosya)

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String habitName;
  late DateTime createdAt; //oluşturulma tarihi
  List<DateTime> completedDays = [];

  Habit({
    required this.habitName,
    required this.createdAt,
    required this.completedDays,
  });
}
