import 'package:equatable/equatable.dart';

enum BookFormat { epub, pdf, txt }

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final BookFormat format;
  final int totalPages;
  final int lastReadPage;
  final double readProgress; // 0.0 -> 1.0
  final int totalMinutesRead;
  final List<int> bookmarkedPages;
  final int lastOpenedTimestamp;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    this.totalPages = 0,
    this.lastReadPage = 1,
    this.readProgress = 0.0,
    this.totalMinutesRead = 0,
    this.bookmarkedPages = const [],
    required this.lastOpenedTimestamp,
  });

  BookEntity copyWith({
    int? totalPages,
    int? lastReadPage,
    double? readProgress,
    int? totalMinutesRead,
    List<int>? bookmarkedPages,
    int? lastOpenedTimestamp,
  }) {
    return BookEntity(
      id: id,
      title: title,
      author: author,
      filePath: filePath,
      format: format,
      totalPages: totalPages ?? this.totalPages,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      readProgress: readProgress ?? this.readProgress,
      totalMinutesRead: totalMinutesRead ?? this.totalMinutesRead,
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      lastOpenedTimestamp: lastOpenedTimestamp ?? this.lastOpenedTimestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        filePath,
        format,
        totalPages,
        lastReadPage,
        readProgress,
        totalMinutesRead,
        bookmarkedPages,
        lastOpenedTimestamp,
      ];
}
