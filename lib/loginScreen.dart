import 'package:flutter/material.dart';
import 'package:app_green_waste/viewOrders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:app_green_waste/Tracking/trackOrder.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

CollectionReference collectionRef =
FirebaseFirestore.instance.collection('Driver');
//collectionRef.add(dataToSave);

class _LoginScreenState extends State<LoginScreen> {
  final _formfield = GlobalKey<FormState>();
  TextEditingController passController = TextEditingController();
  TextEditingController userController = TextEditingController();
  String password = '';
  String user = '';
  bool passToggle = true;
  bool userToggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formfield,
            autovalidateMode: AutovalidateMode
                .onUserInteraction, // this to show error when user is in some textField

            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.approval_outlined,
                size: 100,
              ),
              SizedBox(height: 25),
              // Hello
              Text(
                'Hello!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome back',
                style: TextStyle(fontSize: 20),
              ),
              //user name textfield
              SizedBox(height: 10),
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
                      controller: userController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter user name',
                        prefixIcon: Icon(Icons.account_circle_outlined),
                      ),
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter user name';
                        }
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //password text field
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
                      controller: passController,
                      obscureText: passToggle,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passToggle = !passToggle;
                            });
                          },
                          child: Icon(passToggle
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Enter Password';
                        }
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                child: Container(
                  child: ButtonTheme(
                    child: ElevatedButton(
                      child: Text("Log in"),
                      onPressed: () async {
                        print('this is working ');
                        print('this is working ${userController.text}');

                   if(userController.text.isEmpty||passController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                             content: Text('Please Enter user name and password'),
                       ));
                     }
                        Future getDriverName = FirebaseFirestore.instance
                            .collection("Driver")
                            .where('Driver_username',
                            isEqualTo: userController.text)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          querySnapshot.docs.forEach((doc) {
                            password = doc['Driver_Password'];
                            if (passController.text == password) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => viewOrders(
                                          username: userController.text)));
                            }
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightGreen[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: Size(300, 55),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrackOrder()));
                      },

                      child: Text(
                        "Track order",
                        style: TextStyle(
                            color: Colors.lightGreen[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 25),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }

}
