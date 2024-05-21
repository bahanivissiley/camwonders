import 'package:camwonders/class/classes.dart';
import 'package:camwonders/donneesexemples.dart';
import 'package:camwonders/pages/page_categorie.dart';
import 'package:camwonders/pages/storie.dart';
import 'package:camwonders/shimmers_effect/menu_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
//import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

class ListeVue extends StatefulWidget{
  const ListeVue({super.key});
  static const verte = Color(0xff226900);

  @override
  State<ListeVue> createState() => _ListeVueState();
}

class _ListeVueState extends State<ListeVue> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const StoriesList(),
          //Storie(path: wonders[1].imagePath),

          Container(
            height: width * 15 / 36 + width * 15 / 36 + 50,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cats.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Nombre de colonnes dans la grille
                      crossAxisSpacing: 20.0, // Espace horizontal entre les éléments
                      mainAxisSpacing: 20.0, // Espace vertical entre les éléments
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page_categorie(cat: cats[index],))),

                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 1000), // Durée de l'animation
                            curve: Curves.easeOut, // Type de courbe d'animation
                            transform: Matrix4.translationValues(0, _visible ? 0 : 50, 0), // Déplacement vers le bas
                            child: catButton(width: width, verte: ListeVue.verte, cat: cats[index]),
                          ),
                      );
                    },
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





class catButton extends StatelessWidget {
  const catButton({
    super.key,
    required this.width,
    required this.verte,
    required this.cat,
  });

  final double width;
  final Color verte;
  final Categorie cat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width*15/36,
      height: width*15/36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1.0,
          color: Colors.grey.withOpacity(0.5)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Icon(, size: 55, color: verte,),
          cat.iconcat,
          Text(cat.categoryName, style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),)
        ],
      )
    );
  }
}

class StoriesList extends StatefulWidget {
  const StoriesList({
    super.key
  });

  static const verte = Color(0xff226900);

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final ScrollController _controller = ScrollController();
  final double _height = 200.0;
  final double _width = 150.0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async{
    setState(() {isLoading = true;});
    await Future.delayed(const Duration(seconds: 2));

    if(mounted){
      setState(() {isLoading = false;});
    }
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Les merveilles les mieux notés", style: GoogleFonts.jura(textStyle: const TextStyle(fontSize: 15, color: StoriesList.verte)),),
                IconButton(onPressed: () => _animateToIndex(2), icon: const Icon(LucideIcons.arrowRight, color: StoriesList.verte,),)
              ],
            ),
        ),
        SizedBox(
          height: _height,
          child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: wonders.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: (){
                  Navigator.push(context,
                    PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => Sttories(wond: wonders[index]),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        animation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                        return FadeTransition(opacity: animation, child: child,);
                      },
                    )
                  );
                },
                child: isLoading ? const shimmerStorie() : Storie(wond: wonders[index]),
              );
            }),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // N'oubliez pas de libérer le contrôleur lorsque vous n'en avez plus besoin
    super.dispose();
  }
}


class Storie extends StatefulWidget {
  static const verte = Color(0xff226900);
  final Wonder wond;

  const Storie({super.key, required this.wond});

  @override
  _StorieState createState() => _StorieState(wond: wond);
}

class _StorieState extends State<Storie> with SingleTickerProviderStateMixin {
  double _opacity = 0;
  final Wonder wond;

  _StorieState({required this.wond});

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 1), // Durée de l'effet de transition
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Hero(
            tag: "imageWonder${wond.wonderName}",
            child: Container(
              width: 140,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: AssetImage(widget.wond.imagePath),
                  fit: BoxFit.cover
                ),
              )
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(8),
            height: 60,
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Storie.verte,
                  Storie.verte.withOpacity(0.1),
                ]
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("${widget.wond.wonderName}..", maxLines: 2, style: GoogleFonts.lalezar(textStyle: const TextStyle(fontSize: 16, color:Colors.white, height: 1.0)),),
                //Text(wond.city, maxLines: 1, style: GoogleFonts.jura(textStyle: const TextStyle(color: Colors.white)),),
              ],
            )
          ),
        ],
      ),
    );
  }
}



















class MapVue extends StatefulWidget {
  const MapVue({super.key}); // Correction du constructeur

  static const verte = Color(0xff226900);

  @override
  State<MapVue> createState() => _MapVueState();
}

class _MapVueState extends State<MapVue> with SingleTickerProviderStateMixin {
  double su = 20;
  bool is_loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async{
    await Future.delayed(const Duration(seconds: 2));

    if(mounted){
      setState(() {is_loading = false;});
    }
  }


  @override
  Widget build(BuildContext context) {
    return is_loading ? shimmerMaps() : maps();
    }

}

class shimmerMaps extends StatelessWidget {
  const shimmerMaps({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 235, 235, 235) : const Color.fromARGB(255, 63, 63, 63),
        highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 95, 95, 95),
        child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10)
            ),
          ),
        ),
    
    
    
        Container(
          //padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Center(
            child: Gif(
                height: 100,
                image: const AssetImage("assets/loadmap.gif"),
                autostart: Autostart.loop,
                placeholder: (context) => const Text('Loading...'),
            ),
          ),
        ),
      ],
    );
  }
}



class maps extends StatefulWidget {
  const maps({super.key});

  @override
  State<maps> createState() => _mapsState();
}

class _mapsState extends State<maps> {
  GoogleMapController? mapController;

  //final LatLng _center = const LatLng(3.8480, 11.5021); // Coordonnées du centre du Cameroun
  static const LatLng _currentlocation = LatLng(37.4223, -122.0848);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return const GoogleMap(
        //onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentlocation,
          zoom: 13, // Niveau de zoom
        ),
      );
  }
}