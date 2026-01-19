import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/auth_provider.dart';
import '../vault/add_password_screen.dart';
import '../vaults/vaults_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

// Team Model
class Team {
  final String id;
  final String name;
  final String code;
  final String createdBy;

  Team({
    required this.id,
    required this.name,
    required this.code,
    required this.createdBy,
  });
}

// Team member model
class TeamMember {
  final String id;
  final String name;
  final String email;
  String role;
  final String avatarLetter;
  final Color avatarColor;
  final bool isOnline;
  final List<String> accessibleFiles; // IDs of files they can access

  TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarLetter,
    required this.avatarColor,
    this.isOnline = false,
    this.accessibleFiles = const [],
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
  bool _isInTeam = false;
  Team? _currentTeam;
  String _currentUserId = '1'; // Mocking current user as 'John Doe' (Admin)

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
      accessibleFiles: ['all'],
    ),
    TeamMember(
      id: '2',
      name: 'Sarah Wilson',
      email: 'sarah@company.com',
      role: 'Editor',
      avatarLetter: 'SW',
      avatarColor: AppColors.blue,
      isOnline: true,
      accessibleFiles: ['1', '3'],
    ),
    TeamMember(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@company.com',
      role: 'Viewer',
      avatarLetter: 'MJ',
      avatarColor: AppColors.green,
      isOnline: false,
      accessibleFiles: ['2'],
    ),
  ];

  final List<SharedVault> _sharedVaults = [
    SharedVault(
      id: '1',
      name: 'Development Tools',
      passwordCount: 12,
      memberIds: ['1', '2'],
      createdBy: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SharedVault(
      id: '2',
      name: 'Marketing Accounts',
      passwordCount: 8,
      memberIds: ['1', '3'],
      createdBy: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    SharedVault(
      id: '3',
      name: 'Client Credentials',
      passwordCount: 5,
      memberIds: ['1', '2'],
      createdBy: 'Sarah Wilson',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  int _selectedNavIndex = 2;
  String? _username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final username = await ref.read(apiServiceProvider).getUsername();
    if (mounted) {
      setState(() => _username = username);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createTeam(String name) {
    setState(() {
      _currentTeam = Team(
        id: 'team_1',
        name: name,
        code: 'VX-789-Z2',
        createdBy: _currentUserId,
      );
      _isInTeam = true;
    });
  }

  void _joinTeam(String code) {
    if (code.trim().toUpperCase() == 'VX-789-Z2') {
      setState(() {
        _currentTeam = Team(
          id: 'team_1',
          name: 'Main Dev Team',
          code: code.toUpperCase(),
          createdBy: '2',
        );
        _isInTeam = true;
      });
    } else {
      _showError('Invalid team code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    if (!_isInTeam) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, themeNotifier, isDark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildNoTeamScreen(isDark),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // We use our custom header in the body/Sliver
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, themeNotifier, isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.syne(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Team ',
                              style: TextStyle(color: AppColors.purple),
                            ),
                            TextSpan(
                              text: _currentTeam?.name ?? 'Hub',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: _currentTeam?.code ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Team code copied!')),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Code: ${_currentTeam?.code}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.purple.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy,
                                size: 10, color: AppColors.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_currentTeam?.createdBy == _currentUserId)
                        _buildIconButton(
                          context,
                          icon: Icons.settings_outlined,
                          onTap: () => _showTeamSettings(context, isDark),
                        ),
                      const SizedBox(width: 12),
                      _buildIconButton(
                        context,
                        icon: Icons.logout,
                        color: AppColors.red,
                        onTap: () {
                          setState(() {
                            _isInTeam = false;
                            _currentTeam = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.purple,
              labelColor: AppColors.purple,
              unselectedLabelColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              tabs: const [
                Tab(text: 'Members'),
                Tab(text: 'Vaults'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersTab(isDark),
                  _buildSharedVaultsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100), // Avoid bottom nav overlap
        child: FloatingActionButton.extended(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeNotifier themeNotifier, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: 'Vault',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.purple),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildIconButton(
                context,
                icon: isDark ? Icons.light_mode : Icons.dark_mode,
                onTap: () => themeNotifier.toggleTheme(),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  _buildIconButton(
                    context,
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (_username ?? 'User').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap, Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 2,
          ),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightTextPrimary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Home', 0),
          _buildNavItem(context, Icons.lock, 'Vaults', 1),
          _buildAddButton(context),
          _buildNavItem(context, Icons.people, 'Team', 2),
          _buildNavItem(context, Icons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (index == _selectedNavIndex) return;
          switch (index) {
            case 0: // Home
              Navigator.pop(context);
              break;
            case 1: // Vaults
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VaultsScreen()),
              );
              break;
            case 3: // Settings
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.purple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNoTeamScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_work_outlined,
                size: 80,
                color: AppColors.purple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Collaborate with your Team',
              style: GoogleFonts.syne(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create a workspace for your organization or join an existing one to share passwords securely.',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildLargeActionButton(
              icon: Icons.add_circle_outline,
              title: 'Create a New Team',
              subtitle: 'Start a fresh workspace for your members',
              onTap: () => _showCreateTeamDialog(context),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildLargeActionButton(
              icon: Icons.group_add_outlined,
              title: 'Join with Invitation',
              subtitle: 'Enter a unique code to join a team',
              onTap: () => _showJoinTeamDialog(context),
              isDark: isDark,
              isSecondary: true,
            ),
            const SizedBox(height: 24), // Extra padding at bottom for scroll
          ],
        ),
      ),
    );
  }

  Widget _buildLargeActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSecondary
              ? (isDark
                  ? AppColors.darkBgSecondary
                  : AppColors.lightBgSecondary)
              : AppColors.purple,
          borderRadius: BorderRadius.circular(20),
          border: isSecondary
              ? Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 2)
              : null,
          boxShadow: isSecondary
              ? null
              : [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSecondary
                    ? AppColors.purple.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSecondary ? AppColors.purple : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSecondary
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary)
                          : Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSecondary
                          ? (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isSecondary
                  ? AppColors.purple.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
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
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.purpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${_teamMembers.length}', 'Members'),
              _buildDivider(),
              _buildStatItem(
                  '${_teamMembers.where((m) => m.isOnline).length}', 'Online'),
              _buildDivider(),
              _buildStatItem('${_sharedVaults.length}', 'Vaults'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Team Members',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...(_teamMembers.map((member) => _buildMemberCard(member, isDark))),
      ],
    );
  }

  Widget _buildDivider() => Container(
      width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2));

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.syne(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(TeamMember member, bool isDark) {
    final isAdmin = _currentTeam?.createdBy == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(member, isDark),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.id == _currentUserId
                      ? '${member.name} (You)'
                      : member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  member.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildRoleChip(member.role),
          if (isAdmin && member.id != _currentUserId)
            IconButton(
              icon: const Icon(Icons.shield_outlined, size: 20),
              onPressed: () => _showRoleAssignment(context, member, isDark),
              tooltip: 'Manage Access',
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TeamMember member, bool isDark) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: member.avatarColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: member.avatarColor, width: 2),
          ),
          child: Center(
            child: Text(
              member.avatarLetter,
              style: TextStyle(
                color: member.avatarColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
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
                  color: isDark
                      ? AppColors.darkBgSecondary
                      : AppColors.lightBgSecondary,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    Color color = AppColors.purple;
    if (role == 'Viewer') color = AppColors.green;
    if (role == 'Editor') color = AppColors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSharedVaultsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...(_sharedVaults.map((vault) => _buildVaultCard(vault, isDark))),
      ],
    );
  }

  Widget _buildVaultCard(SharedVault vault, bool isDark) {
    final members =
        _teamMembers.where((m) => vault.memberIds.contains(m.id)).toList();
    final hasAccess = members.any((m) => m.id == _currentUserId);

    return Opacity(
      opacity: hasAccess ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.folder_shared, color: AppColors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vault.name,
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${vault.passwordCount} Items Shared',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasAccess)
                  const Icon(Icons.lock_outline, color: AppColors.red, size: 20)
                else
                  const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            if (!hasAccess)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Access restricted by manager',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.red.withValues(alpha: 0.8)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    String teamName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Workspace',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: TextField(
          autofocus: true,
          onChanged: (v) => teamName = v,
          decoration: const InputDecoration(
            hintText: 'Enter team name',
            prefixIcon: Icon(Icons.business_center),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (teamName.isNotEmpty) {
                _createTeam(teamName);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinTeamDialog(BuildContext context) {
    String code = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Team',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: TextField(
          autofocus: true,
          onChanged: (v) => code = v,
          decoration: const InputDecoration(
            hintText: 'Enter 8-digit unique code',
            prefixIcon: Icon(Icons.vpn_key),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _joinTeam(code);
              Navigator.pop(context);
            },
            child: const Text('Join Workspace'),
          ),
        ],
      ),
    );
  }

  void _showTeamSettings(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Settings',
                style:
                    GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Change Team Name'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined),
                title: const Text('Regenerate Team Code'),
                subtitle: const Text('Old code will stop working'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: const Text('Disband Team',
                    style: TextStyle(color: AppColors.red)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleAssignment(
      BuildContext context, TeamMember member, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Access: ${member.name}',
                  style: GoogleFonts.syne(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Select specific vaults this member can access:'),
                const SizedBox(height: 16),
                ..._sharedVaults.map((vault) {
                  final hasAccess = vault.memberIds.contains(member.id);
                  return CheckboxListTile(
                    title: Text(vault.name),
                    subtitle: Text('${vault.passwordCount} passwords'),
                    value: hasAccess,
                    activeColor: AppColors.purple,
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          vault.memberIds.add(member.id);
                        } else {
                          vault.memberIds.remove(member.id);
                        }
                      });
                      setState(() {}); // Refresh main screen
                    },
                  );
                }),
                const SizedBox(height: 16),
                const Text('Member Role:'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Viewer', 'Editor', 'Admin'].map((r) {
                      final isSelected = member.role == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(r),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => member.role = r);
                              setState(() {});
                            }
                          },
                          selectedColor: AppColors.purple,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter email address',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Send Invite')),
        ],
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Shared Vault'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Vault Name (e.g. Marketing)',
            prefixIcon: Icon(Icons.folder_shared),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Create')),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }
}
