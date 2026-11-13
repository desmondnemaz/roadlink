import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/features/community/data/community_catalog.dart';

class CommunityState extends Equatable {
  final List<CommunityPost> posts;
  final List<CommunityGroup> groups;
  final List<CommunityEvent> events;

  const CommunityState({
    this.posts = kInitialCommunityPosts,
    this.groups = kInitialCommunityGroups,
    this.events = kInitialCommunityEvents,
  });

  CommunityState copyWith({
    List<CommunityPost>? posts,
    List<CommunityGroup>? groups,
    List<CommunityEvent>? events,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      groups: groups ?? this.groups,
      events: events ?? this.events,
    );
  }

  @override
  List<Object?> get props => [posts, groups, events];
}

/// Manages Roadlink Car Community feed posts, comments, clubs, and events.
class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit() : super(const CommunityState());

  void toggleLike(String postId) {
    final updated = state.posts.map((post) {
      if (post.id != postId) return post;
      final nextLiked = !post.isLiked;
      return post.copyWith(
        isLiked: nextLiked,
        likes: nextLiked ? post.likes + 1 : post.likes - 1,
      );
    }).toList();
    emit(state.copyWith(posts: updated));
  }

  void toggleSave(String postId) {
    final updated = state.posts.map((post) {
      if (post.id != postId) return post;
      return post.copyWith(isSaved: !post.isSaved);
    }).toList();
    emit(state.copyWith(posts: updated));
  }

  void addPost({
    required String title,
    required String body,
    required String topic,
    CommunityMediaAttachment? media,
  }) {
    final newPost = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Tendai M.',
      authorInitials: 'TM',
      topic: topic,
      timeAgo: 'Just now',
      title: title.trim(),
      body: body.trim(),
      media: media,
      likes: 0,
    );
    emit(state.copyWith(posts: [newPost, ...state.posts]));
  }

  void addComment({required String postId, required String body}) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    final updated = state.posts.map((post) {
      if (post.id != postId) return post;
      final comment = CommunityComment(
        id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
        authorName: 'Tendai M.',
        authorInitials: 'TM',
        timeAgo: 'Just now',
        body: trimmed,
      );
      return post.copyWith(comments: [...post.comments, comment]);
    }).toList();

    emit(state.copyWith(posts: updated));
  }

  void toggleJoinGroup(String groupId) {
    final updated = state.groups.map((group) {
      if (group.id != groupId) return group;
      final nextJoined = !group.isJoined;
      return group.copyWith(
        isJoined: nextJoined,
        members: nextJoined ? group.members + 1 : group.members - 1,
      );
    }).toList();
    emit(state.copyWith(groups: updated));
  }

  void toggleEventRsvp(String eventId) {
    final updated = state.events.map((event) {
      if (event.id != eventId) return event;
      final nextGoing = !event.isGoing;
      return event.copyWith(
        isGoing: nextGoing,
        attendees: nextGoing ? event.attendees + 1 : event.attendees - 1,
      );
    }).toList();
    emit(state.copyWith(events: updated));
  }
}

