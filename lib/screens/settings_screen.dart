import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _fontSize = prefs.getDouble('fontSize') ?? 18.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setDouble('fontSize', _fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sozlamalar',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('Ko\'rinish'),
          SwitchListTile(
            title: const Text('Tungi rejim'),
            subtitle: const Text('Qorong\'ida o\'qish uchun'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              _saveSettings();
            },
          ),
          ListTile(
            title: const Text('Shrift o\'lchami'),
            subtitle: Slider(
              value: _fontSize,
              min: 14.0,
              max: 28.0,
              divisions: 7,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() => _fontSize = value);
                _saveSettings();
              },
            ),
          ),
          const Divider(height: 40),
          _buildSection('Bildirishnomalar'),
          SwitchListTile(
            title: const Text('Push bildirishnomalar'),
            subtitle: const Text('Yangi ertaklar haqida xabar olish'),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
              _saveSettings();
            },
          ),
          const Divider(height: 40),
          _buildSection('Ilova haqida'),
          ListTile(
            title: const Text('Versiya'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Biz bilan bog\'laning'),
            trailing: const Icon(Icons.email_outlined),
            onTap: () {
              // TODO: Open email
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'O\'zbek Ertaklari © 2025',
              style: GoogleFonts.openSans(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A237E),
        ),
      ),
    );
  }
}
