import 'package:flutter/material.dart';

void main() {
  runApp(const OttawaApp());
}

class OttawaApp extends StatelessWidget {
  const OttawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Score Ottawa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const OttawaHomePage(),
    );
  }
}

class OttawaHomePage extends StatefulWidget {
  const OttawaHomePage({super.key});

  @override
  State<OttawaHomePage> createState() => _OttawaHomePageState();
}

class _OttawaHomePageState extends State<OttawaHomePage> {
  bool painMalleolaire = false;
  bool douleurTibia = false;
  bool douleurFibula = false;

  bool painMedioPied = false;
  bool douleurBase5 = false;
  bool douleurNaviculaire = false;

  bool appuiImpossible = false;

  bool get radioCheville =>
      painMalleolaire && (douleurTibia || douleurFibula || appuiImpossible);

  bool get radioPied =>
      painMedioPied && (douleurBase5 || douleurNaviculaire || appuiImpossible);

  bool get radioIndiquee => radioCheville || radioPied;

  void reset() {
    setState(() {
      painMalleolaire = false;
      douleurTibia = false;
      douleurFibula = false;
      painMedioPied = false;
      douleurBase5 = false;
      douleurNaviculaire = false;
      appuiImpossible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = radioIndiquee ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score d’Ottawa'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Cheville',
              subtitle: 'Zone malléolaire',
              children: [
                _SwitchLine(
                  title: 'Douleur dans la zone malléolaire',
                  value: painMalleolaire,
                  onChanged: (v) => setState(() => painMalleolaire = v),
                ),
                _SwitchLine(
                  title:
                      'Douleur osseuse bord postérieur/tip malléole médiale',
                  value: douleurTibia,
                  onChanged: (v) => setState(() => douleurTibia = v),
                ),
                _SwitchLine(
                  title:
                      'Douleur osseuse bord postérieur/tip malléole latérale',
                  value: douleurFibula,
                  onChanged: (v) => setState(() => douleurFibula = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Pied',
              subtitle: 'Médio-pied',
              children: [
                _SwitchLine(
                  title: 'Douleur dans la zone du médio-pied',
                  value: painMedioPied,
                  onChanged: (v) => setState(() => painMedioPied = v),
                ),
                _SwitchLine(
                  title: 'Douleur osseuse à la base du 5e métatarsien',
                  value: douleurBase5,
                  onChanged: (v) => setState(() => douleurBase5 = v),
                ),
                _SwitchLine(
                  title: 'Douleur osseuse au naviculaire',
                  value: douleurNaviculaire,
                  onChanged: (v) => setState(() => douleurNaviculaire = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Appui',
              subtitle: 'Marche après traumatisme',
              children: [
                _SwitchLine(
                  title:
                      'Impossible de faire 4 pas immédiatement ET à l’examen',
                  value: appuiImpossible,
                  onChanged: (v) => setState(() => appuiImpossible = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: resultColor.withOpacity(0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    radioIndiquee
                        ? 'Imagerie potentiellement indiquée'
                        : 'Critères d’Ottawa négatifs',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: resultColor.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    radioIndiquee
                        ? '${radioCheville ? "• Radio de cheville à discuter\n" : ""}${radioPied ? "• Radio du pied à discuter\n" : ""}'
                        : 'Aucun critère positif retrouvé. La nécessité d’imagerie paraît faible selon les règles d’Ottawa.',
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Nouveau bilan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Application destinée aux professionnels de santé. '
              'Outil d’aide à la décision ne remplaçant pas l’examen clinique, '
              'le jugement professionnel ni les recommandations locales. '
              'Ne pas utiliser comme diagnostic médical automatisé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),

            const SizedBox(height: 10),

            const Text(
              'Aucune donnée patient n’est stockée dans cette version.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score d’Ottawa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aide à la pertinence de l’imagerie après traumatisme de cheville ou du pied.',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchLine extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchLine({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 15.5)),
      value: value,
      onChanged: onChanged,
    );
  }
}