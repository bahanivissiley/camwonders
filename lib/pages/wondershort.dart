import 'package:camwonders/class/classes.dart';
import 'package:camwonders/donneesexemples.dart';
import 'package:camwonders/pages/wonder_page.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//import 'package:flutter/scheduler.dart';

class Wondershort extends StatelessWidget{
  const Wondershort({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        scrollDirection: Axis.vertical,
        viewportFraction: 1.0,
        ),
      items: wondershorts.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return VideoShort(item: item);
          },
        );
      }).toList(),
    );
  }
}

class VideoShort extends StatefulWidget {
  const VideoShort({
    super.key, required this.item,
  });
  final WonderShort item;

  @override
  State<VideoShort> createState() => _VideoShortState();
}

class _VideoShortState extends State<VideoShort> {
  static late VideoPlayerController _controller;
  static bool is_paused = false;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.item.videoPath)
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          ShortWidget(videoUrl: widget.item.videoPath),
          Postcontent(wond: widget.item,),
        ],
      )
    );
  }

}


class ShortWidget extends StatefulWidget {
  const ShortWidget({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<ShortWidget> createState() => _ShortWidgetState();
}

class _ShortWidgetState extends State<ShortWidget> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(!_VideoShortState.is_paused){
          _VideoShortState._controller.pause();
          setState(() {
            _VideoShortState.is_paused = true;
          });
        }else{
          _VideoShortState._controller.play();
          setState(() {
            _VideoShortState.is_paused = false;
          });
        }
      },
      child: Stack(
        children: [
          VideoPlayer(_VideoShortState._controller),
          _VideoShortState.is_paused ? Center(
              child: Icon(Icons.play_arrow, size: MediaQuery.of(context).size.height/6, color: Colors.black.withOpacity(0.4),),
            ) : const Center()
        ],
      ));
  }

}



class Postcontent extends StatefulWidget {
  const Postcontent({super.key, required this.wond});
  static const verte = Color(0xff226900);
  final WonderShort wond;

  @override
  State<Postcontent> createState() => _PostcontentState();
}

class _PostcontentState extends State<Postcontent> {
  bool is_like = false;
  static const verte = Color(0xff226900);
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 35),
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Text("WonderShort", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 20, color: Colors.black, shadows: [ Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6) ])),)),
              Container(

                child: Text("Camwonders", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 25, color: Postcontent.verte, shadows: [ Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6) ])),))
            ],
          ),
        ),

          Expanded(child: Container(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width*3/4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                    Text("${widget.wond.wond.wonderName}...", maxLines: 1, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20, color: Colors.white, shadows: [ Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6) ])),),
                    Text("${widget.wond.desc}...", maxLines: 3, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, color: Colors.white, shadows: [ Shadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 6) ])),)
                  ],),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width/4,
                  //color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    color: Colors.black26,
                                    blurRadius: 7,
                                  )
                                ]
                              ),
                              child: IconButton(onPressed: (){
                                _VideoShortState._controller.pause();
                                Navigator.push(context, PageRouteBuilder(pageBuilder: (_,__,___) => wonder_page(wond: widget.wond.wond),
                                  transitionsBuilder: (_,animation, __, child){
                                      return SlideTransition(
                                        position: Tween<Offset> (begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut, reverseCurve: Curves.easeInOutBack)),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 700),
                                  )
                                );
                              },
                                icon: const Icon(LucideIcons.arrowBigRight, color: Postcontent.verte,),
                              )
                            ),

                          ],
                        ),
                      ),

                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    color: Colors.black26,
                                    blurRadius: 7,
                                  )
                                ]
                              ),
                                child: IconButton(onPressed: (){
                                  setState(() {
                                    if(is_like){
                                      is_like = false;
                                      widget.wond.like -= 1;
                                    }else{
                                      is_like = true;
                                      widget.wond.like += 1;
                                    }
                                  });
                                }, icon: is_like ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border_outlined, color: Postcontent.verte,)
                              ),
                            ),

                            Text(widget.wond.like.toString(), style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),),
                          ],
                        ),
                      ),

                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    color: Colors.black26,
                                    blurRadius: 7,
                                  )
                                ]
                              ),
                              child: IconButton(
                                onPressed: (){
                                    showModalBottomSheet(context: context,
                                    builder: (BuildContext context){
                                      return commentWidget(context);
                                    }
                                  );
                                },
                                icon: const Icon(LucideIcons.messageSquare, color: Postcontent.verte,),)
                            ),

                            Text("25", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),),
                          ],
                        ),
                      ),

                      Container(
                        height: 80,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    color: Colors.black26,
                                    blurRadius: 7,
                                  )
                                ]
                              ),
                              child: const Icon(LucideIcons.share, color: Postcontent.verte,),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ))
      ],
    );
  }

  Container commentWidget(BuildContext context) {
    //final screenHeight = MediaQuery.of(context).size.height;
    //final commentInputHeight = screenHeight / 12;
    final keybheight = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOffset = isKeyboardVisible ? keybheight : 0.0;
    return Container(
      padding: const EdgeInsets.all(0),
      //height: MediaQuery.of(context).size.height/2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),

      child: KeyboardVisibilityBuilder(builder: (context, visible){
        return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Commentaires", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 20)),),
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: const Icon(LucideIcons.xCircle, color: verte,))
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 8,
                    itemBuilder: (BuildContext context, int index){
                      return Expanded(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 15),
                                    height: MediaQuery.of(context).size.height/18,
                                    width: MediaQuery.of(context).size.height/18,
                                    decoration:   BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.grey
                                    ),
                                  ),
                  
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Utilisateur n$index", style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 15)),),
                                      Container(child: Text("Contenu du premier commmentaires", overflow: TextOverflow.visible, softWrap: true, style: GoogleFonts.jura(textStyle : const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),))
                                    ],
                                  )
                                ],
                              ),
                            ),
                  
                            Container(
                              margin: const EdgeInsets.only(right: 45, left: 45, top: 20),
                              color: verte,
                              height: 1,
                              width: MediaQuery.of(context).size.width,
                            )
                          ],
                        ),
                      );
                    }
                  ),
                ),
              )

            ],
          ),

          AnimatedContainer(
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: keyboardOffset),
                color: verte,
                curve: Curves.fastOutSlowIn,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 18,
                      width: MediaQuery.of(context).size.height / 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(500),
                        color: const Color.fromARGB(221, 255, 255, 255),
                      ),
                      child: TextField(
                        maxLines: null,
                        autocorrect: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Ajouter votre commentaire",
                            hintStyle: GoogleFonts.jura(),
                            contentPadding: const EdgeInsets.only(left: 25)),
                      ),
                    ),

                    IconButton(onPressed: (){
                    }, icon: const Icon(LucideIcons.send, size: 25, color: Colors.white,))
                    
                  ],
                ),
              ),

        ],
      );
      })
    );
  }
}
