import 'package:flutter/material.dart';
import 'package:habit_tracker/pages/stats_page.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import 'add_habit_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
        ],
      ),

      //  Alışkanlık listesi
      body: habitProvider.habits.isEmpty
          ? const Center(
              child: Text(
                "Henüz alışkanlık eklenmedi 💤",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: habitProvider.habits.length,
              itemBuilder: (context, index) {
                final habit = habitProvider.habits[index];
                final today = DateTime.now();
                final isCompletedToday = habit.completedDays.any(
                  (date) =>
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day,
                );

                return Dismissible(
                  key: ValueKey(habit.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.redAccent.withOpacity(0.8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Sil",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    habitProvider.deleteHabit(habit.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("'${habit.habitName}' silindi"),
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(habit.habitName),
                        subtitle: Text(
                          "Oluşturulma: ${habit.createdAt.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isCompletedToday
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isCompletedToday
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            habitProvider.toggleHabitCompletion(habit);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

      //  Yeni sayfaya yönlendiren buton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
