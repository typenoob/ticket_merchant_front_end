import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:date_format/date_format.dart';

class HttpUtil {
  // 单例模式
  static final HttpUtil _singleton = HttpUtil._internal();
  factory HttpUtil() => _singleton;
  String uid = '';
  String adminUID = 'gluHlxYooBhJRUb7Mj6LLkhbLME3';
  HttpUtil._internal() {
    init();
  }

  static Dio _dio = Dio();
  // 初始化请求配置
  init() {
    BaseOptions baseOptions = BaseOptions(
      baseUrl: "http://dl.coyote.gq:7001/api/v1",
    );
    _dio = Dio(baseOptions);
    _dio.interceptors.add(CookieManager(CookieJar()));
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.extra["withCredentials"] = true;
      return handler.next(options);
    }));
  }

  bool isAdmin() {
    return uid == adminUID;
  }

  wrapData(response) {
    for (final item in response.data) {
      item.addAll({'selected': false});
    }
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  Future login(idToken) async {
    try {
      return await _dio.post('/sessions', data: {
        'idToken': idToken,
      });
    } on DioError {
      rethrow;
    }
  }

  Future deleteStationByName(name) async {
    try {
      return await _dio.delete('/stations/$name');
    } on DioError {
      rethrow;
    }
  }

  Future searchStationByText(text) async {
    try {
      Response response = await _dio.get('/stations/$text');
      return wrapData(response);
    } on DioError {
      rethrow;
    }
  }

  Future getStationByPage(page, limit) async {
    try {
      Response response = await _dio.get('/stations?page=$page&limit=$limit');
      return wrapData(response);
    } on DioError {
      rethrow;
    }
  }

  Future addStation(name, lon, lat) async {
    try {
      return await _dio.post('/stations', data: {
        'name': name,
        'lon': lon,
        'lat': lat,
      });
    } on DioError {
      rethrow;
    }
  }

  Future searchTicketByNumber(level, date, number) async {
    try {
      Response response =
          await _dio.get('/tickets/$number?&level=$level&date=$date');
      var data = wrapData(response);
      for (var item in data) {
        item['ticket_number'] = item['ticket_number'].toString();
      }
      return data;
    } on DioError {
      rethrow;
    }
  }

  Future getTicketByPageAndLevelAndPage(page, limit, level, date) async {
    try {
      Response response = await _dio
          .get('/tickets?page=$page&limit=$limit&level=$level&date=$date');
      var data = wrapData(response);
      for (var item in data) {
        item['ticket_number'] = item['ticket_number'].toString();
      }
      return data;
    } on DioError {
      rethrow;
    }
  }

  Future modifyTicketByInc(level, date, number, inc) async {
    try {
      return await _dio.post('/tickets', data: {
        'level': level,
        'date': formatDate(date, ['yyyy', '-', 'mm', '-', 'dd']),
        'number': number,
        'inc': inc,
      });
    } on DioError {
      rethrow;
    }
  }

  Future getTrainByDateAndNumber(page, limit, date) async {
    try {
      Response response =
          await _dio.get('/trains?page=$page&limit=$limit&date=$date');
      var data = wrapData(response);
      for (var item in data) {
        item['first_class_ticket'] = item['first_class_ticket'].toString();
        item['second_class_ticket'] = item['second_class_ticket'].toString();
        item['third_class_ticket'] = item['third_class_ticket'].toString();
      }
      return data;
    } on DioError {
      rethrow;
    }
  }

  Future addTrain(number, date, stations) async {
    try {
      return await _dio.post('/trains/$number', data: {
        'date': formatDate(date, ['yyyy', '-', 'mm', '-', 'dd']),
        'through_stations': stations,
      });
    } on DioError {
      rethrow;
    }
  }

  Future getThroughStation(number, date) async {
    try {
      Response response = await _dio.get('/trains/$number/stations?date=$date');
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future searchTrainByTextAndDate(text, date) async {
    try {
      Response response = await _dio.get('/trains/search/$text?date=$date');
      var data = wrapData(response);
      for (var item in data) {
        item['first_class_ticket'] = item['first_class_ticket'].toString();
        item['second_class_ticket'] = item['second_class_ticket'].toString();
        item['third_class_ticket'] = item['third_class_ticket'].toString();
      }
      return data;
    } on DioError {
      rethrow;
    }
  }

  Future getScheduleTime(number, station, date) async {
    try {
      Response response =
          await _dio.get('/trains/$number/stations/$station?date=$date');
      return response.data[0];
    } on DioError {
      rethrow;
    }
  }

  Future deleteTrainByNumber(number, date) async {
    try {
      return await _dio.delete('/trains/$number?date=$date');
    } on DioError {
      rethrow;
    }
  }

  Future getPassengerByID(id) async {
    try {
      Response response = await _dio.get('/passengers/$id');
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future addPassengerByNumber(name, number, phone, id) async {
    try {
      return await _dio.post('/passengers/$number', data: {
        'name': name,
        'phone': phone,
        'id': id,
      });
    } on DioError {
      rethrow;
    }
  }

  Future deletePassengerByNumber(number) async {
    try {
      return await _dio.delete('/passengers/$number');
    } on DioError {
      rethrow;
    }
  }

  Future getTrainBetweenCities(start, end, date) async {
    try {
      Response response = await _dio.get('/trains/$start/to/$end?date=$date');
      return response.data[0]['get_train_number_by_cities'];
    } on DioError {
      rethrow;
    }
  }

  Future getTicketDetail(numbers, date, start, end) async {
    var data = [];
    for (var number in numbers) {
      await searchTicketByNumber(1, date, number).then((value) async {
        var ticketNumber = [];
        ticketNumber.add(value[0]['ticket_number']);
        await searchTicketByNumber(2, date, number).then((value) async {
          ticketNumber.add(value[0]['ticket_number']);
          await searchTicketByNumber(3, date, number).then((value) async {
            ticketNumber.add(value[0]['ticket_number']);
            var trainNumber = value[0]['train_number'];
            await getExactName(start, number, date).then((value) async {
              var startStation = value[0]['station_name'];
              await getExactName(end, number, date).then((value) async {
                var endStation = value[0]['station_name'];
                await getScheduleTime(trainNumber, startStation, date)
                    .then((value) async {
                  var startTime = value['arrive_time'] ?? value['depart_time'];
                  await getScheduleTime(trainNumber, endStation, date)
                      .then((value) {
                    var endTime = value['arrive_time'] ?? value['depart_time'];
                    data.add({
                      'start_station': startStation,
                      'end_station': endStation,
                      'start_time': startTime,
                      'end_time': endTime,
                      'ticket_number': ticketNumber,
                      'train_number': trainNumber
                    });
                  });
                });
              });
            });
          });
        });
      });
    }
    return data;
  }

  Future addOrder(card, id, start, end) async {
    try {
      Response response = await _dio.post('/orders/transaction',
          data: {'card': card, 'id': id, 'start': start, 'end': end});
      purchaseTicket(id, start, end);
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future getPassengerName(id) async {
    try {
      Response response = await _dio.get('/passengers/names/$id');
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future getPassengerCard(id, name) async {
    try {
      Response response = await _dio.get('/passengers/card/?id=$id&name=$name');
      return response.data['card_number'];
    } on DioError {
      rethrow;
    }
  }

  Future submitOrder(id, status) async {
    try {
      await _dio.post('/orders/$id/$status');
      if (status == 'error') {
        refundTicket(id);
      }
    } on DioError {
      rethrow;
    }
  }

  Future getAnyTicket(number, date, level) async {
    try {
      Response response = await _dio
          .get('/tickets/any/?number=$number&level=$level&date=$date');
      return response.data['ticket_id'];
    } on DioError {
      rethrow;
    }
  }

  Future getOrders(id, status) async {
    var datas = [];
    try {
      var names = await getPassengerName(id);
      for (var name in names) {
        await getPassengerCard(id, name).then((number) async {
          await _dio
              .get('/orders?number=$number&status=$status')
              .then((orders) async {
            for (var order in orders.data) {
              var order_id = order['order_id'];
              var created_at = DateTime.parse(order['created_at']);
              var time = created_at.toLocal().toString().substring(0, 16);
              var start_station = order['start_station'];
              var end_station = order['end_station'];
              await _dio
                  .get('/tickets/id/${order['ticket_id']}')
                  .then((ticket) async {
                var level = ticket.data['level'];
                var train_number = ticket.data['train_number'];
                await getPrice(start_station, end_station, level)
                    .then((value) => datas.add({
                          'start_station': start_station,
                          'end_station': end_station,
                          'level': level,
                          'train_number': train_number,
                          'order_id': order_id,
                          'time': time,
                          'created_at': created_at,
                          'name': name,
                          'price': value,
                        }));
              });
            }
          });
        });
      }
      return datas;
    } on DioError {
      rethrow;
    }
  }

  Future purchaseTicket(id, start, end) async {
    try {
      await _dio.post('/tickets/purchase/$id/$start/to/$end');
    } on DioError {
      rethrow;
    }
  }

  Future refundTicket(id) async {
    try {
      await _dio.post('/tickets/$id/refund');
    } on DioError {
      rethrow;
    }
  }

  Future getExactName(city, number, date) async {
    try {
      Response response =
          await _dio.get('/stations/city/$city?number=$number&date=$date');
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future getPrice(start, end, level) async {
    try {
      Response response =
          await _dio.get('/tickets/$start/to/$end?level=$level');
      return response.data;
    } on DioError {
      rethrow;
    }
  }

  Future migrate(date) async {
    try {
      await _dio.post('/migration?date=${date.add(const Duration(days: 1))}');
      return 'OK';
    } on DioError {
      rethrow;
    }
  }
}
