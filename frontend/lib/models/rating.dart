class Rating {
  final int id;
  final int fromUserId;
  final String fromUserName;
  final int toUserId;
  final String toUserName;
  final int bookingId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.bookingId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      toUserId: json['toUserId'],
      toUserName: json['toUserName'],
      bookingId: json['bookingId'],
      score: json['score'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'bookingId': bookingId,
      'score': score,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
