import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final Function onTap;
  final BluetoothDevice device;

  BluetoothDeviceListEntry({this.onTap, @required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: onTap,
      leading: Icon(
        Icons.devices,
        color: Colors.white,
      ),
      title: Text(
        device.name ?? "Unknown device",
        style: TextStyle(color: Colors.greenAccent),
      ),
      subtitle: Text(device.address.toString(),
          style: TextStyle(color: Colors.amberAccent)),
      trailing: TextButton(
        child: Text('Connect'),
        onPressed: onTap,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
            foregroundColor: MaterialStateProperty.all(Colors.white)),
        // color: Colors.blue,
      ),
    );
  }
}