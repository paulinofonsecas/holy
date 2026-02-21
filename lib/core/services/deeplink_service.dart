import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:eu_sou/core/services/logger_service.dart';

abstract class IDeeplinkService {
  /// Stream of incoming deep links (handles background/foreground)
  Stream<Uri?> get onLink;

  /// Retrieves the link that launched the app (handles app killed state)
  Future<Uri?> getInitialLink();

  /// Generates a link for sharing a specific verse
  /// [verseRef]: format "bookId_chapter_verse"
  Future<String> createShortLink({required String verseRef, String? source});

  /// Parses raw URI into structured data for the app
  Map<String, String>? parseLink(Uri uri);
}

class DeeplinkService implements IDeeplinkService {
  final AppLinks _appLinks = AppLinks();
  final LoggerService _logger = LoggerService();

  @override
  Stream<Uri?> get onLink => _appLinks.uriLinkStream.map((uri) {
        _logger.info('Foreground deep link received: $uri');
        return uri;
      });

  @override
  Future<Uri?> getInitialLink() async {
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _logger.info('Initial deep link received: $uri');
    }
    return uri;
  }

  @override
  Future<String> createShortLink({
    required String verseRef,
    String? source,
  }) async {
    final link =
        'holy://share?v=$verseRef${source != null ? '&utm_source=$source' : ''}';
    _logger.info('Generated deep link: $link');
    return link;
  }

  @override
  Map<String, String>? parseLink(Uri uri) {
    _logger.info('Parsing deep link: $uri');

    // Support both custom scheme (holy://share) and the previous https domain (links.holy.app/share)
    final bool isCorrectHost =
        uri.host == 'links.holy.app' || uri.host == 'share';
    final bool isCorrectPath =
        uri.path == '/share' || uri.path == '' || uri.path == '/';
    final bool isCorrectScheme = uri.scheme == 'https' || uri.scheme == 'holy';

    if (isCorrectScheme && isCorrectHost && isCorrectPath) {
      final String? verseRef = uri.queryParameters['v'];
      if (verseRef != null) {
        final List<String> parts = verseRef.split('_');
        if (parts.length >= 2) {
          final result = {
            'bookId': parts[0],
            'chapter': parts[1],
            if (parts.length > 2) 'verse': parts[2],
          };
          _logger.info('Deep link parsed successfully: $result');
          return result;
        }
      }
    }
    _logger.warning('Failed to parse deep link or invalid format: $uri');
    return null;
  }
}
