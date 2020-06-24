import 'dart:async';
import 'package:flutter/material.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:snowm_scanner/snowm_scanner.dart';

class Home extends StatefulWidget {
  @override

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

 List <String> uuid = ['2f234454-cf6D-4a0f-adf2-f4911ba9ffa6'];

  List <String> scannedBeaconDistance = [];
  List <String> scannedBeaconTXPower = [];

  static const UUID = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const MAJOR_ID = 1;
  static const MINOR_ID = 2;
  static const TRANSMISSION_POWER = -56;
  //static const IDENTIFIER = 'com.example.myDeviceRegion';   //For iOS only
  static const LAYOUT = BeaconBroadcast.ALTBEACON_LAYOUT;
  static const MANUFACTURER_ID = 0x0118;                     //For Android only

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    
     snowmScanner.requestPermission();
     
   
    //We are checking if Beacon transmission is supported on initState so that we can know on
    //start of the app if it is possible to transmit or not with this device.
    
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;

      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

        Timer(Duration(milliseconds: 1), (){
            scannedBeaconDistance.clear();
            scannedBeaconTXPower.clear();
      });

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[700],
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Social Distancing App'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 5.0),
                Text('Is transmission supported?', style: TextStyle(fontSize: 20, color: Colors.white),),
                Text('$_isTransmissionSupported', style: TextStyle(fontSize: 15, color: Colors.white)),
                Container(height: 10.0),
                Text('Is beacon started?', style: TextStyle(fontSize: 20, color: Colors.white)),
                Text('$_isAdvertising', style: TextStyle(fontSize: 15, color: Colors.white)),
                Container(height: 10.0),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      beaconBroadcast
                          .setUUID(UUID)
                          .setMajorId(MAJOR_ID)
                          .setMinorId(MINOR_ID)
                          .setTransmissionPower(-59)
                          //.setIdentifier(IDENTIFIER)
                          .setLayout(LAYOUT)
                          .setManufacturerId(MANUFACTURER_ID)
                          .start();
                    },
                    child: Text('START'),
                  ),
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      beaconBroadcast.stop();
                    },
                    child: Text('STOP'),
                  ),
                ),

                SizedBox(height: 15),

                 Center(
                  child: RaisedButton(
                    onPressed: () async {
                      snowmScanner.scanBeacons(uuids: uuid).listen((beacons) {

                        setState(() {
                               scannedBeaconDistance.add(beacons.map((e) => e.distance).toString());
                               scannedBeaconTXPower.add(beacons.map((e) => e.txPower).toString());
                            });
                       
                                print('SCANNED BEACONS: ' + beacons.toString());
                                print(beacons[0].distance.toString());
                                print(beacons[0].txPower.toString());
                            });

                                               
                            
                    },
                    
                    child: Text('SCAN'),
                  ),
                ),
                
                SizedBox(height: 20),
                
                Container(
                  alignment: Alignment.center,
                    child:
                    Text('Device Distance', 
                    style: TextStyle(fontSize: 21, color: Colors.white)),
                ),
                
                 SizedBox(height: 5),

                Container(
                  alignment: Alignment.center,
                    child:
                    Text(scannedBeaconDistance.toString(), 
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                ),
                 
                 SizedBox(height:10),

                  Container(
                  alignment: Alignment.center,
                    child:
                    Text('Transmission Power', 
                    style: TextStyle(fontSize: 21, color: Colors.white)),
                ),

                SizedBox(height: 5),

                Container(
                  alignment: Alignment.center,
                    child:
                    Text(scannedBeaconTXPower.toString(), 
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                ),

                SizedBox(height: 12),

                Center(
                  child: RaisedButton(
                    onPressed: () async {
                      
                      snowmScanner.stopBackgroudScan();
                      print('Background Scanning Stopped');      
                    },
                    child: Text('Stop Backgorund Scanning'),
                  ),
                ),

                
                SizedBox(height: 10),

                Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: 
                <Widget>[
                
                Text('Beacon Data', style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('UUID: $UUID', style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('Major id: $MAJOR_ID', style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('Minor id: $MINOR_ID', style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('Tx Power: $TRANSMISSION_POWER', style: TextStyle(fontSize: 17, color: Colors.white)),
                //Text('Identifier: $IDENTIFIER'),
                Text('Layout: $LAYOUT', style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('Manufacturer Id: $MANUFACTURER_ID', style: TextStyle(fontSize: 17, color: Colors.white)),
               
               ],
              ),
             
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}


//TO CALCULATE DISTANCE BETWEEN DEVICES USING TRANSMISSION_POWER
//

// double getDistance(int rssi, int txPower) {
//        return Math.pow(10d, ((double) txPower - rssi) / (10 * 2));
// }
