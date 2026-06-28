import 'package:flutter/material.dart';
import 'package:my_first_app/shared/widgets/doll_girl_character.dart';

/// Animated doll girl for cart success (same character as login).
class SmilingGirlAsset extends StatelessWidget {
  const SmilingGirlAsset({super.key, this.height = kDollGirlDisplayHeight});

  final double height;

  @override
  Widget build(BuildContext context) {
    return DollGirlCharacter(height: height);
  }
}
