import 'package:flutter/material.dart';

import '../componentes/dialogo_confirmacao.dart';
import '../idiomas/textos.dart';
import '../modelos/configuracao_jogo.dart';
import '../modelos/resultado_jogo.dart';
import '../servicos/servico_ranking.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<GameResult> _all = [];
  bool _loading = true;
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ranking = await ScoreService.instance.loadRanking();
    if (!mounted) return;
    setState(() {
      _all = ranking;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final ok = await showConfirmDialog(
      context,
      title: tr('clearTitle'),
      message: tr('clearMessage'),
      cancelText: tr('back'),
      confirmText: tr('clearConfirm'),
    );
    if (!ok) return;
    await ScoreService.instance.clear();
    _load();
  }

  List<GameResult> get _visible {
    final list = _filter == 0 ? _all : _all.where((r) => r.totalSeconds == _filter).toList();
    return list.take(10).toList();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('ranking')),
        actions: [
          if (_all.isNotEmpty) IconButton(icon: const Icon(Icons.delete), onPressed: _clear),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(tr('all')),
                  selected: _filter == 0,
                  onSelected: (_) => setState(() => _filter = 0),
                ),
                for (final s in kTimeOptions)
                  ChoiceChip(
                    label: Text(timeLabel(s)),
                    selected: _filter == s,
                    onSelected: (_) => setState(() => _filter = s),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _visible;
    if (items.isEmpty) {
      return Center(child: Text(tr('emptyRanking')));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = items[index];
        final position = index + 1;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: position == 1
                ? Colors.amber
                : position == 2
                    ? Colors.grey.shade400
                    : position == 3
                        ? Colors.brown.shade300
                        : Colors.blue.shade50,
            child: Text('$position'),
          ),
          title: Text(r.playerName.isEmpty ? '-' : r.playerName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${modeLabel(r.continentKey)} - ${difficultyLabel(r.difficulty)} - '
            '${timeLabel(r.totalSeconds)} - ${_formatDate(r.date)}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tr('hitsUnit', {'n': '${r.correct}'}),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${r.percentage}%'),
            ],
          ),
        );
      },
    );
  }
}
