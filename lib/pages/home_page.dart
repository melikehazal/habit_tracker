import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/pages/stats_page.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import 'add_habit_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade100,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Habit Tracker",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            Text(
              DateFormat('EEEE, dd MMMM', 'tr_TR').format(today),
              style: const TextStyle(
                fontSize: 13,
                color: Color.fromARGB(255, 60, 59, 59),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
        ],
      ),

      // 🔹 Alışkanlık listesi
      body: habitProvider.habits.isEmpty
          ? const Center(
              child: Text(
                "Henüz alışkanlık eklenmedi 💤",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: habitProvider.habits.length,
              itemBuilder: (context, index) {
                final habit = habitProvider.habits[index];
                final todayDate = DateTime(today.year, today.month, today.day);
                final habitStart = DateTime(
                  habit.createdAt.year,
                  habit.createdAt.month,
                  habit.createdAt.day,
                );

                final hasStarted =
                    habitStart.isBefore(todayDate) ||
                    _isSameDay(habitStart, todayDate);
                final isCompletedToday = habit.completedDays.any(
                  (date) => _isSameDay(date, todayDate),
                );

                return Dismissible(
                  key: ValueKey(habit.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.delete_forever, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          "Sil",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Emin misin?"),
                        content: Text(
                          "'${habit.habitName}' alışkanlığını silmek istediğine emin misin?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Vazgeç"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Sil"),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    habitProvider.deleteHabit(habit.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "'${habit.habitName}' başarıyla silindi 🗑️",
                        ),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: "Geri Al",
                          onPressed: () {
                            habitProvider.addHabit(
                              habit.habitName,
                              habit.createdAt,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: hasStarted ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        habit.habitName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: hasStarted
                              ? Colors.black
                              : Colors.grey.shade500,
                        ),
                      ),
                      subtitle: Text(
                        "Başlangıç: ${DateFormat('dd MMM yyyy').format(habit.createdAt)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: hasStarted
                              ? Colors.black54
                              : Colors.grey.shade500,
                        ),
                      ),
                      trailing: hasStarted
                          ? IconButton(
                              icon: Icon(
                                isCompletedToday
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isCompletedToday
                                    ? Colors.green
                                    : Colors.grey,
                                size: 28,
                              ),
                              onPressed: () {
                                habitProvider.toggleHabitCompletion(habit);
                              },
                            )
                          : const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                              size: 24,
                            ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple.shade100,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Alışkanlık"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitPage()),
          );
        },
      ),
    );
  }
}
