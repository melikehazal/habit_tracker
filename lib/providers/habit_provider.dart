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
    await HabitDatabase.addHabit(newHabit);
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await HabitDatabase.deleteHabit(id);
    await loadHabits();
  }

  //günlük tamamlanma durumunu değiştir
  Future<void> toggleHabitCompletion(Habit habit) async {
    final today = DateTime.now();
    print("🔄 ${habit.habitName} toggle ediliyor - Bugün: $today");

    final isCompletedToday = habit.completedDays.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );

    if (isCompletedToday) {
      habit.completedDays.removeWhere(
        (date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day,
      );
      print("🟡 ${habit.habitName} bugünkü tamamlanma kaldırıldı");
    } else {
      habit.completedDays.add(today);
      print("🟢 ${habit.habitName} bugünkü tamamlanma eklendi");
    }

    await HabitDatabase.updateHabit(habit);
    print("✅ ${habit.habitName} güncellendi: ${habit.completedDays}");

    await loadHabits(); // UI'ı yenile
  }

  Future<void> toggleHabitCompletionForDate(Habit habit, DateTime day) async {
    final isCompleted = habit.completedDays.any(
      (date) =>
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day,
    );

    if (isCompleted) {
      habit.completedDays.removeWhere(
        (date) =>
            date.year == day.year &&
            date.month == day.month &&
            date.day == day.day,
      );
    } else {
      habit.completedDays.add(day);
    }

    await HabitDatabase.updateHabit(habit);
    await loadHabits();
  }
}
