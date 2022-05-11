import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/user_input.dart';
import 'ticket_detail.dart';

class PageHome extends StatefulWidget {
  final String _title;

  const PageHome(this._title, {Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final textStyle = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final TextEditingController startStationController = TextEditingController();
  final TextEditingController endStationController = TextEditingController();
  DateTime _date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.5,
            image: AssetImage("images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: userInput(startStationController, '出发自',
                              TextInputType.streetAddress),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                String temp = startStationController.text;
                                startStationController.text =
                                    endStationController.text;
                                endStationController.text = temp;
                              });
                            },
                            icon: const Icon(Icons.arrow_circle_right_outlined,
                                size: 30),
                          ),
                        ),
                        Flexible(
                          child: userInput(endStationController, '到达于',
                              TextInputType.streetAddress),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Flexible(
                          child: DateTimePicker(
                            initialValue: DateTime.now().toString(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            dateLabelText: '日期',
                            onChanged: (val) => setState(() {
                              _date = DateTime.parse(val);
                            }),
                          ),
                        ),
                        const Spacer(),
                        const Spacer(),
                      ],
                    ),
                    const Divider(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: ElevatedButton(
                          onPressed: (() => HttpUtil()
                                  .getTrainBetweenCities(
                                      startStationController.text,
                                      endStationController.text,
                                      _date)
                                  .then((value) {
                                HttpUtil()
                                    .getTicketDetail(
                                        value,
                                        _date,
                                        startStationController.text,
                                        endStationController.text)
                                    .then((value) => Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => TicketDetail(
                                              startStationController.text,
                                              endStationController.text,
                                              value,
                                              _date),
                                        )));
                              })),
                          child: const Text(
                            '查询车票',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          )),
                    ),
                  ],
                ))),
      ),
    );
  }
}
