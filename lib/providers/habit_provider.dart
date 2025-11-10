import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/habit_database.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  List<Habit> get habits => _habits; //dışardan erişim için

  Future<void> loadHabits() async {
    _habits = await HabitDatabase.getAllHabits();
    notifyListeners(); //UI güncelle
  }

  Future<void> addHabit(String habitName, DateTime createdAt) async {
    final newHabit = Habit(
      habitName: habitName,
      createdAt: createdAt,
      completedDays: [],
    );
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open([HabitSchema], directory: dir.path);
    await isar.writeTxn(() => isar.habits.put(newHabit));
    await isar.close();

    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await HabitDatabase.deleteHabit(id);
    await loadHabits();
  }

  //günlük tamamlanma durumunu değiştir
  Future<void> toggleHabitCompletion(Habit habit) async {
    final today = DateTime.now();
    final isCompletedToday = habit.completedDays.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    ); //Tamamlanmış günler listesinde bugünün tarihi var mı?

    if (isCompletedToday) {
      //eğer bugun zaten tamamlanmışsa bugunun tamamlanmasını kaldır
      habit.completedDays.removeWhere(
        (date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day,
      );
    } else {
      //bugunu tamamlanmış olarak ekle
      habit.completedDays.add(today);
    }

    await HabitDatabase.updateHabit(habit);
    await loadHabits();
  }
}
