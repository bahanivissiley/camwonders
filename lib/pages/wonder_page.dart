import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/auth_pages/debut_inscription.dart';
import 'package:camwonders/pages/AbonnementPage.dart';
import 'package:camwonders/pages/evenement_details.dart';
import 'package:camwonders/pages/guides_details.dart';
import 'package:camwonders/pages/test.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WonderPage extends StatefulWidget {
  final Wonder wond;

  const WonderPage({super.key, required this.wond});

  @override
  State<WonderPage> createState() => _WonderPageState();
}

class _WonderPageState extends State<WonderPage> {
  bool isMap = false;
  bool isItinairaire = false;
  final verte = const Color(0xff226900);
  double userLong = 0.0;
  double userLat = 0.0;
  ValueNotifier<double?> loadVal = ValueNotifier<double?>(null);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final PageController _pageStorieController = PageController();
  final TextEditingController _signalementController = TextEditingController();


  bool isLike = false;
  bool isKeyboardVisible = false;
  late Box<Wonder> favorisBox;
  List<LatLng> points = [];
  double distanceKm = 0.0;
  MapController mapController = MapController();
  String devise = "FCFA";
  String apiKey = "5b3ce3597851110001cf6248b61e34e52a804a1681656eec996f618b";

  @override
  void initState() {
    super.initState();
    _verifyConnection();
    _getCurrentLocation();
    mapController = MapController();
    getRoute();
    favorisBox = Hive.box<Wonder>('favoris_wonder');
    final bool estPresent = favorisBox.values
        .any((wonderdelaBox) => wonderdelaBox.idWonder == widget.wond.idWonder);
    if (estPresent) {
      isLike = true;
    }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
    chargercached();
  }


