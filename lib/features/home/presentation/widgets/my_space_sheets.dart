import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';

class _MessageThread {
  final String initials;
  final String name;
  final String contextLabel;
  final String lastMessage;
  final String timeAgo;
  final bool unread;

  const _MessageThread({
    required this.initials,
    required this.name,
    required this.contextLabel,
    required this.lastMessage,
    required this.timeAgo,
    this.unread = false,
  });
}

class _VehicleEntry {
  final String makeModel;
  final String year;
  final String plate;

  const _VehicleEntry({
    required this.makeModel,
    required this.year,
    required this.plate,
  });
}

final List<_VehicleEntry> _userVehicles = [
  const _VehicleEntry(
    makeModel: 'Toyota Vitz · 1.3L Petrol',
    year: '2016',
    plate: 'AFC 4821',
  ),
];

/// Opens the **Messages** sheet showing conversations with mechanics and sellers.
void showMessagesSheet(BuildContext context) {
  const threads = [
    _MessageThread(
      initials: 'TA',
      name: 'Tawanda’s Auto Care',
      contextLabel: 'Brake inspection bid',
      lastMessage: 'I have OEM front pads in stock and can come by in 20 mins.',
      timeAgo: '12m ago',
      unread: true,
    ),
    _MessageThread(
      initials: 'HS',
      name: 'Harare Spares Hub',
      contextLabel: '16" Alloy wheels',
      lastMessage: 'Yes, they fit 5x100 hubs. Viewing available at Msasa.',
      timeAgo: '2h ago',
    ),
  ];

  final replyController = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final c = sheetContext.colors;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s20,
            AppSpacing.s24,
            AppSpacing.s24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetHeader(
                  title: 'Messages',
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: AppSpacing.s12),
                for (var i = 0; i < threads.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      borderRadius: AppRadius.lgAll,
                      border: Border.all(
                        color: threads[i].unread
                            ? AppPalette.blue500
                            : c.borderDefault,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InitialsAvatar(initials: threads[i].initials, size: 36),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      threads[i].name,
                                      style: AppTypography.label.copyWith(
                                        color: c.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    threads[i].timeAgo,
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                threads[i].contextLabel,
                                style: AppTypography.caption.copyWith(
                                  color: AppPalette.blue500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                threads[i].lastMessage,
                                style: AppTypography.bodySmall.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Reply to Tawanda’s Auto Care...',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    ElevatedButton(
                      onPressed: () {
                        final msg = replyController.text.trim();
                        if (msg.isEmpty) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message sent: "$msg"'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.blue500,
                        foregroundColor: AppPalette.neutral0,
                        elevation: 0,
                        minimumSize: const Size(0, 44),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Opens the **My vehicles** garage sheet where the user can view or add cars.
void showMyVehiclesSheet(BuildContext context) {
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final plateController = TextEditingController();
  var showAddForm = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final c = context.colors;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s24 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SheetHeader(
                      title: 'My vehicles',
                      onClose: () => Navigator.of(sheetContext).pop(),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    for (var i = 0; i < _userVehicles.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.s12),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: c.surfaceRaised,
                          borderRadius: AppRadius.lgAll,
                          border: Border.all(color: c.borderDefault),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: AppPalette.blue50,
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: const Icon(
                                Icons.directions_car_outlined,
                                color: AppPalette.navy900,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userVehicles[i].makeModel,
                                    style: AppTypography.label.copyWith(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${_userVehicles[i].year} · Plate ${_userVehicles[i].plate}',
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
                    ],
                    const SizedBox(height: AppSpacing.s16),
                    if (showAddForm) ...[
                      TextField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          hintText: 'Make & model (e.g. Honda Fit 1.5)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: yearController,
                              decoration: const InputDecoration(
                                hintText: 'Year (e.g. 2018)',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: TextField(
                              controller: plateController,
                              decoration: const InputDecoration(
                                hintText: 'Plate (e.g. AGD 1204)',
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ElevatedButton(
                        onPressed: () {
                          final model = modelController.text.trim();
                          if (model.isEmpty) return;
                          setSheetState(() {
                            _userVehicles.add(
                              _VehicleEntry(
                                makeModel: model,
                                year: yearController.text.trim().isEmpty
                                    ? '2020'
                                    : yearController.text.trim(),
                                plate: plateController.text.trim().isEmpty
                                    ? 'Unlisted'
                                    : plateController.text.trim(),
                              ),
                            );
                            modelController.clear();
                            yearController.clear();
                            plateController.clear();
                            showAddForm = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.buttonBlue,
                          foregroundColor: AppPalette.navy900,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(44),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                        child: Text(
                          'Save vehicle',
                          style: AppTypography.button.copyWith(
                            color: AppPalette.navy900,
                          ),
                        ),
                      ),
                    ] else
                      OutlinedButton.icon(
                        onPressed: () => setSheetState(() => showAddForm = true),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add a vehicle'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

/// Opens the **Help & support** sheet with FAQs and a quick contact action.
void showHelpSupportSheet(BuildContext context) {
  const faqs = [
    (
      'How do service requests & bids work?',
      'Pick the service you need and your location. Nearby mechanics, towing operators, or tyre centres send bids with price and ETA so you can choose the best fit.',
    ),
    (
      'How does live tracking work?',
      'Once you accept a bid, tap Track live to view the provider approaching on the map. Tracking stops automatically when the job finishes or when you tap Stop.',
    ),
    (
      'Location inaccurate on desktop web?',
      'Laptops lack GPS chips. Use the Pick button to search your exact Zimbabwe street or suburb.',
    ),
  ];

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final c = sheetContext.colors;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetHeader(
                  title: 'Help & support',
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: AppSpacing.s12),
                for (var i = 0; i < faqs.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: c.surfaceRaised,
                      borderRadius: AppRadius.lgAll,
                      border: Border.all(color: c.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faqs[i].$1,
                          style: AppTypography.label.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          faqs[i].$2,
                          style: AppTypography.bodySmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Support request received. Our Harare team will reach out shortly.',
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
                  icon: const Icon(Icons.support_agent_outlined, size: 18),
                  label: Text(
                    'Contact Roadlink support',
                    style: AppTypography.button.copyWith(
                      color: AppPalette.neutral0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _SheetHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, size: 20, color: c.textSecondary),
        ),
      ],
    );
  }
}
