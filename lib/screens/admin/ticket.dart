import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/user_input.dart';
import 'package:ticket_merchant/widgets/pg_data_table.dart';
import 'package:ticket_merchant/widgets/navigation_drawer.dart';
import 'package:ticket_merchant/resources/data_source.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:number_selection/number_selection.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  bool loading = true;
  static const int initLoadPage = 5;
  int _maxLoadPage = 0, _count = 0, _currentValue = 1, currentPage = 1;
  DateTime _date = DateTime.now();
  static List<dynamic> tickets = [];
  final TextEditingController searchController = TextEditingController(),
      modifyController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  _TicketPageState() {
    initData();
  }
  refreshTable() {
    setState(() {
      _maxLoadPage = 0;
      _count++;
      loading = true;
    });
    tickets.clear();
  }

  initData() {
    tickets.clear();
    for (int i = 0; i < initLoadPage; i++) {
      fetchData(i + 1);
    }
  }

  fetchData(int page) {
    if (page > _maxLoadPage) {
      _maxLoadPage = page;
      HttpUtil()
          .getTicketByPageAndLevelAndPage(
              page, PgDataTable.perPage, _currentValue, _date)
          .then((value) {
        tickets.addAll(value);
        setState(() {
          loading = false;
        });
      });
    }
  }

  searchData(String name) {
    HttpUtil()
        .searchTicketByNumber(_currentValue, DateTime(2022, 5, 5), name)
        .then((value) {
      tickets.addAll(value);
      setState(() {
        loading = false;
      });
    });
  }

  modifyTicket(int offset) {
    bool visit = false;
    for (var ticket in tickets) {
      if (ticket['selected']) {
        HttpUtil()
            .modifyTicketByInc(
                _currentValue, _date, ticket['train_number'], offset)
            .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.orange,
                    content: Text("添加成功"),
                  ),
                ));
        visit = true;
      }
    }
    if (!visit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("请至少选择一项"),
        ),
      );
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
                const Icon(Icons.airplane_ticket_outlined),
                const Text('车票等级'),
                Container(
                  width: 100,
                  padding: const EdgeInsets.only(left: 20),
                  child: NumberSelection(
                    theme: NumberSelectionTheme(
                        draggableCircleColor: Colors.blue,
                        iconsColor: Colors.white,
                        numberColor: Colors.white,
                        backgroundColor: Colors.deepPurpleAccent,
                        outOfConstraintsColor: Colors.deepOrange),
                    initialValue: 1,
                    minValue: 1,
                    maxValue: 3,
                    withSpring: true,
                    onChanged: (int value) => setState(() {
                      _currentValue = value;
                      refreshTable();
                      initData();
                    }),
                    enableOnOutOfConstraintsAnimation: true,
                  ),
                ),
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
                  Flexible(
                      child: userInput(
                    modifyController,
                    '想要增加的票量（输入负数减少）',
                    TextInputType.number,
                  )),
                  IconButton(
                    icon: const Icon(Icons.check_outlined),
                    onPressed: () {
                      if (modifyController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text("不允许输入空值"),
                          ),
                        );
                      } else {
                        try {
                          modifyTicket(int.parse(modifyController.text));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.orange,
                              content: Text("只接受整数"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                      icon: const Icon(Icons.refresh_outlined),
                      onPressed: () {
                        refreshTable();
                        initData();
                      }),
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
                          const ['车次号', '起始站', '终点站', '余票'],
                          '票量表',
                          tickets,
                          MediaQuery.of(context).size.width * 0.1,
                          DataSource(
                              tickets,
                              const [
                                'train_number',
                                'start_station',
                                'end_station',
                                'ticket_number'
                              ],
                              exclusive: true),
                          false,
                          (value) {
                            fetchData(value);
                            currentPage = value;
                          },
                          (value) {},
                          exclusive: true,
                        )),
                ),
              )
            ])));
  }
}
