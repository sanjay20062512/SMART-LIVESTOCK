// Government Module — Full-Screen Live Risk Map Screen
// Institutional GIS Command View for National & District Disease Surveillance

import 'package:flutter/material.dart';
import '../../services/farmer_data_service.dart';
import 'govt_theme.dart';
import 'widgets/govt_india_map_widget.dart';

class GovtLiveMapScreen extends StatefulWidget {
  final FarmerDataService dataService;
  const GovtLiveMapScreen({super.key, required this.dataService});

  @override
  State<GovtLiveMapScreen> createState() => _GovtLiveMapScreenState();
}

class _GovtLiveMapScreenState extends State<GovtLiveMapScreen> {
  String _state = 'TAMIL NADU';
  String _district = 'ERODE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovtColors.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Prevent any vertical layout overflow on short display / small laptop viewports
          if (constraints.maxHeight < 560) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 560,
                child: IndiaDiseaseIntelligenceMap(
                  isExpanded: true,
                  currentJurisdictionState: _state,
                  currentJurisdictionDistrict: _district,
                  onStateSelected: (st) => setState(() => _state = st),
                  onDistrictSelected: (dt) => setState(() => _district = dt),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: IndiaDiseaseIntelligenceMap(
              isExpanded: true,
              currentJurisdictionState: _state,
              currentJurisdictionDistrict: _district,
              onStateSelected: (st) => setState(() => _state = st),
              onDistrictSelected: (dt) => setState(() => _district = dt),
            ),
          );
        },
      ),
    );
  }
}
