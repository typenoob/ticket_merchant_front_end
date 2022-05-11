import 'package:flutter/material.dart';
import 'package:ticket_merchant/utils/http_util.dart';
import 'package:ticket_merchant/widgets/order_widget.dart';

class PageOrder extends StatefulWidget {
  String title;
  List<List> orders = [[], [], []];
  PageOrder(this.title, {Key? key}) : super(key: key);
  int loading = 0;
  @override
  _PageOrderState createState() => _PageOrderState();
}

class _PageOrderState extends State<PageOrder> {
  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    widget.loading = 0;
    widget.orders = [[], [], []];
    HttpUtil().getOrders(HttpUtil().uid, 'block').then((value) => setState(() {
          widget.orders[0] = value;
          widget.loading++;
        }));
    HttpUtil()
        .getOrders(HttpUtil().uid, 'success')
        .then((value) => setState(() {
              widget.orders[1] = value;
              widget.loading++;
            }));
    HttpUtil().getOrders(HttpUtil().uid, 'error').then((value) => setState(() {
          widget.orders[2] = value;
          widget.loading++;
        }));
  }

  @override
  Widget build(BuildContext context) {
    /// 材料设计主题
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          /// 标题组件
          title: Text(widget.title),
        ),

        /// 列表组件
        body: widget.loading < 3
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: _buildList(),
              ),
      ),
    );
  }

  /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
  List<Widget> _buildList() {
    return [
      ExpansionTile(
        title: const Text(
          '待支付订单',
        ),
        children: List.generate(widget.orders[0].length,
            (index) => OrderWidget(widget.orders[0][index], 0, refreshData)),
      ),
      ExpansionTile(
        title: const Text(
          '已支付订单',
        ),
        children: List.generate(widget.orders[1].length,
            (index) => OrderWidget(widget.orders[1][index], 1, refreshData)),
      ),
      ExpansionTile(
        title: const Text(
          '已取消订单',
        ),
        children: List.generate(widget.orders[2].length,
            (index) => OrderWidget(widget.orders[2][index], 2, refreshData)),
      ),
    ];
  }
}
