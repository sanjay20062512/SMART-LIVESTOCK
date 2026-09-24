// Smart Livestock — Government Disease Intelligence Map (Tab 2)
// Integrates the Maharashtra Disease Intelligence Map (Leaflet + GeoJSON)
// embedded seamlessly into the Government Health Command Center.

// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'govt_theme.dart';
import 'govt_new_data.dart';

class GovtNewDiseaseMap extends StatefulWidget {
  const GovtNewDiseaseMap({super.key});

  @override
  State<GovtNewDiseaseMap> createState() => _GovtNewDiseaseMapState();
}

class _GovtNewDiseaseMapState extends State<GovtNewDiseaseMap> {
  static bool _iframeRegistered = false;
  static const String _viewTypeId = 'maharashtra-disease-map-embed';

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_iframeRegistered) {
      _iframeRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(
        _viewTypeId,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'http://localhost:5174/embed/disease-map'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..allow = 'fullscreen'
            ..setAttribute('allowfullscreen', 'true');
          return iframe;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return _buildFallbackView();
    }

    return const Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: SizedBox.expand(
        child: HtmlElementView(
          viewType: _viewTypeId,
        ),
      ),
    );
  }

  Widget _buildFallbackView() {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 48, color: GovtColors.brandDark),
            const SizedBox(height: 12),
            const Text(
              'Maharashtra Disease Intelligence Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GovtColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive GeoJSON map is enabled for web browser clients.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
