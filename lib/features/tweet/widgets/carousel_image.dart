// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselImage extends StatefulWidget {
  const CarouselImage({
    Key? key,
    required this.imageLinks,
  }) : super(key: key);

  final List<String> imageLinks;

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          items: widget.imageLinks.map((e) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              margin: const EdgeInsets.all(10),
              child: Image.network(
                e,
                fit: BoxFit.contain,
              ),
            );
          }).toList(),
          options: CarouselOptions(
            viewportFraction: 1,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageLinks.asMap().entries.map((e) {
            return Container(
              width: widget.imageLinks.length == 1 ? 0 : 12,
              height: 12,
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withOpacity(_currentIndex == e.key ? 0.9 : 0.4),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