  Future<void> chargercached() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    devise = prefs.getString('devise')!;
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifiez si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez activer les services de localisation."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifiez les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Les permissions de localisation sont refusées."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Les permissions de localisation sont refusées de manière permanente. Veuillez les activer manuellement dans les paramètres."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtenez la position actuelle
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLat = position.latitude;
        userLong = position.longitude;
      });
    } catch (e, stackTrace) {
      debugPrint("Erreur : $e");
      debugPrint("Stack trace : $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    print(wonder.description_acces);
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
      _showImageDialog();
    }
  }

  Future<void> _uploadImageToSupabase() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Empêche la fermeture du modal en cliquant à l'extérieur
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Indicateur de chargement
                SizedBox(height: 16), // Espacement
                Text('Veuillez patienter...'),
              ],
            ),
          );
        },
      );

      if (_image == null) return;

      // Générer un nom de fichier unique
      final String fileName = '${widget.wond.idWonder}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload de l'image dans le stockage Supabase
      final file = File(_image!.path);

      final uploadResponse = await Supabase.instance.client.storage
          .from('wonders_images_proposes') // Remplacez par le nom de votre bucket
          .upload('public/$fileName.jpg', file);

      if (uploadResponse.isEmpty) {
        throw Exception('Erreur lors de l\'upload de l\'image : ${uploadResponse.toString()}');
      }

      final String imageUrl = 'https://hrqjdfpyaucbqitmxlaq.supabase.co/storage/v1/object/public/$uploadResponse';

      // Enregistrement dans la table Supabase
      await Supabase.instance.client
          .from('wonders_images_proposition') // Remplacez par le nom de votre table
          .insert({
        'wonder': widget.wond.idWonder,
        'image_path': imageUrl,
      });

      _showSuccessDialog();
    } catch (e, stackTrace) {
      // Fermer le modal de chargement en cas d'erreur
      Navigator.of(context).pop();

      debugPrint("Erreur : $e");
      debugPrint("Stack trace : $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Image sélectionnée"),
          content: Image.file(File(_image!.path)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _uploadImageToSupabase();
              },
              child: const Text("Soumettre"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Succès"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 15),
              Text(
                "Image proposée avec succès",
                style: GoogleFonts.lalezar(
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Continuer"),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<Map<String, dynamic>> meteoToday() async {
    final weatherData = await widget.wond.meteoFetch();
    return weatherData['current'];
  }

  Future<Map<String, dynamic>> meteoDemain() async {
    final weatherData = await widget.wond.meteoFetch();
    return weatherData['daily'][1];
  }

  Future<Map<String, dynamic>> meteoApresDemain() async {
    final weatherData = await widget.wond.meteoFetch();
    return weatherData['daily'][2];
  }

  Future<Map<String, dynamic>> meteoDernierJour() async {
    final weatherData = await widget.wond.meteoFetch();
    return weatherData['daily'][3];
  }

  String getWeatherIconUrl(String iconId) {
    return 'http://openweathermap.org/img/wn/$iconId@2x.png';
  }

  Future<void> getRoute() async {
    try {
      await _getCurrentLocation();

      if (userLat == null || userLong == null) {
        throw Exception("Localisation de l'utilisateur non disponible.");
      }

      final url = Uri.parse(
          "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=$userLong,$userLat&end=${widget.wond.longitude},${widget.wond.latitude}");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["features"] == null || data["features"].isEmpty) {
          throw Exception("Aucun itinéraire trouvé.");
        }

        final coordinates = data["features"][0]["geometry"]["coordinates"];
        final double distanceMeters =
        data["features"][0]["properties"]["segments"][0]["distance"];

        setState(() {
          points = coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
          distanceKm = distanceMeters / 1000;
          loadVal.value = 1;
        });
      } else {
        throw Exception("Erreur lors de la récupération de l'itinéraire : ${response.body}");
      }
    } catch (e, stackTrace) {
      debugPrint("Erreur : $e");
      debugPrint("Stack trace : $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
                        if (isLike) {
                          isLike = false;
                          Logique()
                              .supprimerFavorisWonder(favorisBox.length - 1);
                        } else {
                          SetFavorisWonder(widget.wond);
                          isLike = true;
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
                      ConnectFirst(context);
                    }
                  },
                  icon: isLike
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(Icons.favorite_border_rounded),
                ),
                IconButton(
                    onPressed: () {
                      //Share.share('check out my website https://example.com');
                      Share.share("J'ai decouvert sur l'application camwonders le lieu : ${widget.wond.wonderName}\n \n Description : ${widget.wond.description}\n \n Télécharger l\'application : https://www.camwonders.com");
                    },
                    icon: const Icon(Icons.share))
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMap
                ? MapsWonder(size)
                : isItinairaire
                    ? ItinairaireWonder(size)
                    : ImagesWonders(wond: widget.wond),
            Container(
                padding: EdgeInsets.only(
                    left: size.width / 16, right: size.width / 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      LigneAccesBtnCarte(size.width),

                      Text(
                        widget.wond.wonderName,
                        style: GoogleFonts.lalezar(
                            textStyle: const TextStyle(
                          fontSize: 24,
                        )),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.wond.city,
                            style: GoogleFonts.jura(),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(left: 10, right: 10),
                            width: 1,
                            height: 10,
                            color: const Color(0xff226900),
                          ),
                          Text(
                            "${distanceKm.toStringAsFixed(2)} km de votre position",
                            style: GoogleFonts.jura(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
                                  widget.wond.note.floor(),
                                  (index) => const Icon(
                                    Icons.star_rounded,
                                    color: Colors.orange,
                                    size: 15,
                                  ),
                                ),
                              ),
                              // Demi-étoile si nécessaire
                              if (widget.wond.note - widget.wond.note.floor() != 1 &&
                                  widget.wond.note - widget.wond.note.floor() != 0)
                                const Icon(
                                  Icons.star_half_rounded,
                                  color: Colors.orange,
                                  size: 15,
                                ),
                              // Étoiles vides
                              if (widget.wond.note.floor() != 5 &&
                                  widget.wond.note - widget.wond.note.floor() == 0)
                                Row(
                                  children: List.generate(
                                    5 - widget.wond.note.floor(),
                                    (index) => const Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.orange,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              if (widget.wond.note.floor() != 5 &&
                                  widget.wond.note - widget.wond.note.floor() != 1 &&
                                  widget.wond.note - widget.wond.note.floor() != 0)
                                Row(
                                  children: List.generate(
                                    4 - widget.wond.note.floor(),
                                    (index) => const Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.orange,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              if (widget.wond.note.floor() == 5 &&
                                  widget.wond.note - widget.wond.note.floor() != 1 &&
                                  widget.wond.note - widget.wond.note.floor() != 0)
                                Row(
                                  children: List.generate(
                                    4 - widget.wond.note.floor(),
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
                            margin:
                                const EdgeInsets.only(left: 10, right: 10),
                            width: 2,
                            height: 20,
                            color: const Color(0xff226900),
                          ),
                          Text(
                            widget.wond.note.toStringAsFixed(1),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      DescriptionWidget(wond: widget.wond),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.withValues(alpha:0.1)
                              : Colors.grey.withValues(alpha:0.1),
                        ),
                        child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.monetization_on_rounded,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "À partir de ${widget.wond.free ? "Gratuit" : (devise == "FCFA" ? "${widget.wond.price} FCFA" : "\$${(widget.wond.price / 600).toStringAsFixed(2)}")}",
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_car,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Accès ${widget.wond.acces}",
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Comment accéder au lieu ?",
                                      style: GoogleFonts.lalezar(
                                          textStyle:
                                          TextStyle(fontSize: 18)),
                                    ),

                                    SizedBox(height: 3,),

                                    Text(widget.wond.description_acces, style: GoogleFonts.jura(
                                        textStyle: const TextStyle()),),
                                  ],
                                ),
                              ),
                            ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Points forts",
                            style: GoogleFonts.lalezar(
                                textStyle:
                                    TextStyle(fontSize: 18, color: verte)),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 20, bottom: 20),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: widget.wond.getAvantages(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text(
                                          "Quelques n'a pas bien marché"));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Color(0xff226900),
                                  ));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  Center(
                                      child: Text(
                                          "Pas de points forts pour ce lieu",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold))));
                                }

                                final documents = snapshot.data!;

                                return Column(
                                    children: List.generate(documents.length,
                                        (index) {
                                  final data = documents[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Icon(
                                              LucideIcons.checkCircle,
                                              color: verte,
                                              size: 17,
                                            )),
                                        Expanded(
                                          child: Text(
                                            data['content'],
                                            style: GoogleFonts.jura(
                                                textStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
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
                                textStyle: const TextStyle(
                                    fontSize: 18, color: Colors.red)),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 20, bottom: 20),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: widget.wond.getInconvenients(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text(
                                          "Quelques n'a pas bien marché"));
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Color(0xff226900),
                                  ));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text(
                                          "Pas de limites enregistrées pour ce lieu",
                                          style: GoogleFonts.jura(
                                              textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.bold))));
                                }

                                final documents = snapshot.data!;

                                return Column(
                                    children: List.generate(documents.length,
                                        (index) {
                                  final data = documents[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.only(
                                                right: 10),
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
                                                  fontWeight:
                                                      FontWeight.bold)),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: meteoToday(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text(
                                                'Un problème est survenu'));
                                      } else if (!snapshot.hasData) {
                                        return const Center(
                                            child: Text(
                                                'Pas de données disponible'));
                                      } else {
                                        final weather = snapshot.data!;
                                        final weatherIconId =
                                            weather['weather'][0]['icon'];
                                        final weatherIconUrl =
                                            getWeatherIconUrl(weatherIconId);
                                        final double temp = weather['temp'];
                                        final double tempCelcius =
                                            temp - 273.15;

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
                                                child: Image.network(
                                                    weatherIconUrl)),
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
                                            child:
                                                CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
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
                                        final double temp =
                                            weather['temp']['day'];
                                        final double tempCelcius =
                                            temp - 273.15;

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
                                                child: Image.network(
                                                    weatherIconUrl)),
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
                                            child:
                                                CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text(
                                                'Un problème est survenu'));
                                      } else if (!snapshot.hasData) {
                                        return const Center(
                                            child: Text(
                                                'Pas de données disponible'));
                                      } else {
                                        final weather = snapshot.data!;
                                        final weatherIconId =
                                            weather['weather'][0]['icon'];
                                        final weatherIconUrl =
                                            getWeatherIconUrl(weatherIconId);
                                        final double temp =
                                            weather['temp']['day'];
                                        final double tempCelcius =
                                            temp - 273.15;

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
                                                child: Image.network(
                                                    weatherIconUrl)),
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
                                            child:
                                                CircularProgressIndicator());
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
                                        final double temp =
                                            weather['temp']['day'];
                                        final double tempCelcius =
                                            temp - 273.15;
                                        final DateTime date = DateTime.now();
                                        final DateTime lendemain =
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
                                                child: Image.network(
                                                    weatherIconUrl)),
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
                        padding: const EdgeInsets.only(top: 15),
                        margin: EdgeInsets.all(size.width / 100),
                        child: Column(
                          children: [
                            Text(
                              "Contribuer",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(fontSize: 20)),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (AuthService().currentUser != null) {
                                      _showReviewModal(context);
                                    } else {
                                      ConnectFirst(context);
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
                                            title: const Text(
                                                "Selectionner une photo"),
                                            actions: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed:
                                                            _pickImage,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(
                                                              LucideIcons
                                                                  .image,
                                                              size: 20,
                                                            ),
                                                            Text(
                                                              "Gallerie",
                                                              style:
                                                                  GoogleFonts
                                                                      .jura(),
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
                          ],
                        ),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: widget.wond.getAvis(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Un problème est survenu");
                          }



                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: size.height / 13,
                                  margin: const EdgeInsets.all(20),
                                  child: Image.asset('assets/review.png'),
                                ),
                                const Text("Pas d'avis !")
                              ],
                            ));
                          }

                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: min(snapshot.data!.length, 2),
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> document = snapshot.data![index];
                                final Avis avis = Avis(
                                  idAvis: document['id'],
                                  note: (document['note'] as num).toDouble(),
                                  content: document['content'],
                                  wonder: document['wonder'],
                                  userImage: document['profil_path_user'],
                                  userName: document['user_name'],
                                  userId: document['user'],
                                );
                                return GestureDetector(
                                    onTap: () {
                                    },
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
                                        child: StreamBuilder<List<Map<String, dynamic>>>(
                                          stream: widget.wond.getAvis(),
                                          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text(
                                                  'Un problème est survenu');
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    CircularProgressIndicator(
                                                        color:
                                                            Color(0xff226900))
                                                  ],
                                                ),
                                              );
                                            }

                                            if (snapshot.data!.isEmpty) {
                                              return Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: size.height / 15,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? Image.asset(
                                                            'assets/review.png')
                                                        : Image.asset(
                                                            'assets/review.png'),
                                                  ),
                                                  const Text("Pas d'avis !")
                                                ],
                                              ));
                                            }

                                            return ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: snapshot
                                                    .data!.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                      final Map<String, dynamic> document = snapshot.data![index];
                                                      final Avis avis = Avis(
                                                        idAvis: document['id'],
                                                        note: (document['note'] as num).toDouble(),
                                                        content: document['content'],
                                                        wonder: document['wonder'],
                                                        userImage: document['profil_path_user'],
                                                        userName: document['user_name'],
                                                        userId: document['user'],
                                                      );
                                                  return GestureDetector(
                                                      onTap: () {},
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
                                backgroundColor:
                                    WidgetStateProperty.all<Color>(
                                        Colors.transparent),
                                foregroundColor:
                                    WidgetStateProperty.all(verte),
                                shape:
                                    WidgetStateProperty.all<OutlinedBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                side: WidgetStateProperty.all<BorderSide>(
                                    BorderSide(color: verte)),
                                padding: WidgetStateProperty.all<
                                        EdgeInsetsGeometry>(
                                    EdgeInsets.fromLTRB(size.width / 4, 7,
                                        size.width / 4, 7)),
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
                    ])),
            EvenementList(wond: widget.wond),
            GuidesList(wond: widget.wond, size: size),
            Container(
              margin: EdgeInsets.only(
                left: size.width / 16,
                right: size.width / 16,
              ),
              child: Text(
                "Similaires",
                style: GoogleFonts.lalezar(
                    textStyle: const TextStyle(
                  fontSize: 20,
                )),
              ),
            ),
            SimilairesList(wond: widget.wond),
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
                                        TextField(
                                          controller: _signalementController,
                                          decoration: const InputDecoration(
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
                                            widget.wond.addSignalement(_signalementController.text);
                                            showDialog(
                                              context: context,
                                              barrierDismissible:
                                              false, // Empêche la fermeture du modal en cliquant à l'extérieur
                                              builder: (BuildContext context) {
                                                return const AlertDialog(
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CircularProgressIndicator(), // Indicateur de chargement
                                                      SizedBox(height: 16), // Espacement
                                                      Text('Veuillez patienter...'),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                            Navigator.of(context)
                                                .pop(); // Fermer la boîte de dialogue
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
                          ConnectFirst(context);
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
      bottomNavigationBar: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
                width: size.width / 3,
                child: Text(
                  "Ouvert : ${widget.wond.horaire}",
                  style: GoogleFonts.lalezar(
                      textStyle: TextStyle(fontSize: 15, color: verte)),
                )),
            ElevatedButton(
              onPressed: () {
                if (AuthService().currentUser != null) {
                  if (widget.wond.isreservable) {
                    if (userProvider.isPremium) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: ReservationModal(wond: widget.wond),
                            );
                          });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscriptionPage()));
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Lieu non pris en charge",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(
                                      color: Color(0xff226900), fontSize: 25)),
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
                  ConnectFirst(context);
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
                    if (userProvider.isPremium) {
                      if (userLong != 0) {
                        setState(() {
                          isItinairaire = true;
                          isMap = false;
                        });
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Empêche la fermeture du modal en cliquant à l'extérieur
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(), // Indicateur de chargement
                                  SizedBox(height: 16), // Espacement
                                  Text('Veuillez patienter...'),
                                ],
                              ),
                            );
                          },
                        );

                        loadVal.addListener(() {
                          if (loadVal.value != null) {
                            Navigator.of(context).pop();
                          }
                        });
                      }
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscriptionPage()));
                    }
                  } else {
                    ConnectFirst(context);
                  }
                },
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.map,
                      color: Colors.white,
                    ),
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

  Future<dynamic> EnDeveloppement(BuildContext context) {
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

  Future<dynamic> ConnectFirst(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ignorer",
                  style: TextStyle(decoration: TextDecoration.underline)),
            )
                          ],
                        ),
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

  Container LigneAccesBtnCarte(double width) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.grey, // Couleur de la bordure
            width: 1.0, // Épaisseur de la bordure
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Bordure arrondie
          ),
          foregroundColor: Theme.of(context).colorScheme.onSurface, // Couleur du texte adaptée au thème
        ),
        onPressed: () {
          setState(() {
            if (isMap) {
              isMap = false;
              isItinairaire = false;
            } else {
              isMap = true;
              isItinairaire = false;
            }
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.map,
            ),
            Text(
              isMap ? "  Images" : "  Carte",
              style: GoogleFonts.lalezar(
                  textStyle:
                      const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox MapsWonder(Size size) {
    return SizedBox(
      height: 350,
      width: size.width,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: latLng.LatLng(
              widget.wond.latitude, widget.wond.longitude),
          initialZoom: 14,
          interactionOptions:
              const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
        ),
        children: [
          openStreetMapTileLatter,
          MarkerLayer(markers: [
            Marker(
                point: latLng.LatLng(
                    widget.wond.latitude, widget.wond.longitude),
                child: const Icon(
                  Icons.location_pin,
                  color: Color(0xff226900),
                  size: 50,
                ))
          ])
        ],
      ),
    );
  }

  SizedBox ItinairaireWonder(Size size) {
    return SizedBox(
      height: 350,
      width: size.width,
      child: Stack(
        alignment: const Alignment(1, 1),
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: latLng.LatLng(userLat, userLong),
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
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
                    point: latLng.LatLng(userLat, userLong),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: latLng.LatLng(widget.wond.latitude,
                        widget.wond.longitude),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 5),
            child: ElevatedButton(
              onPressed: () {
                {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (_, __, ___) => MapScreen(
                                endLat: widget.wond.latitude,
                                endLong: widget.wond.longitude,
                              ),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                      reverseCurve: Curves.easeInOutBack)),
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 500)));
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Agrandir",
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.route,
                    color: Colors.white,
                  ),
                ],
              ),
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
      builder: (context) => Builder(
        builder: (context) => ReviewModal(wond: widget.wond),
      ),
    );
  }
}

