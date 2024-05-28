class CommentItem {
  final String finalNote;

  CommentItem({
    required this.finalNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'finalNote': finalNote,
    };
  }
}
