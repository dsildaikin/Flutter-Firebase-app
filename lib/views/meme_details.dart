import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/models/meme.dart';
import 'package:flutter/material.dart';

class MemeDetailsScreen extends StatelessWidget {
  final Meme meme;

  const MemeDetailsScreen(this.meme, {Key? key}) : super(key: key);

  static getRoute(Meme meme) {
    return PageRouteBuilder(
      transitionsBuilder: (_, animation, secondAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      pageBuilder: (_, __, ___) {
        return MemeDetailsScreen(meme);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    updateViews();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(meme.title),
      ),
      body: Center(
        child: Image.network(meme.image),
      ),
    );
  }

  void updateViews() {
    FirebaseFirestore.instance
        .collection('gallery')
        .doc(meme.docId)
        .update({"views": FieldValue.increment(28)});
  }
}
