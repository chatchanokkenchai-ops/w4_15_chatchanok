import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red.shade700,
          secondary: Colors.green.shade600,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(title: 'SONGS 🎶'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _songNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _songTypeCtrl = TextEditingController();

  void addSong() async {
    String _songName = _songNameCtrl.text;
    String _name = _nameCtrl.text;
    String _songType = _songTypeCtrl.text;

    print("ค่าที่เก็บ $_songName | $_name | $_songType");

    try {
      await FirebaseFirestore.instance.collection('songs').add({
        "songName": _songName,
        "artis": _name,
        "songType": _songType,
      });
      _songNameCtrl.clear();
      _nameCtrl.clear();
      _songTypeCtrl.clear();
    } catch (e) {
      print("ค่าผิดพ่อ : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      //ตกแต่ง
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🎁 Card กรอกข้อมูลเพลง
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(height: 15),

                        TextField(
                          decoration: InputDecoration(labelText: "ชื่อเพลง"),
                          controller: _songNameCtrl,
                        ),
                        SizedBox(height: 10),

                        TextField(
                          decoration: InputDecoration(labelText: "ศิลปิน"),
                          controller: _nameCtrl,
                        ),
                        SizedBox(height: 10),

                        TextField(
                          decoration: InputDecoration(labelText: "แนวเพลง"),
                          controller: _songTypeCtrl,
                        ),
                        SizedBox(height: 15),

                        ElevatedButton(
                          onPressed: addSong,
                          child: Text("บันทึก"),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                SizedBox(
                  height: 400,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("songs")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      final docs = snapshot.data!.docs;

                      return GridView.builder(
                        itemCount: docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final s = docs[index].data();
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SongDetail(song: s),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  s["songName"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SongDetail extends StatelessWidget {
  final song;

  const SongDetail({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Song Detail")),
      body: Column(
        children: [
          Text(song["songName"]),
          Text(song["artis"]),
          Text(song["songType"]),
        ],
      ),
    );
  }
}
