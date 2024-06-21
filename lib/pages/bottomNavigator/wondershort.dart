import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/WonderShort.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/firebase_logique.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/services/logique.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';

class Wondershort extends StatefulWidget {
  const Wondershort({Key? key}) : super(key: key);

  @override
  State<Wondershort> createState() => _WondershortState();
}

class _WondershortState extends State<Wondershort> {
  late final Stream<List<WonderShort>> _wondershortStream;
  late List<VideoPlayerController> _controllers;
  late int _currentIndex;
  final int _preloadOffset = 2;

  @override
  void initState() {
    super.initState();
    _wondershortStream = Camwonder().getWonderShortStream();
    _controllers = [];
    _currentIndex = 0;
    _preloadInitialVideos();
    _verifyConnection();
  }

  void _preloadInitialVideos() {
    _wondershortStream.listen((List<WonderShort> wondershorts) {
      for (int i = 0; i < _preloadOffset; i++) {
        _addVideoController(wondershorts[i]);
      }
    });
  }

  void _preloadMoreVideos(List<WonderShort> wondershorts, int startIndex) {
    for (int i = startIndex;
        i < startIndex + _preloadOffset && i < wondershorts.length;
        i++) {
      _addVideoController(wondershorts[i]);
    }
  }

  void _addVideoController(WonderShort wonderShort) {
    VideoPlayerController controller =
        VideoPlayerController.network(wonderShort.videoPath)
          ..initialize().then((_) {
            _controllers[0].play(); // Commencez à lire la première vidéo
            _controllers[0].setLooping(true);
            setState(() {});
          });
    _controllers.add(controller);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyConnection() async {
    if (!(await Logique.checkInternetConnection())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Connectez-vous à internet"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WonderShort>>(
      stream: _wondershortStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }

        List<WonderShort> wondershorts = snapshot.data!;

        return Stack(
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: double.infinity,
                scrollDirection: Axis.vertical,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  if (index >= _currentIndex + _preloadOffset - 1) {
                    _preloadMoreVideos(
                        wondershorts, _currentIndex + _preloadOffset);
                  }

                  _controllers[_currentIndex].pause();
                  _controllers[index].play();
                  _controllers[index].setLooping(true);
                  _currentIndex = index;
                },
              ),
              itemCount: wondershorts.length,
              itemBuilder: (context, index, realIndex) {
                return VideoShort(
                  item: wondershorts[index],
                  controller: _controllers[index],
                );
              },
            ),
            Container(
              padding: const EdgeInsets.only(top: 35),
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Text(
                    "WonderShort",
                    style: GoogleFonts.jura(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Camwonders",
                    style: GoogleFonts.lalezar(
                      textStyle: const TextStyle(
                        fontSize: 25,
                        color: PostContent.verte,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 6)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class VideoShort extends StatefulWidget {
  final WonderShort item;
  final VideoPlayerController controller;

  const VideoShort({
    Key? key,
    required this.item,
    required this.controller,
  }) : super(key: key);

  @override
  _VideoShortState createState() => _VideoShortState();
}

class _VideoShortState extends State<VideoShort> {
  Wonder _wonder = Wonder(
    idWonder: "chargement...",
    wonderName: "chargement...",
    description: "chargement...",
    imagePath: "chargement...",
    city: "chargement...",
    region: "chargement...",
    free: false,
    price: 500,
    horaire: "chargement...",
    latitude: "chargement...",
    longitude: "chargement...",
    note: 0.0,
    categorie: "chargement...",
    isreservable: false
  );

  @override
  void initState() {
    super.initState();
    _fetchWonder();
  }

  Future<void> _fetchWonder() async {
    Wonder? futureWonder = await Camwonder().getWonderById(widget.item.wond);
    if (futureWonder != null) {
      setState(() {
        _wonder = futureWonder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayer(widget.controller),
        Positioned.fill(
          child: PostContent(
            wondshort: widget.item,
            wonder: _wonder,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}

class PostContent extends StatefulWidget {
  static const Color verte = Color(0xff226900);
  final WonderShort wondshort;
  final Wonder wonder;
  final VideoPlayerController controller;

  const PostContent({
    Key? key,
    required this.wondshort,
    required this.wonder,
    required this.controller,
  }) : super(key: key);

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 5 / 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.wonder.wonderName}...",
                        maxLines: 1,
                        style: GoogleFonts.lalezar(
                            textStyle: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                shadows: [
                              Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 6)
                            ])),
                      ),
                      Text(
                        "${widget.wondshort.desc}...",
                        maxLines: 3,
                        style: GoogleFonts.jura(
                            textStyle: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                shadows: [
                              Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 6)
                            ])),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 6,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: () {
                            widget.controller.pause();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    wonder_page(wond: widget.wonder),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero)
                                        .animate(CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                            reverseCurve:
                                                Curves.easeInOutBack)),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 700),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.arrowBigRight,
                              color: PostContent.verte),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: () {
                            if(AuthService().currentUser != null){
                              setState(() {
                                isLiked = !isLiked;
                                if (isLiked) {
                                  widget.wondshort.setLike();
                                  widget.wondshort.like++;
                                } else {
                                  widget.wondshort.disLike();
                                  widget.wondshort.like--;
                                }
                              });
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vous n'etes pas connecté !")));
                            }
                          },
                          icon: isLiked
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : const Icon(Icons.favorite_border_outlined,
                                  color: PostContent.verte),
                        ),
                      ),
                      Text(widget.wondshort.like.toString(),
                          style: GoogleFonts.jura(
                              textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return CommentWidget(
                                  wondershort: widget.wondshort,
                                );
                              },
                            );
                          },
                          icon: const Icon(LucideIcons.messageSquare,
                              color: PostContent.verte),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          onPressed: () {
                            // Handle share functionality
                          },
                          icon:
                              const Icon(Icons.share, color: PostContent.verte),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CommentWidget extends StatefulWidget {
  const CommentWidget({super.key, required this.wondershort});

  final WonderShort wondershort;

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  Utilisateur? _user;
  String username = "Chargement...";
  bool _isLoading = true;
  String? _error;
  final TextEditingController _controllerComment = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      Utilisateur user = await Camwonder().getUserInfo();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Commentaires",
                      style: GoogleFonts.lalezar(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon:
                          const Icon(LucideIcons.xCircle, color: Colors.green),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: widget.wondershort.getCommentaires(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Quelques chose n'a pas marché");
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height / 20,
                                  margin: const EdgeInsets.all(20),
                                  child: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Image.asset('assets/vide_light.png')
                                      : Image.asset('assets/vide_dark.png'),
                                ),
                                const Text("Pas de commentaires !")
                              ],
                            ));
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot document = snapshot.data!.docs[index];
                              Comment com = Comment(idComment: document.id, content: document['content'], wondershort: document['wondershort'], user: document['user']);
                              return CommentaireWidget(com: com);
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(
                              color: Colors.green,
                              thickness: 1,
                              indent: 45,
                              endIndent: 45,
                              height: 20,
                            ),
                          );
                        })),
              ),
            ],
          ),
          AnimatedContainer(
            padding: const EdgeInsets.all(10),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color.fromARGB(255, 53, 53, 53),
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    color: Colors.grey,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: CachedNetworkImage(
                      cacheManager: CustomCacheManagerLong(),
                      imageUrl: _user!.profilPath,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                        color: Colors.personnalgreen,
                      )),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    //color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                  child: TextField(
                    maxLines: null,
                    autocorrect: true,
                    controller: _controllerComment,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ajouter votre commentaire...",
                      hintStyle: GoogleFonts.jura(),
                      contentPadding: const EdgeInsets.only(left: 25),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.wondershort.addCommentaire(_controllerComment.text);
                    _controllerComment.clear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(
                    LucideIcons.send,
                    size: 25,
                    color: Colors.personnalgreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CommentaireWidget extends StatefulWidget {
  const CommentaireWidget({super.key, required this.com});
  final Comment com;

  @override
  State<CommentaireWidget> createState() => _CommentaireWidgetState();
}

class _CommentaireWidgetState extends State<CommentaireWidget> {
  String username = "Chargement...";
  String profilPath = "...";
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUser();
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadUser() async {
    Utilisateur? user = await Camwonder().getUserByUniqueId(widget.com.user);
    setState(() {
      if (user != null) {
        username = user.nom;
        profilPath = user.profilPath;
      } else {
        username = 'Anonyme';
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _isLoading ?
        Container(
        padding: const EdgeInsets.all(10),
        child: const CircularProgressIndicator(color: Colors.personnalgreen,)) :
            Container(
              margin:
              const EdgeInsets.only(right: 15),
              height:
              MediaQuery.of(context).size.height /
                  18,
              width:
              MediaQuery.of(context).size.height /
                  18,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(30),
                color: Colors.grey,
              ),
              
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: CachedNetworkImage(
                  cacheManager: CustomCacheManagerLong(),
                  imageUrl: profilPath,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.personnalgreen,
                      )),
                  errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.lalezar(
                    textStyle:
                    const TextStyle(fontSize: 15),
                  ),
                ),
                Text(
                  widget.com.content,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: GoogleFonts.jura(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
