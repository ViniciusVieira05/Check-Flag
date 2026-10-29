import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dados/repositorio_paises.dart';
import 'servicos/servico_audio.dart';
import 'servicos/servico_preferencias.dart';
import 'servicos/servico_ranking.dart';
import 'telas/tela_menu.dart';
import 'tema/tema_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CountryRepository.instance.load();
  await SettingsService.instance.load();
  await ScoreService.instance.load();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const CheckFlagApp());

  AudioService.instance.init();
}

class CheckFlagApp extends StatefulWidget {
  const CheckFlagApp({super.key});

  @override
  State<CheckFlagApp> createState() => _CheckFlagAppState();
}

class _CheckFlagAppState extends State<CheckFlagApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService.instance.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioService.instance.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Flag',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MenuScreen(),
    );
  }
}
