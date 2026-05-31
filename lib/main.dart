import 'package:flutter/material.dart';

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
  final List<String> _videos = [];

  bool _rotate = false;
  String _rotationDir = 'cw';
  double _speed = 1.0;
  bool _music = false;
  bool _mixAudio = false;
  String _musicOrder = 'random';
  double _musicVolume = 80;
  bool _fadeIn = false;
  bool _fadeOut = false;
  bool _trim = false;
  int _trimDuration = 30;
  bool _vfadeIn = false;
  bool _vfadeOut = false;
  bool _watermark = false;
  String _logoPosition = 'W-w-35:H-h-35';
  double _logoScale = 20;
  bool _outro = false;
  int _outroDuration = 2;
  int _outroLogoSize = 250;

  String _videoFilter = '';
  String _outputSuffix = '_historia';

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
      body: SingleChildScrollView(
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
            const SizedBox(height: 16),
            _sectionBottom(theme),
          ],
        ),
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
            Text('Videos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addLog('Agregar videos (no implementado)'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _videos.isEmpty ? null : () => _addLog('Quitar seleccionados'),
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Quitar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_videos.isEmpty)
              Container(
                height: 120,
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
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.movie),
                    title: Text(_videos[i], overflow: TextOverflow.ellipsis),
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
            Text('Operaciones', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Rotar
            SwitchListTile(
              title: const Text('Rotar a vertical'),
              value: _rotate,
              onChanged: (v) => setState(() => _rotate = v),
              dense: true,
            ),
            if (_rotate)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [
                    ChoiceChip(label: const Text('90° derecha'), selected: _rotationDir == 'cw',
                        onSelected: (_) => setState(() => _rotationDir = 'cw')),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('90° izquierda'), selected: _rotationDir == 'ccw',
                        onSelected: (_) => setState(() => _rotationDir = 'ccw')),
                  ],
                ),
              ),
            const Divider(),

            // Velocidad
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Text('Velocidad: '),
                  ...['0.5x', '0.75x', 'Normal', '1.5x', '2x'].map((label) {
                    final val = [0.5, 0.75, 1.0, 1.5, 2.0][['0.5x', '0.75x', 'Normal', '1.5x', '2x'].indexOf(label)];
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ChoiceChip(
                        label: Text(label, style: const TextStyle(fontSize: 12)),
                        selected: _speed == val,
                        onSelected: (_) => setState(() => _speed = val),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(),

            // Musica
            SwitchListTile(
              title: const Text('Musica de fondo'),
              value: _music,
              onChanged: (v) => setState(() => _music = v),
              dense: true,
            ),
            if (_music) ...[
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Carpeta: '),
                        Expanded(child: Text('...', style: TextStyle(color: theme.colorScheme.outline))),
                        IconButton(icon: const Icon(Icons.folder_open, size: 20), onPressed: () {}),
                      ],
                    ),
                    SwitchListTile(title: const Text('Mezclar audio'), value: _mixAudio,
                        onChanged: (v) => setState(() => _mixAudio = v), dense: true),
                    Row(
                      children: [
                        ChoiceChip(label: const Text('Aleatoria'), selected: _musicOrder == 'random',
                            onSelected: (_) => setState(() => _musicOrder = 'random')),
                        const SizedBox(width: 8),
                        ChoiceChip(label: const Text('Secuencial'), selected: _musicOrder == 'sequential',
                            onSelected: (_) => setState(() => _musicOrder = 'sequential')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Vol: '),
                        Expanded(
                          child: Slider(
                            value: _musicVolume, min: 10, max: 100, divisions: 9,
                            label: '${_musicVolume.toInt()}',
                            onChanged: (v) => setState(() => _musicVolume = v),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        FilterChip(label: const Text('Fade in'), selected: _fadeIn,
                            onSelected: (v) => setState(() => _fadeIn = v)),
                        const SizedBox(width: 8),
                        FilterChip(label: const Text('Fade out'), selected: _fadeOut,
                            onSelected: (v) => setState(() => _fadeOut = v)),
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
              value: _trim,
              onChanged: (v) => setState(() => _trim = v),
              dense: true,
            ),
            if (_trim)
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [30, 60, 90].map((d) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text('$d seg'),
                      selected: _trimDuration == d,
                      onSelected: (_) => setState(() => _trimDuration = d),
                      visualDensity: VisualDensity.compact,
                    ),
                  )).toList(),
                ),
              ),
            const Divider(),

            // Transicion
            Row(
              children: [
                const Text('Transicion: '),
                FilterChip(label: const Text('Fade in'), selected: _vfadeIn,
                    onSelected: (v) => setState(() => _vfadeIn = v)),
                const SizedBox(width: 8),
                FilterChip(label: const Text('Fade out'), selected: _vfadeOut,
                    onSelected: (v) => setState(() => _vfadeOut = v)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filtro de color ────────────────────────────────────────────────
  Widget _sectionColorFilter(ThemeData theme) {
    final filters = [
      ('Sin filtro', ''), ('B&N', 'hue=s=0'), ('Dramatico', ''),
      ('Sepia', ''), ('Vintage', ''), ('Vivid', ''),
      ('Fade', ''), ('Frio', ''), ('Calido', ''),
      ('Cinematico', ''), ('Neon', ''), ('Vignette', ''),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtro de color', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: filters.map((f) => ChoiceChip(
                label: Text(f.$1, style: const TextStyle(fontSize: 12)),
                selected: _videoFilter == f.$2,
                onSelected: (_) => setState(() => _videoFilter = f.$2),
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
            Text('Marca de agua', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Agregar logo'),
              value: _watermark,
              onChanged: (v) => setState(() => _watermark = v),
              dense: true,
            ),
            if (_watermark) ...[
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Logo: '),
                        Expanded(child: Text('(PNG)', style: TextStyle(color: theme.colorScheme.outline))),
                        IconButton(icon: const Icon(Icons.folder_open, size: 20), onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Posicion:'),
                    Wrap(
                      spacing: 4,
                      children: [
                        ('Arriba izq.', '35:35'),
                        ('Arriba der.', 'W-w-35:35'),
                        ('Abajo izq.', '35:H-h-35'),
                        ('Abajo der.', 'W-w-35:H-h-35'),
                      ].map((p) => ChoiceChip(
                        label: Text(p.$1, style: const TextStyle(fontSize: 11)),
                        selected: _logoPosition == p.$2,
                        onSelected: (_) => setState(() => _logoPosition = p.$2),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Escala: '),
                        ...['10%', '15%', '20%', '25%', '50%', '75%', '100%'].map((l) {
                          final v = double.parse(l.replaceAll('%', ''));
                          return Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: ChoiceChip(
                              label: Text(l, style: const TextStyle(fontSize: 11)),
                              selected: _logoScale == v,
                              onSelected: (_) => setState(() => _logoScale = v),
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
            Text('Outro / Cierre', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Logo centrado al final'),
              subtitle: const Text('Usa el logo de Marca de agua', style: TextStyle(fontSize: 11)),
              value: _outro,
              onChanged: (v) => setState(() => _outro = v),
              dense: true,
            ),
            if (_outro)
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
                            selected: _outroDuration == s,
                            onSelected: (_) => setState(() => _outroDuration = s),
                            visualDensity: VisualDensity.compact,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Tamano: '),
                        ...[('Peq', 150), ('Med', 250), ('Gde', 350), ('XG', 450)].map((t) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: ChoiceChip(
                            label: Text(t.$1, style: const TextStyle(fontSize: 11)),
                            selected: _outroLogoSize == t.$2,
                            onSelected: (_) => setState(() => _outroLogoSize = t.$2),
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
            Text('Carpeta de salida', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar carpeta...',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.folder_open), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Sufijo: '),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: TextEditingController(text: _outputSuffix),
                    decoration: const InputDecoration(
                      hintText: '_historia',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _outputSuffix = v,
                  ),
                ),
                const SizedBox(width: 8),
                Text('ej: video → video_historia.mp4',
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom ─────────────────────────────────────────────────────────
  Widget _sectionBottom(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () {
                        setState(() => _isProcessing = true);
                        _addLog('Iniciando procesamiento...');
                        _simulateProcessing();
                      },
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
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: SizedBox(
            height: 150,
            child: _log.isEmpty
                ? const Center(child: Text('Registro de actividad', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Text(
                      _log[i],
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _simulateProcessing() {
    _progress = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!_isProcessing || !mounted) return false;
      setState(() {
        _progress += 0.1;
        if (_progress >= 1) {
          _progress = 1;
          _isProcessing = false;
          _addLog('Procesamiento completado.');
        }
      });
      return _isProcessing && _progress < 1;
    });
  }
}
