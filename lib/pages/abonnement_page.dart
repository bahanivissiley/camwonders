import 'package:flutter/material.dart';

class abonnementPage extends StatelessWidget {
  const abonnementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/img5.jpg")
                ),
              )
            ),

            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha:0)
                  ],
                  stops: const [0.6, 1.0]
                )
              ),
            )
          ],
        )
      )
    );
  }
}