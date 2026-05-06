import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const OttawaApp());
}

class OttawaApp extends StatelessWidget {
  const OttawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Score Ottawa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: const OttawaPage(),
    );
  }
}

class OttawaPage extends StatefulWidget {
  const OttawaPage({super.key});

  @override
  State<OttawaPage> createState() => _OttawaPageState();
}

class _OttawaPageState extends State<OttawaPage> {
  bool douleurMalleolaire = false;
  bool douleurMalleoleMediale = false;
  bool douleurMalleoleLaterale = false;

  bool douleurMedioPied = false;
  bool douleurCinquiemeMeta = false;
  bool douleurNaviculaire = false;

  bool appuiImpossible = false;
  bool consentementPdf = false;

  bool get radioCheville {
    return douleurMalleolaire &&
        (douleurMalleoleMediale ||
            douleurMalleoleLaterale ||
            appuiImpossible);
  }

  bool get radioPied {
    return douleurMedioPied &&
        (douleurCinquiemeMeta || douleurNaviculaire || appuiImpossible);
  }

  bool get imagerieIndiquee {
    return radioCheville || radioPied;
  }

  int get totalOui {
    return [
      douleurMalleolaire,
      douleurMalleoleMediale,
      douleurMalleoleLaterale,
      douleurMedioPied,
      douleurCinquiemeMeta,
      douleurNaviculaire,
      appuiImpossible,
    ].where((element) => element).length;
  }

  void reinitialiser() {
    setState(() {
      douleurMalleolaire = false;
      douleurMalleoleMediale = false;
      douleurMalleoleLaterale = false;
      douleurMedioPied = false;
      douleurCinquiemeMeta = false;
      douleurNaviculaire = false;
      appuiImpossible = false;
      consentementPdf = false;
    });
  }

