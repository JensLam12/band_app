import 'dart:io';

import 'package:brand_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    Band(id: '1', name: 'Megadeth', votes: 5),
    Band(id: '2', name: 'Slayer', votes: 1),
    Band(id: '3', name: 'Testament', votes: 2),
    Band(id: '4', name: 'Kreator', votes: 5)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Names', style: TextStyle( color:  Colors.black87) ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder:( BuildContext context, int index) => _bandTile(bands[index])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon( Icons.add)
      ),
    );
  }

  Widget _bandTile( Band band) {
    return Dismissible(
      key: Key( band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction) {
        print('direction $direction');
        print('id ${band.id}');
        //TODO: LLAMAR AL BORRADO EN EL SERVER
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.only(left: 8.0),
        child: const Align(
          alignment: Alignment.center,
          child: Text('Delete band', style: TextStyle(color: Colors.white) ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:  Colors.blue[100],
          child: Text(band.name.substring(0,2))
        ),
        title: Text(band.name),
        trailing: Text( '${band.votes}', style: const TextStyle( fontSize: 20) ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {

    final textController = TextEditingController();

    if(Platform.isAndroid) {
      return showDialog(
        context: context, 
        builder: ( context ) {
          return AlertDialog(
            title: const Text("New band name:"),
            content: TextField( 
              controller: textController
            ),
            actions: [
              MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                child: const Text('Add'),
                onPressed: () {
                  addBandToList( textController.text);
                }
              )
            ],
          );
        }
      );
    } else {
      return showCupertinoDialog(
        context: context, 
        builder: ( _ ) {
          return CupertinoAlertDialog(
            title: const Text("New band name:"),
            content: CupertinoTextField( 
              controller: textController
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () {
                  addBandToList( textController.text);
                }
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Dismiss'),
                onPressed: () {
                  Navigator.pop(context);
                }
              ),
            ],
          );
        }
      );
    }
  }

  void addBandToList( String name ) {
    if(name.length > 1) {
      bands.add( Band( id: DateTime.now().toString(), name: name, votes: 0));
    }
    setState(() { });
    Navigator.pop(context);
  }
}