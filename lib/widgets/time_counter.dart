import 'package:flutter/material.dart';

import 'dart:async';

///通过流 Stream 实现的倒计时功能
///倒计时
class TimeCounter extends StatefulWidget {
  double totalTimeNumber = 3000;

  ///当前的时间
  double currentTimeNumber = 3000;
  VoidCallback onFinish;
  TimeCounter(this.totalTimeNumber, this.onFinish, {Key? key})
      : super(key: key) {
    currentTimeNumber = totalTimeNumber;
  }
  @override
  State<StatefulWidget> createState() {
    return TimeCounterState();
  }
}

class TimeCounterState extends State<TimeCounter> {
  ///单订阅流
  final StreamController<double> _streamController = StreamController();

  ///计时器
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      startTimer();
    });
  }

  @override
  void dispose() {
    super.dispose();

    ///关闭
    _streamController.close();
    _timer.cancel();
  }

  void startTimer() {
    ///间隔100毫秒执行时间
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      ///间隔100毫秒执行一次 每次减100
      widget.currentTimeNumber -= 100;

      ///如果计完成取消定时
      if (widget.currentTimeNumber <= 0) {
        _timer.cancel();
        widget.currentTimeNumber = 0;
        widget.onFinish();
      }

      ///流数据更新
      _streamController.add(widget.currentTimeNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildStreamBuilder();
  }

  /// 监听Stream，每次值改变的时候，更新Text中的内容
  StreamBuilder<double> buildStreamBuilder() {
    return StreamBuilder<double>(
      ///绑定stream
      stream: _streamController.stream,

      ///默认的数据
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ///中间显示的文本
            Text(
              (snapshot.data! / 1000).toStringAsFixed(0),
              style: const TextStyle(fontSize: 22, color: Colors.blue),
            ),

            ///圆圈进度
            CircularProgressIndicator(
              value: 1.0 - snapshot.data! / widget.totalTimeNumber,
            )
          ],
        );
      },
    );
  }
}
