import 'package:cached_network_image/cached_network_image.dart';
import 'package:camwonders/class/Utilisateur.dart';
import 'package:camwonders/class/Wonder.dart';
import 'package:camwonders/class/WonderShort.dart';
import 'package:camwonders/class/classes.dart';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:camwonders/services/cachemanager.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/services/logique.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';


class Wondershort extends StatefulWidget {
  const Wondershort({super.key});

  @override
  State<Wondershort> createState() => _WondershortState();
}

class _WondershortState extends State<Wondershort> {
  late final Stream<List<WonderShort>> _wondershortStream;
  late List<VideoPlayerController> _controllers;
  bool _isload = true;
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _preloadInitialVideos() {
    setState(() {
      _isload = false;
    });
    _wondershortStream.listen((List<WonderShort> wondershorts) {
      if (wondershorts.isNotEmpty) {
        for (int i = 0; i < _preloadOffset && i < wondershorts.length; i++) {
          _addVideoController(wondershorts[i]);
        }
      }
    });
  }

  void _preloadMoreVideos(List<WonderShort> wondershorts, int startIndex) {
    if (wondershorts.isNotEmpty) {
      for (int i = startIndex; i < startIndex + _preloadOffset && i < wondershorts.length; i++) {
        _addVideoController(wondershorts[i]);
      }
    }
  }

