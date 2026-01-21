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
import 'models/team_models.dart';
import 'providers/team_provider.dart';
import 'shared_vault_screen.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 2;
  String? _username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadUserInfo());
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final teamsAsync = ref.watch(myTeamsProvider);

    // Listen to controller state for errors/loading
    ref.listen(teamControllerProvider, (previous, next) {
      if (next is AsyncError) {
        _showError(next.error.toString());
      } else if (next is AsyncData &&
          next.value == null &&
          previous is AsyncLoading) {
        // Operation success
      }
    });

    return Scaffold(
      appBar: teamsAsync.asData?.value.isNotEmpty == true
          ? AppBar(
              toolbarHeight: 0,
              elevation: 0,
              backgroundColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        child: teamsAsync.when(
          data: (teams) {
            if (teams.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, themeNotifier, isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildNoTeamScreen(isDark),
                    ),
                  ),
                ],
              );
            }

            // Should ensure a team is selected
            final currentTeam = ref.watch(selectedTeamProvider);
            if (currentTeam == null) {
              // Should not happen if list not empty due to logic in provider
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                _buildHeader(context, themeNotifier, isDark),
                _buildTeamHeader(context, currentTeam, isDark),
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
                      _buildMembersTab(isDark, currentTeam),
                      _buildSharedVaultsTab(isDark, currentTeam),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: teamsAsync.asData?.value.isNotEmpty == true
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          : null,
    );
  }

  Widget _buildTeamHeader(BuildContext context, TeamModel team, bool isDark) {
    return Padding(
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
                      text: team.name,
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
                  Clipboard.setData(ClipboardData(text: team.code));
                  _showSuccess('Team code copied!');
                },
                child: Row(
                  children: [
                    Text(
                      'Code: ${team.code}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.purple.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 10, color: AppColors.purple),
                  ],
                ),
              ),
            ],
          ),
          // TODO: Add Settings button/Leave button logic
          _buildIconButton(
            context,
            icon: Icons.logout,
            color: AppColors.red,
            onTap: () {
              // Logic to switch team or logout of screen?
              // For now just back
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(bool isDark, TeamModel team) {
    final membersAsync = ref.watch(teamMembersProvider(team.id));

    return membersAsync.when(
      data: (members) {
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
                  _buildStatItem('${members.length}', 'Members'),
                  _buildDivider(),
                  _buildStatItem(
                      '${members.where((m) => m.role == "Admin").length}',
                      'Admins'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Team Members',
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...members.map((member) => _buildMemberTile(member, isDark)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading members: $e')),
    );
  }

  Widget _buildSharedVaultsTab(bool isDark, TeamModel team) {
    final vaultsAsync = ref.watch(teamVaultsProvider(team.id));

    return vaultsAsync.when(
      data: (vaults) {
        if (vaults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    size: 60, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text("No shared vaults yet",
                    style:
                        TextStyle(color: Colors.grey.withValues(alpha: 0.8))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vaults.length,
          itemBuilder: (context, index) {
            final vault = vaults[index];
            // Reusing vault item style or similar
            return _buildVaultTile(vault, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildVaultTile(SharedVaultModel vault, bool isDark) {
    return GestureDetector(
        onTap: () {
          // Check if team is present
          final currentTeam = ref.read(selectedTeamProvider);
          if (currentTeam != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SharedVaultScreen(
                        vault: vault, teamId: currentTeam.id)));
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '${vault.memberIds.length} members • ${vault.passwordCount} passwords',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: isDark ? Colors.white54 : Colors.black45,
                onPressed: () => _showEditVaultDialog(context, vault),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: isDark ? Colors.white54 : Colors.black45),
            ],
          ),
        ));
  }

  Widget _buildMemberTile(TeamMemberModel member, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.purple,
            child: Text(
                member.name.isNotEmpty
                    ? member.name.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  member.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: member.role == 'Admin'
                  ? AppColors.purple.withValues(alpha: 0.2)
                  : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: member.role == 'Admin'
                    ? AppColors.purple
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ],
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.syne(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
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
            const SizedBox(height: 24),
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

  Widget _buildBottomNav(BuildContext context) {
    // Reuse from original file but adjust logic if needed
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
          // Add button normally here? No, design has logic to replace with "Team" active
          // But original nav had 5 items.
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

  // Dialogs

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Team'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
              labelText: 'Team Name', hintText: 'e.g. Acme Corp'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref
                    .read(teamControllerProvider.notifier)
                    .createTeam(nameController.text);
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
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Team'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
              labelText: 'Invite Code', hintText: 'Enter code'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                ref
                    .read(teamControllerProvider.notifier)
                    .joinTeam(codeController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    final team = ref.read(selectedTeamProvider);

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Invite Member"),
              content: TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
                keyboardType: TextInputType.emailAddress,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                  onPressed: () {
                    if (emailController.text.isNotEmpty && team != null) {
                      ref
                          .read(teamControllerProvider.notifier)
                          .inviteMember(team.id, emailController.text);
                      Navigator.pop(context);
                      _showSuccess("Invitation sent!");
                    }
                  },
                  child: const Text("Invite"),
                )
              ],
            ));
  }

  void _showCreateVaultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateSharedVaultDialog(),
    );
  }

  void _showEditVaultDialog(BuildContext context, SharedVaultModel vault) {
    showDialog(
      context: context,
      builder: (context) => _CreateSharedVaultDialog(existingVault: vault),
    );
  }
}

class _CreateSharedVaultDialog extends ConsumerStatefulWidget {
  final SharedVaultModel? existingVault;
  const _CreateSharedVaultDialog({this.existingVault});

  @override
  ConsumerState<_CreateSharedVaultDialog> createState() =>
      _CreateSharedVaultDialogState();
}

class _CreateSharedVaultDialogState
    extends ConsumerState<_CreateSharedVaultDialog> {
  late TextEditingController _nameController;
  List<String> _selectedMemberIds = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingVault?.name ?? "");
    _selectedMemberIds = List.from(widget.existingVault?.memberIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(selectedTeamProvider);
    if (team == null) return const SizedBox.shrink(); // Should not happen

    final membersAsync = ref.watch(teamMembersProvider(team.id));

    return AlertDialog(
      title: Text(widget.existingVault == null
          ? "New Shared Vault"
          : "Edit Shared Vault"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Vault Name"),
            ),
            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Select Members:",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Flexible(
                child: membersAsync.when(
              data: (members) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isSelected = _selectedMemberIds.contains(member.id);
                      return CheckboxListTile(
                          value: isSelected,
                          title: Text(member.name),
                          subtitle: Text(member.email),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedMemberIds.add(member.id);
                              } else {
                                _selectedMemberIds.remove(member.id);
                              }
                            });
                          });
                    });
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text("Error: $e"),
            ))
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) return;

            if (widget.existingVault == null) {
              // Create
              // Need to update controller to support member list creation
              // For now calling service directly or updating controller in next step?
              // Controller update is pending.
              // Wait, I can't call controller.createVault with members yet.
              // I need to update createVault signature first?
              // Let's assume I will update it.
              // Actually, let's just use the updateVault for now if editing, and createVault if new.
              // But createVault in controller doesn't take members.
              // I should assume I'll fix the controller signature.
              // OR I can use the service directly here for now to avoid breaking existing calls?
              // Better to update controller.

              // Since I haven't updated createVault signature in controller, I will do a quick fix here
              // and then update controller in next step.
              ref
                  .read(teamServiceProvider)
                  .createSharedVault(
                      team.id, _nameController.text, _selectedMemberIds)
                  .then((_) {
                ref.invalidate(teamVaultsProvider(team.id));
                Navigator.pop(context);
              });
            } else {
              // Update
              ref.read(teamControllerProvider.notifier).updateVault(
                  team.id,
                  widget.existingVault!.id,
                  _nameController.text,
                  _selectedMemberIds);
              Navigator.pop(context);
            }
          },
          child: Text(widget.existingVault == null ? "Create" : "Save"),
        )
      ],
    );
  }
}
