class User {
  final int id;
  final String username;
  final String email;
  final String avatar;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'] ?? 0,
      username: json['Username'] ?? '',
      email: json['Email'] ?? '',
      avatar: json['Avatar'] ?? '',
    );
  }
}

class Review {
  final int id;
  final int rating;
  final String comment;
  final int userId;
  final int noteId;
  final DateTime createdAt;
  final String userName; // Added for compatibility with existing code

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userId,
    required this.noteId,
    required this.createdAt,
    this.userName = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['ID'] ?? 0,
      rating: json['Rating'] ?? 0,
      comment: json['Comment'] ?? '',
      userId: json['UserID'] ?? 0,
      noteId: json['NoteID'] ?? 0,
      createdAt: json['CreatedAt'] != null 
          ? DateTime.parse(json['CreatedAt']) 
          : DateTime.now(),
      userName: json['User'] != null ? json['User']['Username'] ?? '' : '',
    );
  }
}

class Note {
  final String id; // Keeping as string to maintain compatibility
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> tags;
  final int likes;
  
  // New fields from API
  final bool isPublic;
  final DateTime updatedAt;
  final User? user;
  final List<Review>? reviews;
  
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.tags,
    required this.likes,
    this.isPublic = true,
    DateTime? updatedAt,
    this.user,
    this.reviews,
  }) : updatedAt = updatedAt ?? createdAt;
  
    factory Note.fromJson(Map<String, dynamic> json) {
    // 检查是否有 data 字段并使用它
    final noteData = json.containsKey('data') ? json['data'] : json;
    
    final user = User.fromJson(noteData['User'] ?? {});
    final reviewsList = (noteData['Reviews'] as List<dynamic>? ?? [])
        .map((reviewJson) => Review.fromJson(reviewJson))
        .toList();
        
    return Note(
      id: noteData['ID'].toString(),
      title: noteData['Title'] ?? '',
      content: noteData['Content'] ?? '',
      authorId: noteData['UserID'].toString(),
      authorName: user.username,
      createdAt: noteData['CreatedAt'] != null ? DateTime.parse(noteData['CreatedAt']) : DateTime.now(),
      updatedAt: noteData['UpdatedAt'] != null ? DateTime.parse(noteData['UpdatedAt']) : null,
      tags: [], // API doesn't provide tags yet
      likes: reviewsList.length, // Count reviews as likes
      isPublic: noteData['IsPublic'] ?? true,
      user: user,
      reviews: reviewsList,
    );
  }
  // factory Note.fromJson(Map<String, dynamic> json) {
  //   final user = User.fromJson(json['User'] ?? {});
  //   final reviewsList = (json['Reviews'] as List<dynamic>? ?? [])
  //       .map((reviewJson) => Review.fromJson(reviewJson))
  //       .toList();
        
  //   return Note(
  //     id: json['ID'].toString(),
  //     title: json['Title'] ?? '',
  //     content: json['Content'] ?? '',
  //     authorId: json['UserID'].toString(),
  //     authorName: user.username,
  //     createdAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : DateTime.now(),
  //     updatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
  //     tags: [], // API doesn't provide tags yet
  //     likes: reviewsList.length, // Count reviews as likes
  //     isPublic: json['IsPublic'] ?? true,
  //     user: user,
  //     reviews: reviewsList,
  //   );
  // }
}