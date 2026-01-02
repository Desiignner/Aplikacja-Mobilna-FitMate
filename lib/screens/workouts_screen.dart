import 'package:fitmate/models/plan.dart';
import 'package:fitmate/models/friend.dart';
import 'package:fitmate/screens/active_workout_screen.dart';
import 'package:fitmate/screens/create_plan_screen.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';

import 'package:fitmate/models/shared_plan.dart';
import 'package:flutter/material.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final AppDataService _appData = AppDataService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _appData.loadPlans();
    await _appData.loadSharedPlans();
    await _appData.loadFriendsAndRequests();
    if (mounted) setState(() {});
  }

  Future<void> _navigateAndAddPlan() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatePlanScreen()),
    );
    if (result is Plan) {
      await _appData.addPlan(result);
      setState(() {});
    }
  }

  Future<void> _editPlan(Plan plan) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => CreatePlanScreen(planToEdit: plan)),
    );

    // If result is Plan, it means it was saved.
    // If null, user cancelled.
    if (result is Plan) {
      // The Plan object is already mutated in CreatePlanScreen's save method
      // if passed by reference, but we might want to ensure it's saved/reloaded in AppDataService
      // For now, assuming in-memory update is sufficient for local list,
      // but let's force a reload or update call if needed.
      await _appData.updatePlan(
          result); // We need to ensure this method exists or addPlan handles updates?
      // Creating updatePlan in AppDataService might be safer.
      // Checking AppDataService shows addPlan just adds to list.
      // We should verify if we need a specific update method.
      // For mock/local, modifying the object reference might reflect directly,
      // but explicitly handling it is better.
      setState(() {});
    }
  }

  void _startWorkout(Plan plan) async {
    final newWorkout = await _appData.scheduleWorkout(plan, DateTime.now());
    if (!mounted) return;

    final bool? workoutFinished = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (context) => ActiveWorkoutScreen(workout: newWorkout)),
    );

    if (workoutFinished == true && mounted) {
      await _appData.completeWorkout(newWorkout, context);
      setState(() {});
    }
  }

  void _deletePlan(Plan plan) async {
    await _appData.deletePlan(plan);
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${plan.name}' deleted."),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await _appData.addPlan(plan);
              setState(() {});
            }),
      ),
    );
  }

  void _confirmAndDeletePlan(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title:
            const Text('Delete Plan?', style: TextStyle(color: Colors.white)),
        content: Text(
            'Are you sure you want to delete "${plan.name}"? This cannot be undone.',
            style: const TextStyle(color: secondaryTextColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePlan(plan);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _sharePlan(Plan plan) {
    showDialog(
      context: context,
      builder: (context) => _SharePlanDialog(plan: plan),
    );
  }

  void _startSharedWorkout(SharedPlan sharedPlan) async {
    // Show simple loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Loading plan...'), duration: Duration(seconds: 1)),
    );

    final plan = await _appData.getPlan(sharedPlan.planId);
    if (!mounted) return;

    if (plan != null) {
      _startWorkout(plan);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load plan. It might have been deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Plans'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Plans'),
              Tab(text: 'Shared Plans'),
            ],
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: secondaryTextColor,
          ),
          actions: [
            IconButton(
                onPressed: _navigateAndAddPlan,
                icon: const Icon(Icons.add, color: primaryColor, size: 30)),
          ],
        ),
        body: TabBarView(
          children: [
            _buildMyPlansTab(),
            _buildSharedPlansTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPlansTab() {
    final allPlans = _appData.plans;
    if (allPlans.isEmpty) {
      return const Center(
          child: Text('No workout plans yet.\nPress "+" to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontSize: 18)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPlans.length,
      itemBuilder: (context, index) {
        final plan = allPlans[index];
        return _WorkoutPlanCard(
          plan: plan,
          onStart: () => _startWorkout(plan),
          onShare: () => _sharePlan(plan),
          onEdit: () => _editPlan(plan),
          onDelete: () => _confirmAndDeletePlan(plan),
        );
      },
    );
  }

  Widget _buildSharedPlansTab() {
// ... (omitted shared plans code for brevity, it remains unchanged) ...
// But I need to hit the _WorkoutPlanCard definition too.
// I will split this into two ReplacementChunks if needed or use MultiReplace.
// Actually, I can just replace the usage in _buildMyPlansTab first,
// wait, I need to update the Class definition of _WorkoutPlanCard as well.
// I will use replace_file_content for the usage first, but I need to be careful about the range.
// Let's use multi_replace to do both usage and definition.

    return AnimatedBuilder(
      animation: Listenable.merge([
        _appData.sharedPlans,
        _appData.sharedByMePlans,
        _appData.pendingSharedPlans,
        _appData.sentSharedPlans,
        _appData.friends,
      ]),
      builder: (context, _) {
        final incomingAccepted = _appData.sharedPlans.value;
        final incomingPending = _appData.pendingSharedPlans.value;
        final outgoingAccepted = _appData.sharedByMePlans.value;
        final outgoingPending = _appData.sentSharedPlans.value;
        final friendsList = _appData.friends.value;

        if (incomingAccepted.isEmpty &&
            incomingPending.isEmpty &&
            outgoingAccepted.isEmpty &&
            outgoingPending.isEmpty) {
          return const Center(
            child: Text('No shared plans properly.',
                style: TextStyle(color: secondaryTextColor)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- SHARED TO (Outgoing) ---
            if (outgoingPending.isNotEmpty || outgoingAccepted.isNotEmpty) ...[
              const Text('Shared To (My Shares)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...outgoingPending.map((plan) => _SharedPlanItem(
                    sharedPlan: plan,
                    displaySenderName: _resolveName(
                        plan.receiverId, plan.receiverName, friendsList),
                    isPending: true, // Pending outgoing
                    isOutgoing: true,
                    onRemove: () => _appData.removeSharedPlan(plan.id),
                  )),
              ...outgoingAccepted.map((plan) => _SharedPlanItem(
                    sharedPlan: plan,
                    displaySenderName: _resolveName(
                        plan.receiverId, plan.receiverName, friendsList),
                    isPending: false,
                    isOutgoing: true,
                    onRemove: () => _appData.removeSharedPlan(plan.id),
                  )),
              const Divider(color: secondaryTextColor),
              const SizedBox(height: 10),
            ],

            // --- SHARED WITH ME (Incoming) ---
            if (incomingPending.isNotEmpty || incomingAccepted.isNotEmpty) ...[
              const Text('Shared With Me',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Pending first
              ...incomingPending.map((plan) => _SharedPlanItem(
                    sharedPlan: plan,
                    displaySenderName: _resolveName(
                        plan.senderId, plan.senderName, friendsList),
                    isPending: true,
                    isOutgoing: false,
                    onRespond: (accept) =>
                        _appData.respondToSharedPlan(plan.id, accept),
                  )),
              // Accepted
              ...incomingAccepted.map((plan) => _SharedPlanItem(
                    sharedPlan: plan,
                    displaySenderName: _resolveName(
                        plan.senderId, plan.senderName, friendsList),
                    isPending: false,
                    isOutgoing: false,
                    onStart: () => _startSharedWorkout(plan),
                    // No remove button for accepted incoming as per user request ("tylko odpalenia")
                  )),
            ],
          ],
        );
      },
    );
  }

  String _resolveName(
      String userId, String fallbackName, List<Friend> friends) {
    if (fallbackName != 'Unknown' && fallbackName.isNotEmpty) {
      return fallbackName;
    }
    try {
      final friend = friends.firstWhere((f) => f.id == userId,
          orElse: () => Friend(id: '', username: ''));
      if (friend.username.isNotEmpty) {
        return friend.username;
      }
    } catch (_) {}
    return fallbackName;
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onStart;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WorkoutPlanCard(
      {required this.plan,
      required this.onStart,
      required this.onShare,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final description = plan.description.isNotEmpty
        ? plan.description
        : "${plan.exercises.length} exercises";
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(plan.name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: primaryColor),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: primaryColor),
                      onPressed: onShare,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description,
                style:
                    const TextStyle(color: secondaryTextColor, fontSize: 16)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: mainBackgroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12)),
                child: const Text('Start Workout',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedPlanItem extends StatelessWidget {
  final SharedPlan sharedPlan;
  final String?
      displaySenderName; // This is now just "DisplayName" (sender or receiver)
  final bool isPending;
  final bool isOutgoing;
  final Function(bool)? onRespond;
  final VoidCallback? onRemove;
  final VoidCallback? onStart;

  const _SharedPlanItem(
      {required this.sharedPlan,
      required this.isPending,
      required this.isOutgoing,
      this.displaySenderName,
      this.onRespond,
      this.onRemove,
      this.onStart});

  @override
  Widget build(BuildContext context) {
    String subtitleText;
    if (isOutgoing) {
      subtitleText = 'To: ${displaySenderName ?? sharedPlan.receiverName}';
      if (!isPending) {
        subtitleText +=
            '\nShared: ${sharedPlan.created.toString().split(' ')[0]}';
      } else {
        subtitleText += '\nStatus: Pending';
      }
    } else {
      subtitleText = 'From: ${displaySenderName ?? sharedPlan.senderName}';
      if (!isPending) {
        subtitleText +=
            '\nAccepted: ${sharedPlan.created.toString().split(' ')[0]}';
      }
    }

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(sharedPlan.planName,
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitleText,
            style: const TextStyle(color: secondaryTextColor)),
        trailing: _buildTrailingActions(),
      ),
    );
  }

  Widget _buildTrailingActions() {
    if (isPending && !isOutgoing) {
      // Incoming Pending: Accept/Decline
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => onRespond?.call(true),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => onRespond?.call(false),
          ),
        ],
      );
    }

    // Outgoing or Accepted Incoming
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onStart != null)
          IconButton(
            icon: const Icon(Icons.play_arrow, color: primaryColor),
            onPressed: onStart,
          ),
        if (onRemove != null)
          IconButton(
            icon: Icon(Icons.delete,
                color: isOutgoing ? Colors.redAccent : Colors.grey),
            onPressed: onRemove,
          ),
      ],
    );
  }
}