TileLayer get openStreetMapTileLatter => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );



class ImagesWonders extends StatefulWidget {
  const ImagesWonders({super.key, required this.wond});
  final Wonder wond;

  @override
  State<ImagesWonders> createState() => _ImagesWondersState();
}

class _ImagesWondersState extends State<ImagesWonders> {
  final PageController _pageStorieController = PageController();
  int _currentPageIndex = 0;
  List<Map<String, dynamic>>? _documents;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final List<Map<String, dynamic>> images = await widget.wond.fetchImages();
      setState(() {
        _documents = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFullScreenImage(String imageUrl, String source) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 50,
                    ),
                  );
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                bottom: 30,
                right: 0,
                left: 0,
                child: Center(
                  child: Text(
                    source.length > 4 ? source.substring(0, source.length - 4) : source,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: 350,
          width: size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (_isLoading)
                Center(
                  child: shimmerOffre(width: size.width, height: 350),
                )
              else if (_documents == null || _documents!.isEmpty)
                const Center(child: Text('No images found.'))
              else
                PageView.builder(
                  controller: _pageStorieController,
                  itemCount: _documents!.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final document = _documents![index];
                    return GestureDetector(
                      onTap: () {
                        _showFullScreenImage(document['image_url'], document['source']);
                      },
                      child: PhotoWonder(
                        path: document['image_url'],
                        wonderName: widget.wond.wonderName,
                      ),
                    );
                  },
                ),
              // Indicateur de position (rectangles)
              Positioned(
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_documents?.length ?? 0, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: _currentPageIndex == index ? 20 : 10,
                      decoration: BoxDecoration(
                        color: _currentPageIndex == index ? Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DescriptionWidget extends StatefulWidget {
  const DescriptionWidget({super.key, required this.wond});
  final Wonder wond;

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  bool isVoir = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.wond.description,
                maxLines: isVoir ? 1000 : 4,
                style: GoogleFonts.jura(
                    textStyle: const TextStyle(
                  fontSize: 15,
                ))),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isVoir) {
                    isVoir = false;
                  } else {
                    isVoir = true;
                  }
                });
              },
              child: Text(
                isVoir ? "Voir moins" : "Voir plus",
                style: GoogleFonts.lalezar(
                    textStyle: const TextStyle(
                        fontSize: 16, decoration: TextDecoration.underline)),
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
    final Utilisateur? user =
        await Camwonder().getUserByUniqueRealId(widget.avis.userId);
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
            color: Theme.of(context).brightness != Brightness.light
                ? Colors.black.withValues(alpha:0.3)
                : Colors.grey)),
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black.withValues(alpha:0.3),
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
                              widget.avis.note - widget.avis.note.floor() != 0)
                            const Icon(
                              Icons.star_half_rounded,
                              color: Colors.orange,
                              size: 15,
                            ),
                          // Étoiles vides
                          if (widget.avis.note.floor() != 5 &&
                              widget.avis.note - widget.avis.note.floor() == 0)
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
                              widget.avis.note - widget.avis.note.floor() != 0)
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
                              widget.avis.note - widget.avis.note.floor() != 0)
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

