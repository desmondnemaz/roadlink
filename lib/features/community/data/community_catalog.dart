import 'dart:typed_data';

/// Media attachment types supported in the Roadlink Car Community.
enum CommunityMediaType { image, video, reel }

/// Represents an uploaded or bundled image, video, or reel attached to a
/// [CommunityPost].
class CommunityMediaAttachment {
  final CommunityMediaType type;
  final String fileName;
  final Uint8List? bytes;
  final String? assetPath;
  final String? videoPath;
  final int? sizeBytes;

  const CommunityMediaAttachment({
    required this.type,
    required this.fileName,
    this.bytes,
    this.assetPath,
    this.videoPath,
    this.sizeBytes,
  });

  String get formattedSize {
    final size = sizeBytes;
    if (size == null || size <= 0) return '';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(0)} KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Validates uploaded media files per `.agent/GEMINI.md` Section 7.
/// Returns `null` when valid, or a user-facing error message when invalid.
String? validateCommunityMediaFile({
  required String fileName,
  required int sizeBytes,
  required CommunityMediaType type,
}) {
  final lower = fileName.toLowerCase();
  final ext = lower.contains('.') ? lower.split('.').last : '';

  if (type == CommunityMediaType.image) {
    const allowedImages = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
    // Web blob filenames may not include an extension; only reject known bad extensions.
    if (ext.isNotEmpty && !allowedImages.contains(ext)) {
      return 'Unsupported image format (.$ext). Use JPG, PNG, or WEBP.';
    }
    const maxImageBytes = 10 * 1024 * 1024;
    if (sizeBytes > maxImageBytes) {
      return 'Image must be 10 MB or smaller.';
    }
    return null;
  }

  const allowedVideos = {'mp4', 'mov', 'webm', 'm4v', 'avi'};
  if (ext.isNotEmpty && !allowedVideos.contains(ext)) {
    return 'Unsupported video format (.$ext). Use MP4, MOV, or WEBM.';
  }
  const maxVideoBytes = 50 * 1024 * 1024;
  if (sizeBytes > maxVideoBytes) {
    return 'Video/Reel must be 50 MB or smaller.';
  }
  return null;
}

/// A reply/comment on a [CommunityPost].
class CommunityComment {
  final String id;
  final String authorName;
  final String authorInitials;
  final String timeAgo;
  final String body;

  const CommunityComment({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.timeAgo,
    required this.body,
  });
}

/// An automotive community discussion post, photo, video, or reel.
class CommunityPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final String topic;
  final String timeAgo;
  final String title;
  final String body;
  final CommunityMediaAttachment? media;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  final List<CommunityComment> comments;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.topic,
    required this.timeAgo,
    required this.title,
    required this.body,
    this.media,
    required this.likes,
    this.isLiked = false,
    this.isSaved = false,
    this.comments = const [],
  });

  bool get isReel => media?.type == CommunityMediaType.reel;

  CommunityPost copyWith({
    int? likes,
    bool? isLiked,
    bool? isSaved,
    List<CommunityComment>? comments,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorInitials: authorInitials,
      topic: topic,
      timeAgo: timeAgo,
      title: title,
      body: body,
      media: media,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      comments: comments ?? this.comments,
    );
  }
}

/// A Zimbabwe automotive club or interest group.
class CommunityGroup {
  final String id;
  final String name;
  final String area;
  final int members;
  final String description;
  final bool isJoined;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.area,
    required this.members,
    required this.description,
    this.isJoined = false,
  });

  CommunityGroup copyWith({bool? isJoined, int? members}) {
    return CommunityGroup(
      id: id,
      name: name,
      area: area,
      members: members ?? this.members,
      description: description,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

/// An automotive meetup, car show, or convoy event.
class CommunityEvent {
  final String id;
  final String title;
  final String dateLabel;
  final String location;
  final int attendees;
  final String description;
  final bool isGoing;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.location,
    required this.attendees,
    required this.description,
    this.isGoing = false,
  });

  CommunityEvent copyWith({bool? isGoing, int? attendees}) {
    return CommunityEvent(
      id: id,
      title: title,
      dateLabel: dateLabel,
      location: location,
      attendees: attendees ?? this.attendees,
      description: description,
      isGoing: isGoing ?? this.isGoing,
    );
  }
}

