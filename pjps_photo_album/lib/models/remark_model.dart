class RemarkModel {
  final String id;
  final String remarkBook;
  final String author;
  final String authorName;
  final String remarkType;
  final String visibility;
  final String title;
  final String content;
  final String? attachment;
  final List<RemarkCommentModel> comments;
  final int commentCount;
  final String createdAt;
  final String updatedAt;

  RemarkModel({
    required this.id,
    required this.remarkBook,
    required this.author,
    required this.authorName,
    required this.remarkType,
    required this.visibility,
    required this.title,
    required this.content,
    this.attachment,
    required this.comments,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RemarkModel.fromJson(Map<String, dynamic> json) {
    return RemarkModel(
      id: json['id'],
      remarkBook: json['remark_book'],
      author: json['author'],
      authorName: json['author_name'],
      remarkType: json['remark_type'],
      visibility: json['visibility'],
      title: json['title'],
      content: json['content'],
      attachment: json['attachment'],
      comments: json['comments'] != null
          ? List<RemarkCommentModel>.from(
              json['comments'].map((x) => RemarkCommentModel.fromJson(x)))
          : [],
      commentCount: json['comment_count'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class RemarkCommentModel {
  final String id;
  final String author;
  final String authorName;
  final String content;
  final String createdAt;

  RemarkCommentModel({
    required this.id,
    required this.author,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory RemarkCommentModel.fromJson(Map<String, dynamic> json) {
    return RemarkCommentModel(
      id: json['id'],
      author: json['author'],
      authorName: json['author_name'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}

class RemarkBookModel {
  final String id;
  final String title;
  final List<RemarkModel> remarks;
  final int remarkCount;
  final String? lastRemarkDate;
  final String createdAt;
  final String updatedAt;

  RemarkBookModel({
    required this.id,
    required this.title,
    required this.remarks,
    required this.remarkCount,
    this.lastRemarkDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RemarkBookModel.fromJson(Map<String, dynamic> json) {
    return RemarkBookModel(
      id: json['id'],
      title: json['title'],
      remarks: json['remarks'] != null
          ? List<RemarkModel>.from(
              json['remarks'].map((x) => RemarkModel.fromJson(x)))
          : [],
      remarkCount: json['remark_count'] ?? 0,
      lastRemarkDate: json['last_remark_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
