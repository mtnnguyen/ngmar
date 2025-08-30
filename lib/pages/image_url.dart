String buildImageBase(String imageHost, String siteName) {
  final host = imageHost.endsWith('/') ? imageHost.substring(0, imageHost.length - 1) : imageHost;
  final site = siteName.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  return '$host/images/$site/';
}

String? normalizeImageUrl(String? url, {required String imageHost, required String siteName}) {
  if (url == null) return null;
  final u = url.trim();
  if (u.isEmpty) return null;

  final base = buildImageBase(imageHost, siteName);
  final isAbs = u.startsWith('http://') || u.startsWith('https://');

  if (isAbs) {
    final idx = u.indexOf('/images/');
    if (idx != -1) {
      final after = u.substring(idx + '/images/'.length);
      final remainder = after.startsWith('$siteName/') ? after.substring('$siteName/'.length) : after;
      return '$base$remainder';
    }
    return u; // absolute but not under /images/
  }

  if (u.startsWith('/images/')) {
    final after = u.substring('/images/'.length);
    final remainder = after.startsWith('$siteName/') ? after.substring('$siteName/'.length) : after;
    return '$base$remainder';
  }

  return '$base$u'; // relative like CAM_001/...
}
