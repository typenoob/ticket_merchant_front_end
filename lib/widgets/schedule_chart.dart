import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';

class ScheduleChart extends StatefulWidget {
  final String title, train;
  final DateTime date;
  const ScheduleChart(this.train, this.date, this.title, {Key? key})
      : super(key: key);

  @override
  State<ScheduleChart> createState() => _ScheduleChartState();
}

class _ScheduleChartState extends State<ScheduleChart> {
  List<List> data = [[], [], []];
  bool _loading = true;
  void initState() {
    super.initState();
    data = [[], [], []];
    setState(() {
      _loading = true;
    });
    initData();
  }

  initData() {
    HttpUtil().getThroughStation(widget.train, widget.date).then((stations) {
      data[0] = stations;
      for (var station in stations) {
        HttpUtil()
            .getScheduleTime(widget.train, station, widget.date)
            .then((value) {
          data[1].add(value['arrive_time']);
          data[2].add(value['depart_time']);
          setState(() {
            _loading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Container(
        width: 500,
        height: 500,
        child: Row(
          children: [
            Card(
              child: Column(children: const [
                Text('到达时间'),
                Spacer(),
                Text('车站'),
                Spacer(),
                Text('离开时间')
              ]),
            ),
            Flexible(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data[1].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      children: [
                        Card(
                          child: Column(
                            children: [
                              Text(data[1][index] ?? '起始站'),
                              Spacer(),
                              Text(data[0][index]),
                              Spacer(),
                              Text(data[2][index] ?? '终点站'),
                            ],
                          ),
                        ),
                        VerticalDivider(),
                      ],
                    );
                  }),
            ),
          ],
        ),
      );
    }

    // This trailing comma makes auto-formatting nicer for build methods.
  }
}
