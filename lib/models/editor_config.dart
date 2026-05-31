class EditorConfig {
  // Video list
  List<String> videos;

  // Rotate
  bool doRotate;
  String rotationDir; // "cw" | "ccw"

  // Speed
  double speed; // 0.5, 0.75, 1.0, 1.5, 2.0

  // Music
  bool doMusic;
  bool mixAudio;
  String musicOrder; // "random" | "sequential"
  int musicVolume; // 10-100 step 10
  bool doFadeIn;
  bool doFadeOut;
  String musicFolder;

  // Trim
  bool doTrim;
  int trimDuration; // 30, 60, 90

  // Video transitions
  bool doVfadeIn;
  bool doVfadeOut;

  // Color filter
  String videoFilter; // "" = sin filtro

  // Watermark
  bool doWatermark;
  String logoPath;
  String logoPosition; // "35:35", "W-w-35:35", etc.
  int logoScale; // 10, 15, 20, 25, 50, 75, 100

  // Outro
  bool doOutro;
  int outroDuration; // 1, 2, 3
  int outroLogoSize; // 150, 250, 350, 450

  // Output
  String outputFolder;
  String outputSuffix;

  // Player
  Set<String> favorites;
  List<String> recents;
  String? lockedSong;

  EditorConfig({
    this.videos = const [],
    this.doRotate = false,
    this.rotationDir = 'cw',
    this.speed = 1.0,
    this.doMusic = false,
    this.mixAudio = false,
    this.musicOrder = 'random',
    this.musicVolume = 80,
    this.doFadeIn = false,
    this.doFadeOut = false,
    this.musicFolder = '',
    this.doTrim = false,
    this.trimDuration = 30,
    this.doVfadeIn = false,
    this.doVfadeOut = false,
    this.videoFilter = '',
    this.doWatermark = false,
    this.logoPath = '',
    this.logoPosition = 'W-w-35:H-h-35',
    this.logoScale = 20,
    this.doOutro = false,
    this.outroDuration = 2,
    this.outroLogoSize = 250,
    this.outputFolder = '',
    this.outputSuffix = '_historia',
    this.favorites = const {},
    this.recents = const [],
    this.lockedSong,
  });

  bool get hasAnyOperation =>
      doRotate ||
      (speed - 1.0).abs() > 0.001 ||
      doMusic ||
      doTrim ||
      doWatermark ||
      doVfadeIn ||
      doVfadeOut ||
      videoFilter.isNotEmpty ||
      doOutro;

  EditorConfig copy() => EditorConfig(
        videos: List.from(videos),
        doRotate: doRotate,
        rotationDir: rotationDir,
        speed: speed,
        doMusic: doMusic,
        mixAudio: mixAudio,
        musicOrder: musicOrder,
        musicVolume: musicVolume,
        doFadeIn: doFadeIn,
        doFadeOut: doFadeOut,
        musicFolder: musicFolder,
        doTrim: doTrim,
        trimDuration: trimDuration,
        doVfadeIn: doVfadeIn,
        doVfadeOut: doVfadeOut,
        videoFilter: videoFilter,
        doWatermark: doWatermark,
        logoPath: logoPath,
        logoPosition: logoPosition,
        logoScale: logoScale,
        doOutro: doOutro,
        outroDuration: outroDuration,
        outroLogoSize: outroLogoSize,
        outputFolder: outputFolder,
        outputSuffix: outputSuffix,
        favorites: Set.from(favorites),
        recents: List.from(recents),
        lockedSong: lockedSong,
      );

  Map<String, dynamic> toJson() => {
        'videos': videos,
        'doRotate': doRotate,
        'rotationDir': rotationDir,
        'speed': speed,
        'doMusic': doMusic,
        'mixAudio': mixAudio,
        'musicOrder': musicOrder,
        'musicVolume': musicVolume,
        'doFadeIn': doFadeIn,
        'doFadeOut': doFadeOut,
        'musicFolder': musicFolder,
        'doTrim': doTrim,
        'trimDuration': trimDuration,
        'doVfadeIn': doVfadeIn,
        'doVfadeOut': doVfadeOut,
        'videoFilter': videoFilter,
        'doWatermark': doWatermark,
        'logoPath': logoPath,
        'logoPosition': logoPosition,
        'logoScale': logoScale,
        'doOutro': doOutro,
        'outroDuration': outroDuration,
        'outroLogoSize': outroLogoSize,
        'outputFolder': outputFolder,
        'outputSuffix': outputSuffix,
        'favorites': favorites.toList(),
        'recents': recents,
        'lockedSong': lockedSong ?? '',
      };

  factory EditorConfig.fromJson(Map<String, dynamic> json) => EditorConfig(
        videos: List<String>.from(json['videos'] ?? []),
        doRotate: json['doRotate'] ?? false,
        rotationDir: json['rotationDir'] ?? 'cw',
        speed: (json['speed'] ?? 1.0).toDouble(),
        doMusic: json['doMusic'] ?? false,
        mixAudio: json['mixAudio'] ?? false,
        musicOrder: json['musicOrder'] ?? 'random',
        musicVolume: json['musicVolume'] ?? 80,
        doFadeIn: json['doFadeIn'] ?? false,
        doFadeOut: json['doFadeOut'] ?? false,
        musicFolder: json['musicFolder'] ?? '',
        doTrim: json['doTrim'] ?? false,
        trimDuration: json['trimDuration'] ?? 30,
        doVfadeIn: json['doVfadeIn'] ?? false,
        doVfadeOut: json['doVfadeOut'] ?? false,
        videoFilter: json['videoFilter'] ?? '',
        doWatermark: json['doWatermark'] ?? false,
        logoPath: json['logoPath'] ?? '',
        logoPosition: json['logoPosition'] ?? 'W-w-35:H-h-35',
        logoScale: json['logoScale'] ?? 20,
        doOutro: json['doOutro'] ?? false,
        outroDuration: json['outroDuration'] ?? 2,
        outroLogoSize: json['outroLogoSize'] ?? 250,
        outputFolder: json['outputFolder'] ?? '',
        outputSuffix: json['outputSuffix'] ?? '_historia',
        favorites: Set<String>.from(json['favorites'] ?? []),
        recents: List<String>.from(json['recents'] ?? []),
        lockedSong:
            (json['lockedSong'] as String?)?.isEmpty == true || json['lockedSong'] == null
                ? null
                : json['lockedSong'],
      );
}
