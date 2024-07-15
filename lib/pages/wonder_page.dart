import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/pages/evenement_details.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class wonder_page extends StatefulWidget {
  final Wonder wond;

  const wonder_page({super.key, required this.wond});

  @override
  State<wonder_page> createState() => _wonder_pageState(wond: wond);
}

class _wonder_pageState extends State<wonder_page> {
  int _currentPageIndex = 0;
  bool is_map = false;
  bool isItinairaire = false;
  final Wonder wond;
  final verte = const Color(0xff226900);
  double userLong = 0.0;
  double userLat = 0.0;
  List<latLng.LatLng> routePoints = [];

  final PageController _pageStorieController = PageController();

  _wonder_pageState({required this.wond});

  bool is_like = false;
  bool isKeyboardVisible = false;
  late Box<Wonder> favorisBox;
  late final Future<QuerySnapshot> images;
  String _locationMessage = "";
  List<LatLng> points = [];
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _verifyConnection();
    _getCurrentLocation();
    _fetchRoute();
    images = FirebaseFirestore.instance
        .collection('images_wonder')
        .where('wonder_id', isEqualTo: wond.idWonder)
        .get();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    bool estPresent = favorisBox.values
        .any((wonder_de_la_box) => wonder_de_la_box.idWonder == wond.idWonder);
    if (estPresent) {
      is_like = true;
    }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  void _verifyConnection() async {
    if (await Logique.checkInternetConnection()) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connectez-vous a internet"),
        backgroundColor: Colors.red,
      ));
    }
  }




  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    }

    // If we reach here, permissions are granted and we can get the location.
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLat = position.latitude;
      userLong = position.longitude;
      _locationMessage = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
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

  void SetFavorisWonder(Wonder wonder) {
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    favorisBox.add(wonder);
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });

    if (_image != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Images selectionnees"),
              content: Image.file(File(_image!.path)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Annuler")),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Success"),
                              content: SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Gif(
                                        height: 100,
                                        image: const AssetImage(
                                            "assets/succes1.gif"),
                                        autostart: Autostart.loop,
                                        placeholder: (context) =>
                                            const Text('Loading...'),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 15),
                                        child: Text(
                                            "Images proposes avec succes",
                                            style: GoogleFonts.lalezar(
                                                textStyle: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Continuer")),
                                )
                              ],
                            );
                          });
                    },
                    child: const Text("Soumettre"))
              ],
            );
          });
    }
  }

  Future<Map<String, dynamic>> meteoToday() async {
    final weatherData = await wond.meteoFetch();
    return weatherData['current'];
  }

  Future<Map<String, dynamic>> meteoDemain() async {
    final weatherData = await wond.meteoFetch();
    return weatherData['daily'][1];
  }

  Future<Map<String, dynamic>> meteoApresDemain() async {
    final weatherData = await wond.meteoFetch();
    return weatherData['daily'][2];
  }

  Future<Map<String, dynamic>> meteoDernierJour() async {
    final weatherData = await wond.meteoFetch();
    return weatherData['daily'][3];
  }

  String getWeatherIconUrl(String iconId) {
    return 'http://openweathermap.org/img/wn/$iconId@2x.png';
  }


  Future<void> _fetchRoute() async {
    final response = await http.get(Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248b61e34e52a804a1681656eec996f618b&start=${userLong},${userLat}&end=${wond.longitude},${wond.latitude}',
    ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['features'][0]['geometry']['coordinates'] as List;

      setState(() {
        routePoints = geometry.map((point) {
          return latLng.LatLng(point[1], point[0]);
        }).toList();
      });
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        primary: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 30),
            width: size.width / 4,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    if (AuthService().currentUser != null) {
                      setState(() {
                        if (is_like) {
                          is_like = false;
                          Logique()
                              .supprimerFavorisWonder(favorisBox.length - 1);
                        } else {
                          SetFavorisWonder(wond);
                          is_like = true;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                  child: Text("Element Ajouté aux Favoris !")),
                            ),
                            duration: const Duration(milliseconds: 900),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ));
                        }
                      });
                    } else {
                      connect_first(context);
                    }
                  },
                  icon: is_like
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(Icons.favorite_border_rounded),
                ),
                IconButton(
                    onPressed: () {
                      Share.share(
                          '*Titre* : ${widget.wond.wonderName}\n \n Description : ${widget.wond.description}\n \n Télécharger l\'application : ${widget.wond.imagePath}');
                    },
                    icon: const Icon(Icons.share))
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              is_map ? mapsWonder(size) : isItinairaire ? ItinairaireWonder(size) : imagesWonder(size),
              Container(
                  padding:
                  EdgeInsets.only(left: size.width / 16, right: size.width / 16),
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  ligneAcces_btnCarte(size.width),
                  Text(
                    wond.wonderName,
                    style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(
                          fontSize: 24,
                        )),
                  ),
                  Row(
                    children: [
                      Text(
                        wond.city,
                        style: GoogleFonts.jura(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        width: 1,
                        height: 10,
                        color: const Color(0xff226900),
                      ),
                      Text(
                        "24km de votre position",
                        style: GoogleFonts.jura(
                            textStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          // Pleines étoiles
                          Row(
                            children: List.generate(
                              wond.note.floor(),
                                  (index) => const Icon(
                                Icons.star_rounded,
                                color: Colors.orange,
                                size: 15,
                              ),
                            ),
                          ),
                          // Demi-étoile si nécessaire
                          if (wond.note - wond.note.floor() != 1 &&
                              wond.note - wond.note.floor() != 0)
                            const Icon(
                              Icons.star_half_rounded,
                              color: Colors.orange,
                              size: 15,
                            ),
                          // Étoiles vides
                          if (wond.note.floor() != 5 &&
                              wond.note - wond.note.floor() == 0)
                            Row(
                              children: List.generate(
                                5 - wond.note.floor(),
                                    (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                          if (wond.note.floor() != 5 &&
                              wond.note - wond.note.floor() != 1 &&
                              wond.note - wond.note.floor() != 0)
                            Row(
                              children: List.generate(
                                4 - wond.note.floor(),
                                    (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                          if (wond.note.floor() == 5 &&
                              wond.note - wond.note.floor() != 1 &&
                              wond.note - wond.note.floor() != 0)
                            Row(
                              children: List.generate(
                                4 - wond.note.floor(),
                                    (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        width: 2,
                        height: 20,
                        color: const Color(0xff226900),
                      ),
                      Text(
                        wond.note.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  descriptionWidget(wond: wond),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Points forts",
                        style: GoogleFonts.lalezar(
                            textStyle: TextStyle(fontSize: 18, color: verte)),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: size.width / 20, bottom: 20),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: wond.getAvantages(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.personnalgreen,
                                  ));
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              Center(
                                  child: Text("Pas de points forts pour ce lieu",
                                      style: GoogleFonts.jura(
                                          textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))));
                            }

                            final documents = snapshot.data!;

                            return Column(
                                children: List.generate(documents.length, (index) {
                                  final data = documents[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Icon(
                                              LucideIcons.checkCircle,
                                              color: verte,
                                              size: 17,
                                            )),
                                        Text(
                                          data['content'],
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  );
                                }));
                          },
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Limites",
                        style: GoogleFonts.lalezar(
                            textStyle:
                            const TextStyle(fontSize: 18, color: Colors.red)),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: size.width / 20, bottom: 20),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: wond.getInconvenients(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Something went wrong'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.personnalgreen,
                                  ));
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text("Pas de problèmes pource lieu",
                                      style: GoogleFonts.jura(
                                          textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))));
                            }

                            final documents = snapshot.data!;

                            return Column(
                                children: List.generate(documents.length, (index) {
                                  final data = documents[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Icon(
                                              LucideIcons.ban,
                                              color: verte,
                                              size: 17,
                                            )),
                                        Text(
                                          data['content'],
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  );
                                }));
                          },
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            "Méteo",
                            style: GoogleFonts.lalezar(
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: size.width,
                          //padding: EdgeInsets.fromLTRB(
                          //  size.width / 25, size.width / 25, size.width / 25, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FutureBuilder<Map<String, dynamic>>(
                                future: meteoToday(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Un problème est survenu'));
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                        child: Text('Pas de données disponible'));
                                  } else {
                                    final weather = snapshot.data!;
                                    final weatherIconId =
                                    weather['weather'][0]['icon'];
                                    final weatherIconUrl =
                                    getWeatherIconUrl(weatherIconId);
                                    final double temp = weather['temp'];
                                    final double tempCelcius = temp - 273.15;

                                    return Column(
                                      children: [
                                        Text(
                                          "Aujourd'hui",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                              )),
                                        ),
                                        SizedBox(
                                            width: size.width / 5,
                                            child: Image.network(weatherIconUrl)),
                                        Text(
                                          '${tempCelcius.toStringAsFixed(1)}°',
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                              )),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<Map<String, dynamic>>(
                                future: meteoDemain(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Pas de données disponible'));
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                        child: Text('No data available'));
                                  } else {
                                    final weather = snapshot.data!;
                                    final weatherIconId =
                                    weather['weather'][0]['icon'];
                                    final weatherIconUrl =
                                    getWeatherIconUrl(weatherIconId);
                                    final double temp = weather['temp']['day'];
                                    final double tempCelcius = temp - 273.15;

                                    return Column(
                                      children: [
                                        Text(
                                          "Demain",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                              )),
                                        ),
                                        SizedBox(
                                            width: size.width / 5,
                                            child: Image.network(weatherIconUrl)),
                                        Text(
                                          '${tempCelcius.toStringAsFixed(1)}°',
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                              )),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<Map<String, dynamic>>(
                                future: meteoApresDemain(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Un problème est survenu'));
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                        child: Text('Pas de données disponible'));
                                  } else {
                                    final weather = snapshot.data!;
                                    final weatherIconId =
                                    weather['weather'][0]['icon'];
                                    final weatherIconUrl =
                                    getWeatherIconUrl(weatherIconId);
                                    final double temp = weather['temp']['day'];
                                    final double tempCelcius = temp - 273.15;

                                    return Column(
                                      children: [
                                        Text(
                                          "Après-demain",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                              )),
                                        ),
                                        SizedBox(
                                            width: size.width / 5,
                                            child: Image.network(weatherIconUrl)),
                                        Text(
                                          '${tempCelcius.toStringAsFixed(1)}°',
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                              )),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              FutureBuilder<Map<String, dynamic>>(
                                future: meteoDernierJour(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text(
                                            'Quelques chose n\'a pas bien marché'));
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                        child: Text('Pas de donnees'));
                                  } else {
                                    final weather = snapshot.data!;
                                    final weatherIconId =
                                    weather['weather'][0]['icon'];
                                    final weatherIconUrl =
                                    getWeatherIconUrl(weatherIconId);
                                    final double temp = weather['temp']['day'];
                                    final double tempCelcius = temp - 273.15;
                                    DateTime date = DateTime.now();
                                    DateTime lendemain =
                                    date.add(const Duration(days: 3));

                                    return Column(
                                      children: [
                                        Text(
                                          "${lendemain.day}/${lendemain.month}/${lendemain.year}",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                              )),
                                        ),
                                        SizedBox(
                                            width: size.width / 5,
                                            child: Image.network(weatherIconUrl)),
                                        Text(
                                          '${tempCelcius.toStringAsFixed(1)}°',
                                          style: GoogleFonts.lalezar(
                                              textStyle: const TextStyle(
                                                fontSize: 18,
                                              )),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(size.width / 100),
                    child: Column(
                      children: [
                        Text(
                          "Contribuer",
                          style: GoogleFonts.lalezar(
                              textStyle: const TextStyle(fontSize: 20)),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (AuthService().currentUser != null) {
                                    _showReviewModal(context);
                                  } else {
                                    connect_first(context);
                                  }
                                },
                                child: Text(
                                  "Laisser un avis",
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                          const Text("Choisissez une methode"),
                                          actions: [
                                            Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: _pickImage,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          const Icon(
                                                            LucideIcons.image,
                                                            size: 20,
                                                          ),
                                                          Text(
                                                            "Gallerie",
                                                            style:
                                                            GoogleFonts.jura(),
                                                          )
                                                        ],
                                                      )),
                                                  ElevatedButton(
                                                      onPressed: null,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          const Icon(
                                                            LucideIcons.camera,
                                                            size: 20,
                                                          ),
                                                          Text(
                                                            "Appareil photo",
                                                            style:
                                                            GoogleFonts.jura(),
                                                          )
                                                        ],
                                                      )),
                                                ])
                                          ],
                                        );
                                      });
                                },
                                child: Text(
                                  "Proposer des photos",
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: wond.getAvis(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Un problème est survenu");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SingleChildScrollView(
                          child: const Column(
                            children: [
                              CircularProgressIndicator(
                                  color: Colors.personnalgreen)
                            ],
                          ),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: size.height / 20,
                                  margin: const EdgeInsets.all(20),
                                  child:
                                  Theme.of(context).brightness == Brightness.light
                                      ? Image.asset('assets/vide_light.png')
                                      : Image.asset('assets/vide_dark.png'),
                                ),
                                const Text("Pas d'avis !")
                              ],
                            ));
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: min(snapshot.data!.docs.length, 2),
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot document = snapshot.data!.docs[index];
                            Avis avis = Avis(
                              idAvis: document.id,
                              note: document['note'],
                              content: document['content'],
                              wonder: document['wonder'],
                              user: document['user'],
                              userImage: document['userImage'],
                            );
                            return GestureDetector(
                                onTap: () => null,
                                child: CommentWidget(
                                    size: size, avis: avis, maxlines: 2));
                          });
                    },
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 15),
                      child: TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: wond.getAvis(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasError) {
                                          return const Text('Un problème est survenu');
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SingleChildScrollView(
                                            child: const Column(
                                              children: [
                                                CircularProgressIndicator(
                                                    color: Colors.personnalgreen)
                                              ],
                                            ),
                                          );
                                        }

                                        if (snapshot.data!.docs.isEmpty) {
                                          return Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: size.height / 15,
                                                    margin: const EdgeInsets.all(10),
                                                    child:
                                                    Theme.of(context).brightness ==
                                                        Brightness.light
                                                        ? Image.asset(
                                                        'assets/vide_light.png')
                                                        : Image.asset(
                                                        'assets/vide_dark.png'),
                                                  ),
                                                  const Text("Pas d'avis !")
                                                ],
                                              ));
                                        }

                                        return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data!.docs.length,
                                            itemBuilder:
                                                (BuildContext context, int index) {
                                              DocumentSnapshot document =
                                              snapshot.data!.docs[index];
                                              Avis avis = Avis(
                                                idAvis: document.id,
                                                note: document['note'],
                                                content: document['content'],
                                                wonder: document['wonder'],
                                                user: document['user'],
                                                userImage: document['userImage'],
                                              );
                                              return GestureDetector(
                                                  onTap: () => null,
                                                  child: CommentWidget(
                                                      size: size,
                                                      avis: avis,
                                                      maxlines: 2000));
                                            });
                                      },
                                    ),
                                  );
                                });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            foregroundColor: MaterialStateProperty.all(verte),
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: verte, width: 1.0)),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                EdgeInsets.fromLTRB(
                                    size.width / 4, 7, size.width / 4, 7)),
                          ),
                          child: const Text(
                            "Charger plus d'avis",
                            style: TextStyle(fontSize: 10),
                          )),
                    ),
                  ),
                  Text(
                    "Evénements",
                    style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(
                          fontSize: 20,
                        )),
                  ),
                ])
              ),

              EvenementList(wond: wond),
              Container(
                margin:
                  EdgeInsets.only(left: size.width / 16, right: size.width / 16, top: 30),
                child: Text(
                  "Similaires",
                  style: GoogleFonts.lalezar(
                      textStyle: const TextStyle(
                        fontSize: 20,
                      )),
                ),
              ),
              SimilairesList(wond: wond),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: GestureDetector(
                        onTap: () {
                          if (AuthService().currentUser != null) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Signalez une erreur sur ce lieu :",
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          const SizedBox(height: 16.0),
                                          const TextField(
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Quelle erreur vous trouvez sur ce lieu...",
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 16.0),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              // Logique pour enregistrer l'avis
                                              Navigator.of(context)
                                                  .pop(); // Fermer la boîte de dialogue
                                            },
                                            child: const Text("Envoyer"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            connect_first(context);
                          }
                        },
                        child: Text("Signalez une erreur",
                            style: GoogleFonts.jura(
                                textStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline))))),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
                width: size.width / 3,
                child: Text(
                  "Ouvert : ${wond.horaire}",
                  style: GoogleFonts.lalezar(
                      textStyle: TextStyle(fontSize: 15, color: verte)),
                )),
            ElevatedButton(
              onPressed: () {
                if (AuthService().currentUser != null) {
                  if (wond.isreservable) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return ReservationModal(wond: wond);
                      },
                    );
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Lieu non pris en charge",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(
                                      color: Colors.personnalgreen,
                                      fontSize: 25)),
                            ),
                            content: Text(
                              "Reservation pas disponible pour ce lieu",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(fontSize: 15)),
                            ),
                          );
                        });
                  }
                } else {
                  connect_first(context);
                }
              },
              child: Text(
                "Reserver",
                style: GoogleFonts.lalezar(
                    textStyle:
                        const TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (AuthService().currentUser != null) {
                    setState((){
                      isItinairaire = true;
                      is_map = false;
                    });
                  } else {
                    connect_first(context);
                  }
                },
                child: Row(
                  children: [
                    const Icon(LucideIcons.map, color: Colors.white,),
                    Text(
                      "  Itineraire",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(
                              fontSize: 14, color: Colors.white)),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<dynamic> en_developpement(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Icon(
              LucideIcons.cog,
              size: 50,
            ),
            content: Text("Fonctionnalites en developpement"),
          );
        });
  }

  Future<dynamic> connect_first(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Ignorer",
                      style: TextStyle(decoration: TextDecoration.underline)),
                )
              ],
            )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    //width: 20,
                    height: 100,
                    child: Image.asset('assets/logo.png')),
                Text(
                  "Connectez vous pour acceder a tout les foncionnalités",
                  style: GoogleFonts.lalezar(
                      textStyle: const TextStyle(fontSize: 25)),
                ),
                Text(
                  "Connectez vous ou inscrivez vous pour acceder a toutes les fonctionnalites de l'application et pour garder une trace de tout vos activites et vos abonnements.",
                  style: GoogleFonts.jura(
                      textStyle: const TextStyle(fontSize: 10)),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Debut_Inscription())),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.userPlus),
                      Text("Me connecter")
                    ],
                  ))
            ],
          );
        });
  }

  Container ligneAcces_btnCarte(double width) {
    return Container(
      padding: EdgeInsets.all(width / 50),
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text("Modalités")),
                      content: SizedBox(
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Icon(
                              LucideIcons.banknote,
                              size: 60,
                            ),
                            Text(
                              wond.free ? "Gratuit" : "${wond.price} Fcfa",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(fontSize: 25)),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            child: Container(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xff226900),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(255, 148, 148, 148),
                              blurRadius: 2,
                              offset: Offset(0, 3))
                        ]),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Accès",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(255, 160, 160, 160),
                              blurRadius: 2,
                              offset: Offset(0, 3))
                        ]),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      wond.free ? "Gratuit" : "Payant",
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(
                              fontSize: 16, color: Color(0xff226900))),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            width: 2,
            height: 30,
            color: const Color(0xff226900),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (is_map) {
                  is_map = false;
                  isItinairaire = false;
                } else {
                  is_map = true;
                  isItinairaire = false;
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  LucideIcons.map,
                  color: Colors.white,
                ),
                Text(
                  is_map ? "  Images" : "  Carte",
                  style: GoogleFonts.lalezar(
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container mapsWonder(Size size) {
    return Container(
      height: 350,
      width: size.width,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: latLng.LatLng(double.parse(wond.latitude), double.parse(wond.longitude)),
          initialZoom: 14,
          interactionOptions:
          const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
        ),
        children: [
          openStreetMapTileLatter,
          MarkerLayer(markers: [
            Marker(
                point: latLng.LatLng(double.parse(wond.latitude), double.parse(wond.longitude)),
                child: Icon(Icons.location_pin, color: Colors.personnalgreen, size: 50,)
            )
          ])
        ],
      ),
    );
  }

  Container ItinairaireWonder(Size size) {
    return Container(
      height: 350,
      width: size.width,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: latLng.LatLng(double.parse(wond.latitude), double.parse(wond.longitude)),
          initialZoom: 10,
          interactionOptions:
          const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
        ),
        children: [
          openStreetMapTileLatter,
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),

          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(userLat, userLong),
                child: Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(double.parse(wond.latitude), double.parse(wond.longitude)),
                child: Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container imagesWonder(Size size) {
    int taille = 0;
    return Container(
      height: 350,
      width: size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<QuerySnapshot>(
            future: wond.fetchImages(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: shimmerOffre(width: size.width, height: 350));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No images found.'));
              }

              final documents = snapshot.data!.docs;

              return PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageStorieController,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  final data = document.data() as Map<String, dynamic>;
                  return photoWonder(
                    path: data['image_url'],
                    wonderName: wond.wonderName,
                  );
                },
              );
            },
          ),
          Container(
            width: size.width / 50 * (taille + 2),
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(taille, (index) {
                return Container(
                  width: size.width / 50,
                  height: size.height / 65,
                  //margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPageIndex == index
                          ? const Color(0xff226900)
                          : const Color.fromARGB(255, 255, 255, 255),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromARGB(255, 86, 86, 86),
                            offset: Offset(0, 2),
                            blurRadius: 3)
                      ]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ReviewModal(
          wond: wond,
        );
      },
    );
  }
}



