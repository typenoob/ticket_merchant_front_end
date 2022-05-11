import 'package:flutter/material.dart';
import 'package:ticket_merchant/widgets/ticket_widget.dart';

class TicketDetail extends StatelessWidget {
  final String startStation, endStation;
  DateTime date;
  List<dynamic> trains = [];
  TicketDetail(this.startStation, this.endStation, this.trains, this.date,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$startStation<>$endStation'),
        ),
        body: ListView.builder(
          itemBuilder: ((context, index) => TicketWidget(
                trains[index]['start_station'],
                trains[index]['end_station'],
                trains[index]['start_time'],
                trains[index]['end_time'],
                trains[index]['train_number'],
                trains[index]['ticket_number'],
                date,
              )),
          itemCount: trains.length,
        ));
  }
}
