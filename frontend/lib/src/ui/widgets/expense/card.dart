import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String value;
  final bool isLastOne;

  const ExpenseCard({Key? key, required this.value, required this.isLastOne}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              const ClipOval(
                child: Material(
                  color: Colors.grey, // button color
                  child: SizedBox(
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              !isLastOne
                  ? Container(
                      height: 45.0,
                      width: 1.5,
                      color: Colors.grey,
                      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                    )
                  : Container(),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 15.0, top: 5.0),
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