TileLayer get openStreetMapTileLatter => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);




class descriptionWidget extends StatefulWidget {
  const descriptionWidget({super.key, required this.wond});
  final Wonder wond;

  @override
  State<descriptionWidget> createState() => _descriptionWidgetState();
}

class _descriptionWidgetState extends State<descriptionWidget> {
  bool is_voir = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.wond.description,
                maxLines: is_voir ? 1000 : 4,
                style: GoogleFonts.jura(
                    textStyle: const TextStyle(
                      fontSize: 15,
                    ))),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (is_voir) {
                    is_voir = false;
                  } else {
                    is_voir = true;
                  }
                });
              },
              child: Text(
                is_voir ? "Voir moins" : "Voir plus",
                style: GoogleFonts.lalezar(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline)),
              ),
            )
          ],
        ));
  }
}







class CommentWidget extends StatefulWidget {
  const CommentWidget({
    super.key,
    required this.size,
    required this.avis,
    required this.maxlines,
  });

  final Avis avis;
  final Size size;
  final int maxlines;

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  String username = "Chargement...";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    Utilisateur? user = await Camwonder().getUserByUniqueId(widget.avis.user);
    setState(() {
      if (user != null) {
        username = user.nom;
      } else {
        username = 'Anonyme';
      }
    });
  }

  String truncate(String text) {
    if (text.length > 35) {
      return "${text.substring(0, 35)}...";
    }
    return text;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.fromBorderSide(BorderSide(
            width: 1,
            color: Theme.of(context).brightness != Brightness.light
                ? Colors.black.withOpacity(0.3)
                : Colors.grey)),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(widget.avis.userImage),
                    )),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(fontSize: 12)),
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          // Pleines étoiles
                          Row(
                            children: List.generate(
                              widget.avis.note.floor(),
                              (index) => const Icon(
                                Icons.star_rounded,
                                color: Colors.orange,
                                size: 15,
                              ),
                            ),
                          ),
                          // Demi-étoile si nécessaire
                          if (widget.avis.note - widget.avis.note.floor() !=
                                  1 &&
                              widget.avis.note - widget.avis.note.floor() !=
                                  0)
                            const Icon(
                              Icons.star_half_rounded,
                              color: Colors.orange,
                              size: 15,
                            ),
                          // Étoiles vides
                          if (widget.avis.note.floor() != 5 &&
                              widget.avis.note - widget.avis.note.floor() ==
                                  0)
                            Row(
                              children: List.generate(
                                5 - widget.avis.note.floor(),
                                (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                          if (widget.avis.note.floor() != 5 &&
                              widget.avis.note - widget.avis.note.floor() !=
                                  1 &&
                              widget.avis.note - widget.avis.note.floor() !=
                                  0)
                            Row(
                              children: List.generate(
                                4 - widget.avis.note.floor(),
                                (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                          if (widget.avis.note.floor() == 5 &&
                              widget.avis.note - widget.avis.note.floor() !=
                                  1 &&
                              widget.avis.note - widget.avis.note.floor() !=
                                  0)
                            Row(
                              children: List.generate(
                                4 - widget.avis.note.floor(),
                                (index) => const Icon(
                                  Icons.star_border_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          Text(
            widget.avis.content,
            maxLines: widget.maxlines,
            textAlign: TextAlign.start,
            style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}

class photoWonder extends StatelessWidget {
  final String path;
  final String wonderName;

  const photoWonder({super.key, required this.path, required this.wonderName});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Hero(
      tag: "imageWonder$wonderName",
      child: Container(
        height: height,
        width: width,
        padding:
        EdgeInsets.only(left: size.width / 16, right: size.width / 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            cacheManager: CustomCacheManager(),
            imageUrl: path,
            placeholder: (context, url) =>
                Center(child: shimmerOffre(width: width, height: height)),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class SimilairesList extends StatefulWidget {
  const SimilairesList({super.key, required this.wond});
  final Wonder wond;
  static const verte = Color(0xff226900);

  @override
  State<SimilairesList> createState() => _SimilairesListState();
}

class _SimilairesListState extends State<SimilairesList> {
  final ScrollController _controller = ScrollController();
  final double _height = 150.0;
  final double _width = 140.0;

  @override
  void initState() {
    super.initState();
    // Assurez-vous que le widget est construit avant d'appeler _animateToIndex
  }

  // Largeur de chaque élément dans la liste
  void _animateToIndex(int index) {
    double offset = index * _width;
    if (_controller.hasClients) {
      offset = offset - (_controller.position.viewportDimension - _width) / 2;
      _controller.animateTo(
        offset,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: widget.wond.getSimilar(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                  color: Colors.personnalgreen,
                ));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Vous n'etes pas connecté "),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                      child: Theme.of(context).brightness == Brightness.light
                          ? Image.asset('assets/vide_light.png')
                          : Image.asset('assets/vide_dark.png'),
                    ),
                    const Text("Vide"),
                  ],
                ));
          }else{
            return Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children:
                snapshot.data!.docs.where((doc) => doc.id != widget.wond.idWonder).map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  Wonder wwond = Wonder(idWonder: document.id, wonderName: document['wonderName'],
                      description: document['description'],
                      imagePath: document['imagePath'],
                      city: document['city'],
                      region: document['region'],
                      free: document['free'],
                      price: document['price'],
                      horaire: document['horaire'],
                      latitude: document['latitude'],
                      longitude: document['longitude'],
                      note: (document['note'] as num).toDouble(),
                      categorie: document['categorie'],
                      isreservable: document['isreservable']);
                  return Storie(wond: wwond);
                }).toList(),
              ),
            );
          }
        }
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}




class EvenementList extends StatefulWidget {
  const EvenementList({super.key, required this.wond});
  final Wonder wond;

  static const verte = Color(0xff226900);

  @override
  State<EvenementList> createState() => _EvenementListState();
}

class _EvenementListState extends State<EvenementList> {
  final ScrollController _controller = ScrollController();
  final double _height = 150.0;
  final double _width = 140.0;

  @override
  void initState() {
    super.initState();
    // Assurez-vous que le widget est construit avant d'appeler _animateToIndex
  }


  void _animateToIndex(int index) {
    double offset = index * _width;
    if (_controller.hasClients) {
      offset = offset - (_controller.position.viewportDimension - _width) / 2;
      _controller.animateTo(
        offset,
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  String truncate(String text) {
    if (text.length > 20) {
      return "${text.substring(0, 20)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: widget.wond.getEvenement(),
        builder: (BuildContext context,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                  color: Colors.personnalgreen,
                ));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Vous n'etes pas connecté "),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 12,
                      child: Image.asset("assets/vide_street.png"),
                    ),
                    const Text("Pas d'événements pour ce lieu")
                  ],
                ));
          }else{
            return Container(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  Evenements evenement = Evenements(idevenements: document.id,
                      contenu: document['contenu'],
                      title: document['title'],
                      numeroTel: document['numeroTel'],
                      imagePath: document['imagepath'],
                      idWonder: document['idwonder'],
                      date: document['date']);
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => EvenementDetails(evenement: evenement, wond: widget.wond),
                          transitionsBuilder: (_,animation,__,child){
                            return SlideTransition(
                              position: Tween<Offset> (begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 700)
                        )
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 15, left: 15),
                      width: MediaQuery.of(context).size.width/2,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.personnalgreen.withOpacity(0.1) : Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 125,
                            width: MediaQuery.of(context).size.width/2,
                            decoration: BoxDecoration(
                              color: Colors.personnalgreen,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                cacheManager: CustomCacheManager(),
                                imageUrl: document['imagepath'],
                                placeholder: (context, url) => Center(child: shimmerOffre(height: 200, width: MediaQuery.of(context).size.width,)),
                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(truncate(document['title']), maxLines: 1, style: GoogleFonts.lalezar(textStyle: TextStyle(fontSize: 15, color: Colors.personnalgreen)),),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.personnalgreen, weight: 4,)
                                  ],
                                ),
                                Text(document['contenu'], maxLines: 1, style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 12, color: Colors.grey)),),
                                Text(document['date'], style: GoogleFonts.jura(textStyle: TextStyle(fontSize: 12)),),
                                Container(
                                  height: 1,
                                  width: 40,
                                  color: Colors.personnalgreen,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        }
    );
  }

  @override
  void dispose() {
    _controller
        .dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}





class Storie extends StatelessWidget {
  static const verte = Color(0xff226900);
  final Wonder wond;

  const Storie({super.key, required this.wond});

  String truncate(String text) {
    if (text.length > 15) {
      return "${text.substring(0, 15)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => wonder_page(wond: wond)));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
                width: 140,
                height: 150,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  cacheManager: CustomCacheManager(),
                  imageUrl: wond.imagePath,
                  placeholder: (context, url) => Center(child: shimmerOffre(height: 200, width: MediaQuery.of(context).size.width,)),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
              ),

            ),
            Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                height: 40,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: verte.withOpacity(0.8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(truncate(wond.wonderName),
                      style: GoogleFonts.lalezar(
                          textStyle: const TextStyle(color: Colors.white)),
                    )),
                    //Text(wond.city, style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.white)),),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class ReviewModal extends StatefulWidget {
  final Wonder wond;

  const ReviewModal({super.key, required this.wond});

  @override
  _ReviewModalState createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Donnez votre avis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Votre avis',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.wond.addAvis(_reviewController.text, _rating);
                Navigator.pop(context);
              },
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReservationModal extends StatefulWidget {
  final Wonder wond;

  const ReservationModal({super.key, required this.wond});

  @override
  _ReservationModalModalState createState() => _ReservationModalModalState();
}

class _ReservationModalModalState extends State<ReservationModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nbrePersonnesController = TextEditingController();
  final TextEditingController numeroTelController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.text =
          "${picked.toLocal()}".split(' ')[0]; // Format the date as needed
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Faire une demande de reservation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Une fois la demande de reservation envoyé vous serait communiqué dans les 24h si la reservation est confirmé ou rejeté',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 25),
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    cacheManager: CustomCacheManager(),
                    imageUrl: widget.wond.imagePath,
                    placeholder: (context, url) => Center(child: shimmerOffre(height: 200, width: MediaQuery.of(context).size.width,)),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nbrePersonnesController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de personnes',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.white12)),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nombre de personnes';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: numeroTelController,
                      decoration: const InputDecoration(
                        labelText: 'Numéro de téléphone',
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.white12)),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un numéro de téléphone';
                        }
                        if (value.length != 9){
                          return 'Votre numero de telephone est invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: "Date",
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.white12)),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  icon: IconButton(
                                      alignment: Alignment.topRight,
                                      onPressed: () => Navigator.pop(context),
                                      icon: Icon(Icons.close_rounded)
                                  ),
                                  content: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.question_mark_rounded, size: 70, color: Colors.green,),
                                        const SizedBox(height: 20),
                                        Text(
                                          "Confirmation",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lalezar(
                                              textStyle: TextStyle(
                                                  fontSize: 18)),
                                        ),
                                        Text(
                                          "Confirmez la reservation du lieu : ${widget.wond.wonderName}",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.jura(
                                              textStyle: TextStyle(
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Annuler")),
                                          ElevatedButton(
                                              onPressed: () {
                                                widget.wond.addReservation(numeroTelController.text, int.parse(nbrePersonnesController.text), dateController.text);
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reservation enregistré !"), backgroundColor: Colors.personnalgreen, duration: Duration(seconds: 1),));
                                              },
                                              child: const Text("Confirmer"))
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      child: const Text('Demander une reservation'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
