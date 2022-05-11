import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';

double btnHeight = 60;
double borderWidth = 2;

class DialogInput extends StatefulWidget {
  int _level = 1;
  int _index = 0;
  List people = [];
  String cancelBtnTitle;
  String okBtnTitle;
  ValueChanged okBtnTap;
  DialogInput({
    this.cancelBtnTitle = "Cancel",
    this.okBtnTitle = "Ok",
    required this.okBtnTap,
  });

  @override
  DialogInputState createState() => DialogInputState();
}

class DialogInputState extends State<DialogInput> {
  @override
  initState() {
    super.initState();
    HttpUtil()
        .getPassengerName(HttpUtil().uid)
        .then((value) => setState(() => widget.people = value));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.people.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
          margin: EdgeInsets.only(top: 20),
          height: 200,
          width: 1000,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('车票等级'),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                    value: widget._level,
                    items: const [
                      DropdownMenuItem(
                        child: Text("一等票"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("二等票"),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text("三等票"),
                        value: 3,
                      )
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        widget._level = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('乘车人'),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                    value: widget._index,
                    items: List.generate(
                        widget.people.length,
                        (index) => DropdownMenuItem(
                            child: Text(widget.people[index]), value: index)),
                    onChanged: (int? value) {
                      setState(() {
                        widget._index = value!;
                      });
                    },
                  )
                ],
              ),
              Container(
                // color: Colors.red,
                height: btnHeight,
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Column(
                  children: [
                    Container(
                      // 按钮上面的横线
                      width: double.infinity,
                      color: Colors.blue,
                      height: borderWidth,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            widget.cancelBtnTitle,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.blue),
                          ),
                        ),
                        Container(
                          // 按钮中间的竖线
                          width: borderWidth,
                          color: Colors.blue,
                          height: btnHeight - borderWidth - borderWidth,
                        ),
                        TextButton(
                            onPressed: () {
                              widget.okBtnTap([
                                widget.people[widget._index],
                                widget._level
                              ]);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              widget.okBtnTitle,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.blue),
                            )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ));
    }
  }
}
