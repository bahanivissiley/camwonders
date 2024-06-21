

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class policies extends StatelessWidget{
  const policies({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
          },
          icon: const Icon(LucideIcons.arrowLeft)
        ),
      ),
      body: const Center(
      child: Text("Les conditions d'utilisations"),
    ),
    );
  }
}