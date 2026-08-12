import 'package:flutter/material.dart';

class ScannedCarton extends StatefulWidget {
  ScannedCarton({super.key, this.rKey = ''});
  static const String routeName = '/scanned/carton';
  final String rKey;

  @override
  State<ScannedCarton> createState() => _ScannedCartonState();
}

class _ScannedCartonState extends State<ScannedCarton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Carton')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.inventory),
            title: Text('Carton Item ${index + 1}'),
            trailing: const Icon(Icons.delete, color: Colors.red),
          );
        },
      ),
    );
  }
}
