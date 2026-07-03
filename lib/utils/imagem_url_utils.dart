/// Converte links de compartilhamento do Google Drive (que abrem uma página
/// HTML de visualização) em um link direto para a imagem, que funciona com
/// Image.network.
///
/// Aceita formatos como:
///   https://drive.google.com/file/d/FILE_ID/view?usp=sharing
///   https://drive.google.com/open?id=FILE_ID
///   https://drive.google.com/uc?id=FILE_ID&export=download
///
/// Se a URL não for do Drive, retorna sem alterações (ex.: Imgur, ImgBB,
/// link direto de site, etc.).
String normalizarUrlImagem(String url) {
  final texto = url.trim();
  if (texto.isEmpty || !texto.contains('drive.google.com')) {
    return texto;
  }

  // Formato: .../file/d/FILE_ID/...
  final regexFileD = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
  final matchFileD = regexFileD.firstMatch(texto);
  if (matchFileD != null) {
    return 'https://lh3.googleusercontent.com/d/${matchFileD.group(1)}';
  }

  // Formato: .../open?id=FILE_ID ou .../uc?id=FILE_ID&export=...
  final regexId = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)');
  final matchId = regexId.firstMatch(texto);
  if (matchId != null) {
    return 'https://lh3.googleusercontent.com/d/${matchId.group(1)}';
  }

  return texto;
}
