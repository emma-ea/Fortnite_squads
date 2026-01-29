import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/squad/squad_bloc.dart';
import '../../widgets/common/empty_state_widget.dart'; // Helper widget

class SquadsListScreen extends StatefulWidget {
  const SquadsListScreen({super.key});

  @override
  State<SquadsListScreen> createState() => _SquadsListScreenState();
}

class _SquadsListScreenState extends State<SquadsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load initial data
    context.read<SquadBloc>().add(LoadMySquads());
    // Hardcoded region for now - in real app, get from UserBloc
    context.read<SquadBloc>().add(DiscoverSquadsRequested('NA-East'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squad Finder'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Squads'),
            Tab(text: 'Discover'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/squads/create'), // Trigger Phase 3.3.1
          )
        ],
      ),
      body: BlocBuilder<SquadBloc, SquadState>(
        builder: (context, state) {
          if (state is SquadLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SquadError) {
            return Center(child: Text(state.message));
          }

          if (state is SquadLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildSquadList(state.mySquads, isMySquad: true),
                _buildSquadList(state.discoverableSquads, isMySquad: false),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSquadList(List<dynamic> squads, {required bool isMySquad}) {
    if (squads.isEmpty) {
      return EmptyStateWidget(
        message: isMySquad 
            ? "You haven't joined any squads yet." 
            : "No open squads found in your region.",
        icon: Icons.group_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: squads.length,
      itemBuilder: (context, index) {
        final squad = squads[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: squad.avatarUrl != null 
                  ? NetworkImage(squad.avatarUrl!) 
                  : null,
              child: squad.avatarUrl == null ? const Icon(Icons.shield) : null,
            ),
            title: Text(squad.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${squad.currentSize}/${squad.maxSize} Members • ${squad.tags.join(", ")}'),
            trailing: isMySquad 
                ? const Icon(Icons.chat_bubble_outline) 
                : ElevatedButton(
                    onPressed: () {
                      // Logic to join/request join [Source 44]
                    },
                    child: const Text('Join'),
                  ),
            onTap: () => context.go('/squads/${squad.id}'),
          ),
        );
      },
    );
  }
}