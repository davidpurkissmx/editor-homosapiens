import 'package:flutter/material.dart';

import 'models/editor_config.dart';
import 'services/command_builder.dart';

void main() {
  runApp(const EditorApp());
}

class EditorApp extends StatelessWidget {
  const EditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Editor Homosapiens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  EditorConfig _config = EditorConfig();
  bool _isProcessing = false;
  double _progress = 0;
  final List<String> _log = [];

  void _addLog(String msg) {
    setState(() {
      _log.add('[${DateTime.now().toString().substring(11, 19)}] $msg');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Homosapiens'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionVideos(theme),
                  const SizedBox(height: 12),
                  _sectionOperations(theme),
                  const SizedBox(height: 12),
                  _sectionColorFilter(theme),
                  const SizedBox(height: 12),
                  _sectionWatermark(theme),
                  const SizedBox(height: 12),
                  _sectionOutro(theme),
                  const SizedBox(height: 12),
                  _sectionOutput(theme),
                ],
              ),
            ),
          ),
          _sectionBottom(theme),
        ],
      ),
    );
  }

  // ─── Videos ────────────────────────────────────────────────────────
  Widget _sectionVideos(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Videos (${_config.videos.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _addLog('Agregar videos (funcionalidad pendiente)');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _config.videos.isEmpty
                      ? null
                      : () {
                          setState(() => _config.videos.removeLast());
                          _addLog('Video removido');
                        },
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Quitar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_config.videos.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withAlpha(80)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('Arrastra o agrega videos aqui',
                      style: TextStyle(color: theme.colorScheme.outline)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _config.videos.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.movie),
                  title: Text(
                    _config.videos[i].split('/').last.split('\\').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Operaciones ────────────────────────────────────────────────────
  Widget _sectionOperations(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operaciones',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Rotar
            SwitchListTile(
              title: const Text('Rotar a vertical'),
              value: _config.doRotate,
              onChanged: (v) => setState(() => _config.doRotate = v),
              dense: true,
            ),
            if (_config.doRotate)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [
                    ChoiceChip(
                        label: const Text('90° derecha'),
                        selected: _config.rotationDir == 'cw',
                        onSelected: (_) =>
                            setState(() => _config.rotationDir = 'cw')),
                    const SizedBox(width: 8),
                    ChoiceChip(
                        label: const Text('90° izquierda'),
                        selected: _config.rotationDir == 'ccw',
                        onSelected: (_) =>
                            setState(() => _config.rotationDir = 'ccw')),
                  ],
                ),
              ),
            const Divider(),

            // Velocidad
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                spacing: 4,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8, top: 8),
                    child: Text('Velocidad:'),
                  ),
                  ...['0.5×', '0.75×', 'Normal', '1.5×', '2×'].map((label) {
                    final val = [0.5, 0.75, 1.0, 1.5, 2.0][
                        ['0.5×', '0.75×', 'Normal', '1.5×', '2×']
                            .indexOf(label)];
                    return ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      selected: (_config.speed - val).abs() < 0.001,
                      onSelected: (_) => setState(() => _config.speed = val),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ],
              ),
            ),
            const Divider(),

            // Musica
            SwitchListTile(
              title: const Text('Musica de fondo'),
              value: _config.doMusic,
              onChanged: (v) => setState(() => _config.doMusic = v),
              dense: true,
            ),
            if (_config.doMusic) ...[
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Carpeta: '),
                        Expanded(
                            child: Text(
                                _config.musicFolder.isNotEmpty
                                    ? _config.musicFolder.split('\\').last
                                    : '...',
                                style: TextStyle(
                                    color: theme.colorScheme.outline))),
                        IconButton(
                            icon: const Icon(Icons.folder_open, size: 20),
                            onPressed: () => _addLog(
                                'Seleccionar carpeta (pendiente)')),
                      ],
                    ),
                    SwitchListTile(
                        title: const Text('Mezclar audio'),
                        value: _config.mixAudio,
                        onChanged: (v) =>
                            setState(() => _config.mixAudio = v),
                        dense: true),
                    Row(
                      children: [
                        ChoiceChip(
                            label: const Text('Aleatoria'),
                            selected: _config.musicOrder == 'random',
                            onSelected: (_) => setState(
                                () => _config.musicOrder = 'random')),
                        const SizedBox(width: 8),
                        ChoiceChip(
                            label: const Text('Secuencial'),
                            selected: _config.musicOrder == 'sequential',
                            onSelected: (_) => setState(
                                () => _config.musicOrder = 'sequential')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Vol: '),
                        Expanded(
                          child: Slider(
                            value: _config.musicVolume.toDouble(),
                            min: 10,
                            max: 100,
                            divisions: 9,
                            label: '${_config.musicVolume}',
                            onChanged: (v) => setState(
                                () => _config.musicVolume = v.round()),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        FilterChip(
                            label: const Text('Fade in'),
                            selected: _config.doFadeIn,
                            onSelected: (v) =>
                                setState(() => _config.doFadeIn = v)),
                        const SizedBox(width: 8),
                        FilterChip(
                            label: const Text('Fade out'),
                            selected: _config.doFadeOut,
                            onSelected: (v) =>
                                setState(() => _config.doFadeOut = v)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Recortar
            SwitchListTile(
              title: const Text('Recortar duracion'),
              value: _config.doTrim,
              onChanged: (v) => setState(() => _config.doTrim = v),
              dense: true,
            ),
            if (_config.doTrim)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [30, 60, 90]
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: ChoiceChip(
                              label: Text('$d seg'),
                              selected: _config.trimDuration == d,
                              onSelected: (_) =>
                                  setState(() => _config.trimDuration = d),
                              visualDensity: VisualDensity.compact,
                            ),
                          ))
                      .toList(),
                ),
              ),
            const Divider(),

            // Transicion
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Text('Transicion:'),
                ),
                FilterChip(
                    label: const Text('Fade in'),
                    selected: _config.doVfadeIn,
                    onSelected: (v) =>
                        setState(() => _config.doVfadeIn = v)),
                const SizedBox(width: 8),
                FilterChip(
                    label: const Text('Fade out'),
                    selected: _config.doVfadeOut,
                    onSelected: (v) =>
                        setState(() => _config.doVfadeOut = v)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filtro de color ────────────────────────────────────────────────
  Widget _sectionColorFilter(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtro de color',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: CommandBuilder.videoFilters.map((f) => ChoiceChip(
                    label: Text(f.name, style: const TextStyle(fontSize: 12)),
                    selected: _config.videoFilter == f.filter,
                    onSelected: (_) => setState(
                        () => _config.videoFilter = f.filter),
                    visualDensity: VisualDensity.compact,
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Marca de agua ──────────────────────────────────────────────────
  Widget _sectionWatermark(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca de agua',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Agregar logo'),
              value: _config.doWatermark,
              onChanged: (v) =>
                  setState(() => _config.doWatermark = v),
              dense: true,
            ),
            if (_config.doWatermark) ...[
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Logo: '),
                        Expanded(
                            child: Text(
                                _config.logoPath.isNotEmpty
                                    ? _config.logoPath.split('\\').last
                                    : '(PNG)',
                                style: TextStyle(
                                    color: theme.colorScheme.outline))),
                        IconButton(
                            icon: const Icon(Icons.folder_open, size: 20),
                            onPressed: () => _addLog(
                                'Seleccionar logo (pendiente)')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Posicion:'),
                    Wrap(
                      spacing: 4,
                      children:
                          CommandBuilder.logoPositions.map((p) => ChoiceChip(
                                label: Text(p.label,
                                    style: const TextStyle(fontSize: 11)),
                                selected: _config.logoPosition == p.value,
                                onSelected: (_) => setState(
                                    () => _config.logoPosition = p.value),
                                visualDensity: VisualDensity.compact,
                              )).toList(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Escala: '),
                        ...['10%', '15%', '20%', '25%', '50%', '75%', '100%']
                            .map((l) {
                          final v =
                              double.parse(l.replaceAll('%', '')).toInt();
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: ChoiceChip(
                              label: Text(l,
                                  style: const TextStyle(fontSize: 11)),
                              selected: _config.logoScale == v,
                              onSelected: (_) =>
                                  setState(() => _config.logoScale = v),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Outro ──────────────────────────────────────────────────────────
  Widget _sectionOutro(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Outro / Cierre',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Logo centrado al final'),
              subtitle: const Text('Usa el logo de Marca de agua',
                  style: TextStyle(fontSize: 11)),
              value: _config.doOutro,
              onChanged: (v) => setState(() => _config.doOutro = v),
              dense: true,
            ),
            if (_config.doOutro)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Duracion: '),
                        ...[1, 2, 3].map((s) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ChoiceChip(
                                label: Text('$s seg'),
                                selected: _config.outroDuration == s,
                                onSelected: (_) => setState(
                                    () => _config.outroDuration = s),
                                visualDensity: VisualDensity.compact,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Tamano: '),
                        ...[('Peq', 150), ('Med', 250), ('Gde', 350), ('XG', 450)]
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: ChoiceChip(
                                    label: Text(t.$1,
                                        style: const TextStyle(fontSize: 11)),
                                    selected:
                                        _config.outroLogoSize == t.$2,
                                    onSelected: (_) => setState(
                                        () => _config.outroLogoSize = t.$2),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Salida ─────────────────────────────────────────────────────────
  Widget _sectionOutput(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Carpeta de salida',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: _config.outputFolder),
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar carpeta...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () =>
                        _addLog('Seleccionar carpeta de salida (pendiente)')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Sufijo: '),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: TextEditingController(text: _config.outputSuffix),
                    decoration: const InputDecoration(
                      hintText: '_historia',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _config.outputSuffix = v,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                    'ej: video → video${_config.outputSuffix}.mp4',
                    style: TextStyle(
                        fontSize: 11, color: theme.colorScheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom bar ─────────────────────────────────────────────────────
  Widget _sectionBottom(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _processVideos,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('PROCESAR VIDEOS'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _isProcessing
                    ? () {
                        setState(() => _isProcessing = false);
                        _addLog('Procesamiento cancelado.');
                      }
                    : null,
                child: const Text('CANCELAR'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isProcessing)
            LinearProgressIndicator(value: _progress),
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: SizedBox(
              height: 120,
              child: _log.isEmpty
                  ? const Center(
                      child: Text('Registro de actividad',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _log.length,
                      itemBuilder: (_, i) => Text(
                        _log[i],
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Processing ─────────────────────────────────────────────────────
  void _processVideos() {
    if (_config.videos.isEmpty) {
      _addLog('ERROR: Agrega al menos un video.');
      return;
    }
    if (_config.outputFolder.isEmpty) {
      _addLog('ERROR: Selecciona carpeta de salida.');
      return;
    }
    if (_config.doMusic && _config.musicFolder.isEmpty) {
      _addLog('ERROR: Selecciona carpeta de musica.');
      return;
    }
    if (!_config.hasAnyOperation) {
      _addLog('ERROR: Activa al menos una operacion.');
      return;
    }

    setState(() => _isProcessing = true);
    _progress = 0;
    _addLog('Iniciando procesamiento de ${_config.videos.length} videos...');

    _simulateBatch();
  }

  void _simulateBatch() {
    int i = 0;
    final n = _config.videos.length;

    Future.doWhile(() async {
      if (!_isProcessing || !mounted) return false;
      await Future.delayed(const Duration(milliseconds: 600));

      final video = _config.videos[i];
      final name = video.split('/').last.split('\\').last;
      final suffix = _config.outputSuffix;
      final output = '${_config.outputFolder}/${name.split('.').first}$suffix.mp4';

      // Build the command (mirrors Python's _build_cmd exactly)
      final cmd = CommandBuilder().build(
        inputVideo: video,
        outputVideo: output,
        config: _config,
        musicFile: _config.doMusic ? 'music.mp3' : null,
        videoDuration: 120.0,
      );

      _addLog('');
      _addLog('[${{i + 1}}/$n] $name');
      _addLog('  Comando: ${cmd.take(6).join(' ')} ...');
      _addLog('  Salida: $output');

      setState(() {
        _progress = (i + 1) / n;
      });

      i++;
      if (i >= n) {
        _isProcessing = false;
        _progress = 1;
        _addLog('');
        _addLog('Listo: $n/$n videos generados.');
        _addLog('(Comandos FFmpeg listos para ejecutar en terminal)');
        return false;
      }
      return true;
    });
  }
}