class GuideWidget extends StatefulWidget {
  const GuideWidget({
    super.key,
    required this.size,
    required this.guide,
    required this.maxlines,
  });

  final Guide guide;
  final Size size;
  final int maxlines;

  @override
  State<GuideWidget> createState() => _GuideWidgetState();
}

class _GuideWidgetState extends State<GuideWidget> {
  String username = "Chargement...";

  @override
  void initState() {
    super.initState();
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
      margin: const EdgeInsets.only(left: 10, top: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(widget.guide.profilPath),
                        fit: BoxFit.cover)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.guide.nom,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(fontSize: 13)),
                  ),
                  Row(
                    children: [
                      Text(
                        "Guide certifié",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(fontSize: 10)),
                      ),
                      const SizedBox(width: 5,),
                      const Icon(LucideIcons.shieldCheck, color: Colors.blue, size: 15,)
                    ],
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PhotoWonder extends StatelessWidget {
  final String path;
  final String wonderName;

  const PhotoWonder({super.key, required this.path, required this.wonderName});

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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
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

  @override
  void initState() {
    super.initState();
    // Assurez-vous que le widget est construit avant d'appeler _animateToIndex
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.wond.getSimilar(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xff226900),
            ));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Vous n'etes pas connecté "),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
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
          } else {
            return SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: snapshot.data!
                    .where((doc) => doc['id'] != widget.wond.idWonder)
                    .map((Map<String, dynamic> document) {
                  final Wonder wwond = Wonder(
                      idWonder: document['id'],
                      wonderName: document['wonder_name'],
                      description: document['description'],
                      imagePath: document['image_path'],
                      city: document['city'],
                      region: document['region'],
                      free: document['free'],
                      price: document['price'],
                      horaire: document['horaire'],
                      latitude: document['latitude'],
                      longitude: document['longitude'],
                      note: (document['note'] as num).toDouble(),
                      categorie: document['categorie'],
                      isreservable: document['is_reservable'],
                      acces: document['acces'],
                      description_acces: document['description_acces'],
                      is_premium: document['is_premium']);
                  return Storie(wond: wwond);
                }).toList(),
              ),
            );
          }
        });
  }

  @override
  void dispose() {
    _controller
        .dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}

