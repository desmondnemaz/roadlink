import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/features/marketplace/data/marketplace_catalog.dart';
import 'package:roadlink/shared/widgets/section_layout.dart';

/// Full **Roadlink Marketplace** page for browsing cars, spare parts, tyres,
/// and automotive accessories across Zimbabwe.
class MarketplacePage extends StatefulWidget {
  final String? initialCategory;
  final bool initialSavedOnly;

  const MarketplacePage({
    super.key,
    this.initialCategory,
    this.initialSavedOnly = false,
  });

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  static const List<String> _categories = [
    'All',
    'Cars',
    'Parts & tyres',
    'Accessories',
  ];

  late String _selectedCategory;
  String _searchQuery = '';
  late bool _savedOnly;
  final Set<String> _savedIds = <String>{};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _selectedCategory =
        (initial != null && _categories.contains(initial)) ? initial : 'All';
    _savedOnly = widget.initialSavedOnly;
  }

  void _toggleSaved(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _showItemDetails(BuildContext context, MarketplaceItem item) {
    final c = context.colors;
    final isSaved = _savedIds.contains(item.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surfaceDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.category,
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.blue500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: Icon(Icons.close, size: 20, color: c.textSecondary),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: AppRadius.lgAll,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: c.surfaceRaised),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  item.title,
                  style: AppTypography.h3.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: AppTypography.h2.copyWith(
                    color: AppPalette.blue500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  '${item.location} · ${item.sellerType} · ${item.condition}',
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _toggleSaved(item.id);
                        Navigator.of(sheetContext).pop();
                      },
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isSaved ? AppPalette.blue500 : c.textPrimary,
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save'),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Inquiry started for ${item.title} (${item.location}).',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.blue500,
                          foregroundColor: AppPalette.neutral0,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(46),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                        child: Text(
                          'Contact seller',
                          style: AppTypography.button.copyWith(
                            color: AppPalette.neutral0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    final filtered = kMarketplaceItems.where((item) {
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }
      if (_savedOnly && !_savedIds.contains(item.id)) {
        return false;
      }
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();

    final mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTypography.bodySmall.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search cars, alloy wheels, brake pads, towns...',
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: c.textSecondary,
            ),
          ),
        ),
        if (!isDesktop) ...[
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              for (final category in _categories)
                ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category && !_savedOnly,
                  onSelected: (_) => setState(() {
                    _selectedCategory = category;
                    _savedOnly = false;
                  }),
                  selectedColor: AppPalette.blue500,
                  backgroundColor: c.surfaceDefault,
                  labelStyle: AppTypography.caption.copyWith(
                    color: _selectedCategory == category && !_savedOnly
                        ? AppPalette.neutral0
                        : c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _selectedCategory == category && !_savedOnly
                        ? AppPalette.blue500
                        : c.borderDefault,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.s20),
        Text(
          '${filtered.length} listing${filtered.length == 1 ? '' : 's'} available',
          style: AppTypography.caption.copyWith(
            color: c.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s32),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 36,
                  color: c.textSecondary,
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _savedOnly
                      ? 'No saved listings yet'
                      : 'No matching listings found',
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedCategory = 'All';
                    _searchQuery = '';
                    _savedOnly = false;
                  }),
                  child: const Text('Show all listings'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720
                  ? 2
                  : (constraints.maxWidth >= 520 ? 2 : 1);
              final rows = (filtered.length / columns).ceil();

              return Column(
                children: [
                  for (var r = 0; r < rows; r++) ...[
                    if (r > 0) const SizedBox(height: AppSpacing.s16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var col = 0; col < columns; col++) ...[
                          if (col > 0) const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: (r * columns + col) < filtered.length
                                ? _MarketplaceListingCard(
                                    item: filtered[r * columns + col],
                                    isSaved: _savedIds.contains(
                                      filtered[r * columns + col].id,
                                    ),
                                    onToggleSaved: () => _toggleSaved(
                                      filtered[r * columns + col].id,
                                    ),
                                    onTap: () => _showItemDetails(
                                      context,
                                      filtered[r * columns + col],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
      ],
    );

    return Scaffold(
      backgroundColor: c.backgroundCanvas,
      bottomNavigationBar:
          !isDesktop ? const HomeMobileBottomNav(selectedIndex: 2) : null,
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
          'Marketplace',
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
      body: isDesktop
          ? ResponsiveCenter(
              maxContentWidth: 1520,
              padding: const EdgeInsets.only(
                left: AppSpacing.s16,
                right: AppSpacing.s24,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 220,
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s24,
                      ),
                      child: _buildLeftExploreNav(context),
                    ),
                  ),
                  const VerticalSectionDivider(),
                  Expanded(
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s24,
                      ),
                      child: mainColumn,
                    ),
                  ),
                  const VerticalSectionDivider(),
                  SizedBox(
                    width: 320,
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s24,
                      ),
                      child: _buildRightRail(context),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: ResponsiveCenter(
                maxContentWidth: 960,
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: mainColumn,
              ),
            ),
    );
  }

  Widget _buildLeftExploreNav(BuildContext context) {
    const items = [
      ('All', Icons.apps_outlined),
      ('Cars', Icons.directions_car_outlined),
      ('Parts & tyres', Icons.tire_repair_outlined),
      ('Accessories', Icons.handyman_outlined),
    ];

    return SectionRailCard(
      title: 'Explore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            SectionNavButton(
              label: items[i].$1,
              icon: items[i].$2,
              selected: _selectedCategory == items[i].$1 && !_savedOnly,
              onTap: () => setState(() {
                _selectedCategory = items[i].$1;
                _savedOnly = false;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightRail(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _savedOnly = !_savedOnly),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: _savedOnly ? AppPalette.blue500 : c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: _savedOnly ? AppPalette.blue500 : c.borderDefault,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _savedOnly ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: AppPalette.blue500,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    'Saved listings',
                    style: AppTypography.bodySmall.copyWith(
                      color: _savedOnly ? AppPalette.neutral0 : c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${_savedIds.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.blue500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SectionRailCard(
          title: 'Featured listings',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < kMarketplaceItems.take(3).length; i++) ...[
                if (i > 0) const Divider(height: AppSpacing.s16),
                InkWell(
                  onTap: () => _showItemDetails(context, kMarketplaceItems[i]),
                  borderRadius: AppRadius.smAll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kMarketplaceItems[i].price,
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.blue500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kMarketplaceItems[i].title,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        kMarketplaceItems[i].location,
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SectionRailCard(
          title: 'Sell on Roadlink',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register as a dealer, parts shop, or individual seller to list items.',
                style: AppTypography.caption.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s12),
              ElevatedButton(
                onPressed: () =>
                    context.push(AppRoutes.marketplaceRegisterPath),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.navy900,
                  foregroundColor: AppPalette.neutral0,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(40),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                child: const Text('Register seller'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketplaceListingCard extends StatelessWidget {
  final MarketplaceItem item;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  const _MarketplaceListingCard({
    required this.item,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: c.surfaceRaised),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: onToggleSaved,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppPalette.neutral0,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isSaved
                              ? AppPalette.blue500
                              : AppPalette.navy900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: AppTypography.label.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

