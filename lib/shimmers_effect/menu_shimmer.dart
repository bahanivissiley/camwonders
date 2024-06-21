import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class menu_shimmer extends StatelessWidget{
  const menu_shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.only(left: 20, right: 20),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 215, 215, 215),
            highlightColor: const Color.fromARGB(255, 240, 240, 240),
            child: Container(
              height: size.height*3/17,
              width: size.width,
              decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
            )
            ),

            Shimmer.fromColors(
            baseColor: const Color.fromARGB(255, 215, 215, 215),
            highlightColor: const Color.fromARGB(255, 240, 240, 240),
            child: Container(
              height: size.height/50,
              width: size.width,
              decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
            )
            ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 215, 215, 215),
                highlightColor: const Color.fromARGB(255, 240, 240, 240),
                child: Container(
                  height: size.height*2/15,
                  width: size.width*2/7,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 227, 227, 227),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 215, 215, 215),
                highlightColor: const Color.fromARGB(255, 240, 240, 240),
                child: Container(
                  height: size.height*2/15,
                  width: size.width*2/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 215, 215, 215),
                highlightColor: const Color.fromARGB(255, 240, 240, 240),
                child: Container(
                  height: size.height*2/15,
                  width: size.width*2/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),


            ],
          ),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 215, 215, 215),
                highlightColor: const Color.fromARGB(255, 240, 240, 240),
                child: Container(
                  height: size.height*3/16,
                  width: size.width*3/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 215, 215, 215),
                highlightColor: const Color.fromARGB(255, 240, 240, 240),
                child: Container(
                  height: size.height*3/16,
                  width: size.width*3/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

            ],
          ),



          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Shimmer.fromColors(
                baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
                highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
                child: Container(
                  height: size.height*3/16,
                  width: size.width*3/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

              Shimmer.fromColors(
                baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
                highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
                child: Container(
                  height: size.height*3/16,
                  width: size.width*3/7,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}


class shimmerStorie extends StatelessWidget {
  const shimmerStorie({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
      highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
      child: Container(
          width: 140,
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10)
          ),
        ),
      );
  }
}



class shimmerWonder extends StatelessWidget {
  const shimmerWonder({super.key, required this.width});
  final width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
          highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
          child: Column(
            children: [
              Container(
                height: 250,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10)
                ),
              ),

              Container(
                padding: const EdgeInsets.all(15),
                height: 100,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Container(
                      height: 20,
                      width: width*4/5,
                      decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),


                  Container(
                      height: 15,
                      width: width/3,
                      decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),


                  Container(
                      height: 10,
                      width: width/4,
                      decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],),
              )
            ],
          )
      );
  }
}

class shimmerOffre extends StatelessWidget {
  const shimmerOffre({super.key, required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
          baseColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 215, 215, 215) : const Color.fromARGB(255, 63, 63, 63),
          highlightColor: Theme.of(context).brightness == Brightness.light ? const Color.fromARGB(255, 240, 240, 240) : const Color.fromARGB(255, 95, 95, 95),
          child: Container(
            height: height,
            width: width,
            color: Colors.grey,
          )
    );
  }
}