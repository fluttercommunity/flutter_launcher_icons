class ContentsImageObject {
  ContentsImageObject({
    required this.size,
    required this.idiom,
    required this.filename,
    required this.scale,
  });

  final String size;
  final String idiom;
  final String filename;
  final String scale;

  Map<String, String> toJson() {
    return <String, String>{
      'size': size,
      'idiom': idiom,
      'filename': filename,
      'scale': scale
    };
  }
}


class ContentsInfoObject {
  ContentsInfoObject({
    required this.version,
    required this.author
  });

  final int version;
  final String author;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'author': author,
    };
  }
}