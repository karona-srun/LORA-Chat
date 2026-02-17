import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'screens/channel_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MeshtasticApp());
}

class MeshtasticApp extends StatefulWidget {
  const MeshtasticApp({super.key});

  @override
  State<MeshtasticApp> createState() => _MeshtasticAppState();
}

class _MeshtasticAppState extends State<MeshtasticApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadLocalePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode');
    if (dark != null && mounted) {
      setState(() {
        _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  Future<void> _loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale');
    if (code != null && mounted && (code == 'en' || code == 'km')) {
      setState(() => _locale = Locale(code));
    }
  }

  void _onThemeChanged(bool dark) {
    setState(() {
      _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _onLanguageChanged(bool isKhmer) {
    setState(() {
      _locale = isKhmer ? const Locale('km') : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meshtastic Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.black,
          tertiary: Colors.black,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          onSurfaceVariant: Colors.black87,
          outline: Colors.black,
          outlineVariant: Colors.black54,
          surfaceContainerHighest: Colors.black12,
          surfaceContainerHigh: Colors.black12,
          surfaceContainer: Colors.black12,
          surfaceContainerLow: Colors.black12,
          surfaceBright: Colors.white,
          surfaceDim: Colors.black12,
          inverseSurface: Colors.white,
          onInverseSurface: Colors.black,
          inversePrimary: Colors.white,
          error: Colors.black,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.white,
          onSecondary: Colors.white,
          tertiary: Colors.white,
          onTertiary: Colors.black,
          surface: Colors.black,
          onSurface: Colors.white,
          onSurfaceVariant: Colors.white70,
          outline: Colors.white,
          outlineVariant: Colors.white54,
          surfaceContainerHighest: Colors.white12,
          surfaceContainerHigh: Colors.white12,
          surfaceContainer: Colors.white12,
          surfaceContainerLow: Colors.white12,
          surfaceBright: Colors.white12,
          surfaceDim: Colors.black,
          inverseSurface: Colors.black,
          onInverseSurface: Colors.white,
          inversePrimary: Colors.black,
          error: Colors.white,
          onError: Colors.black,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('km')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AppLocalizations.wrap(
        locale: _locale,
        child: MainScreen(
          onThemeChanged: _onThemeChanged,
          onLanguageChanged: _onLanguageChanged,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    this.onThemeChanged,
    this.onLanguageChanged,
  });

  final void Function(bool dark)? onThemeChanged;
  final void Function(bool isKhmer)? onLanguageChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Start with Channels & Chats tab

  List<Widget> get _screens => [
        const ChannelScreen(),
        const ConnectScreen(),
        SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat),
            label: l10n.tr('messages'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.link),
            label: l10n.tr('connect'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tr('settings'),
          ),
        ],
      ),
    );
  }
}
