import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/models/meme.dart';
import 'package:firebase_test/views/meme_details.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
              accentColor: Colors.deepOrangeAccent)),
      home: const MyArtApp(),
    );
  }
}

class MyArtApp extends StatefulWidget {
  const MyArtApp({Key? key}) : super(key: key);

  @override
  State<MyArtApp> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyArtApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FireBase"),
      ),
      body: FutureBuilder(
        /// Initialize FlutterFire:
        future: getArt(),
        builder: (context, snapshot) {
          /// if Error
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          /// On completion
          if (snapshot.connectionState == ConnectionState.done) {
            List<Meme> list = snapshot.data as List<Meme>;
            return buildGridView(list);
          }

          /// On Loading
          return const Center(
              child: CircularProgressIndicator(
            strokeWidth: 3,
          ));
        },
      ),
    );
  }

  getArt() async {
    List<Meme> memes = [];
    await FirebaseFirestore.instance
        .collection("gallery")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        memes.add(Meme.fromDoc(element));
      }
    });
    return memes;
  }

  Widget buildGridView(List<Meme> list) {
    return RefreshIndicator(
      onRefresh: () async {
        await getArt();
        setState(() {});
        return Future.value();
      },
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
        ),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(context, MemeDetailsScreen.getRoute(list[index]));
              setState(() {});
            },
            child: Card(
              color: Colors.amber,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.network(
                    list[index].image,
                    height: 177,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        list[index].title,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye),
                        const SizedBox(width: 8),
                        Text(
                          '${list[index].views}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
