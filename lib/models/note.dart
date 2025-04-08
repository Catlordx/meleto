class Note {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> tags;
  final int likes;
  final List<Review>? reviews;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.tags,
    this.likes = 0,
    this.reviews,
  });
}

class Review {
  final String id;
  final String noteId;
  final String userId;
  final String userName;
  final String content;
  final int rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.rating,
    required this.createdAt,
  });
}