  Future<void> exporterPdf() async {
    if (!consentementPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci de cocher le consentement avant export PDF.'),
        ),
      );
      return;
    }

    final pdfData = await creerPdf();

    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'score_ottawa.pdf',
    );
  }

  Future<Uint8List> creerPdf() async {
  final document = pw.Document();
  final date = DateTime.now();

  String ouiNon(bool value) {
    return value ? 'Oui' : 'Non';
  }

  final resultat = imagerieIndiquee
      ? 'Imagerie potentiellement indiquee'
      : "Criteres d'Ottawa negatifs";

  final detail = imagerieIndiquee
      ? '${radioCheville ? '- Radiographie de cheville a discuter.\n' : ''}${radioPied ? '- Radiographie du pied a discuter.' : ''}'
      : "Aucun critere positif retrouve. La necessite d'imagerie parait faible selon les regles d'Ottawa.";

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (context) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300),
            ),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                "Score Ottawa - Outil d'aide a la decision clinique",
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "© 2026 MB - Tous droits reserves",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "Ne constitue pas un diagnostic medical automatise.",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        );
      },
      build: (context) {
        return [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#2563EB'),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Score Ottawa - Cheville / Pied',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  "Aide a la pertinence de l'imagerie apres traumatisme.",
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Date : ${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Criteres evalues',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('- Douleur dans la zone malleolaire : ${ouiNon(douleurMalleolaire)}'),
          pw.Text('- Douleur osseuse malleole mediale : ${ouiNon(douleurMalleoleMediale)}'),
          pw.Text('- Douleur osseuse malleole laterale : ${ouiNon(douleurMalleoleLaterale)}'),
          pw.Text('- Douleur dans la zone du medio-pied : ${ouiNon(douleurMedioPied)}'),
          pw.Text('- Douleur base du 5e metatarsien : ${ouiNon(douleurCinquiemeMeta)}'),
          pw.Text('- Douleur osseuse au naviculaire : ${ouiNon(douleurNaviculaire)}'),
          pw.Text('- Impossible de faire 4 pas : ${ouiNon(appuiImpossible)}'),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: imagerieIndiquee
                  ? PdfColor.fromHex('#FEE2E2')
                  : PdfColor.fromHex('#DCFCE7'),
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(
                color: imagerieIndiquee
                    ? PdfColor.fromHex('#DC2626')
                    : PdfColor.fromHex('#16A34A'),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resultat,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: imagerieIndiquee
                        ? PdfColor.fromHex('#991B1B')
                        : PdfColor.fromHex('#166534'),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  detail,
                  style: const pw.TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 28),
          pw.Text(
            'Consentement et RGPD',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Le patient a ete informe de la generation de ce document PDF. "
            "Cette application ne stocke aucune donnee nominative ni donnee de sante dans cette version. "
            "Le document exporte devient un document de sante relevant des regles professionnelles applicables.",
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Mention de prudence',
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Outil d'aide a la decision clinique. "
            "Ne remplace pas l'examen clinique, le jugement professionnel ni les recommandations locales. "
            "Ne constitue pas un diagnostic medical automatise.",
            style: const pw.TextStyle(fontSize: 11),
          ),
        ];
      },
    ),
  );

  return document.save();
}

  @override
  Widget build(BuildContext context) {
    final Color resultatCouleur =
        imagerieIndiquee ? const Color(0xFFDC2626) : const Color(0xFF16A34A);

    final String resultatTitre = imagerieIndiquee
        ? 'Imagerie potentiellement indiquée'
        : 'Critères d’Ottawa négatifs';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Ottawa'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF06B6D4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Règles d’Ottawa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aide à décider si une radiographie est pertinente après traumatisme de cheville ou du pied.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Progression',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: totalOui / 7,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 8),
                Text('$totalOui critère(s) sélectionné(s) sur 7'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Cheville',
            child: Column(
              children: [
                _QuestionSwitch(
                  title: 'Douleur dans la zone malléolaire',
                  subtitle: 'Douleur autour des malléoles interne ou externe.',
                  value: douleurMalleolaire,
                  onChanged: (value) {
                    setState(() {
                      douleurMalleolaire = value;
                    });
                  },
                ),
                _QuestionSwitch(
                  title: 'Douleur osseuse malléole médiale',
                  subtitle:
                      'Douleur sur le bord postérieur du tibia distal ou à la pointe de la malléole interne.',
                  value: douleurMalleoleMediale,
                  onChanged: (value) {
                    setState(() {
                      douleurMalleoleMediale = value;
                    });
                  },
                ),
                _QuestionSwitch(
                  title: 'Douleur osseuse malléole latérale',
                  subtitle:
                      'Douleur sur le bord postérieur de la fibula distale ou à la pointe de la malléole externe.',
                  value: douleurMalleoleLaterale,
                  onChanged: (value) {
                    setState(() {
                      douleurMalleoleLaterale = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Pied',
            child: Column(
              children: [
                _QuestionSwitch(
                  title: 'Douleur dans la zone du médio-pied',
                  subtitle: 'Douleur au niveau de la partie centrale du pied.',
                  value: douleurMedioPied,
                  onChanged: (value) {
                    setState(() {
                      douleurMedioPied = value;
                    });
                  },
                ),
                _QuestionSwitch(
                  title: 'Douleur base du 5e métatarsien',
                  subtitle: 'Douleur osseuse sur le bord externe du pied.',
                  value: douleurCinquiemeMeta,
                  onChanged: (value) {
                    setState(() {
                      douleurCinquiemeMeta = value;
                    });
                  },
                ),
                _QuestionSwitch(
                  title: 'Douleur osseuse au naviculaire',
                  subtitle: 'Douleur osseuse sur la partie interne du médio-pied.',
                  value: douleurNaviculaire,
                  onChanged: (value) {
                    setState(() {
                      douleurNaviculaire = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Appui',
            child: _QuestionSwitch(
              title: 'Impossible de faire 4 pas',
              subtitle:
                  'Immédiatement après le traumatisme et lors de l’examen.',
              value: appuiImpossible,
              onChanged: (value) {
                setState(() {
                  appuiImpossible = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: imagerieIndiquee
                  ? const Color(0xFFFFE4E6)
                  : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: resultatCouleur),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultatTitre,
                  style: TextStyle(
                    color: resultatCouleur,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  imagerieIndiquee
                      ? '${radioCheville ? '• Radio de cheville à discuter\n' : ''}${radioPied ? '• Radio du pied à discuter' : ''}'
                      : 'Aucun critère positif retrouvé. La nécessité d’imagerie paraît faible selon les règles d’Ottawa.',
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Consentement RGPD',
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: consentementPdf,
              onChanged: (value) {
                setState(() {
                  consentementPdf = value ?? false;
                });
              },
              title: const Text(
                'Le patient est informé de la génération du PDF.',
              ),
              subtitle: const Text(
                'Aucune donnée nominative n’est saisie ni stockée dans cette version.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: reinitialiser,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: exporterPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
const Text(
  "Outil d'aide a la decision. Ne remplace pas l'examen clinique, "
  "le jugement professionnel ni les recommandations locales. "
  "Ne constitue pas un diagnostic medical automatise.",
  textAlign: TextAlign.center,
  style: TextStyle(color: Colors.black54, fontSize: 12),
),
const SizedBox(height: 8),
const Text(
  "Mode hors connexion : aucun appel reseau, aucun stockage patient.",
  textAlign: TextAlign.center,
  style: TextStyle(color: Colors.black45, fontSize: 12),
),
const SizedBox(height: 8),
const Text(
  "© 2026 MB - Tous droits reserves",
  textAlign: TextAlign.center,
  style: TextStyle(color: Colors.black45, fontSize: 11),
),
const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _QuestionSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _QuestionSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2563EB),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle),
    );
  }
}