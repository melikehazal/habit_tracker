import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(title: const Text("İstatistikler"), centerTitle: true),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                "Henüz istatistik gösterecek alışkanlık yok 💤",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return _buildHabitCard(context, habitProvider, habit);
              },
            ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildHabitCard(
    BuildContext context,
    HabitProvider provider,
    Habit habit,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Eğer alışkanlık henüz başlamadıysa (gelecekteyse)
    final hasStarted =
        habit.createdAt.isBefore(today) || _isSameDay(habit.createdAt, today);

    // Haftanın günleri: Pazartesi -> Pazar
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final weekDays = List.generate(
      7,
      (i) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i),
    );

    final dateFormat = DateFormat('E', 'tr_TR');
    final completedCount = weekDays
        .where((d) => habit.completedDays.any((c) => _isSameDay(c, d)))
        .length;
    final completionRate = completedCount / 7;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      color: hasStarted ? Colors.purple.shade50 : Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.habitName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hasStarted ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            if (!hasStarted)
              Text(
                "Bu alışkanlık henüz başlamadı ",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

            if (hasStarted) ...[
              //  Gün daireleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays.map((day) {
                  final isFuture = day.isAfter(today);
                  final isDone = habit.completedDays.any(
                    (d) => _isSameDay(d, day),
                  );
                  final isToday = _isSameDay(day, today);

                  Color circleColor;
                  if (isFuture) {
                    circleColor = Colors.grey.shade300; //  gelecek gün
                  } else if (isDone) {
                    circleColor = Colors.green; //  tamamlandı
                  } else {
                    circleColor = Colors.grey.shade400; //  geçmiş ama yapılmadı
                  }

                  return GestureDetector(
                    onTap: hasStarted && isToday
                        ? () async {
                            await provider.toggleHabitCompletionForDate(
                              habit,
                              day,
                            );
                          }
                        : null, //  sadece bugünkü aktif
                    child: Opacity(
                      opacity: isFuture ? 0.4 : 1.0,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: circleColor,
                              shape: BoxShape.circle,
                              border: isToday
                                  ? Border.all(
                                      color: Colors.deepPurple,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                dateFormat.format(day).substring(0, 2),
                                style: TextStyle(
                                  color: isFuture
                                      ? Colors.black45
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM').format(day),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Haftalık ilerleme: ${(completionRate * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
