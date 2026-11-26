import 'package:flutter/material.dart';

/// User-supplied MuslimGo artwork, shared by launch, splash and account screens.
class MuslimGoMark extends StatelessWidget {
  const MuslimGoMark({super.key, this.size = 80});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'MuslimGo logo: a mosque, crescent and open book', image: true,
    child: Image.asset('assets/images/app_logo.png', width: size, height: size, fit: BoxFit.contain),
  );
}
