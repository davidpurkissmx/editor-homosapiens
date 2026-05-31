import 'dart:math';

import '../models/editor_config.dart';

class CommandBuilder {
  static const List<({String name, String filter})> videoFilters = [
    (name: 'Sin filtro', filter: ''),
    (name: 'B&N', filter: 'hue=s=0'),
    (name: 'Dramatico',
        filter: 'hue=s=0,eq=contrast=1.6:brightness=-0.06'),
    (name: 'Sepia',
        filter:
            'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131'),
    (name: 'Vintage',
        filter:
            'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131,vignette=PI/5'),
    (name: 'Vivid', filter: 'eq=saturation=1.8:contrast=1.1:brightness=0.03'),
    (name: 'Fade',
        filter: 'eq=saturation=0.55:brightness=0.1:contrast=0.82'),
    (name: 'Frio', filter: 'colorbalance=bs=0.18:bh=0.09'),
    (name: 'Calido', filter: 'colorbalance=rs=0.14:gs=0.02:rh=0.07'),
    (name: 'Cinematico',
        filter:
            'eq=contrast=1.3:saturation=0.78:brightness=-0.04,vignette=PI/6'),
    (name: 'Neon', filter: 'eq=saturation=2.4:contrast=1.2:brightness=0.02'),
    (name: 'Vignette', filter: 'vignette=PI/4'),
  ];

  static const List<({String label, String value})> logoPositions = [
    (label: 'Arr. izq.', value: '35:35'),
    (label: 'Arr. der.', value: 'W-w-35:35'),
    (label: 'Ab. izq.', value: '35:H-h-35'),
    (label: 'Ab. der.', value: 'W-w-35:H-h-35'),
  ];