class _SharePlanDialog extends StatefulWidget {
  final Plan plan;
  const _SharePlanDialog({required this.plan});

  @override
  State<_SharePlanDialog> createState() => _SharePlanDialogState();
}

class _SharePlanDialogState extends State<_SharePlanDialog> {
  final AppDataService _appData = AppDataService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final friends = _appData.friends.value;

    return AlertDialog(
      backgroundColor: cardBackgroundColor,
      title: Text('Share "${widget.plan.name}"',
          style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: friends.isEmpty
            ? const Text('You have no friends yet.',
                style: TextStyle(color: secondaryTextColor))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                          friend.username.isNotEmpty
                              ? friend.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(friend.username,
                        style: const TextStyle(color: Colors.white)),
                    trailing: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            icon: const Icon(Icons.send, color: primaryColor),
                            onPressed: () async {
                              setState(() => _loading = true);
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await _appData.sharePlan(
                                    widget.plan.id, friend.id);
                                if (mounted) {
                                  navigator.pop();
                                  messenger.showSnackBar(SnackBar(
                                      content: Text(
                                          'Shared with ${friend.username}')));
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _loading = false);
                                  messenger.showSnackBar(
                                      SnackBar(content: Text('Failed: $e')));
                                }
                              }
                            },
                          ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: primaryColor)),
        ),
      ],
    );
  }
}
