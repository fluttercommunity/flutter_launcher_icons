class WebIconTemplate {
  const WebIconTemplate({
    required this.size,
    this.maskable = false,
  });

  final int size;
  final bool maskable;

  /// Icon file name
  String get iconFile => 'Icon${maskable ? '-maskable' : ''}-$size.png';

  /// Icon config for manifest.json
  ///
  /// ```json
  ///  {
  ///         "src": "icons/Icon-maskable-192.png",
  ///         "sizes": "192x192",
  ///         "type": "image/png",
  ///         "purpose": "maskable"
  ///  },
  /// ```
  Map<String, dynamic> get iconManifest {
    return <String, dynamic>{
      'src': 'icons/$iconFile',
      'sizes': '${size}x$size',
      'type': 'image/png',
      if (maskable) 'purpose': 'maskable',
    };
  }
}
