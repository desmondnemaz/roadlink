import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/community/data/community_catalog.dart';
import 'package:roadlink/features/community/presentation/cubit/community_cubit.dart';
import 'package:roadlink/features/community/presentation/widgets/community_media_view.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';

/// Opens a modal bottom sheet to publish a new [CommunityPost] (with optional
/// image, video, or reel upload) into [CommunityCubit].
void showNewPostSheet(
  BuildContext context, {
  CommunityMediaType? initialMediaType,
  String? initialTopic,
}) {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final picker = ImagePicker();
  const topics = [
    'Maintenance talk',
    'Car meets',
    'Road reports',
    '4x4 & Overlanding',
  ];
  var selectedTopic = topics.contains(initialTopic)
      ? initialTopic!
      : topics.first;
  CommunityMediaAttachment? attachedMedia;
  String? mediaError;
  var isPickingMedia = false;

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

          Future<void> pickMedia(CommunityMediaType type) async {
            setSheetState(() {
              isPickingMedia = true;
              mediaError = null;
            });
            try {
              final XFile? file = type == CommunityMediaType.image
                  ? await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    )
                  : await picker.pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: type == CommunityMediaType.reel
                          ? const Duration(seconds: 60)
                          : const Duration(minutes: 5),
                    );
              if (file == null) {
                setSheetState(() => isPickingMedia = false);
                return;
              }

              final sizeBytes = await file.length();
              final validationError = validateCommunityMediaFile(
                fileName: file.name,
                sizeBytes: sizeBytes,
                type: type,
              );
              if (validationError != null) {
                setSheetState(() {
                  isPickingMedia = false;
                  mediaError = validationError;
                });
                return;
              }

              if (type == CommunityMediaType.image) {
                final bytes = await file.readAsBytes();
                setSheetState(() {
                  attachedMedia = CommunityMediaAttachment(
                    type: type,
                    fileName: file.name,
                    bytes: bytes,
                    sizeBytes: sizeBytes,
                  );
                  isPickingMedia = false;
                });
              } else {
                setSheetState(() {
                  attachedMedia = CommunityMediaAttachment(
                    type: type,
                    fileName: file.name,
                    videoPath: file.path,
                    sizeBytes: sizeBytes,
                  );
                  isPickingMedia = false;
                });
              }
            } catch (_) {
              setSheetState(() {
                isPickingMedia = false;
                mediaError = 'Could not read the selected file.';
              });
            }
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s24 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        initialMediaType == CommunityMediaType.reel
                            ? 'Upload reel'
                            : 'New community post',
                        style: AppTypography.h3.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(Icons.close, size: 20, color: c.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      for (final topic in topics)
                        ChoiceChip(
                          label: Text(topic),
                          selected: selectedTopic == topic,
                          onSelected: (_) =>
                              setSheetState(() => selectedTopic = topic),
                          selectedColor: AppPalette.navy900,
                          backgroundColor: c.surfaceRaised,
                          labelStyle: AppTypography.caption.copyWith(
                            color: selectedTopic == topic
                                ? AppPalette.neutral0
                                : c.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  TextField(
                    controller: titleController,
                    style: AppTypography.bodySmall.copyWith(color: c.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Headline',
                      hintText: 'e.g. Any reliable brake specialist in Rusape?',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    style: AppTypography.bodySmall.copyWith(color: c.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      hintText:
                          'Share road conditions, maintenance tips, or car meet info...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'ADD MEDIA',
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Row(
                    children: [
                      Expanded(
                        child: _MediaUploadOptionButton(
                          icon: Icons.image_outlined,
                          label: 'Image',
                          onTap: isPickingMedia
                              ? null
                              : () => pickMedia(CommunityMediaType.image),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: _MediaUploadOptionButton(
                          icon: Icons.videocam_outlined,
                          label: 'Video',
                          onTap: isPickingMedia
                              ? null
                              : () => pickMedia(CommunityMediaType.video),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: _MediaUploadOptionButton(
                          icon: Icons.movie_creation_outlined,
                          label: 'Reel',
                          onTap: isPickingMedia
                              ? null
                              : () => pickMedia(CommunityMediaType.reel),
                        ),
                      ),
                    ],
                  ),
                  if (isPickingMedia) ...[
                    const SizedBox(height: AppSpacing.s12),
                    const LinearProgressIndicator(
                      color: AppPalette.blue500,
                    ),
                  ],
                  if (mediaError != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: c.warningBackground,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Text(
                        mediaError!,
                        style: AppTypography.caption.copyWith(
                          color: c.warningForeground,
                        ),
                      ),
                    ),
                  ],
                  if (attachedMedia != null) ...[
                    const SizedBox(height: AppSpacing.s12),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: c.surfaceRaised,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: c.borderDefault),
                      ),
                      child: Row(
                        children: [
                          if (attachedMedia!.type == CommunityMediaType.image &&
                              attachedMedia!.bytes != null)
                            ClipRRect(
                              borderRadius: AppRadius.smAll,
                              child: Image.memory(
                                attachedMedia!.bytes!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppPalette.blue50,
                                borderRadius: AppRadius.smAll,
                              ),
                              child: Icon(
                                attachedMedia!.type == CommunityMediaType.reel
                                    ? Icons.movie_creation_outlined
                                    : Icons.videocam_outlined,
                                size: 22,
                                color: AppPalette.navy900,
                              ),
                            ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attachedMedia!.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${attachedMedia!.type.name.toUpperCase()}'
                                  '${attachedMedia!.formattedSize.isNotEmpty ? ' · ${attachedMedia!.formattedSize}' : ''}',
                                  style: AppTypography.caption.copyWith(
                                    color: c.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setSheetState(() => attachedMedia = null),
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: c.textSecondary,
                            ),
                            tooltip: 'Remove media',
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final body = bodyController.text.trim();
                      if (title.isEmpty || body.isEmpty) return;

                      context.read<CommunityCubit>().addPost(
                            title: title,
                            body: body,
                            topic: selectedTopic,
                            media: attachedMedia,
                          );
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post shared with the Roadlink community.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.buttonBlue,
                      foregroundColor: AppPalette.navy900,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(46),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    child: Text(
                      'Publish post',
                      style: AppTypography.button.copyWith(
                        color: AppPalette.navy900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _MediaUploadOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MediaUploadOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: c.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: c.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a modal bottom sheet displaying the full discussion thread and
/// reply input for a [CommunityPost].
void showPostThreadSheet(BuildContext context, String postId) {
  final replyController = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          final c = context.colors;
          final post = state.posts.firstWhere(
            (p) => p.id == postId,
            orElse: () => state.posts.first,
          );

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      InitialsAvatar(initials: post.authorInitials, size: 34),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: AppTypography.label.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${post.topic} · ${post.timeAgo}',
                              style: AppTypography.caption.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(Icons.close, size: 20, color: c.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    post.title,
                    style: AppTypography.h3.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Divider(height: 1, color: c.borderDefault),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'Replies (${post.comments.length})',
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: post.comments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s16,
                            ),
                            child: Text(
                              'No replies yet. Start the conversation!',
                              style: AppTypography.bodySmall.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: post.comments.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.s12),
                            itemBuilder: (context, index) {
                              final comment = post.comments[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InitialsAvatar(
                                    initials: comment.authorInitials,
                                    size: 28,
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.s12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.surfaceRaised,
                                        borderRadius: AppRadius.mdAll,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${comment.authorName} · ${comment.timeAgo}',
                                            style: AppTypography.caption.copyWith(
                                              color: c.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            comment.body,
                                            style: AppTypography.bodySmall
                                                .copyWith(color: c.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          style: AppTypography.bodySmall.copyWith(
                            color: c.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Write a reply...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      ElevatedButton(
                        onPressed: () {
                          final text = replyController.text.trim();
                          if (text.isEmpty) return;
                          context.read<CommunityCubit>().addComment(
                                postId: post.id,
                                body: text,
                              );
                          replyController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.navy900,
                          foregroundColor: AppPalette.neutral0,
                          elevation: 0,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                        child: const Text('Reply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Full **Roadlink Car Community** page featuring discussions, car clubs,
/// and automotive meetups/events across Zimbabwe.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  static const List<String> _topics = [
    'All',
    'Maintenance talk',
    'Car meets',
    'Road reports',
    '4x4 & Overlanding',
  ];

  int _selectedSection = 0; // 0 = Feed, 1 = Clubs, 2 = Events, 3 = Reels
  String _selectedTopic = 'All';
  String _searchQuery = '';
  bool _savedOnly = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        final activeSection = switch (_selectedSection) {
          0 => _buildFeedSection(context, state),
          1 => _buildClubsSection(context, state),
          2 => _buildEventsSection(context, state),
          3 => _buildReelsSection(context, state),
          _ => _buildRoadReportsSection(context, state),
        };

        final mobileColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: _SectionTabButton(
                      label: const ['Feed', 'Clubs', 'Events', 'Reels'][i],
                      icon: const [
                        Icons.forum_outlined,
                        Icons.groups_outlined,
                        Icons.event_outlined,
                        Icons.movie_creation_outlined,
                      ][i],
                      selected: _selectedSection == i && !_savedOnly,
                      onTap: () => setState(() {
                        _selectedSection = i;
                        _savedOnly = false;
                      }),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            activeSection,
          ],
        );

        return Scaffold(
          backgroundColor: c.backgroundCanvas,
          bottomNavigationBar:
              !isDesktop ? const HomeMobileBottomNav(selectedIndex: 3) : null,
          appBar: AppBar(
            backgroundColor: AppPalette.navy900,
            foregroundColor: AppPalette.neutral0,
            elevation: 0,
            title: Text(
              'Community',
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
                          child: _buildLeftSectionNav(context),
                        ),
                      ),
                      _verticalSectionDivider(context),
                      Expanded(
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24,
                          ),
                          child: activeSection,
                        ),
                      ),
                      _verticalSectionDivider(context),
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24,
                          ),
                          child: _buildRightRail(
                            context,
                            state,
                            includeSavedCard: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxContentWidth: 960,
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    child: mobileColumn,
                  ),
                ),
        );
      },
    );
  }

  Widget _verticalSectionDivider(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.borderDefault.withValues(alpha: 0),
            c.borderDefault,
            c.borderDefault,
            c.borderDefault.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.08, 0.92, 1.0],
        ),
      ),
    );
  }

  Widget _buildLeftSectionNav(BuildContext context) {
    const items = [
      ('Feed', Icons.forum_outlined),
      ('Clubs', Icons.groups_outlined),
      ('Events', Icons.event_outlined),
      ('Reels', Icons.movie_creation_outlined),
      ('Road reports', Icons.traffic_outlined),
    ];

    return _railCard(
      context,
      title: 'Explore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            _SectionTabButton(
              label: items[i].$1,
              icon: items[i].$2,
              selected: _selectedSection == i && !_savedOnly,
              centered: false,
              onTap: () => setState(() {
                _selectedSection = i;
                _savedOnly = false;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _railCard(
    BuildContext context, {
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          child,
        ],
      ),
    );
  }

  Widget _buildSavedRailCard(BuildContext context, int savedCount) {
    final c = context.colors;
    return InkWell(
      onTap: () => setState(() {
        _selectedSection = 0;
        _savedOnly = !_savedOnly;
      }),
      borderRadius: AppRadius.lgAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: _savedOnly ? AppPalette.navy900 : c.surfaceDefault,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: _savedOnly ? AppPalette.navy900 : c.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _savedOnly ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: AppPalette.blue500,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                'Saved posts',
                style: AppTypography.bodySmall.copyWith(
                  color: _savedOnly ? AppPalette.neutral0 : c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$savedCount',
              style: AppTypography.caption.copyWith(
                color: AppPalette.blue500,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightRail(
    BuildContext context,
    CommunityState state, {
    required bool includeSavedCard,
  }) {
    final c = context.colors;
    final savedCount = state.posts.where((p) => p.isSaved).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeSavedCard) ...[
          _buildSavedRailCard(context, savedCount),
          const SizedBox(height: AppSpacing.s16),
        ],
        _railCard(
          context,
          title: 'Upcoming events',
          trailing: TextButton(
            onPressed: () => setState(() => _selectedSection = 2),
            child: const Text('See all'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < state.events.take(2).length; i++) ...[
                if (i > 0) const Divider(height: AppSpacing.s16),
                Text(
                  state.events[i].dateLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.blue500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.events[i].title,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${state.events[i].location} · ${state.events[i].attendees} going',
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        _railCard(
          context,
          title: 'Car clubs',
          trailing: TextButton(
            onPressed: () => setState(() => _selectedSection = 1),
            child: const Text('See all'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < state.groups.take(3).length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.groups[i].name,
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${state.groups[i].members} members',
                            style: AppTypography.caption.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    TextButton(
                      onPressed: () => context
                          .read<CommunityCubit>()
                          .toggleJoinGroup(state.groups[i].id),
                      child: Text(state.groups[i].isJoined ? 'Joined' : 'Join'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedSection(BuildContext context, CommunityState state) {
    final c = context.colors;

    final filtered = state.posts.where((post) {
      if (_selectedTopic != 'All' && post.topic != _selectedTopic) {
        return false;
      }
      if (_savedOnly && !post.isSaved) return false;
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return post.title.toLowerCase().contains(q) ||
          post.body.toLowerCase().contains(q) ||
          post.authorName.toLowerCase().contains(q) ||
          post.topic.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Composer strip
        InkWell(
          onTap: () => showNewPostSheet(context),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              children: [
                const InitialsAvatar(initials: 'TM', size: 34),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    'What’s happening in your car world?',
                    style: AppTypography.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
                Icon(Icons.edit_outlined, size: 18, color: c.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Search
        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTypography.bodySmall.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search road reports, maintenance talk, car meets...',
            prefixIcon: Icon(Icons.search, size: 18, color: c.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),

        // Topic chips
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final topic in _topics)
              ChoiceChip(
                label: Text(topic),
                selected: _selectedTopic == topic,
                onSelected: (_) => setState(() => _selectedTopic = topic),
                selectedColor: AppPalette.navy900,
                backgroundColor: c.surfaceDefault,
                labelStyle: AppTypography.caption.copyWith(
                  color: _selectedTopic == topic
                      ? AppPalette.neutral0
                      : c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: _selectedTopic == topic
                      ? AppPalette.navy900
                      : c.borderDefault,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

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
                Icon(Icons.forum_outlined, size: 36, color: c.textSecondary),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'No matching discussions found',
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedTopic = 'All';
                    _searchQuery = '';
                  }),
                  child: const Text('Show all discussions'),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s16),
            _CommunityPostCard(post: filtered[i]),
          ],
      ],
    );
  }

  Widget _buildRoadReportsSection(BuildContext context, CommunityState state) {
    final c = context.colors;
    final reports =
        state.posts.where((p) => p.topic == 'Road reports').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => showNewPostSheet(
            context,
            initialTopic: 'Road reports',
          ),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: const BoxDecoration(
              color: AppPalette.navy900,
              borderRadius: AppRadius.lgAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue500,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.traffic_outlined,
                    size: 22,
                    color: AppPalette.navy900,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share a road report',
                        style: AppTypography.label.copyWith(
                          color: AppPalette.neutral0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Warn fellow drivers about potholes, roadworks, detours, or traffic.',
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.neutral300,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add_circle_outline,
                  color: AppPalette.blue500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        if (reports.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s32),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Center(
              child: Text(
                'No road reports yet. Share an update from your route!',
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
            ),
          )
        else
          for (var i = 0; i < reports.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s16),
            _CommunityPostCard(post: reports[i]),
          ],
      ],
    );
  }

  Widget _buildReelsSection(BuildContext context, CommunityState state) {
    final c = context.colors;
    final reels = state.posts.where((p) => p.isReel).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => showNewPostSheet(
            context,
            initialMediaType: CommunityMediaType.reel,
          ),
          borderRadius: AppRadius.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: const BoxDecoration(
              color: AppPalette.navy900,
              borderRadius: AppRadius.lgAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue500,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.movie_creation_outlined,
                    size: 22,
                    color: AppPalette.navy900,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share a car reel',
                        style: AppTypography.label.copyWith(
                          color: AppPalette.neutral0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Upload a short clip of your build, exhaust note, or road trip.',
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.neutral300,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add_circle_outline,
                  color: AppPalette.blue500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        if (reels.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.s32),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Center(
              child: Text(
                'No reels uploaded yet. Be the first to share one!',
                style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
              ),
            ),
          )
        else
          for (var i = 0; i < reels.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s16),
            _CommunityPostCard(post: reels[i]),
          ],
      ],
    );
  }

  Widget _buildClubsSection(BuildContext context, CommunityState state) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < state.groups.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue50,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    size: 22,
                    color: AppPalette.navy900,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.groups[i].name,
                        style: AppTypography.label.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${state.groups[i].area} · ${state.groups[i].members} members',
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.groups[i].description,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                ElevatedButton(
                  onPressed: () => context
                      .read<CommunityCubit>()
                      .toggleJoinGroup(state.groups[i].id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.groups[i].isJoined
                        ? c.surfaceRaised
                        : AppPalette.navy900,
                    foregroundColor: state.groups[i].isJoined
                        ? c.textPrimary
                        : AppPalette.neutral0,
                    elevation: 0,
                    minimumSize: const Size(84, 36),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  child: Text(
                    state.groups[i].isJoined ? 'Joined' : 'Join',
                    style: AppTypography.caption.copyWith(
                      color: state.groups[i].isJoined
                          ? c.textPrimary
                          : AppPalette.neutral0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventsSection(BuildContext context, CommunityState state) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < state.events.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: c.borderDefault),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue50,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.event_outlined,
                    size: 22,
                    color: AppPalette.navy900,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.events[i].dateLabel,
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.blue500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.events[i].title,
                        style: AppTypography.label.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${state.events[i].location} · ${state.events[i].attendees} going',
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.events[i].description,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                ElevatedButton(
                  onPressed: () => context
                      .read<CommunityCubit>()
                      .toggleEventRsvp(state.events[i].id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.events[i].isGoing
                        ? AppPalette.blue500
                        : AppPalette.navy900,
                    foregroundColor: state.events[i].isGoing
                        ? AppPalette.navy900
                        : AppPalette.neutral0,
                    elevation: 0,
                    minimumSize: const Size(84, 36),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  child: Text(
                    state.events[i].isGoing ? 'Going ✓' : 'RSVP',
                    style: AppTypography.caption.copyWith(
                      color: state.events[i].isGoing
                          ? AppPalette.navy900
                          : AppPalette.neutral0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool centered;
  final VoidCallback onTap;

  const _SectionTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.centered = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        height: 44,
        padding: centered
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        decoration: BoxDecoration(
          color: selected ? AppPalette.navy900 : c.surfaceDefault,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppPalette.navy900 : c.borderDefault,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppPalette.blue500 : c.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: selected ? AppPalette.neutral0 : c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const _CommunityPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Facebook-style Header: Avatar + Author + Time/Topic + More/Open
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s12,
              AppSpacing.s12,
            ),
            child: Row(
              children: [
                InitialsAvatar(initials: post.authorInitials, size: 40),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: AppTypography.label.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${post.timeAgo} · ${post.topic}',
                            style: AppTypography.caption.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 12,
                            color: c.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showPostThreadSheet(context, post.id),
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: c.textSecondary,
                  ),
                  tooltip: 'Open discussion',
                ),
              ],
            ),
          ),

          // 2. Post Copy (Title + Body)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              0,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.trim().isNotEmpty) ...[
                  Text(
                    post.title,
                    style: AppTypography.label.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  post.body,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // 3. Full-bleed Media (edge-to-edge below text)
          if (post.media != null) CommunityMediaView(media: post.media!),

          // 4. Engagement Counts Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    size: 10,
                    color: AppPalette.neutral0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.likes}',
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => showPostThreadSheet(context, post.id),
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      '${post.comments.length} '
                      '${post.comments.length == 1 ? 'comment' : 'comments'}',
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Divider + 3-Column Action Bar (Like, Comment, Save)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Divider(height: 1, color: c.borderDefault),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PostActionButton(
                    icon: post.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: 'Like',
                    active: post.isLiked,
                    onTap: () =>
                        context.read<CommunityCubit>().toggleLike(post.id),
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: () => showPostThreadSheet(context, post.id),
                  ),
                ),
                Expanded(
                  child: _PostActionButton(
                    icon: post.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: post.isSaved ? 'Saved' : 'Save',
                    active: post.isSaved,
                    onTap: () =>
                        context.read<CommunityCubit>().toggleSave(post.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? AppPalette.blue500 : c.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