  void _addVideoController(WonderShort wonderShort) async {
    try {
      final VideoPlayerController controller =
      VideoPlayerController.networkUrl(Uri.parse(wonderShort.videoPath));

      await controller.initialize();
      if (!mounted) return; // Vérifier si le widget est toujours monté

      setState(() {
        _controllers.add(controller);
        if (_controllers.length == 1) {
          // Démarrer la première vidéo
          _controllers[_currentIndex].play();
          _controllers[_currentIndex].setLooping(true);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Erreur lors du chargement de la vidéo"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _verifyConnection() async {
    if (!(await Logique.checkInternetConnection())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Connectez-vous à internet"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isload ? const Center(child: CircularProgressIndicator(color: Colors.green)) : StreamBuilder<List<WonderShort>>(
      stream: _wondershortStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Quelque chose a mal tourné'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        final List<WonderShort> wondershorts = snapshot.data!;

        return Stack(
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: double.infinity,
                scrollDirection: Axis.vertical,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  if (_controllers.isNotEmpty && index < _controllers.length) {
                    if (index >= _currentIndex + _preloadOffset - 1) {
                      _preloadMoreVideos(wondershorts, _currentIndex + _preloadOffset);
                    }

                    _controllers[_currentIndex].pause();
                    _controllers[index].play();
                    _controllers[index].setLooping(true);
                    _currentIndex = index;
                  }
                },
              ),
              itemCount: wondershorts.length,
              itemBuilder: (context, index, realIndex) {
                if (index < _controllers.length) {
                  return VideoShort(
                    item: wondershorts[index],
                    controller: _controllers[index],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }
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
                          Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6)
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
                          Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6)
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
  Wonder? _wonder; // Utiliser null pour indiquer que les données sont en cours de chargement
  bool _isLoading = true; // Indicateur de chargement
  String? _errorMessage; // Message d'erreur en cas de problème
  bool _isPlaying = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchWonder();
  }

  Future<void> _fetchWonder() async {
    try {
      final Wonder? futureWonder = await Camwonder().getWonderById(widget.item.wond);
      if (futureWonder != null) {
        setState(() {
          _wonder = futureWonder;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Impossible de charger les données.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur s'est produite : $e";
        _isLoading = false;
      });
    }
  }


  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _isPlaying = false;
      } else {
        widget.controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          alignment: Alignment(1, 1),
          children: [
            GestureDetector(
              onTap: (){
                _togglePlayPause();
              },
                child: VideoPlayer(widget.controller)
            ),
            VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.green,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black54,
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: !_isPlaying ? IconButton(
                icon: const Icon(Icons.play_arrow,
                  color: Colors.white,
                  size: 80,
                ),
                onPressed: _togglePlayPause,
              ) : const SizedBox(),
            ),
          ],
        ),
        Positioned.fill(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      // Afficher un indicateur de chargement pendant le chargement des données
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (_errorMessage != null) {
      // Afficher un message d'erreur si le chargement a échoué
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Afficher le contenu une fois les données chargées
      return PostContent(
        wondshort: widget.item,
        wonder: _wonder!,
        controller: widget.controller,
      );
    }
  }
}

class PostContent extends StatefulWidget {
  static const Color verte = Color(0xff226900);
  final WonderShort wondshort;
  final Wonder wonder;
  final VideoPlayerController controller;

  const PostContent({
    super.key,
    required this.wondshort,
    required this.wonder,
    required this.controller,
  });

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
                SizedBox(
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
                SizedBox(
                  width: MediaQuery.of(context).size.width / 6,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
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
                                    WonderPage(wond: widget.wonder),
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
                            if (AuthService().currentUser != null) {
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Vous n'etes pas connecté !")));
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
                            //Share.share('check out my website https://example.com');
                            Share.share("J'ai decouvert sur l'application camwonders le lieu : ${widget.wonder.wonderName}\n \n Description : ${widget.wonder.description}\n \n Télécharger l\'application : https://www.camwonders.com");
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
  final TextEditingController _controllerComment = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
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
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: widget.wondershort.getCommentaires(),
                        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Quelques chose n'a pas marché");
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SingleChildScrollView(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                      color: Color(0xff226900))
                                ],
                              ),
                            );
                          }

                          if (snapshot.data!.isEmpty) {
                            return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height:
                                      MediaQuery.of(context).size.height / 20,
                                      margin: const EdgeInsets.all(20),
                                      child: Image.asset('assets/review.png'),
                                    ),
                                    const Text("Pas de commentaires !")
                                  ],
                                ));
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Map<String, dynamic> document = snapshot.data![index];
                              final Comment com = Comment(
                                  idComment: document['id'],
                                  idUser: document['user']?['id'],
                                  content: document['content'],
                                  wondershort: document['wondershort'],
                              userImage: document['user']?['profil_path'],
                              userName: document['user']?['name']);
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
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    color: Colors.grey,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(500),
                    child: CachedNetworkImage(
                      cacheManager: CustomCacheManagerLong(),
                      imageUrl: userProvider.profilPath,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff226900),
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
                    color: Color(0xff226900),
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
  String profilPath = "https://www.camwonders.com/static/img/Logo.jpg"; // Remplacer par l'URL d'une image par défaut
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    // Appel de la méthode pour récupérer l'utilisateur
    try {
      final Utilisateur? user = await Camwonder().getUserByUniqueRealId(widget.com.idUser);
      // Vérification de l'état du widget avant de mettre à jour l'état
      if (mounted) {
        setState(() {
          if (user != null) {
            username = user.nom.isNotEmpty ? user.nom : 'Anonyme'; // Gestion du nom vide
            profilPath = user.profilPath.isNotEmpty
                ? user.profilPath
                : "https://example.com/default_profile.png"; // Remplace par une URL d'image par défaut
          } else {
            username = 'Anonyme';
            profilPath = "https://example.com/default_profile.png"; // Image par défaut
          }
          _isLoading = false; // Mise à jour de l'état de chargement
        });
      }
    } catch (e) {
      // Gestion des erreurs lors de la récupération de l'utilisateur
      if (mounted) {
        setState(() {
          username = 'Erreur lors du chargement';
          profilPath = "https://example.com/default_profile.png"; // Image par défaut en cas d'erreur
          _isLoading = false; // Met à jour l'état de chargement
        });
      }
      print("Erreur lors de la récupération de l'utilisateur: $e"); // Log de l'erreur
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _isLoading
                ? Container(
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(
                  color: Color(0xff226900),
                ))
                : Container(
              margin: const EdgeInsets.only(right: 15),
              height: MediaQuery.of(context).size.height / 18,
              width: MediaQuery.of(context).size.height / 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: CachedNetworkImage(
                  cacheManager: CustomCacheManagerLong(),
                  imageUrl: profilPath,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      child: Image.asset('assets/holder.jpg'),
                    ),),
                  errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.lalezar(
                    textStyle: const TextStyle(fontSize: 15),
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