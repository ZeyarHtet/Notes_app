import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/screens/note_editor.dart';
import 'package:notes_app/screens/note_reader.dart';
import 'package:notes_app/style/app_style.dart';
import 'package:notes_app/widget/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PopupMenuItem _buildPopupMenuItem(String title, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          Text(title),
        ],
      ),
    );
  }

  _popUpWidget(String docID) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
        color: Colors.black,
      ),
      onSelected: (value) {
        if (value == 0) {
          setState(() {});
        } else if (value == 1) {
          setState(
            () {
              final collection =
                  FirebaseFirestore.instance.collection('notes_app');

              collection
                  .doc(docID)
                  .delete()
                  .then((_) => print('Deleted'))
                  .catchError((error) => print('Delete failed: $error'));
            },
          );
        } else {
          print("value >>>> : $value");
        }
      },
      offset: Offset(
        0.0,
        AppBar().preferredSize.height,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      itemBuilder: (ctx) => [
        _buildPopupMenuItem(
          'Edit',
          0,
        ),
        _buildPopupMenuItem(
          'Delete',
          1,
        ),
      ],
    );
  }

  Widget noteCard(
      Function()? onTap, QueryDocumentSnapshot doc, BuildContext context) {
    // doc.id
    print(">>>>>>>>>>>>> doc is ${doc.id}");
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppStyle.cardsColor[doc['color_id']],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc["note_title"].toString(),
                  style: AppStyle.mainTitle,
                ),
                SizedBox(
                  height: 4.0,
                ),
                Text(
                  doc["creation_date"].toString(),
                  style: AppStyle.dateTitle,
                ),
                SizedBox(
                  height: 4.0,
                ),
                // Container(
                //   width: 150,
                //   child: Text(
                //     doc["note_content"].toString(),
                //     style: AppStyle.mainContent,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    doc["note_content"].toString(),
                    style: AppStyle.mainContent,
                    maxLines: 10,
                  ),
                ),
                // Icon(Icons.menu)
              ],
            ),
            _popUpWidget(doc.id.toString()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppStyle.mainColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Notes"),
        centerTitle: true,
        backgroundColor: AppStyle.mainColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/aaaa.jpeg"), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your recent Notes",
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notes_app")
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      return GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        children: snapshot.data!.docs
                            .map(
                              (note) => noteCard(
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NoteReaderScreen(note),
                                    ),
                                  );
                                  // print(note);
                                  // print(">>>>> My note");
                                  // print(note["note_title"]);
                                },
                                note,
                                context,
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Text(
                      "there is no Notes",
                      style: GoogleFonts.nunito(color: Colors.white),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NoteEditorScreen()));
        },
        label: Text("Add Note"),
        icon: Icon(Icons.add),
      ),
    );
  }
}
