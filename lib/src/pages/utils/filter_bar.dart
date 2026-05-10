import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterBarWidget extends StatefulWidget {
  final String hintText;

  FilterBarWidget(this.hintText);

  @override
  State<FilterBarWidget> createState() => FilterBarWidgetState();
}

class FilterBarWidgetState extends State<FilterBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(100000)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  hintText: widget.hintText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 243, 244, 250),
              child: SvgPicture.asset(
                "assets/images/navigation/search.svg",
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
