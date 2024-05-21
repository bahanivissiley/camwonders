import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class wonders_shimmer extends StatelessWidget{
  const wonders_shimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 215, 215, 215),
              highlightColor: const Color.fromARGB(255, 240, 240, 240),
              child: Container(
                height: 30,
                width: size.width,
                margin: const EdgeInsets.only(bottom: 15),
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
                height: 130,
                width: size.width,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)
                    ),
              )
              ),
      
      
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 215, 215, 215),
                    highlightColor: const Color.fromARGB(255, 240, 240, 240),
                    child: Container(
                      height: 200,
                      width: size.width,
                      margin: const EdgeInsets.only(bottom: 10),
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
                      margin: const EdgeInsets.only(top: 7, bottom: 10),
                      height: 15,
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
                      margin: const EdgeInsets.only(top: 7, bottom: 15),
                      height: 15,
                      width: size.width/2,
                      decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                    )
                    ),
                ],
              ),
      
      
      
      
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 215, 215, 215),
                    highlightColor: const Color.fromARGB(255, 240, 240, 240),
                    child: Container(
                      height: 200,
                      width: size.width,
                      margin: const EdgeInsets.only(bottom: 10),
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
                      margin: const EdgeInsets.only(top: 7, bottom: 10),
                      height: 15,
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
                      margin: const EdgeInsets.only(top: 7, bottom: 15),
                      height: 15,
                      width: size.width/2,
                      decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                    )
                    ),
                ],
              ),
      
      
      
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 215, 215, 215),
                    highlightColor: const Color.fromARGB(255, 240, 240, 240),
                    child: Container(
                      height: 200,
                      width: size.width,
                      margin: const EdgeInsets.only(bottom: 10),
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
                      margin: const EdgeInsets.only(top: 7, bottom: 10),
                      height: 15,
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
                      margin: const EdgeInsets.only(top: 7),
                      height: 15,
                      width: size.width/2,
                      decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                    )
                    ),
                ],
              )
      
      
      
          ],
        ),
      ),
    );
  }
}