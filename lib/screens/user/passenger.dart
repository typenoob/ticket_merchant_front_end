import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/user_input.dart';

class PagePassenger extends StatefulWidget {
  final String _title;

  const PagePassenger(this._title, {Key? key}) : super(key: key);

  @override
  _PagePassengerState createState() => _PagePassengerState();
}

class _PagePassengerState extends State<PagePassenger> {
  bool loading = true;
  List<dynamic> passengers = [];
  double widgetHeight = 75;
  TextEditingController idCardInput = TextEditingController();
  TextEditingController nameInput = TextEditingController();
  TextEditingController phoneInput = TextEditingController();
  TextEditingController nothingInput = TextEditingController();
  TextStyle textStyle = const TextStyle(
      fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic);
  @override
  void initState() {
    super.initState();
    refreshData();
  }

  refreshData() {
    setState(() {
      loading = true;
    });
    HttpUtil().getPassengerByID(HttpUtil().uid).then((value) {
      setState(() {
        passengers = value;
        loading = false;
      });
    });
  }

  addPassenger() {
    HttpUtil()
        .addPassengerByNumber(
            nameInput.text, idCardInput.text, phoneInput.text, HttpUtil().uid)
        .then((value) {
      refreshData();
      if (value.toString() == '该乘客已被绑定至其他账号') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text("添加失败：该乘客已被绑定至其他账号"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("添加成功"),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                itemBuilder: (context, index) => index < passengers.length
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.01),
                              height: widgetHeight,
                              child: userInput(
                                nothingInput,
                                passengers[index]['card_number'],
                                TextInputType.text,
                                readOnly: true,
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.01),
                              height: widgetHeight,
                              child: userInput(
                                nothingInput,
                                passengers[index]['name'],
                                TextInputType.text,
                                readOnly: true,
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              margin: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.01),
                              height: widgetHeight,
                              child: userInput(
                                nothingInput,
                                passengers[index]['phone'],
                                TextInputType.text,
                                readOnly: true,
                              )),
                          OutlinedButton(
                              onPressed: () {
                                HttpUtil()
                                    .deletePassengerByNumber(
                                        passengers[index]['card_number'])
                                    .then((value) => refreshData());
                              },
                              child: const Icon(Icons.remove_outlined))
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.01),
                                height: widgetHeight,
                                child: userInput(
                                  idCardInput,
                                  '身份证号',
                                  TextInputType.text,
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.01),
                                height: widgetHeight,
                                child: userInput(
                                  nameInput,
                                  '姓名',
                                  TextInputType.text,
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.01),
                                height: widgetHeight,
                                child: userInput(
                                  phoneInput,
                                  '手机号码',
                                  TextInputType.text,
                                )),
                            FloatingActionButton(
                              onPressed: () {
                                setState(() {
                                  if (!verifyCardId(idCardInput.text)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.orange,
                                        content: Text("非法的身份证号"),
                                      ),
                                    );
                                  } else if ([
                                    idCardInput.text,
                                    nameInput.text,
                                    phoneInput.text
                                  ].any((value) => value.isEmpty)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.orange,
                                        content: Text("不允许输入空值"),
                                      ),
                                    );
                                  } else {
                                    addPassenger();
                                    idCardInput.clear();
                                    nameInput.clear();
                                    phoneInput.clear();
                                  }
                                });
                              },
                              child: const Icon(Icons.add),
                            ),
                          ]),
                itemCount: passengers.length + 1,
              ),
            ),
    );
  }
}

bool verifyCardId(String cardId) {
  const Map city = {
    11: "北京",
    12: "天津",
    13: "河北",
    14: "山西",
    15: "内蒙古",
    21: "辽宁",
    22: "吉林",
    23: "黑龙江 ",
    31: "上海",
    32: "江苏",
    33: "浙江",
    34: "安徽",
    35: "福建",
    36: "江西",
    37: "山东",
    41: "河南",
    42: "湖北 ",
    43: "湖南",
    44: "广东",
    45: "广西",
    46: "海南",
    50: "重庆",
    51: "四川",
    52: "贵州",
    53: "云南",
    54: "西藏 ",
    61: "陕西",
    62: "甘肃",
    63: "青海",
    64: "宁夏",
    65: "新疆",
    71: "台湾",
    81: "香港",
    82: "澳门",
    91: "国外 "
  };
  String tip = '';
  bool pass = true;

  RegExp cardReg = RegExp(
      r'^\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|X)$');
  if (cardId == null || cardId.isEmpty || !cardReg.hasMatch(cardId)) {
    tip = '身份证号格式错误';
    print(tip);
    pass = false;
    return pass;
  }
  if (city[int.parse(cardId.substring(0, 2))] == null) {
    tip = '地址编码错误';
    print(tip);
    pass = false;
    return pass;
  }
  // 18位身份证需要验证最后一位校验位
  if (cardId.length == 18) {
    List numList = cardId.split('');
    //∑(ai×Wi)(mod 11)
    //加权因子
    List factor = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    //校验位
    List parity = [1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    int ai = 0;
    int wi = 0;
    for (var i = 0; i < 17; i++) {
      ai = int.parse(numList[i]);
      wi = factor[i];
      sum += ai * wi;
    }
    var last = parity[sum % 11];
    if (parity[sum % 11].toString() != numList[17]) {
      tip = "校验位错误";
      print(tip);
      pass = false;
    }
  }
//  print('证件格式$pass');
  return pass;
}
