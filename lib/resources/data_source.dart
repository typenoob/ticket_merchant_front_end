import 'package:flutter/material.dart';

class DataSource extends DataTableSource {
  List<dynamic> value;
  List<String> names;
  bool exclusive;
  DataSource(this.value, this.names, {this.exclusive = false});
  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      selected: value[index]['selected'],
      index: index,
      cells: [
            DataCell(
              InkWell(
                onTap: () {
                  value[index]['selected'] = !value[index]['selected'];
                  if (exclusive) {
                    for (var i = 0; i < value.length; i++) {
                      if (i != index) {
                        value[i]['selected'] = false;
                      }
                    }
                  }
                  notifyListeners();
                },
                child: value[index]['selected']
                    ? const Icon(Icons.check_box_outlined)
                    : const Icon(Icons.check_box_outline_blank),
              ),
            ),
          ] +
          List.generate(names.length,
              (_index) => DataCell(Text(value[index][names[_index]]))),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => value.length;

  @override
  int get selectedRowCount => 0;
}
