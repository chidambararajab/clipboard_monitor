class ClipboardItem {
  final int id;
  final String? text;
  final String? imagePath;

  ClipboardItem({required this.id, this.text, this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
    };
  }
}
