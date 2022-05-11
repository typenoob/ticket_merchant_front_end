import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/user_input.dart';
import 'package:ticket_merchant/widgets/pg_data_table.dart';
import 'package:ticket_merchant/widgets/navigation_drawer.dart';
import 'package:ticket_merchant/resources/data_source.dart';

class StationPage extends StatefulWidget {
  const StationPage({Key? key}) : super(key: key);

  @override
  _StationPageState createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  bool loading = true, allSelected = false;
  static const int initLoadPage = 5;
  int _maxLoadPage = 0, _count = 0, currentPage = 1;
  static List<dynamic> stations = [];
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    stations.clear();
    super.initState();
  }

  _StationPageState() {
    initData();
  }
  refreshTable() {
    setState(() {
      _maxLoadPage = 0;
      _count++;
      loading = true;
    });
    stations.clear();
  }

  initData() {
    stations.clear();
    for (int i = 0; i < initLoadPage; i++) {
      fetchData(i + 1);
    }
  }

  fetchData(int page) {
    if (page > _maxLoadPage) {
      _maxLoadPage = page;
      HttpUtil().getStationByPage(page, PgDataTable.perPage).then((value) {
        stations.addAll(value);
        setState(() {
          loading = false;
        });
      });
    }
  }

  searchData(String text) {
    HttpUtil().searchStationByText(text).then((value) {
      stations.addAll(value);
      setState(() {
        loading = false;
      });
    });
  }

  deleteData() {
    bool visited = false;
    for (var station in stations) {
      if (station['selected']) {
        visited = true;
        HttpUtil().deleteStationByName(station['station_name']).then((value) {
          setState(() {
            stations.remove(station);
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

  addStation(String name, String lon, String lat) {
    setState(() {
      stations.insert(
          0, {'station_name': name, 'lon': lon, 'lat': lat, 'selected': false});
    });
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
              StationInput(addStation),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: userInput(
                    searchController,
                    '搜索车站',
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
                  IconButton(
                      icon: const Icon(Icons.refresh_outlined),
                      onPressed: () {
                        refreshTable();
                        initData();
                      }),
                  const Spacer(),
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
                    child: loading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : PgDataTable(
                            const ['车站', '经度', '纬度'],
                            '车站表',
                            stations,
                            MediaQuery.of(context).size.width * 0.14,
                            DataSource(
                                stations, const ['station_name', 'lon', 'lat']),
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
                                  if (i < stations.length) {
                                    stations[i]['selected'] = !value;
                                  }
                                }
                              });
                            },
                          )),
              )
            ])));
  }
}

class StationInput extends StatelessWidget {
  final TextEditingController stationNameController = TextEditingController();
  final TextEditingController lonController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final Function addStation;
  StationInput(this.addStation, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(
          child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '名称',
        ),
        controller: stationNameController,
      )),
      const Spacer(),
      Flexible(
          child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '经度',
        ),
        controller: lonController,
      )),
      const Spacer(),
      Flexible(
          child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '纬度',
        ),
        controller: latController,
      )),
      const Spacer(),
      MaterialButton(
        color: const Color.fromRGBO(163, 22, 0, 100),
        minWidth: 200,
        onPressed: () {
          if ([
            stationNameController.text,
            lonController.text,
            latController.text
          ].any((value) => value.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.orange,
                content: Text("不允许输入空值"),
              ),
            );
          } else {
            HttpUtil()
                .addStation(
              stationNameController.text,
              double.parse(lonController.text),
              double.parse(latController.text),
            )
                .then((value) {
              if (value.data == '添加成功') {
                addStation(
                  stationNameController.text,
                  lonController.text,
                  latController.text,
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: value.data == '添加成功'
                      ? Colors.lightGreenAccent
                      : Colors.redAccent,
                  content: Text(value.data),
                ),
              );
              stationNameController.clear();
              lonController.clear();
              latController.clear();
            });
          }
        },
        child: const Text(
          '添加车站',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ]);
  }
}
