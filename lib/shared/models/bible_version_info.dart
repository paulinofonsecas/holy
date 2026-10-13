// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/models/bible_version_ref.dart';

/// Estado de uma tradução da Bíblia apresentado na UI
/// (sheet de seleção e página de gerenciamento).
class BibleVersionInfo {
  const BibleVersionInfo({
    required this.version,
    this.isDownloaded = false,
    this.isActive = false,
    this.progress,
  });

  /// Tradução em si (metadados de sigla, nome, idioma e ano).
  ///
  /// Pode ser uma tradução oficial (enum) ou uma versão da comunidade.
  final BibleVersionRef version;

  /// `true` quando a versão está disponível offline no dispositivo.
  final bool isDownloaded;

  /// `true` quando é a versão atualmente em uso.
  final bool isActive;

  /// Progresso do download em andamento, quando houver.
  final DownloadProgress? progress;

  /// `true` enquanto um download está em andamento.
  bool get isDownloading =>
      progress != null &&
      (progress!.status == DownloadStatus.downloading ||
          progress!.status == DownloadStatus.extracting);

  /// `true` enquanto o arquivo baixado está sendo processado/descompactado.
  ///
  /// Nesta fase o percentual já chegou a 100%, então a UI deve mostrar um
  /// indicador indeterminado em vez de um valor fixo.
  bool get isExtracting => progress?.status == DownloadStatus.extracting;

  /// `true` quando o último download falhou.
  bool get hasError => progress?.status == DownloadStatus.error;

  BibleVersionInfo copyWith({
    BibleVersionRef? version,
    bool? isDownloaded,
    bool? isActive,
    DownloadProgress? progress,
    bool clearProgress = false,
  }) {
    return BibleVersionInfo(
      version: version ?? this.version,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isActive: isActive ?? this.isActive,
      progress: clearProgress ? null : (progress ?? this.progress),
    );
  }

  @override
  String toString() =>
      'BibleVersionInfo(${version.id}, downloaded: $isDownloaded, '
      'active: $isActive, progress: $progress)';
}
