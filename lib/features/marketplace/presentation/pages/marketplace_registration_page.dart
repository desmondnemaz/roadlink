import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/shared/widgets/roadlink_button.dart';
import 'package:roadlink/shared/widgets/roadlink_text_field.dart';

/// Registration page for Roadlink Marketplace sellers (car dealers, spare
/// parts shops, tyre retailers, and individual sellers).
class MarketplaceRegistrationPage extends StatefulWidget {
  const MarketplaceRegistrationPage({super.key});

  @override
  State<MarketplaceRegistrationPage> createState() =>
      _MarketplaceRegistrationPageState();
}

class _MarketplaceRegistrationPageState
    extends State<MarketplaceRegistrationPage> {
  static const List<String> _sellerTypes = [
    'Dealer',
    'Parts shop',
    'Individual seller',
  ];

  static const List<String> _categories = [
    'Cars',
    'Parts & tyres',
    'Accessories',
  ];

  final _businessNameController = TextEditingController();
  late final TextEditingController _locationController;
  final _phoneController = TextEditingController();
  final _inventoryController = TextEditingController();

  String _selectedSellerType = _sellerTypes.first;
  String _selectedCategory = _categories.first;

  String? _businessNameError;
  String? _locationError;
  String? _phoneError;
  String? _inventoryError;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: context.read<LocationCubit>().state.areaLabel,
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _businessNameController.text.trim();
    final location = _locationController.text.trim();
    final phone = _phoneController.text.trim();
    final inventory = _inventoryController.text.trim();

    setState(() {
      _businessNameError =
          name.isEmpty ? 'Enter your store or seller name.' : null;
      _locationError =
          location.isEmpty ? 'Enter or pick your store location.' : null;
      _phoneError =
          phone.length < 7 ? 'Enter a valid Zimbabwe mobile number.' : null;
      _inventoryError = inventory.length < 10
          ? 'Describe what you sell (at least 10 characters).'
          : null;
    });

    if (_businessNameError == null &&
        _locationError == null &&
        _phoneError == null &&
        _inventoryError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seller registered: $name ($_selectedSellerType · $_selectedCategory).',
          ),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.marketplacePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: c.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: AppPalette.navy900,
        foregroundColor: AppPalette.neutral0,
        elevation: 0,
        title: Text(
          'Marketplace seller registration',
          style: AppTypography.label.copyWith(
            color: AppPalette.neutral0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: 680,
          padding: EdgeInsets.all(isDesktop ? AppSpacing.s32 : AppSpacing.s20),
          child: Container(
            padding: EdgeInsets.all(
              isDesktop ? AppSpacing.s32 : AppSpacing.s20,
            ),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sell on Roadlink Marketplace',
                  style: AppTypography.h2.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'List vehicles, spare parts, tyres, and accessories to buyers across Zimbabwe.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                RoadlinkTextField(
                  label: 'Store or seller name',
                  hintText: 'e.g. Harare Spares Hub',
                  controller: _businessNameController,
                  errorText: _businessNameError,
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Account type',
                  style: AppTypography.label.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    for (final type in _sellerTypes)
                      ChoiceChip(
                        label: Text(type),
                        selected: _selectedSellerType == type,
                        onSelected: (_) =>
                            setState(() => _selectedSellerType = type),
                        selectedColor: AppPalette.navy900,
                        backgroundColor: c.surfaceRaised,
                        labelStyle: AppTypography.caption.copyWith(
                          color: _selectedSellerType == type
                              ? AppPalette.neutral0
                              : c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Primary listing category',
                  style: AppTypography.label.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s8,
                  children: [
                    for (final category in _categories)
                      ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                        selectedColor: AppPalette.navy900,
                        backgroundColor: c.surfaceRaised,
                        labelStyle: AppTypography.caption.copyWith(
                          color: _selectedCategory == category
                              ? AppPalette.neutral0
                              : c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: RoadlinkTextField(
                        label: 'Location',
                        hintText: 'e.g. Msasa, Harare',
                        controller: _locationController,
                        errorText: _locationError,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: _locationError == null ? 0 : 22,
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await showLocationPickerSheet(context);
                          if (!context.mounted) return;
                          _locationController.text =
                              context.read<LocationCubit>().state.areaLabel;
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text('Pick'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                RoadlinkTextField(
                  label: 'Phone number',
                  hintText: '7X XXX XXXX',
                  controller: _phoneController,
                  errorText: _phoneError,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: AppSpacing.s12),
                      Text(
                        '+263',
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                        ),
                        width: 1,
                        height: 20,
                        color: c.borderDefault,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                RoadlinkTextField(
                  label: 'About your inventory',
                  hintText:
                      'e.g. Japanese OEM spares, alloy wheels, brake pads, and body panels.',
                  controller: _inventoryController,
                  errorText: _inventoryError,
                ),
                const SizedBox(height: AppSpacing.s24),
                RoadlinkButton(
                  label: 'Register seller account',
                  onPressed: _handleSubmit,
                  variant: RoadlinkButtonVariant.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
