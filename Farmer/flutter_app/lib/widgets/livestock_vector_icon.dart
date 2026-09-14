// Clean outlined SVG vector icons for livestock species.
// Renders unmistakable silhouettes for Cow, Buffalo, Goat, Sheep, etc.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/animal.dart';

class LivestockVectorIcon extends StatelessWidget {
  final AnimalSpecies? species;
  final String? speciesName;
  final Color color;
  final double size;

  const LivestockVectorIcon({
    super.key,
    this.species,
    this.speciesName,
    required this.color,
    this.size = 22,
  });

  static AnimalSpecies resolveSpecies({AnimalSpecies? species, String? speciesName}) {
    if (species != null) return species;
    final name = (speciesName ?? '').toLowerCase();
    if (name.contains('buffalo') || name.contains('murrah') || name.contains('bhains')) {
      return AnimalSpecies.buffalo;
    }
    if (name.contains('goat') || name.contains('bakri') || name.contains('boer')) {
      return AnimalSpecies.goat;
    }
    if (name.contains('sheep') || name.contains('bhed') || name.contains('ram')) {
      return AnimalSpecies.sheep;
    }
    if (name.contains('poultry') || name.contains('chicken') || name.contains('hen') || name.contains('bird')) {
      return AnimalSpecies.poultry;
    }
    if (name.contains('pig') || name.contains('swine') || name.contains('suar')) {
      return AnimalSpecies.pig;
    }
    return AnimalSpecies.cow;
  }