const List<CommunityPost> kInitialCommunityPosts = [
  CommunityPost(
    id: 'post-tinashe-trip',
    authorName: 'Tinashe K.',
    authorInitials: 'TK',
    topic: 'Maintenance talk',
    timeAgo: '1h ago',
    title: 'What’s on your pre-road-trip checklist?',
    body:
        'Planning a Harare–Bulawayo drive. Tyres, fluids, brakes... '
        'what else do you always check before heading out?',
    likes: 18,
    comments: [
      CommunityComment(
        id: 'c1',
        authorName: 'Nyasha M.',
        authorInitials: 'NM',
        timeAgo: '42m ago',
        body: 'Spare wheel pressure, wheel spanner, and a reflective triangle!',
      ),
      CommunityComment(
        id: 'c2',
        authorName: 'Tawanda C.',
        authorInitials: 'TC',
        timeAgo: '25m ago',
        body: 'Always check coolant hoses and fan belt tension before Gweru.',
      ),
    ],
  ),
  CommunityPost(
    id: 'post-nyasha-meetup',
    authorName: 'Nyasha M.',
    authorInitials: 'NM',
    topic: 'Car meets',
    timeAgo: '2h ago',
    title: 'Good cars. Even better company.',
    body:
        'A few favourites from our weekend catch-up. What are you driving these days?',
    media: CommunityMediaAttachment(
      type: CommunityMediaType.image,
      fileName: 'community_meetup.png',
      assetPath: 'assets/images/community_meetup.png',
    ),
    likes: 32,
    comments: [
      CommunityComment(
        id: 'c3',
        authorName: 'Kuda S.',
        authorInitials: 'KS',
        timeAgo: '1h ago',
        body: 'That W123 Mercedes is spotless! Next meetup in Borrowdale?',
      ),
    ],
  ),
  CommunityPost(
    id: 'post-nyanga-reel',
    authorName: 'Farai C.',
    authorInitials: 'FC',
    topic: '4x4 & Overlanding',
    timeAgo: '3h ago',
    title: 'Sunrise climb up Nyanga mountain pass',
    body:
        'Short reel from our weekend convoy out of Rusape toward World’s View. '
        'Drop your tyres to 1.8 bar on the gravel!',
    media: CommunityMediaAttachment(
      type: CommunityMediaType.reel,
      fileName: 'nyanga_pass_reel.mp4',
      assetPath: 'assets/images/hero_convoy.png',
    ),
    likes: 49,
  ),
  CommunityPost(
    id: 'post-rudo-rusape',
    authorName: 'Rudo B.',
    authorInitials: 'RB',
    topic: 'Road reports',
    timeAgo: '4h ago',
    title: 'Harare–Rusape–Mutare A3 road update',
    body:
        'Clean run past Macheke and Headlands this morning. Watch for heavy '
        'trucks climbing Christmas Pass if you are heading to Mutare.',
    likes: 27,
    comments: [
      CommunityComment(
        id: 'c4',
        authorName: 'Tendai M.',
        authorInitials: 'TM',
        timeAgo: '3h ago',
        body: 'Thanks for the heads-up, passing Rusape shortly.',
      ),
    ],
  ),
];

const List<CommunityGroup> kInitialCommunityGroups = [
  CommunityGroup(
    id: 'grp-harare',
    name: 'Harare Car Lovers',
    area: 'Harare',
    members: 1420,
    description: 'Sunday morning coffee runs, classic restorations, and car meets.',
    isJoined: true,
  ),
  CommunityGroup(
    id: 'grp-rusape',
    name: 'Rusape & Manicaland Drivers',
    area: 'Rusape · Mutare',
    members: 485,
    description: 'A3 highway updates, trusted local mechanics, and convoy trips.',
  ),
  CommunityGroup(
    id: 'grp-4x4',
    name: 'Zim 4x4 & Overlanders',
    area: 'Nationwide',
    members: 930,
    description: 'Nyanga, Chimanimani, Kariba, and Zambezi trail planning.',
  ),
  CommunityGroup(
    id: 'grp-diy',
    name: 'Maintenance & DIY Tech',
    area: 'Nationwide',
    members: 760,
    description: 'Diagnostics, spare parts sourcing, and honest workshop reviews.',
  ),
];

const List<CommunityEvent> kInitialCommunityEvents = [
  CommunityEvent(
    id: 'evt-coffee',
    title: 'Borrowdale Cars & Coffee',
    dateLabel: 'Sat, 22 Nov · 08:00',
    location: 'Sam Levy’s Village, Harare',
    attendees: 64,
    description: 'Casual morning display for classics, JDM, and daily drivers.',
    isGoing: true,
  ),
  CommunityEvent(
    id: 'evt-nyanga',
    title: 'Eastern Highlands Scenic Convoy',
    dateLabel: 'Sun, 30 Nov · 07:00',
    location: 'Rusape → Nyanga',
    attendees: 28,
    description: 'Meet at Rusape Engen at 07:00 sharp for a scenic mountain run.',
  ),
  CommunityEvent(
    id: 'evt-byo',
    title: 'Bulawayo Classic & Custom Show',
    dateLabel: 'Sat, 6 Dec · 10:00',
    location: 'ZITF Grounds, Bulawayo',
    attendees: 112,
    description: 'Vintage builds, sound-off showcase, and local parts stalls.',
  ),
];
