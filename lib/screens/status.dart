import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/socket_service.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server status: ${socketService.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon( Icons.message),
        onPressed: () {
          socketService.emit( 'emit-message', { 'name': 'Flutter', 'message': 'hello from flutter'} );
        },
      ),
    );
  }
}