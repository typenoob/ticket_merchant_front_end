import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/dialog_input.dart';
import 'package:ticket_merchant/widgets/schedule_chart.dart';

// ignore: must_be_immutable
class TicketWidget extends StatelessWidget {
  final String startStation, endStation, trainNo;
  final String startTime, endTime;
  DateTime date;
  List<dynamic> ticketNumber = [];
  TicketWidget(this.startStation, this.endStation, this.startTime, this.endTime,
      this.trainNo, this.ticketNumber, this.date,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey,
      ),
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(children: [
        Row(
          children: [
            Text(
              startTime,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              trainNo,
              style: const TextStyle(fontSize: 23, fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            Text(
              endTime,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          children: [
            Text(
              startStation,
              style: const TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Text(
              endStation,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              '一等票:${ticketNumber[0].toString()}张',
              style: const TextStyle(fontSize: 15),
            ),
            const Spacer(),
            Text(
              '二等票:${ticketNumber[1].toString()}张',
              style: const TextStyle(fontSize: 15),
            ),
            const Spacer(),
            Text(
              '三等票:${ticketNumber[2].toString()}张',
              style: const TextStyle(fontSize: 15),
            ),
            const Spacer(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () => {
                      showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("经停站详情"),
                          content:
                              //.......
                              ScheduleChart(
                            trainNo,
                            date,
                            '修改车站',
                          ),
                          actions: <Widget>[
                            TextButton(
                                child: const Text("返回"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                } // 关闭对话框
                                ),
                          ],
                        ),
                      )
                    },
                child: const Text('详情')),
            TextButton(
                onPressed: () {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("添加订单"),
                          content: DialogInput(
                            okBtnTap: (value) => HttpUtil()
                                .getPassengerCard(HttpUtil().uid, value[0])
                                .then(
                                  (card) => HttpUtil()
                                      .getAnyTicket(trainNo, date, value[1])
                                      .then((id) => HttpUtil().addOrder(
                                          card, id, startStation, endStation))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.orange,
                                              content:
                                                  Text("已添加至订单，请在一分钟内及时支付！"),
                                            ),
                                          )),
                                ),

                            //TODO 添加订单
                          ),
                        );
                      });
                },
                child: const Text('购买')),
          ],
        )
      ]),
    );
  }
}
