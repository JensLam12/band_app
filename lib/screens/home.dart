import 'dart:io';
import 'package:brand_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on( 'active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands( dynamic payload ) {
    bands = (payload as List).map(( band) =>  Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Names', style: TextStyle( color:  Colors.black87) ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ( socketService.serverStatus == ServerStatus.online) ? Icon( Icons.check_circle, color: Colors.blue[300] ) : Icon( Icons.offline_bolt, color: Colors.red[300] )
          )
        ],
      ),
      body: Column(
        children: [
          _ShowGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder:( BuildContext context, int index) => _bandTile(bands[index])
            ) 
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: const Icon( Icons.add)
      ),
    );
  }

  Widget _bandTile( Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key( band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction) => socketService.emit('remove-band', { 'id': band.id} ),
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
        onTap: () => socketService.emit('vote-band', { 'id': band.id} ),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if(Platform.isAndroid) {
      return showDialog(
        context: context, 
        builder: ( _ ) =>  AlertDialog(
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
        )
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
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', { 'name': name} );
    }
    
    Navigator.pop(context);
  }

  Widget _ShowGraph() {
    Map<String, double> dataMap = {};
    bands.forEach( (band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble() );
    });

    return Container(
      padding: const EdgeInsets.only(top:  10),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2,
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}