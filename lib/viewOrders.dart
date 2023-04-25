import 'package:flutter/material.dart';
import 'package:animated_button_bar/animated_button_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Tracking/tracking_location.dart';

class viewOrders extends StatefulWidget {
  final String username;

  viewOrders({required this.username});

  @override
  State<viewOrders> createState() => _viewOrdersState();
}

class _viewOrdersState extends State<viewOrders> {
  final CollectionReference order =
  FirebaseFirestore.instance.collection('order');
  late double returnOrderlong;
  late double returnOrderlat;
  List userOrder = [];

  Future<void> retriveData(String order_id, String sp_name,
      String waste_quantity, String waste_type,String req_email,String compName,double orderlat,double orderlong) async {
    return await order.doc(order_id).set({
      'order_id': order_id,
      'sp_name': sp_name,
      'waste_qauntity': waste_quantity,
      'waste_type': waste_type,
      'comp_email':req_email,
      'Company_name':compName,
      'latitude':orderlat,
      'longitude':orderlong
    });
  }

  Future getOrderList() async {
    List itemsList = [];
    try {
      await order.get().then((QuerySnapshot) {
        QuerySnapshot.docs.forEach((doc) {
          itemsList.add(doc.data);
        });
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    //here i change it from fetch databaselist into getOrderList
    getOrderList();
  }

  fetchDatabaseList() async {
    dynamic resultant = await getOrderList();
    if (resultant == null) {
      print('Unable to retrive');
    } else {
      setState(() {
        userOrder = resultant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.lightGreen[300],
      ),
      body: Container(
        width: 1000,
        height: 3000,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Welcome, ${widget.username}! ',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
            ),
            AnimatedButtonBar(
              radius: 8.0,
              padding: const EdgeInsets.all(13.0),
              //invertedSelection: true,
              backgroundColor: Colors.lightGreen.shade300,
              foregroundColor: Colors.lightGreen.shade800,
              borderColor: Colors.white,
              children: [
                ButtonBarEntry(
                    onTap: () => print('First item tapped'),
                    child: Text('In progress')),
                ButtonBarEntry(
                    onTap: () => setState(DonePage() as VoidCallback),
                    child: Text('Done')),
              ],
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: order
                    .where('DriverID', isEqualTo: widget.username)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text('Loading...');
                    default:
                      if (snapshot.hasData) {
                        return Flexible(
                            child: ClipRect(
                              child: ListView(
                                children:
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                                 /* var returnCompem =  ((doc.data() as dynamic)[
                                  'comp_email']).toString();*/
                                   returnOrderlat =  ((doc.data() as dynamic)[
                                  'latitude']);
                                  returnOrderlong =  ((doc.data() as dynamic)[
                                  'longitude']);
                                  var returnSp_name =  ((doc.data() as dynamic)[
                                  'sp_name']).toString();
                                  var docId = doc.id;
                                  return Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => tracking_location(orderlat:returnOrderlat,orderlong: returnOrderlong,sp_name:returnSp_name,docId: docId),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Colors.lightGreen[200],
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                      height: 100, width: 10),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Order ID:',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      ((doc.data() as dynamic)[
                                                      'order_id'])
                                                          .toString(),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      'Waste type:',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                        ((doc.data() as dynamic)[
                                                        'waste_type'])
                                                            .toString(),
                                                        overflow:
                                                        TextOverflow.ellipsis),
                                                    Text(
                                                      'Waste quntity:',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                        ((doc.data() as dynamic)[
                                                        'waste_qauntity'])
                                                            .toString(),
                                                        overflow:
                                                        TextOverflow.visible),
                                                    Text(
                                                      'Company Name:',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      ((doc.data() as dynamic)[
                                                      'Company_name'])
                                                          .toString(),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                                }).toList(),
                              ),
                            ));
                      }
                      return Text('Error');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DonePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    backgroundColor: Colors.lightGreen[100];
    return Container(
    );
  }
}