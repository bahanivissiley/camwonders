// ignore_for_file: use_build_context_synchronously, unused_field

import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/pages/AbonnementPage.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/auth_pages/inscription.dart';
import 'package:camwonders/pages/policies.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  bool light = false;
  static const verte = Color(0xff226900);
  String _selectedDevise = "FCFA";
  String _selectedlangue = "Français";
  Utilisateur? _user;
  bool _isLoading = true;
  String? _error;
  String profilpath = "";
  String devise = "...";

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    chargercached();
  }

  Future<void> chargercached() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    devise = prefs.getString('devise') ?? 'FCFA';
    _selectedDevise = devise;
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

  Future<void> _fetchUserInfo() async {
    try {
      final Utilisateur user = await Camwonder().getUserInfo();

      setState(() {
        _user = user;
        _isLoading = false;
        profilpath = _user!.profilPath;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });

    if (_image != null) {
      final File imageFile = File(_image!.path);

      try {
        if (profilpath !=
            "https://hrqjdfpyaucbqitmxlaq.supabase.co/storage/v1/object/public/profilsUser/public/inconnu.png") {
          try {
            final oldFileName = profilpath.split('/').last;
            await Supabase.instance.client.storage
                .from('profilsUser') // Remplacez par le nom de votre bucket
                .remove([oldFileName]);
          } catch (e) {
            print('Erreur lors de la suppression de l\'ancienne image : $e');
          }
        }

        final uploadResponse = await Supabase.instance.client.storage
            .from('profilsUser') // Remplacez par le nom de votre bucket
            .upload('public/profil_${_user!.identifiant}.jpg', imageFile);

        if (uploadResponse.isEmpty) {
          throw Exception('Erreur lors de l\'upload de l\'image : ${uploadResponse.toString()}');
        }

        final String downloadURL = 'https://hrqjdfpyaucbqitmxlaq.supabase.co/storage/v1/object/public/$uploadResponse';

        await Supabase.instance.client
            .from('user')
            .update({'profil_path': downloadURL})
            .eq('uid', Supabase.instance.client.auth.currentUser!.id);

        // Mettre à jour les SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profilPath', downloadURL);

        // Mettre à jour l'état
        setState(() {
          profilpath = downloadURL;
        });

        // Mettre à jour le profil de l'utilisateur dans la table 'users'
        await Supabase.instance.client
            .from('user') // Remplacez par le nom de votre table
            .update({'profil_path': downloadURL})
            .eq('uid', _user!.uid); // Remplacez 'id' par le nom de la colonne
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'image de profil : $e');
      }
    }
  }

  final List<String> langues = [
    'Français',
    //'English',
    // Ajoutez d'autres notifications selon vos besoins
  ];

  final List<String> themes = [
    'activé',
    'Desactivé',
    // Ajoutez d'autres notifications selon vos besoins
  ];

  final List<String> devises = [
    'FCFA',
    'Dollar',
    // Ajoutez d'autres notifications selon vos besoins
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return _isLoading ? const CircularProgressIndicator() : SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 13),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            margin: const EdgeInsets.all(15),
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.height / 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(500),
                              child: _image !=
                                      null // Vérifie si une image a été sélectionnée
                                  ? Image.file(
                                      File(_image!
                                          .path), // Affiche l'image locale
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      cacheManager: CustomCacheManagerLong(),
                                      imageUrl: profilpath,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator(
                                        color: Color(0xff226900),
                                      )),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                              child: Icon(Icons.error)),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_user!.nom == "Utilisateur inconnu") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Center(
                                      child: Text("Vous n'etes pas connecté")),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                _pickImage();
                              }
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.height / 5.8,
                              height: MediaQuery.of(context).size.height / 5.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(500),
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          _user!.nom,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lalezar(
                              textStyle:
                                  const TextStyle(fontSize: 20, color: verte)),
                        ),
                      ),
                      Text(
                        _user!.identifiant,
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 170,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Compte : ",
                              style: GoogleFonts.lalezar(
                                  textStyle: const TextStyle(fontSize: 16)),
                            ),
                            _user!.premium
                                ? Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child: Text(
                                        "Premium",
                                        style: GoogleFonts.jura(
                                            textStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(5),
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: verte,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child: Text(
                                        "Gratuit",
                                        style: GoogleFonts.jura(
                                            textStyle: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : const CircularProgressIndicator(
                    color: verte,
                  ),
            Column(
              children: [
                Column(
                  children: [
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.languages,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Langues",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                            const TextStyle(fontSize: 15))),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _selectedlangue,
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 15)),
                                ),
                                const Icon(LucideIcons.chevronRight,
                                    color: verte),
                              ],
                            )
                          ],
                        ),
                      ),
                      itemBuilder: (BuildContext context) {
                        return langues.map((String langue) {
                          return PopupMenuItem<String>(
                            value: langue,
                            child: SizedBox(
                              width: size.width,
                              child: Text(langue),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (String langue) {
                        // Traitez la notification sélectionnée ici
                        setState(() {
                          _selectedlangue = langue;
                        });
                      },
                    ),
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.dollarSign,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Devises",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                            const TextStyle(fontSize: 15))),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _selectedDevise,
                                  style: GoogleFonts.jura(
                                      textStyle: const TextStyle(fontSize: 15)),
                                ),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  color: verte,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      itemBuilder: (BuildContext context) {
                        return devises.map((String devise) {
                          return PopupMenuItem<String>(
                            value: devise,
                            child: SizedBox(
                              width: size.width,
                              child: Text(devise),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (String devise) async {
                        // Traitez la notification sélectionnée ici
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString("devise", devise);
                        setState(() {
                          _selectedDevise = devise;
                        });
                      },
                    ),
                    PopupMenuButton<String>(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.dark_mode,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Thème sombre",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                            const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(LucideIcons.chevronRight, color: verte),
                              ],
                            )
                          ],
                        ),
                      ),
                      itemBuilder: (BuildContext context) {
                        return themes.map((String langue) {
                          return PopupMenuItem<String>(
                            value: langue,
                            child: SizedBox(
                              width: size.width,
                              child: Text(langue),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (String langue) {
                        // Traitez la notification sélectionnée ici
                        if (langue == "activé") {
                          setState(() {
                            AdaptiveTheme.of(context).setDark();
                          });
                        } else {
                          AdaptiveTheme.of(context).setLight();
                        }
                      },
                    ),
                    _user == null || _user!.nom  == "Utilisateur inconnu" ? const SizedBox() : (userProvider.isPremium || (_user?.premium ?? false)) ? const SizedBox() : GestureDetector(

                      onTap: () {
                        Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => SubscriptionPage(),

                            transitionsBuilder: (_,animation,__,child){
                              return SlideTransition(
                                position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 500)
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Passez en premium",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                        const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const Row(
                              children: [
                                IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      LucideIcons.chevronRight,
                                      color: verte,
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.green.withValues(alpha:0.2),
                                            borderRadius:
                                                BorderRadius.circular(500)),
                                        height: 80,
                                        width: 80,
                                        child: const Icon(
                                          Icons.help,
                                          size: 40,
                                          color: Colors.green,
                                        )),
                                  ],
                                ),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Demandez une assistance",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                    Text(
                                        "Comment voulez-vous nous contacter pour assistance ?"),
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: const ElevatedButton(
                                              onPressed: null,
                                              child: Text("Email")),
                                        ),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: const ElevatedButton(
                                              onPressed: null,
                                              child: Text("WhatsApp")),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("Annuler")),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.helpCircle,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Assistance",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                            const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const Row(
                              children: [
                                IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      LucideIcons.chevronRight,
                                      color: verte,
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color:
                                            Colors.green.withValues(alpha:0.2),
                                            borderRadius:
                                            BorderRadius.circular(500)),
                                        height: 60,
                                        width: 60,
                                        child: const Icon(
                                          Icons.info,
                                          size: 30,
                                          color: Colors.green,
                                        )),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.height/10,
                                      child: Image.asset('assets/logo.png'),
                                    ),
                                    const Text(
                                      "Information de l'application",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    ),
                                    const SizedBox(height: 30,),
                                    const Text(
                                        "Camwonders est une application mobile de tourisme destinée au amoureux de tourisme et de nouvelle expérience tant nationaux, qu'internatinaux. Elle redefinit la focon de decouvrir les lieux au cameroun"),
                                    const SizedBox(height: 10,),
                                    TextButton(
                                        onPressed: () async {
                                          final Uri url = Uri.parse("https://www.camwonders.com");
                                          if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                          } else {
                                          throw "Impossible d'ouvrir le lien";
                                          }
                                        },
                                        child: Text('Site web : www.camwonders.com'),
                                    ),
                                    const SizedBox(height: 30,),
                                    const Row(
                                      children: [
                                        Icon(Icons.perm_contact_calendar_sharp, size: 50,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Auteur', style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),),
                                            Text('Camwonders team')
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        SizedBox(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Ok")),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.info,
                                  color: verte,
                                ),
                                const SizedBox(width: 10),
                                Text("Infos sur l'application",
                                    style: GoogleFonts.jura(
                                        textStyle:
                                        const TextStyle(fontSize: 15))),
                              ],
                            ),
                            const Row(
                              children: [
                                IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      LucideIcons.chevronRight,
                                      color: verte,
                                    ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (AuthService().currentUser != null) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withValues(alpha:0.2),
                                              borderRadius:
                                                  BorderRadius.circular(500)),
                                          height: 80,
                                          width: 80,
                                          child: const Icon(
                                            Icons.help,
                                            size: 40,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Deconnexion",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Center(
                                          child: Text(
                                        "Etes vous sûr de vouloir vous déconnecter de votre compte ?",
                                        style: TextStyle(color: Colors.grey),
                                      ))
                                    ],
                                  ),
                                  actions: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent),
                                              onPressed: () async {
                                                await AuthService().signOut();
                                                Provider.of<UserProvider>(context, listen: false).logout();
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Inscription()),
                                                  (Route<dynamic> route) =>
                                                      false,
                                                );
                                              },
                                              child: const Text("Deconnecter")),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              "Annuler",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                      ],
                                    )
                                  ],
                                );
                              });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Center(child: Text("Vous n'etes pas connecté")),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Deconnexion",
                                style: GoogleFonts.jura(
                                    textStyle: const TextStyle(
                                        color: Colors.red, fontSize: 15)))
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (AuthService().currentUser != null) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withValues(alpha:0.2),
                                              borderRadius:
                                                  BorderRadius.circular(500)),
                                          height: 80,
                                          width: 80,
                                          child: const Icon(
                                            Icons.help,
                                            size: 40,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                  content: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Suppression",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Center(
                                          child: Text(
                                        "Vous allez supprimer votre compte, etes vous sur de vouloir continuer",
                                        style: TextStyle(color: Colors.grey),
                                      ))
                                    ],
                                  ),
                                  actions: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent),
                                              onPressed: () async {
                                                await AuthService().signOut();
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const Inscription()),
                                                  (Route<dynamic> route) =>
                                                      false,
                                                );
                                              },
                                              child:
                                                  const Text("Oui supprimer")),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              "Annuler",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )),
                                      ],
                                    )
                                  ],
                                );
                              });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Center(child: Text("Vous n'etes pas connecté")),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha:0.5))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Supprimer mon compte",
                                style: GoogleFonts.jura(
                                    textStyle: const TextStyle(
                                        color: Colors.red, fontSize: 15)))
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Policies()));
              },
              child: Text(
                "Conditions d'utilisation",
                style: GoogleFonts.jura(
                    textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: verte,
                )),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Version de l'application : 1.0.0",
              style: GoogleFonts.jura(
                  textStyle: const TextStyle(
                fontSize: 12,
              )),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
