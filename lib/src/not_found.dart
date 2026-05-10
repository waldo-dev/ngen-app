import 'package:flutter/material.dart';

class NotFoundWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd8f3dc),
      body: Stack(
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/development.png', height: 200,),
                SizedBox(height: 10,),
                Text(
                  'Sorry, this page is still in development!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    color: const Color(0xff2f3640),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}