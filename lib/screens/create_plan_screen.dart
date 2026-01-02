import 'package:fitmate/models/exercise.dart';
import 'package:fitmate/models/set_details.dart';
import 'package:fitmate/models/plan.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreatePlanScreen extends StatefulWidget {
  final Plan? planToEdit;

  const CreatePlanScreen({super.key, this.planToEdit});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _planNameController;
  late TextEditingController _planTypeController;
  late TextEditingController _planDescriptionController;

  final List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.planToEdit != null) {
      _planNameController =
          TextEditingController(text: widget.planToEdit!.name);
      _planTypeController =
          TextEditingController(text: widget.planToEdit!.type);
      _planDescriptionController =
          TextEditingController(text: widget.planToEdit!.description);

      _exercises.addAll(widget.planToEdit!.exercises.map((ex) => Exercise(
            name: ex.name,
            rest: ex.rest,
            sets: ex.sets
                .map((s) => SetDetails(reps: s.reps, weight: s.weight))
                .toList(),
          )));
    } else {
      _planNameController = TextEditingController();
      _planTypeController = TextEditingController();
      _planDescriptionController = TextEditingController();
      _addExercise();
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(sets: [SetDetails()]));
    });
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final sets = _exercises[exerciseIndex].sets;
      if (sets.isNotEmpty) {
        final lastSet = sets.last;
        sets.add(SetDetails(reps: lastSet.reps, weight: lastSet.weight));
      } else {
        sets.add(SetDetails());
      }
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() => _exercises[exerciseIndex].sets.removeAt(setIndex));
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.planToEdit != null) {
        widget.planToEdit!.name = _planNameController.text;
        widget.planToEdit!.type = _planTypeController.text;
        widget.planToEdit!.description = _planDescriptionController.text;
        widget.planToEdit!.exercises = _exercises;
        Navigator.of(context).pop(widget.planToEdit);
      } else {
        final newPlan = Plan(
          id: const Uuid().v4(),
          name: _planNameController.text,
          type: _planTypeController.text,
          description: _planDescriptionController.text,
          exercises: _exercises,
        );
        Navigator.of(context).pop(newPlan);
      }
    }
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _planTypeController.dispose();
    _planDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.planToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Training Plan' : 'New Training Plan'),
        actions: [
          IconButton(
              icon: const Icon(Icons.save, color: primaryColor),
              onPressed: _savePlan),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CustomTextField(
                  controller: _planNameController, label: 'Plan name'),
              const SizedBox(height: 16),
              _CustomTextField(
                  controller: _planTypeController,
                  label: 'Type (e.g. FBW, Push/Pull)'),
              const SizedBox(height: 16),
              _CustomTextField(
                  controller: _planDescriptionController,
                  label: 'Short description',
                  maxLines: 3),
              const SizedBox(height: 24),
              const Text('Exercises',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return _ExerciseCard(
                    key: ValueKey(_exercises[index]),
                    exercise: _exercises[index],
                    onDelete: () => _removeExercise(index),
                    onAddSet: () => _addSet(index),
                    onDeleteSet: (setIndex) => _removeSet(index, setIndex),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, color: primaryColor),
                  label: const Text('Add Exercise',
                      style: TextStyle(color: primaryColor)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final VoidCallback onAddSet;
  final Function(int) onDeleteSet;

  const _ExerciseCard(
      {super.key,
      required this.exercise,
      required this.onDelete,
      required this.onAddSet,
      required this.onDeleteSet});

  @override
  State<_ExerciseCard> createState() => __ExerciseCardState();
}

class __ExerciseCardState extends State<_ExerciseCard> {
  bool _setsVisible = true;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: const Text('Delete Exercise?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'Are you sure you want to delete this exercise? This cannot be undone.',
            style: TextStyle(color: secondaryTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: _CustomTextField(
                        initialValue: widget.exercise.name,
                        label: 'Exercise Name',
                        onSaved: (val) => widget.exercise.name = val ?? '')),
                const SizedBox(width: 16),
                SizedBox(
                    width: 80,
                    child: _CustomTextField(
                        initialValue: widget.exercise.rest.toString(),
                        label: 'Rest (s)',
                        keyboardType: TextInputType.number,
                        onSaved: (val) => widget.exercise.rest =
                            int.tryParse(val ?? '60') ?? 60)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () =>
                        setState(() => _setsVisible = !_setsVisible),
                    child: Text(_setsVisible ? 'Hide sets' : 'Show sets',
                        style: const TextStyle(color: secondaryTextColor))),
                TextButton(
                    onPressed: () =>
                        setState(() => _setsVisible = !_setsVisible),
                    child: Text(_setsVisible ? 'Hide sets' : 'Show sets',
                        style: const TextStyle(color: secondaryTextColor))),
              ],
            ),
            if (_setsVisible) ...[
              const SizedBox(height: 8),
              for (int i = 0; i < widget.exercise.sets.length; i++)
                _SetRow(
                    key: ValueKey(widget.exercise.sets[i]),
                    set: widget.exercise.sets[i],
                    setNumber: i + 1,
                    onDelete: () => widget.onDeleteSet(i)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                  onPressed: widget.onAddSet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: secondaryTextColor))),
            ],
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final SetDetails set;
  final int setNumber;
  final VoidCallback onDelete;

  const _SetRow(
      {super.key,
      required this.set,
      required this.setNumber,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
              child: _CustomTextField(
                  initialValue: set.reps.toString(),
                  label: 'Reps (set $setNumber)',
                  keyboardType: TextInputType.number,
                  onSaved: (val) => set.reps = int.tryParse(val ?? '0') ?? 0)),
          const SizedBox(width: 16),
          Expanded(
              child: _CustomTextField(
                  initialValue: set.weight.toString(),
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  onSaved: (val) =>
                      set.weight = double.tryParse(val ?? '0.0') ?? 0.0)),
          const SizedBox(width: 8),
          IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;
  final FormFieldSetter<String>? onSaved;

  const _CustomTextField(
      {this.controller,
      this.initialValue,
      required this.label,
      this.maxLines = 1,
      this.keyboardType = TextInputType.text,
      this.onSaved});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onSaved: onSaved,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryTextColor),
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (controller != null && (value == null || value.isEmpty)) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}