  List<String> build({
    required String inputVideo,
    required String outputVideo,
    required EditorConfig config,
    String? musicFile,
    double? videoDuration,
  }) {
    final speed = config.speed;
    final doSpeed = (speed - 1.0).abs() > 0.001;
    final doRot = config.doRotate;
    final vfPreset = config.videoFilter;
    final hasMusic = musicFile != null;
    final logoFile = config.logoPath;
    final hasLogo = config.doWatermark && logoFile.isNotEmpty;
    final doOutro = config.doOutro && logoFile.isNotEmpty;
    final doMix = hasMusic && config.mixAudio;
    final vol = config.musicVolume / 100.0;
    final doFi = hasMusic && config.doFadeIn;
    final doFo = hasMusic && config.doFadeOut;
    final logoScale = config.logoScale;
    final doVfi = config.doVfadeIn;
    final doVfo = config.doVfadeOut && !doOutro;

    // Effective output duration
    double? outDur;
    if (videoDuration != null) {
      outDur = doSpeed ? videoDuration / speed : videoDuration;
      if (config.doTrim) {
        outDur = min(outDur, config.trimDuration.toDouble());
      }
    }

    // Inputs
    final cmd = <String>['ffmpeg', '-y', '-i', inputVideo];
    int musicIdx = -1, logoIdx = -1, outroLogoIdx = -1;
    int nextIn = 1;

    if (hasMusic) {
      musicIdx = nextIn;
      nextIn++;
      cmd.addAll(['-i', musicFile]);
    }
    if (hasLogo) {
      logoIdx = nextIn;
      nextIn++;
      cmd.addAll(['-i', logoFile]);
    }
    if (doOutro) {
      outroLogoIdx = nextIn;
      nextIn++;
      cmd.addAll(['-i', logoFile]);
    }

    // Need filter_complex?
    final needFc = doSpeed ||
        doRot ||
        vfPreset.isNotEmpty ||
        hasLogo ||
        hasMusic ||
        doVfi ||
        doVfo ||
        doOutro;

    if (needFc) {
      final fc = <String>[];
      var vLbl = '[0:v]';
      int n = 0;
      String nxt() => '[vt${++n}]';

      // Step 1: speed + rotation + color filter
      final vf = <String>[];
      if (doSpeed) {
        vf.add('setpts=${(1.0 / speed).toStringAsFixed(6)}*PTS');
      }
      if (doRot) {
        vf.add(config.rotationDir == 'cw' ? 'transpose=1' : 'transpose=2');
      }
      if (vfPreset.isNotEmpty) {
        vf.add(vfPreset);
      }

      if (vf.isNotEmpty) {
        final out = nxt();
        fc.add('$vLbl${vf.join(',')}$out');
        vLbl = out;
      }

      // Step 2: logo watermark
      if (hasLogo) {
        String logoSrc;
        if (logoScale != 100) {
          fc.add(
              '[$logoIdx:v]scale=iw*${(logoScale / 100.0).toStringAsFixed(4)}:-1[logo_s]');
          logoSrc = '[logo_s]';
        } else {
          logoSrc = '[$logoIdx:v]';
        }
        final out = nxt();
        fc.add('$vLbl$logoSrc overlay=${config.logoPosition}$out');
        vLbl = out;
      }

      // Step 3: video fade in
      if (doVfi) {
        final out = nxt();
        fc.add('${vLbl}fade=t=in:st=0:d=1$out');
        vLbl = out;
      }

      // Step 4a: video fade out (no outro)
      if (doVfo && outDur != null) {
        final fadeSt = max(0.0, outDur - 1.0);
        final out = nxt();
        fc.add('${vLbl}fade=t=out:st=${fadeSt.toStringAsFixed(2)}:d=1$out');
        vLbl = out;
      }

      // Step 4b: outro
      else if (doOutro && outDur != null) {
        final outroDurVal = config.outroDuration.toDouble();
        final logoSz = config.outroLogoSize;
        final fadeSt = max(0.0, outDur - outroDurVal);
        final logoAppearSt = fadeSt + 0.6;

        final faded = nxt();
        fc.add('${vLbl}fade=t=out:st=${fadeSt.toStringAsFixed(2)}:d=1$faded');
        fc.add('[$outroLogoIdx:v]scale=$logoSz:-1[otr_s]');
        final out = nxt();
        fc.add(
            '$faded[otr_s]overlay=(W-w)/2:(H-h)/2:enable=\'gte(t,${logoAppearSt.toStringAsFixed(2)})\'$out');
        vLbl = out;
      }

      final vMap = vLbl != '[0:v]' ? vLbl : '0:v';

      // Audio: video original chain
      String a0Lbl = '[0:a]';
      if (doSpeed && (doMix || !hasMusic)) {
        fc.add('[0:a]atempo=${speed.toStringAsFixed(6)}[a0out]');
        a0Lbl = '[a0out]';
      }

      // Audio: music chain
      String? aMap;
      if (hasMusic) {
        final mf = <String>['volume=${vol.toStringAsFixed(4)}'];
        if (doFi) {
          mf.add('afade=t=in:st=0:d=2');
        }
        if (doFo) {
          double? afxSt;
          if (config.doTrim) {
            afxSt = max(0.0, config.trimDuration - 2).toDouble();
          } else if (videoDuration != null) {
            afxSt = max(0.0, videoDuration - 2);
          }
          if (afxSt != null) {
            mf.add('afade=t=out:st=${afxSt.toStringAsFixed(2)}:d=2');
          }
        }
        fc.add('[$musicIdx:a]${mf.join(',')}[mout]');
        if (doMix) {
          fc.add('$a0Lbl[mout]amix=inputs=2:duration=first[aout]');
          aMap = '[aout]';
        } else {
          aMap = '[mout]';
        }
      } else {
        aMap = doSpeed ? a0Lbl : '0:a';
      }

      cmd.addAll(['-filter_complex', fc.join(';')]);
      cmd.addAll(['-map', vMap, '-map', aMap]);
    }

    // Trim
    if (config.doTrim) {
      cmd.addAll(['-t', config.trimDuration.toString()]);
    }

    // Codec + output
    final extra = <String>[];
    if (hasMusic) extra.add('-shortest');
    cmd.addAll(['-c:v', 'libx264', '-c:a', 'aac', ...extra, outputVideo]);

    return cmd;
  }

  static String formatTime(int secs) {
    if (secs < 60) return '${secs}s';
    final m = secs ~/ 60;
    final s = secs % 60;
    if (m < 60) return '${m}m ${s.toString().padLeft(2, '0')}s';
    final h = m ~/ 60;
    final rm = m % 60;
    return '${h}h ${rm.toString().padLeft(2, '0')}m';
  }

  static double? parseOutTime(String line) {
    if (!line.startsWith('out_time=')) return null;
    try {
      final t = line.split('=')[1].trim();
      final parts = t.split(':');
      return int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          double.parse(parts[2]);
    } catch (_) {
      return null;
    }
  }
}
