import 'package:flutter/material.dart';
import 'user_input.dart';

GlobalKey<_ThroughStationInputState> stationKey = GlobalKey();

class ThroughStationInput extends StatefulWidget {
  final ValueChanged onSubmit;
  const ThroughStationInput({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<ThroughStationInput> createState() => _ThroughStationInputState();
}

class _ThroughStationInputState extends State<ThroughStationInput> {
  int _counter = 2;
  List nameInput = [
    TextEditingController(),
    TextEditingController(),
  ];
  List arriveTimeInput = [
    TextEditingController(),
    TextEditingController(),
  ];
  List departTimeInput = [
    TextEditingController(),
    TextEditingController(),
  ];

  getStations() {
    return List.generate(
        _counter,
        ((index) => {
              'station_name': nameInput[index].text,
              'arrive_time': arriveTimeInput[index].text == ''
                  ? null
                  : arriveTimeInput[index].text,
              'depart_time': departTimeInput[index].text == ''
                  ? null
                  : departTimeInput[index].text,
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
        width: 5,
      )),
      width: 600,
      height: 600,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: _counter,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Flexible(
                          child: userInput(
                        nameInput[index],
                        '车站名称',
                        TextInputType.text,
                      )),
                      Flexible(
                        child: index > 0
                            ? userInput(
                                arriveTimeInput[index],
                                '到达时间',
                                TextInputType.text,
                              )
                            : userInput(
                                arriveTimeInput[index],
                                '起点站',
                                TextInputType.none,
                                readOnly: true,
                              ),
                      ),
                      Flexible(
                          child: index < _counter - 1
                              ? userInput(
                                  departTimeInput[index],
                                  '离开时间',
                                  TextInputType.text,
                                )
                              : userInput(
                                  departTimeInput[index],
                                  '终点站',
                                  TextInputType.none,
                                  readOnly: true,
                                ))
                    ],
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _counter++;
                    nameInput.add(TextEditingController());
                    arriveTimeInput.add(TextEditingController());
                    departTimeInput.add(TextEditingController());
                  });
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(
                width: 25,
              ),
              ElevatedButton(
                  onPressed: () {
                    widget.onSubmit(getStations());
                    Navigator.pop(context);
                  },
                  child: const Text('提交'))
            ],
          )
        ],
      ),
    );
  }
}
