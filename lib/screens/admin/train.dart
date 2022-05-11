import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/through_station_input.dart';
import 'package:ticket_merchant/widgets/user_input.dart';
import 'package:ticket_merchant/widgets/pg_data_table.dart';
import 'package:ticket_merchant/widgets/navigation_drawer.dart';
import 'package:ticket_merchant/resources/data_source.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:ticket_merchant/widgets/schedule_chart.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({Key? key}) : super(key: key);

  @override
  _TrainPageState createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  bool loading = true, allSelected = false;
  static const int initLoadPage = 5;
  int _maxLoadPage = 0, _count = 0, currentPage = 1;
  DateTime _date = DateTime.now();
  static List<dynamic> trains = [];
  final TextEditingController searchController = TextEditingController(),
      modifyController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  _TrainPageState() {
    initData();
  }
  refreshTable() {
    setState(() {
      _maxLoadPage = 0;
      _count++;
      loading = true;
    });
    trains.clear();
  }

  initData() {
    trains.clear();
    for (int i = 0; i < initLoadPage; i++) {
      fetchData(i + 1);
    }
  }

  fetchData(int page) {
    if (page > _maxLoadPage) {
      _maxLoadPage = page;
      HttpUtil()
          .getTrainByDateAndNumber(page, PgDataTable.perPage, _date)
          .then((value) {
        trains.addAll(value);
        setState(() {
          loading = false;
        });
      });
    }
  }

  searchData(text) {
    HttpUtil().searchTrainByTextAndDate(text, _date).then((value) {
      trains.addAll(value);
      setState(() {
        loading = false;
      });
    });
  }

  deleteData() {
    bool visited = false;
    for (var train in trains) {
      if (train['selected']) {
        visited = true;
        HttpUtil()
            .deleteTrainByNumber(train['train_number'], _date)
            .then((value) {
          setState(() {
            trains.remove(train);
          });
        });
      }
    }
    if (!visited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("请至少选择一项"),
        ),
      );
    }
  }

  getSelectTrain() {
    for (var train in trains) {
      if (train['selected']) {
        return train;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavigationDrawerWidget(),
        // endDrawer: NavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text("管理员面板"),
        ),
        body: Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.03,
                MediaQuery.of(context).size.width * 0.1,
                MediaQuery.of(context).size.height * 0.05),
            child: Column(children: [
              TrainInput(),
              const SizedBox(height: 20),
              Row(children: [
                Flexible(
                  child: DateTimePicker(
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    dateLabelText: '日期',
                    onChanged: (val) => setState(() {
                      _date = DateTime.parse(val);
                      refreshTable();
                      initData();
                    }),
                  ),
                ),
                const Spacer(),
              ]),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: userInput(
                    searchController,
                    '搜索车次',
                    TextInputType.values.first,
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      icon: const Icon(Icons.search_outlined),
                      onPressed: () {
                        if (searchController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.orange,
                              content: Text("不允许输入空值"),
                            ),
                          );
                        } else {
                          refreshTable();
                          searchData(searchController.text);
                        }
                      }),
                  const Spacer(),
                  TextButton(
                      child: const Text('批量迁移全部车次至下一天'),
                      onPressed: () {
                        HttpUtil().migrate(_date).then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("操作成功"),
                              ),
                            ));
                      }),
                  IconButton(
                      icon: const Icon(Icons.refresh_outlined),
                      onPressed: () {
                        refreshTable();
                        initData();
                      }),
                  IconButton(
                      icon: const Icon(Icons.details_outlined),
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          builder: (context) {
                            for (var train in trains) {
                              if (train['selected']) {
                                return AlertDialog(
                                  title: const Text("经停站详情"),
                                  content:
                                      //.......
                                      ScheduleChart(
                                    train['train_number'],
                                    _date,
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
                                );
                              }
                            }
                            return const AlertDialog();
                          },
                        );
                      }),
                  IconButton(
                      onPressed: () {
                        deleteData();
                      },
                      icon: const Icon(Icons.delete_forever))
                ],
              ),
              KeyedSubtree(
                key: ValueKey<int>(_count),
                // ignore: sized_box_for_whitespace
                child: Flexible(
                  child: (loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : PgDataTable(
                          const ['车次号', '起始站', '终点站', '一等票', '二等票', '三等票'],
                          '车次表',
                          trains,
                          MediaQuery.of(context).size.width * 0.07,
                          DataSource(
                            trains,
                            const [
                              'train_number',
                              'start_station',
                              'end_station',
                              'first_class_ticket',
                              'second_class_ticket',
                              'third_class_ticket'
                            ],
                          ),
                          allSelected,
                          (value) {
                            fetchData(value);
                            currentPage = value;
                          },
                          (value) {
                            setState(() {
                              allSelected = !allSelected;
                              for (int i =
                                      (currentPage - 1) * PgDataTable.perPage;
                                  i < currentPage * PgDataTable.perPage;
                                  i++) {
                                if (i < trains.length) {
                                  trains[i]['selected'] = !value;
                                }
                              }
                            });
                          },
                        )),
                ),
              )
            ])));
  }
}

// ignore: must_be_immutable
class TrainInput extends StatelessWidget {
  List<dynamic> stations = [];
  final TextEditingController trainNumberController = TextEditingController();
  TrainInput({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(
          child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '车次',
        ),
        controller: trainNumberController,
      )),
      const Spacer(),
      MaterialButton(
        color: Colors.orangeAccent,
        minWidth: 200,
        onPressed: () {
          showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("输入经停站"),
                content: ThroughStationInput(
                  onSubmit: (value) {
                    stations = value;
                  },
                  key: stationKey,
                ),
                actions: <Widget>[
                  TextButton(
                      child: const Text("返回"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              );
            },
          );
        },
        child: const Text(
          '输入经停站',
          style: TextStyle(color: Colors.white),
        ),
      ),
      MaterialButton(
        color: const Color.fromRGBO(163, 22, 0, 100),
        minWidth: 200,
        onPressed: () {
          if ([
            trainNumberController.text,
          ].any((value) => value.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text("不允许输入空值"),
              ),
            );
          } else {
            HttpUtil().addTrain(
              trainNumberController.text,
              DateTime.now(),
              stations,
            );
          }
        },
        child: const Text(
          '添加车次',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ]);
  }
}
