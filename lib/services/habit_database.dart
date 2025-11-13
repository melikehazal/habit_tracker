import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/habit_model.dart';

class HabitDatabase {
  static late Isar _isar;

  //veritabanını başlat
  static Future<void> initialize() async {
    print(" Isar başlatılıyor...");
    final dir = await getApplicationDocumentsDirectory();
    print(" Path alındı: ${dir.path}");

    _isar = await Isar.open([HabitSchema], directory: dir.path);
    print("✅ Isar veritabanı başarıyla açıldı.");
  }

  //tüm alışkanlıkları getir
  static Future<List<Habit>> getAllHabits() async {
    return await _isar.habits.where().findAll();
  }

  //yeni alışkanlık ekle
  static Future<void> addHabit(Habit habit) async {
    await _isar.writeTxn(() async {
      await _isar.habits.put(habit);
    });
  }

  //Güncelle
  static Future<void> updateHabit(Habit habit) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.habits.put(habit);
      });
      print("💾 Güncelleme başarılı: ${habit.habitName}");
    } catch (e) {
      print("❌ Güncelleme hatası: $e");
    }
  }

  //Sil

  static Future<void> deleteHabit(int id) async {
    await _isar.writeTxn(() async {
      _isar.habits.delete(id);
    });
  }
}
