// This is a basic Flutter widget test.
//
import 'package:flutter_test/flutter_test.dart';
import 'package:meleto/models/note.dart';

void main() {
  group('Note.fromJson', () {
    test('should parse complete JSON correctly', () {
      final json = {
        'ID': 123,
        'Title': 'Test Note',
        'Content': 'This is a test note',
        'UserID': 456,
        'CreatedAt': '2023-05-01T10:00:00Z',
        'UpdatedAt': '2023-05-02T11:00:00Z',
        'IsPublic': true,
        'User': {
          'ID': 456,
          'Username': 'testuser',
          'Email': 'test@example.com',
          'Avatar': 'avatar.png',
        },
        'Reviews': [
          {
            'ID': 789,
            'Rating': 5,
            'Comment': 'Great note!',
            'UserID': 101,
            'NoteID': 123,
            'CreatedAt': '2023-05-03T12:00:00Z',
            'User': {'Username': 'reviewer1'},
          },
          {
            'ID': 790,
            'Rating': 4,
            'Comment': 'Good note',
            'UserID': 102,
            'NoteID': 123,
            'CreatedAt': '2023-05-04T13:00:00Z',
            'User': {'Username': 'reviewer2'},
          },
        ],
      };

      final note = Note.fromJson(json);

      expect(note.id, '123');
      expect(note.title, 'Test Note');
      expect(note.content, 'This is a test note');
      expect(note.authorId, '456');
      expect(note.authorName, 'testuser');
      expect(note.createdAt, DateTime.parse('2023-05-01T10:00:00Z'));
      expect(note.updatedAt, DateTime.parse('2023-05-02T11:00:00Z'));
      expect(note.isPublic, true);
      expect(note.likes, 2); // Two reviews
      expect(note.tags, isEmpty);

      // Check user data
      expect(note.user?.id, 456);
      expect(note.user?.username, 'testuser');
      expect(note.user?.email, 'test@example.com');

      // Check reviews data
      expect(note.reviews?.length, 2);
      expect(note.reviews?[0].rating, 5);
      expect(note.reviews?[0].comment, 'Great note!');
      expect(note.reviews?[1].userName, 'reviewer2');
    });

    test('should handle missing or null fields gracefully', () {
      final json = {
        'ID': 123,
        // Missing Title, Content
        'UserID': 456,
        // Missing dates
        'User': {
          'ID': 456,
          // Missing other user fields
        },
        // Missing Reviews
      };

      final note = Note.fromJson(json);

      expect(note.id, '123');
      expect(note.title, '');
      expect(note.content, '');
      expect(note.authorId, '456');
      expect(note.likes, 0);
      expect(note.isPublic, true);
      expect(note.reviews, isEmpty);
    });
  });
}
