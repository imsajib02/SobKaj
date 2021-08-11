import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sobkaj/localization/app_localization.dart';
import 'dart:math';
import 'package:sobkaj/models/user.dart';
import 'package:sobkaj/resources/images.dart';

class SeekerSliver implements SliverPersistentHeaderDelegate {

  final User seeker;

  final double minExtent;
  final double maxExtent;

  SeekerSliver({this.minExtent, @required this.maxExtent, @required this.seeker});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    return Stack(
      children: <Widget>[

        Hero(
          tag: seeker.id.toString(),
          child: seeker.avatar == null || seeker.avatar.isEmpty ? Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Images.noImage),
                  fit: BoxFit.cover,
                )
            ),
          ) : Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(seeker.avatar),
                  fit: BoxFit.cover,
                )
            ),
          ),
        ),

        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 50, left: 30),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {

                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).accentColor,
                child: Icon(Icons.arrow_back, size: 22, color: Colors.black.withOpacity(.65),),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          right: 25,
          child: Opacity(
            opacity: ratingOpacity(shrinkOffset),
            child: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Icon(Icons.star, size: 23, color: Colors.yellow,),

                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(seeker.rating == null || seeker.rating.isEmpty ? AppLocalization.of(context).getTranslatedValue("none") : seeker.rating,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  double ratingOpacity(double shrinkOffset) {

    return 1 - max(0.0, shrinkOffset) / maxExtent;
  }


  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }


  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;


  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}