import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/time_counter.dart';
import 'schedule_chart.dart';

class OrderWidget extends StatefulWidget {
  Map data;
  int status;
  Function refresh;
  OrderWidget(this.data, this.status, this.refresh, {Key? key})
      : super(key: key);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  wrapLevel(level) {
    switch (level) {
      case 1:
        return '一等票';
      case 2:
        return '二等票';
      case 3:
        return '三等票';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.data['time'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              wrapLevel(widget.data['level']),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '票价' + widget.data['price'].round().toString(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          children: [
            Text(
              widget.data['start_station'],
              style: const TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Text(
              widget.data['train_number'],
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            Text(
              widget.data['end_station'],
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.status == 0
                ? Row(
                    children: [
                      Text('剩余时间:'),
                      TimeCounter(
                          60000 -
                              DateTime.now()
                                  .difference(widget.data['created_at'])
                                  .inMilliseconds
                                  .toDouble(), () {
                        HttpUtil()
                            .submitOrder(widget.data['order_id'], 'error');
                        widget.refresh();
                      }),
                    ],
                  )
                : Row(),
            Row(
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
                                widget.data['train_number'],
                                widget.data['created_at'],
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
                if (widget.status == 0)
                  TextButton(
                      onPressed: () => HttpUtil()
                          .submitOrder(widget.data['order_id'], 'success')
                          .then((value) => widget.refresh()),
                      child: const Text('支付')),
                if (widget.status == 1)
                  TextButton(
                      onPressed: () => HttpUtil()
                          .submitOrder(widget.data['order_id'], 'error')
                          .then((value) => widget.refresh()),
                      child: const Text('退票')),
              ],
            ),
          ],
        ),
        Divider(),
      ]),
    );
  }
}
