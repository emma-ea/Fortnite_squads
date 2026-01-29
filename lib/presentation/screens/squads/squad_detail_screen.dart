import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/squad/squad_bloc.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../../domain/entities/squad_member.dart';

class SquadDetailScreen extends StatefulWidget {
  final String squadId;

  const SquadDetailScreen({super.key, required this.squadId});

  @override
  State<SquadDetailScreen> createState() => _SquadDetailScreenState();
}

class _SquadDetailScreenState extends State<SquadDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SquadBloc>().add(LoadSquadDetails(widget.squadId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SquadBloc, SquadState>(
      builder: (context, state) {
        if (state is SquadLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is SquadError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }

        if (state is SquadDetailsLoaded) {
          final squad = state.squad;
          final members = state.members;
          final isLeader = state.isLeader;

          return Scaffold(
            appBar: AppBar(
              title: Text(squad.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to Settings/Edit Squad
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // --- Header ---
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: squad.avatarUrl != null
                            ? NetworkImage(squad.avatarUrl!)
                            : null,
                        child: squad.avatarUrl == null
                            ? const Icon(Icons.shield, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        squad.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (squad.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            squad.description!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('Members', '${squad.currentSize}/${squad.maxSize}'),
                          _buildStatItem('Status', squad.isPublic ? 'Public' : 'Private'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- Action Buttons ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Chat',
                          icon: Icons.chat_bubble,
                          onPressed: () {
                            context.push(
                              '/squads/${squad.id}/chat',
                              extra: {'name': squad.name},
                            );
                          },
                        ),
                      ),
                      if (isLeader) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Invite',
                            icon: Icons.person_add,
                            backgroundColor: Colors.grey[800],
                            onPressed: () {
                              // Show Invite Bottom Sheet
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(),

                // --- Member List ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Roster',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                Expanded(
                  child: members.isEmpty
                      ? const EmptyStateWidget(message: "No members loaded.")
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return _MemberTile(
                              member: members[index],
                              isLeaderView: isLeader,
                              onKick: (userId) {
                                context.read<SquadBloc>().add(
                                      RemoveMemberRequested(
                                        squadId: squad.id,
                                        userId: userId,
                                      ),
                                    );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final SquadMember member;
  final bool isLeaderView;
  final Function(String) onKick;

  const _MemberTile({
    required this.member,
    required this.isLeaderView,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = member.isOnline;
    
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: member.profilePictureUrl != null
                ? NetworkImage(member.profilePictureUrl!)
                : null,
            child: member.profilePictureUrl == null 
                ? Text(member.username[0].toUpperCase()) 
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(member.username),
      subtitle: Text(member.role, style: const TextStyle(fontSize: 12)),
      trailing: isLeaderView && member.role != 'LEADER'
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => onKick(member.userId),
            )
          : null,
    );
  }
}