import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// Mock team member model
class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarLetter;
  final Color avatarColor;
  final bool isOnline;

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarLetter,
    required this.avatarColor,
    this.isOnline = false,
  });
}

// Mock shared vault model
class SharedVault {
  final String id;
  final String name;
  final int passwordCount;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;

  SharedVault({
    required this.id,
    required this.name,
    required this.passwordCount,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
  });
}

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<TeamMember> _teamMembers = [
    TeamMember(
      id: '1',
      name: 'John Doe',
      email: 'john@company.com',
      role: 'Admin',
      avatarLetter: 'JD',
      avatarColor: AppColors.purple,
      isOnline: true,
    ),
    TeamMember(
      id: '2',
      name: 'Sarah Wilson',
      email: 'sarah@company.com',
      role: 'Member',
      avatarLetter: 'SW',
      avatarColor: AppColors.blue,
      isOnline: true,
    ),
    TeamMember(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@company.com',
      role: 'Member',
      avatarLetter: 'MJ',
      avatarColor: AppColors.green,
      isOnline: false,
    ),
    TeamMember(
      id: '4',
      name: 'Emily Brown',
      email: 'emily@company.com',
      role: 'Viewer',
      avatarLetter: 'EB',
      avatarColor: AppColors.yellow,
      isOnline: false,
    ),
  ];

  final List<SharedVault> _sharedVaults = [
    SharedVault(
      id: '1',
      name: 'Development Tools',
      passwordCount: 12,
      memberIds: ['1', '2', '3'],
      createdBy: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SharedVault(
      id: '2',
      name: 'Marketing Accounts',
      passwordCount: 8,
      memberIds: ['1', '4'],
      createdBy: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    SharedVault(
      id: '3',
      name: 'Client Credentials',
      passwordCount: 5,
      memberIds: ['1', '2', '3', '4'],
      createdBy: 'Sarah Wilson',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: 'Team ',
                style: TextStyle(color: AppColors.purple),
              ),
              TextSpan(text: 'Hub'),
            ],
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.purple,
          labelColor: AppColors.purple,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Members'),
            Tab(text: 'Shared Vaults'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(isDark),
          _buildSharedVaultsTab(isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showInviteDialog(context);
          } else {
            _showCreateVaultDialog(context);
          }
        },
        backgroundColor: AppColors.purple,
        icon: Icon(
          _tabController.index == 0 ? Icons.person_add : Icons.add,
          color: Colors.white,
        ),
        label: Text(
          _tabController.index == 0 ? 'Invite' : 'New Vault',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMembersTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple,
                AppColors.purple.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${_teamMembers.length}', 'Members'),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatItem('${_teamMembers.where((m) => m.isOnline).length}', 'Online'),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatItem('${_sharedVaults.length}', 'Vaults'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Members List
        Text(
          'Team Members',
          style: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...(_teamMembers.map((member) => _buildMemberCard(member, isDark))),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(TeamMember member, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: member.avatarColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    member.avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (member.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(member.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(member.role),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit Role'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, size: 20, color: AppColors.red),
                    const SizedBox(width: 12),
                    const Text('Remove', style: TextStyle(color: AppColors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              // Handle action
              _showComingSoon();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSharedVaultsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Shared vaults allow you to securely share passwords with your team members.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Vaults List
        Text(
          'Shared Vaults',
          style: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...(_sharedVaults.map((vault) => _buildVaultCard(vault, isDark))),
      ],
    );
  }

  Widget _buildVaultCard(SharedVault vault, bool isDark) {
    final members = _teamMembers.where((m) => vault.memberIds.contains(m.id)).toList();

    return GestureDetector(
      onTap: () => _showComingSoon(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_shared, color: AppColors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vault.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${vault.passwordCount} passwords',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                // Member Avatars
                SizedBox(
                  width: 80,
                  height: 28,
                  child: Stack(
                    children: [
                      for (int i = 0; i < members.take(3).length; i++)
                        Positioned(
                          left: i * 20.0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: members[i].avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                members[i].avatarLetter[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (members.length > 3)
                        Positioned(
                          left: 60,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${members.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'by ${vault.createdBy}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppColors.purple;
      case 'Member':
        return AppColors.blue;
      case 'Viewer':
        return AppColors.green;
      default:
        return Colors.grey;
    }
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add, color: AppColors.purple),
            ),
            const SizedBox(width: 12),
            const Text('Invite Team Member'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'member', child: Text('Member')),
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              ],
              onChanged: (_) {},
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
              Navigator.pop(context);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder, color: AppColors.purple),
            ),
            const SizedBox(width: 12),
            const Text('Create Shared Vault'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Vault Name',
                prefixIcon: const Icon(Icons.folder_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
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
              Navigator.pop(context);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        backgroundColor: AppColors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
