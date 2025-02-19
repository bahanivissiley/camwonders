//import 'dart:async';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sttories extends StatefulWidget {
  static const verte = Color(0xff226900);
  final Wonder wond;
  const Sttories({super.key, required this.wond});

  @override
  State<Sttories> createState() => _StoriesState();
}

class _StoriesState extends State<Sttories> {
  final int _currentPageIndex = 0;
  final PageController _pageStorieController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _pageStorieController.dispose();
    super.dispose();
  }

  String truncate(String text) {
    if (text.length > 35) {
      return "${text.substring(0, 35)}...";
    }
    return text;
  }

  Future<List<Map<String, dynamic>>> _fetchImages() async {
    try {
      final response = await Supabase.instance.client
          .from('images_wonder') // Remplacez 'images_wonder' par le nom de votre table
          .select() // Sélectionner toutes les colonnes
          .eq('wonder_id', widget.wond.idWonder); // Filtrer par wonder_id

      return response;
    } catch (e) {
      print('Erreur lors de la récupération des images : $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    final int tailledocuments = 0;
    //final List<Img> listeimages = images.where((img) => img.wonder == wond).toList();
    const verte = Color(0xff226900);
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              final tapPosition = details.globalPosition.dx;
              if (_pageStorieController.positions.isNotEmpty) {
                // Vérifier si le PageView est construit
                if (tapPosition < screenWidth / 2) {
                  // Balayage vers la gauche
                  _pageStorieController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                } else {
                  // Balayage vers la droite
                  _pageStorieController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              }
            },
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchImages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: shimmerOffre(width: size.width, height: size.height),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No images found.'));
                }

                final documents = snapshot.data!;

                return PageView.builder(
                  controller: _pageStorieController,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data = documents[index];
                    return Sttorie(
                      path: data['image_url'], // Remplacez 'image_url' par le nom de la colonne
                      wonderName: widget.wond.wonderName,
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: width,
                  margin: const EdgeInsets.only(top: 30, left: 15),
                  child: Column(
                    children: [
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width / 10,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: Colors.white,
                                  size: 25,
                                )),
                          ),
                          SizedBox(
                            height: height / 45,
                            width: width / 10 * 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(tailledocuments, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: size.width /
                                      (tailledocuments *
                                          4 /
                                          3), // Ajustement en fonction du nombre total d'éléments
                                  height: height / 300,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withValues(alpha:0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2))
                                    ],
                                    color: _currentPageIndex == index
                                        ? Colors.white
                                        : const Color.fromARGB(
                                                255, 231, 231, 231)
                                            .withValues(alpha:0.4),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        truncate(widget.wond.wonderName),
                        style: GoogleFonts.lalezar(
                            textStyle: const TextStyle(
                                fontSize: 20, color: Colors.white)),
                      )
                    ],
                  ),
                ),
                Container(
                    height: height / 12,
                    width: width,
                    color: verte.withValues(alpha:0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        WonderPage(
                                      wond: widget.wond,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      animation = CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeIn);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ));
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  Colors.transparent),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              side: WidgetStateProperty.all<BorderSide>(
                                  const BorderSide(
                                      color: Colors.white, width: 2.0)),
                              padding: WidgetStateProperty.all<
                                      EdgeInsetsGeometry>(
                                  const EdgeInsets.fromLTRB(60, 10, 60, 10)),
                            ),
                            child: const Text(
                              "Visiter",
                              style: TextStyle(fontSize: 17),
                            )),
                      ],
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Sttorie extends StatelessWidget {
  final String path;
  final String wonderName;

  const Sttorie({super.key, required this.path, required this.wonderName});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double height = size.height;
    final double width = size.width;
    return Hero(
      tag: "imageWonder$wonderName",
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(path), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
