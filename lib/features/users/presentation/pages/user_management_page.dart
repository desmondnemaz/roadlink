import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart' hide DataCell, DataRow;
import 'package:material_ui/material_ui.dart' as mui;
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';

enum _UserStatus { verified, pending, suspended }

class _ManagedUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String area;
  final _UserStatus status;

  const _ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.area,
    required this.status,
  });

  _ManagedUser copyWith({String? role, _UserStatus? status}) {
    return _ManagedUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role ?? this.role,
      area: area,
      status: status ?? this.status,
    );
  }
}

/// Roadlink **User Management** space powered by `data_table_2` for viewing,
/// filtering, sorting, verifying, and managing user roles across the platform.
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  static const List<String> _roles = [
    'All',
    'Driver',
    'Service provider',
    'Seller',
    'Admin',
  ];

  final List<_ManagedUser> _users = [
    const _ManagedUser(
      id: 'u-1',
      name: 'Tendai Moyo',
      email: 'tendai.moyo@roadlink.co.zw',
      phone: '+263 77 412 8890',
      role: 'Driver',
      area: 'Avondale, Harare',
      status: _UserStatus.verified,
    ),
    const _ManagedUser(
      id: 'u-2',
      name: 'Tawanda’s Auto Care',
      email: 'tawanda@autocare.co.zw',
      phone: '+263 71 204 5511',
      role: 'Service provider',
      area: 'Avondale, Harare',
      status: _UserStatus.verified,
    ),
    const _ManagedUser(
      id: 'u-3',
      name: 'Harare Spares Hub',
      email: 'sales@hararespares.co.zw',
      phone: '+263 77 980 1122',
      role: 'Seller',
      area: 'Msasa, Harare',
      status: _UserStatus.verified,
    ),
    const _ManagedUser(
      id: 'u-4',
      name: 'Nyasha M.',
      email: 'nyasha.m@roadlink.co.zw',
      phone: '+263 78 331 0945',
      role: 'Driver',
      area: 'Borrowdale, Harare',
      status: _UserStatus.verified,
    ),
    const _ManagedUser(
      id: 'u-5',
      name: 'Mbare Fleet & Diagnostics',
      email: 'fleet@mbarediag.co.zw',
      phone: '+263 77 654 3210',
      role: 'Service provider',
      area: 'Mbare, Harare',
      status: _UserStatus.pending,
    ),
    const _ManagedUser(
      id: 'u-6',
      name: 'Chiedza R.',
      email: 'chiedza@roadlink.co.zw',
      phone: '+263 71 889 4401',
      role: 'Admin',
      area: 'Harare CBD',
      status: _UserStatus.verified,
    ),
  ];

  String _searchQuery = '';
  String _selectedRole = 'All';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<_ManagedUser> get _filteredUsers {
    final q = _searchQuery.trim().toLowerCase();
    final list = _users.where((u) {
      if (_selectedRole != 'All' && u.role != _selectedRole) return false;
      if (q.isEmpty) return true;
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.area.toLowerCase().contains(q) ||
          u.role.toLowerCase().contains(q);
    }).toList();

    list.sort((a, b) {
      final cmp = switch (_sortColumnIndex) {
        1 => a.role.compareTo(b.role),
        2 => a.area.compareTo(b.area),
        3 => a.status.index.compareTo(b.status.index),
        _ => a.name.compareTo(b.name),
      };
      return _sortAscending ? cmp : -cmp;
    });
    return list;
  }

  void _updateUser(String id, {String? role, _UserStatus? status}) {
    setState(() {
      final idx = _users.indexWhere((u) => u.id == id);
      if (idx == -1) return;
      _users[idx] = _users[idx].copyWith(role: role, status: status);
    });
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final areaController = TextEditingController(text: 'Avondale, Harare');
    var role = 'Driver';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add user'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (+263 ...)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: areaController,
                      decoration: const InputDecoration(labelText: 'Area'),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'Driver', child: Text('Driver')),
                        DropdownMenuItem(
                          value: 'Service provider',
                          child: Text('Service provider'),
                        ),
                        DropdownMenuItem(value: 'Seller', child: Text('Seller')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => role = v);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    if (name.isEmpty || email.isEmpty) return;
                    setState(() {
                      _users.insert(
                        0,
                        _ManagedUser(
                          id: 'u-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          email: email,
                          phone: phoneController.text.trim().isEmpty
                              ? '+263 77 000 0000'
                              : phoneController.text.trim(),
                          role: role,
                          area: areaController.text.trim().isEmpty
                              ? 'Harare'
                              : areaController.text.trim(),
                          status: _UserStatus.pending,
                        ),
                      );
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;
    final rows = _filteredUsers;

    return Scaffold(
      backgroundColor: c.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.neutral0,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: RoadlinkColors.brandGradientHorizontal,
          ),
        ),
        title: Text(
          'Admin',
          style: AppTypography.label.copyWith(
            color: AppPalette.neutral0,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s16),
            child: Center(
              child: InitialsAvatar(
                initials: 'TM',
                size: 36,
                onTap: () => context.push(AppRoutes.profilePath),
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveCenter(
        maxContentWidth: 1360,
        padding: EdgeInsets.all(isDesktop ? AppSpacing.s24 : AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AdminKpiRow(
              totalUsers: _users.length,
              verifiedCount: _users
                  .where((u) => u.status == _UserStatus.verified)
                  .length,
              pendingCount: _users
                  .where((u) => u.status == _UserStatus.pending)
                  .length,
              suspendedCount: _users
                  .where((u) => u.status == _UserStatus.suspended)
                  .length,
            ),
            const SizedBox(height: AppSpacing.s16),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: isDesktop ? 320 : double.infinity,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTypography.bodySmall.copyWith(
                      color: c.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search users, emails, areas...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                for (final role in _roles)
                  ChoiceChip(
                    label: Text(role),
                    selected: _selectedRole == role,
                    onSelected: (_) => setState(() => _selectedRole = role),
                    selectedColor: AppPalette.navy900,
                    backgroundColor: c.surfaceDefault,
                    labelStyle: AppTypography.caption.copyWith(
                      color: _selectedRole == role
                          ? AppPalette.neutral0
                          : c.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.buttonBlue,
                    foregroundColor: AppPalette.navy900,
                    elevation: 0,
                    minimumSize: const Size(0, 40),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: Text(
                    'Add user',
                    style: AppTypography.caption.copyWith(
                      color: AppPalette.navy900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceDefault,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: c.borderDefault),
                ),
                clipBehavior: Clip.antiAlias,
                child: mui.Material(
                  type: mui.MaterialType.transparency,
                  child: DataTable2(
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  dataRowHeight: 68,
                  minWidth: 780,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowColor: WidgetStatePropertyAll(c.surfaceRaised),
                  columns: [
                    DataColumn2(
                      label: const Text('User'),
                      size: ColumnSize.L,
                      onSort: (idx, asc) => setState(() {
                        _sortColumnIndex = idx;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Role'),
                      size: ColumnSize.M,
                      onSort: (idx, asc) => setState(() {
                        _sortColumnIndex = idx;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Area'),
                      size: ColumnSize.M,
                      onSort: (idx, asc) => setState(() {
                        _sortColumnIndex = idx;
                        _sortAscending = asc;
                      }),
                    ),
                    DataColumn2(
                      label: const Text('Status'),
                      size: ColumnSize.S,
                      onSort: (idx, asc) => setState(() {
                        _sortColumnIndex = idx;
                        _sortAscending = asc;
                      }),
                    ),
                    const DataColumn2(
                      label: Text('Actions'),
                      size: ColumnSize.S,
                      numeric: true,
                    ),
                  ],
                  rows: [
                    for (final user in rows)
                      mui.DataRow(
                        cells: [
                          mui.DataCell(
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${user.email} · ${user.phone}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          mui.DataCell(
                            Text(
                              user.role,
                              style: AppTypography.bodySmall.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          mui.DataCell(
                            Text(
                              user.area,
                              style: AppTypography.bodySmall.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                          mui.DataCell(_UserStatusChip(status: user.status)),
                          mui.DataCell(
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_horiz,
                                color: c.textSecondary,
                              ),
                              onSelected: (action) {
                                switch (action) {
                                  case 'verify':
                                    _updateUser(
                                      user.id,
                                      status: _UserStatus.verified,
                                    );
                                  case 'suspend':
                                    _updateUser(
                                      user.id,
                                      status: _UserStatus.suspended,
                                    );
                                  case 'role_provider':
                                    _updateUser(
                                      user.id,
                                      role: 'Service provider',
                                    );
                                  case 'role_seller':
                                    _updateUser(user.id, role: 'Seller');
                                  case 'role_driver':
                                    _updateUser(user.id, role: 'Driver');
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'verify',
                                  child: Text('Mark verified'),
                                ),
                                PopupMenuItem(
                                  value: 'suspend',
                                  child: Text('Suspend user'),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'role_driver',
                                  child: Text('Set role: Driver'),
                                ),
                                PopupMenuItem(
                                  value: 'role_provider',
                                  child: Text('Set role: Service provider'),
                                ),
                                PopupMenuItem(
                                  value: 'role_seller',
                                  child: Text('Set role: Seller'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStatusChip extends StatelessWidget {
  final _UserStatus status;

  const _UserStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _UserStatus.verified => ('Verified', Colors.green),
      _UserStatus.pending => ('Pending', AppPalette.blue500),
      _UserStatus.suspended => ('Suspended', Colors.redAccent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AdminKpiRow extends StatelessWidget {
  final int totalUsers;
  final int verifiedCount;
  final int pendingCount;
  final int suspendedCount;

  const _AdminKpiRow({
    required this.totalUsers,
    required this.verifiedCount,
    required this.pendingCount,
    required this.suspendedCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = [
      ('Total users', '$totalUsers', Icons.people_outline, AppPalette.blue500),
      ('Verified', '$verifiedCount', Icons.verified_outlined, Colors.green),
      (
        'Pending',
        '$pendingCount',
        Icons.hourglass_top_outlined,
        AppPalette.blue400,
      ),
      (
        'Suspended',
        '$suspendedCount',
        Icons.block_outlined,
        Colors.redAccent,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: c.surfaceDefault,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: c.borderDefault),
              ),
              child: Row(
                children: [
                  Icon(cards[i].$3, size: 20, color: cards[i].$4),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cards[i].$2,
                          style: AppTypography.h3.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          cards[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