class GuidesList extends StatefulWidget {
  const GuidesList({super.key, required this.wond, required this.size});
  final Wonder wond;
  final Size size;

  @override
  State<GuidesList> createState() => _GuidesListState();
}

class _GuidesListState extends State<GuidesList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = Provider.of<UserProvider>(context);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.wond.getGuide(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Un problème est survenu");
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Container(
                margin: const EdgeInsets.all(25),
                child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                Container(
                  height: widget.size.height / 20,
                  margin: const EdgeInsets.all(20),
                  child: const Icon(Icons.person_off_outlined, size: 40,),
                ),
                const Text("Pas de guide enregistré pour ce lieu !")
                            ],
                          ),
              ));
        }

        return SizedBox(
          height: 155,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // Permet le défilement
            children: snapshot.data!.map((Map<String, dynamic> document) {
              final Guide guide = Guide(
                id: document['id'],
                numero: document['numero'],
                nom: document['nom'],
                wonder: document['wonder'],
                profilPath: document['profil_path'],
              );
              return SizedBox(
                child: GestureDetector(
                  onTap: () {
                    if(widget.wond.free || userProvider.isPremium){
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  GuidesDetails(guide: guide),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                      begin: const Offset(-1.0, 0.0),
                                      end: Offset.zero)
                                      .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                      reverseCurve: Curves.easeInOutBack)),
                                  child: child,
                                );
                              },
                              transitionDuration:
                              const Duration(milliseconds: 700)));
                    }else{
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SubscriptionPage()));
                    }

                  },
                  child: GuideWidget(
                    size: widget.size,
                    guide: guide,
                    maxlines: 2,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class EvenementList extends StatefulWidget {
  const EvenementList({super.key, required this.wond});
  final Wonder wond;

  static const verte = Color(0xff226900);

  @override
  State<EvenementList> createState() => _EvenementListState();
}

class _EvenementListState extends State<EvenementList> with AutomaticKeepAliveClientMixin{
  final ScrollController _controller = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Assurez-vous que le widget est construit avant d'appeler _animateToIndex
  }

  String truncate(String text) {
    if (text.length > 20) {
      return "${text.substring(0, 20)}...";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.wond.getEvenement(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Vous n'etes pas connecté "),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                  child: Image.asset("assets/vide_street.png"),
                ),
                const Text("Pas d'événements pour ce lieu")
              ],
            ));
          } else {
            return SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: snapshot.data!.map((Map<String, dynamic> document) {
                  final Evenements evenement = Evenements(
                      idevenements: document['id'],
                      contenu: document['contenu'],
                      title: document['title'],
                      numeroTel: document['numero_tel'],
                      imagePath: document['image_path'],
                      idWonder: document['wonder'],
                      date: document['date']);
                  return GestureDetector(
                    onTap: () {
                      if(widget.wond.free || userProvider.isPremium){
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (_, __, ___) => EvenementDetails(
                                    evenement: evenement, wond: widget.wond),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                        begin: const Offset(-1.0, 0.0),
                                        end: Offset.zero)
                                        .animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                        reverseCurve: Curves.easeInOutBack)),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                const Duration(milliseconds: 700)));
                      }else{
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SubscriptionPage()));
                      }

                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 10, bottom: 15, left: 15),
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xff226900).withValues(alpha:0.1)
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 125,
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                              color: const Color(0xff226900),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                cacheManager: CustomCacheManager(),
                                imageUrl: document['image_path'],
                                placeholder: (context, url) => Center(
                                    child: shimmerOffre(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                )),
                                errorWidget: (context, url, error) =>
                                    const Center(child: Icon(Icons.error)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      truncate(document['title']),
                                      maxLines: 1,
                                      style: GoogleFonts.lalezar(
                                          textStyle: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff226900))),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Color(0xff226900),
                                      weight: 4,
                                    )
                                  ],
                                ),
                                Text(
                                  document['contenu'],
                                  maxLines: 1,
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ),
                                Text(
                                  document['date'],
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 12)),
                                ),
                                Container(
                                  height: 1,
                                  width: 40,
                                  color: const Color(0xff226900),
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
        });
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => WonderPage(wond: wond)));
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
                  placeholder: (context, url) => Center(
                      child: shimmerOffre(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                  )),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
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
                  color: verte.withValues(alpha:0.8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(
                      truncate(wond.wonderName),
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
              minRating: 1,
              allowHalfRating: true,
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
                if (_reviewController.text != '') {
                  widget.wond.addAvis(_reviewController.text, _rating);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: Text("Impossible d'ajouter un avis vide !")),
                    ),
                    duration: const Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ));
                }
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
    final DateTime? picked = await showDatePicker(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.green.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(500)),
            height: 80,
            width: 80,
            child: const Icon(
              Icons.sticky_note_2,
              size: 40,
              color: Colors.green,
            )),
        const Text(
          'Demande de reservation',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Une fois la demande envoyé vous serait communiqué dans les 24h si la reservation est confirmé ou rejeté',
          style: TextStyle(fontSize: 10, color: Colors.red),
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
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de personnes';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre valide (supérieur à 0)';
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
                      borderSide: BorderSide(width: 2, color: Colors.white12)),
                  contentPadding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  if (value.length != 9) {
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
                      borderSide: BorderSide(width: 2, color: Colors.white12)),
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
                            content: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha:0.2),
                                          borderRadius:
                                              BorderRadius.circular(500)),
                                      height: 80,
                                      width: 80,
                                      child: const Icon(
                                        Icons.help,
                                        size: 40,
                                        color: Colors.green,
                                      )),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Confirmation",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lalezar(
                                        textStyle:
                                            const TextStyle(fontSize: 25)),
                                  ),
                                  Text(
                                    "Confirmez la reservation du lieu : ${widget.wond.wonderName}",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                            const TextStyle(fontSize: 15)),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          widget.wond.addReservation(
                                              numeroTelController.text,
                                              int.parse(
                                                  nbrePersonnesController
                                                      .text),
                                              dateController.text);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                "Reservation enregistré !"),
                                            backgroundColor:
                                                Color(0xff226900),
                                            duration: Duration(seconds: 1),
                                          ));
                                        },
                                        child: const Text("Confirmer")),
                                  ),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Annuler")),
                                ],
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
    );
  }
}
