import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudOperations extends StatefulWidget {
  const CrudOperations({super.key});

  @override
  State<CrudOperations> createState() => _CrudOperationsState();
}

class _CrudOperationsState extends State<CrudOperations> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final CollectionReference myItems = FirebaseFirestore.instance.collection(
    "CRUDitems",
  );

  Future<void> create() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Create Operation",
          condition: "Create",
          onPressed: () {
            String name = nameController.text;
            String post = postController.text;
            addItems(name, post);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void addItems(String name, String post) {
    myItems.add({'name': name, 'post': post});
  }

  Future<void> update(DocumentSnapshot documentSnapshot) async {
    nameController.text = documentSnapshot['name'];
    postController.text = documentSnapshot['post'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialogBox(
          name: "Update Operation",
          condition: "Update",
          onPressed: () async {
            String name = nameController.text;
            String post = postController.text;
            await myItems.doc(documentSnapshot.id).update({
              'name': name,
              'post': post,
            });
            nameController.text = '';
            postController.text = '';
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> delete(String productId) async {
    await myItems.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Delete Successfully"),
        duration: Duration(milliseconds: 500),
        backgroundColor: Colors.red,
      ),
    );
  }

  String searchText = '';

  void onSearchChange(String value) {
    setState(() {
      searchText = value;
    });
  }

  bool isSearchClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title:
            isSearchClick
                ? Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: onSearchChange,
                    controller: searchController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                      border: InputBorder.none,
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                )
                : const Text(
                  "Firestore CRUD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClick = !isSearchClick;
              });
            },
            icon: Icon(
              isSearchClick ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items = streamSnapshot.data!.docs
                .where(
                  (doc) => doc['name'].toLowerCase().contains(
                    searchText.toLowerCase(),
                  ),
                ).toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          documentSnapshot['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(documentSnapshot['post']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => update(documentSnapshot),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => delete(documentSnapshot.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          create();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Dialog myDialogBox({
    required String name,
    required String condition,
    required VoidCallback onPressed,
  }) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Enter the Name",
              hintText: 'e.g- Ramesh',
            ),
          ),
          TextField(
            controller: postController,
            decoration: InputDecoration(
              labelText: "Enter the Post",
              hintText: 'Postman',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: onPressed, child: Text(condition)),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}
