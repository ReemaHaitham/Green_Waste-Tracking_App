import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'compTrackOrder.dart';

class TrackOrder extends StatefulWidget {
  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  late double returnOrderlat;
  late double returnOrderlong;
  var returnSpName;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController idController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        title: const Text('Track Orders'),
        backgroundColor: Colors.lightGreen[300],
      ),
      body: Container(
        width: 1000,
        height: 3000,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Enter Your Order ID',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.lightGreen[800]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: idController,
                    //the order ID input field
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter the Order ID ',
                    ),
                    validator: ((value) {
                      if (value!.isEmpty) {
                        return 'Enter Order ID';
                      }
                    }),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
        Container(
          width: 200,
          height: 40,
           child: MaterialButton(
              onPressed: () async {
                if (idController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Color.fromRGBO(171,35,40,80),
                      content: Text("Please Enter your Order Id")));
                }
                var contID = int.parse(idController.text);
                var result = await firestore
                    .collection("order")
                    .where("order_id", isEqualTo: contID)
                    .get();
                if (result.docs.isNotEmpty) {
                  // handle the case when the document is present
                  var element = result.docs.first;
                  returnOrderlat = element['latitude'];
                  returnOrderlong = element['longitude'];
                  returnSpName = element['sp_name'];
                  //when Track btn clicked it will take the user to google map
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => comp_tracking_order(
                        orderlat: returnOrderlat,orderlong: returnOrderlong,
                        sp_name: returnSpName,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No Such Order")));
                }
              },
              color: Colors.lightGreen[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Start Tracking',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
        )
          ],
        ),
      ),
    );
  }
}
