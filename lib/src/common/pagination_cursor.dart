import 'package:meta/meta.dart';

/// {@template pagination_cursor}
/// Paggination cursor, which holds info about current state of pagination
/// {@endtemplate}
@immutable
final class PaginationCursor {
  /// {@macro pagination_cursor}
  const PaginationCursor({required this.hasMore, required this.offset, this.limit = 20});

  /// Factory constructor with default values
  factory PaginationCursor.initial() => const PaginationCursor(hasMore: true, offset: 0);

  /// Indicates whether there are more items to fetch.
  final bool hasMore;

  /// The starting position for the next page of data.
  final int offset;

  /// The maximum number of items to be returned in one page.
  final int limit;

  PaginationCursor copyWith({bool? hasMore, int? offset, int? limit}) =>
      PaginationCursor(hasMore: hasMore ?? this.hasMore, offset: offset ?? this.offset, limit: limit ?? this.limit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationCursor &&
          runtimeType == other.runtimeType &&
          hasMore == other.hasMore &&
          offset == other.offset &&
          limit == other.limit;

  @override
  int get hashCode => hasMore.hashCode ^ offset.hashCode ^ limit.hashCode;
}
