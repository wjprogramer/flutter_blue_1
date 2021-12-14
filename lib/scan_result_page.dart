import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_common_package/extensions/src/number_extensions.dart';

class ScanResultPage extends StatefulWidget {
  const ScanResultPage({
    Key? key,
    required this.scanResult,
  }) : super(key: key);

  final ScanResult scanResult;

  @override
  _ScanResultPageState createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  late TextTheme _textTheme;

  ScanResult get _scanResult => widget.scanResult;
  BluetoothDevice get _device => widget.scanResult.device;

  List<BluetoothService> _connectedDeviceServices = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _connectedDeviceServices = await _device.discoverServices();
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _device.name == ''
                ? '(Unknown Device)'
                : _device.name,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          24.height,
          Text(
            'Services',
            style: _textTheme.headline4,
          ),
          ..._connectedDeviceServices.map((service) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.uuid.toString(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