  static String getSvgForSpecies(AnimalSpecies species) {
    switch (species) {
      case AnimalSpecies.cow:
        return _cowSvg;
      case AnimalSpecies.buffalo:
        return _buffaloSvg;
      case AnimalSpecies.goat:
        return _goatSvg;
      case AnimalSpecies.sheep:
        return _sheepSvg;
      case AnimalSpecies.poultry:
        return _poultrySvg;
      case AnimalSpecies.pig:
        return _pigSvg;
      case AnimalSpecies.other:
        return _cowSvg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetSpecies = resolveSpecies(species: species, speciesName: speciesName);
    final svgString = getSvgForSpecies(targetSpecies);

    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // ─── Clean Outlined SVG Definitions ────────────────────────────────────────

  // 1. Cow: Outward-curving horns, horizontal ears, broad forehead, muzzle with nostrils
  static const String _cowSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 6c0-2.5 2-4 4.5-4C8 3.5 7 5 7 6"/>
  <path d="M20 6c0-2.5-2-4-4.5-4 0 1.5 1 3 1 4"/>
  <path d="M7 8L2.5 9.5c-.8.3-.8 1.4 0 1.7L7 12"/>
  <path d="M17 8l4.5 1.5c.8.3.8 1.4 0 1.7L17 12"/>
  <path d="M7 6h10c.8 0 1.5.7 1.4 1.5l-.8 6.5c-.1.7-.5 1.3-1.1 1.6L16 16v3c0 1.1-.9 2-2 2h-4c-1.1 0-2-.9-2-2v-3l-.5-.4c-.6-.3-1-.9-1.1-1.6L5.6 7.5C5.5 6.7 6.2 6 7 6z"/>
  <path d="M8 16.5h8"/>
  <circle cx="10" cy="18.5" r="0.75" fill="currentColor"/>
  <circle cx="14" cy="18.5" r="0.75" fill="currentColor"/>
</svg>
''';

  // 2. Buffalo: Wide sweeping crescent water buffalo horns curving outward and down
  static const String _buffaloSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M8 6C5 3 2 4 2 8c0 3 3 5 5 4"/>
  <path d="M16 6c3-3 6-2 6 2 0 3-3 5-5 4"/>
  <path d="M7 11l-3 1.5c-.7.4-.7 1.4 0 1.7L7 15"/>
  <path d="M17 11l3 1.5c.7.4.7 1.4 0 1.7L17 15"/>
  <path d="M7 7h10c.8 0 1.4.6 1.4 1.4l-.6 6.6c-.1.8-.7 1.4-1.5 1.5L16 17v2.5c0 1.1-.9 2-2 2h-4c-1.1 0-2-.9-2-2V17l-.3-.5c-.8-.1-1.4-.7-1.5-1.5L5.6 8.4C5.6 7.6 6.2 7 7 7z"/>
  <path d="M8 17h8"/>
  <circle cx="10" cy="19" r="0.75" fill="currentColor"/>
  <circle cx="14" cy="19" r="0.75" fill="currentColor"/>
</svg>
''';

  // 3. Goat: Backward arching horns, slender wedge face, goatee beard
  static const String _goatSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9 7C8.5 4 7 2 5 2c0 2 1.5 4 3 6"/>
  <path d="M15 7c.5-3 2-5 4-5 0 2-1.5 4-3 6"/>
  <path d="M7 9L3 8.5c-.8-.1-1.2.9-.6 1.4L6.5 12"/>
  <path d="M17 9l4-.5c.8-.1 1.2.9.6 1.4L17.5 12"/>
  <path d="M8 7h8l-1 8c-.1.9-.8 1.6-1.7 1.7L13 17v2l-1 2-1-2v-2l-.3-.3c-.9-.1-1.6-.8-1.7-1.7L8 7z"/>
  <path d="M11 19l1 3 1-3"/>
  <circle cx="10.5" cy="12" r="0.75" fill="currentColor"/>
  <circle cx="13.5" cy="12" r="0.75" fill="currentColor"/>
</svg>
''';

  // 4. Sheep: Spiral ram horns, woolly cloud crown, gentle snout
  static const String _sheepSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M7 8C5.5 5 2 6 2 8.5c0 2 2.5 3 4 1.5"/>
  <path d="M17 8c1.5-3 5-2 5 .5 0 2-2.5 3-4 1.5"/>
  <path d="M8 7c0-1.7 1.3-3 3-3 .7 0 1.4.3 1.9.8.5-.5 1.2-.8 2.1-.8 1.7 0 3 1.3 3 3"/>
  <path d="M6 10.5L3 13c-.6.5-.4 1.4.3 1.6l3 .4"/>
  <path d="M18 10.5L21 13c.6.5.4 1.4-.3 1.6l-3 .4"/>
  <path d="M7.5 9h9l-.8 7c-.1.9-.8 1.6-1.7 1.8L12 18l-2-.2c-.9-.2-1.6-.9-1.7-1.8L7.5 9z"/>
  <path d="M10.5 15.5h3"/>
  <path d="M12 15.5v1.5"/>
</svg>
''';

  // 5. Poultry: Rooster/Hen comb, beak, wattle
  static const String _poultrySvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M11 3c0 1.5-1 2-1 3s1 1.5 1 2.5"/>
  <path d="M13 2c0 1.5 1 2.5 1 3.5s-1 1.5-1 2.5"/>
  <path d="M8 12c0-3.3 2.7-6 6-6h1c1 0 2 .5 2.5 1.5L21 11l-3.5 1v3c0 2.8-2.2 5-5 5H9"/>
  <path d="M18 10l3.5 1.5L18 13"/>
  <circle cx="15" cy="9.5" r="1" fill="currentColor"/>
  <path d="M16 13c0 1.5-.7 2.5-1.5 2.5S13 14.5 13 13"/>
</svg>
''';

  // 6. Pig: Rounded face, snout with two nostrils, ears
  static const String _pigSvg = '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
  <path d="M5 7L3 3c2 0 4 1.5 4.5 3.5"/>
  <path d="M19 7l2-4c-2 0-4 1.5-4.5 3.5"/>
  <circle cx="12" cy="13" r="8"/>
  <ellipse cx="12" cy="14" rx="3.5" ry="2.5"/>
  <circle cx="10.8" cy="14" r="0.6" fill="currentColor"/>
  <circle cx="13.2" cy="14" r="0.6" fill="currentColor"/>
  <circle cx="8.5" cy="10" r="0.75" fill="currentColor"/>
  <circle cx="15.5" cy="10" r="0.75" fill="currentColor"/>
</svg>
''';
}
