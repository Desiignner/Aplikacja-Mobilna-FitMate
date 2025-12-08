import 'package:fitmate/models/goal.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:flutter/material.dart';

class GoalsCard extends StatefulWidget {
  const GoalsCard({super.key});

  @override
  State<GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends State<GoalsCard> {
  final AppDataService _appData = AppDataService();

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    String selectedEmoji = '🎯';
    final List<String> emojis = [
      '🎯',
      '💧',
      '💤',
      '🥗',
      '🧘',
      '🏃',
      '🏋️',
      '🍎',
      '📅',
      '🚫',
      '📖',
      '💡'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardBackgroundColor,
          title: const Text('Add Goal', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  labelStyle: TextStyle(color: secondaryTextColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondaryTextColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Icon',
                    style: TextStyle(color: secondaryTextColor)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((emoji) {
                  final isSelected = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                            color:
                                isSelected ? primaryColor : Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(emoji,
                          style: isSelected
                              ? const TextStyle(fontSize: 24)
                              : const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _appData.addGoal(titleController.text, selectedEmoji);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Goals',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              GestureDetector(
                onTap: _showAddGoalDialog,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: primaryColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<Goal>>(
            valueListenable: _appData.goals,
            builder: (context, goals, child) {
              if (goals.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No goals set yet. Add one!',
                        style: TextStyle(color: secondaryTextColor)),
                  ),
                );
              }
              return Column(
                children: goals.map((goal) => _buildGoalItem(goal)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Goal goal) {
    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _appData.removeGoal(goal.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.redAccent.withValues(alpha: 0.2),
        child: const Icon(Icons.delete, color: Colors.redAccent),
      ),
      child: GestureDetector(
        onTap: () => _appData.toggleGoalCompletion(goal.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: goal.isCompleted
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: goal.isCompleted ? Colors.green : Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(goal.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration:
                        goal.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white54,
                  ),
                ),
              ),
              if (goal.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[600], size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
