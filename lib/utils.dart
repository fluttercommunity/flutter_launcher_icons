

/// Returns true if the file ends in .png to indicate PNG image
bool isPngImage(String backgroundFile) {
  return backgroundFile.endsWith('.png');
}

/// Returns true if the file ends in .svg to indicate SVG image
bool isSvgImage(String backgroundFile) {
  return backgroundFile.endsWith('.svg');
}

String generateSvgToPngFileName(String originalFilePath) {
  return originalFilePath.replaceAll('.svg', '.png');
}


