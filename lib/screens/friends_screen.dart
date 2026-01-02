import 'package:fitmate/api/api_client.dart';
import 'package:fitmate/models/friend.dart';
import 'package:fitmate/models/friend_request.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final AppDataService _appData = AppDataService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _appData.loadFriendsAndRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: mainBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Friends'),
          bottom: const TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: secondaryTextColor,
            tabs: [
              Tab(text: 'My Friends'),
              Tab(text: 'Requests'),
              Tab(text: 'Find Friends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyFriendsTab(),
            _buildRequestsTab(),
            _buildFindFriendsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyFriendsTab() {
    return ValueListenableBuilder<List<Friend>>(
      valueListenable: _appData.friends,
      builder: (context, friends, child) {
        if (friends.isEmpty) {
          return const Center(
            child: Text(
              'No friends yet.',
              style: TextStyle(color: secondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    friend.username.isNotEmpty
                        ? friend.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: primaryColor),
                  ),
                ),
                title: Text(
                  friend.username,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: friend.fullName != null
                    ? Text(friend.fullName!,
                        style: const TextStyle(color: secondaryTextColor))
                    : null,
                trailing: IconButton(
                  icon:
                      const Icon(Icons.person_remove, color: Colors.redAccent),
                  onPressed: () => _confirmRemoveFriend(friend),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incoming Requests',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<FriendRequest>>(
            valueListenable: _appData.incomingRequests,
            builder: (context, requests, child) {
              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text('No incoming requests.',
                      style: TextStyle(color: secondaryTextColor)),
                );
              }
              return Column(
                children: requests
                    .map((req) => _buildIncomingRequestItem(req))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text('Outgoing Requests',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ValueListenableBuilder<List<FriendRequest>>(
            valueListenable: _appData.outgoingRequests,
            builder: (context, requests, child) {
              if (requests.isEmpty) {
                return const Text('No outgoing requests.',
                    style: TextStyle(color: secondaryTextColor));
              }
              return Column(
                children: requests
                    .map((req) => _buildOutgoingRequestItem(req))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestItem(FriendRequest request) {
    return AppCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: cardBackgroundColor,
              child: Icon(Icons.person, color: secondaryTextColor),
            ),
            title: Text(
              request.senderName,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              DateFormat('yyyy-MM-dd').format(request.created),
              style: const TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    _appData.respondToFriendRequest(request.id, false),
                child: const Text('Reject',
                    style: TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    _appData.respondToFriendRequest(request.id, true),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child:
                    const Text('Accept', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingRequestItem(FriendRequest request) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: cardBackgroundColor,
          child: Icon(Icons.person_outline, color: secondaryTextColor),
        ),
        title: Text(
          request.receiverName != null
              ? 'To: ${request.receiverName}'
              : 'To: Unknown (ID: ${request.receiverId ?? "N/A"})',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          DateFormat('yyyy-MM-dd').format(request.created),
          style: const TextStyle(color: secondaryTextColor, fontSize: 12),
        ),
        trailing: const Icon(Icons.hourglass_empty, color: primaryColor),
      ),
    );
  }

  Widget _buildFindFriendsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search User',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter username',
              hintStyle: const TextStyle(color: secondaryTextColor),
              filled: true,
              fillColor: cardBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: primaryColor),
                onPressed: _sendRequest,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter the exact username of the user you want to add.',
            style: TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest() async {
    if (_searchController.text.isEmpty) return;
    try {
      await _appData.sendFriendRequest(_searchController.text);
      _searchController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
      }
    } catch (e) {
      String message = 'Failed to send request: $e';
      if (e is ApiException) {
        if (e.statusCode == 404) {
          message = 'User does not exist';
        } else if (e.statusCode == 400 &&
            e.toString().toLowerCase().contains('already in progress')) {
          message = 'Invitation pending'; // User friendly message
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  Future<void> _confirmRemoveFriend(Friend friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title:
            const Text('Remove Friend', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove ${friend.username}?',
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _appData.removeFriend(friend.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed ${friend.username}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove: $e')),
          );
        }
      }
    }
  }
}
