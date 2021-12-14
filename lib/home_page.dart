import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_1/flutter_blue_example/example_main.dart';
import 'package:flutter_blue_1/scan_result_page.dart';
import 'package:flutter_blue_1/utils.dart';
import 'package:flutter_common_package/flutter_common_package.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  late StreamSubscription subscription;
  List<ScanResult> _scanResults = [];
  DateTime? _lastScanDateTime;

  BluetoothDevice? _selectedDevice;
  BluetoothDevice? _connectedDevice;

  late TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    subscription = flutterBlue.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
        _lastScanDateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bluetooth Demo'
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => FlutterBlueOfficialExample()));
            },
            icon: Tooltip(
              message: '官方範例',
              child: Icon(
                Icons.code,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: [
          24.height,
          Text(
            'Actions',
            style: _textTheme.headline4,
          ),
          8.height,
          button(
            onPressed: _startScan,
            icon: Icons.play_arrow,
            text: 'Start scanning'
          ),
          button(
            onPressed: _stopScan,
            icon: Icons.pause,
            text: 'Stop scanning',
          ),
          button(
            onPressed: () {

            },
            text: '',
          ),
          button(
            onPressed: () {

            },
          ),
          24.height,
          Text(
            'Scan Results',
            style: _textTheme.headline4,
          ),
          4.height,
          Text(
            '最後更新時間: ${_lastScanDateTime ?? '-'}'
          ),
          8.height,
          ..._scanResults.map(_buildScanResultCard),
          24.height,
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    try {
      flutterBlue.startScan(timeout: Duration(seconds: 4));
    } catch (e) {

    }
  }

  Future<void> _stopScan() async {
    try {
      flutterBlue.stopScan();
    } catch (e) {

    }
  }

  Widget _buildScanResultCard(ScanResult result) {
    final device = result.device;
    final advertisementData = result.advertisementData;

    final isSelected = _selectedDevice?.id == device.id;
    final isConnected = _connectedDevice != null && _connectedDevice?.id == device.id;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDevice = result.device;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                'RSSI',
                                style: _textTheme.headline6,
                              ),
                              4.width,
                              Text(
                                result.rssi.toString(),
                              ),
                            ],
                          ),
                          Text(
                            'Device',
                            style: _textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    if (isConnected)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.link,
                          color: Colors.blue,
                        ),
                      ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
                Text(
                  'ID: ${result.device.id}\n'
                      'Name: ${result.device.name == '' ? '(Unknown Device)' : result.device.name}\n'
                      'Type: ${result.device.type}'
                ),
                Text(
                  'Advertisement Data',
                  style: _textTheme.headline6,
                ),
                Text(
                  'localName: ${result.advertisementData.localName}\n'
                      'connectable: ${result.advertisementData.connectable}\n'
                      'manufacturerData: ${result.advertisementData.manufacturerData}\n'
                      'serviceData: ${result.advertisementData.serviceData}\n'
                      'serviceUuids: ${result.advertisementData.serviceUuids}\n'
                      'txPowerLevel: ${result.advertisementData.txPowerLevel}',
                ),
              ],
            ),
          ),
        ),
        if (isSelected)
          Row(
            children: [
              Expanded(
                child: button(
                  onPressed: !advertisementData.connectable || isConnected ? null : () async {
                    print('連結開始');

                    try {
                      print('連結成功');
                      setState(() {
                        _connectedDevice = device;
                      });

                      // _connectedDeviceServices = await device.discoverServices();
                      await device.connect();
                    } catch (e, s) {
                      print('連結失敗');
                      print(e);
                      print(s);

                      if (_connectedDevice != null && _connectedDevice?.id == device) {
                        setState(() {
                          _connectedDevice = null;
                        });
                      }
                    } finally {
                    }
                  },
                  text: _connectedDevice != null && device.id == _connectedDevice?.id
                      ? 'Connected' : 'Connect',
                ),
              ),
              8.width,
              Expanded(
                child: button(
                  onPressed: !advertisementData.connectable || !isConnected ? null : () async {
                    await result.device.disconnect();

                    if (_connectedDevice != null && _connectedDevice?.id == device.id) {
                      setState(() {
                        _connectedDevice = null;
                      });
                    }
                  },
                  color: Colors.red,
                  text: 'Disconnect',
                ),
              ),
            ],
          ),
        if (isSelected && isConnected)
          ...[
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ScanResultPage(
                      scanResult: result,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo,
                ),
                child: Text(
                  'Details',
                ),
              ),
            ),
            8.height,
          ],
      ],
    );
  }
}
