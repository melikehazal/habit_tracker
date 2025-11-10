import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    if (habits.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Henüz istatistik gösterecek alışkanlık yok ",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("İstatistikler"), centerTitle: true),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return _buildHabitStatsCard(habit);
        },
      ),
    );
  }

  Widget _buildHabitStatsCard(Habit habit) {
    final startDate = habit.createdAt;
    final now = DateTime.now();

    // Eğer oluşturulma tarihi bugünden sonraysa (ileriye tarih seçilmişse), durumu koruyalım
    if (startDate.isAfter(now)) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.habitName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text("Henüz başlamadı ⏳"),
            ],
          ),
        ),
      );
    }

    // ✅ oluşturulma tarihinden itibaren bugüne kadar geçen günleri hesapla
    final totalDays = now.difference(startDate).inDays + 1;
    final shownDays = totalDays < 7 ? totalDays : 7;

    // 📆 oluşturulma tarihinden itibaren gösterilecek günleri üret
    final days = List.generate(
      shownDays,
      (i) => startDate.add(Duration(days: i)),
    );

    final dateFormat = DateFormat('E');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.habitName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isDone = habit.completedDays.any(
                  (d) =>
                      d.year == day.year &&
                      d.month == day.month &&
                      d.day == day.day,
                );

                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isDone ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(day),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
