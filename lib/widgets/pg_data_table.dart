import 'package:flutter/material.dart';

class PgDataTable extends StatefulWidget {
  static const perPage = 10;
  final List<String> labels;
  final List<dynamic> data;
  final String title;
  final double columnSpacing;
  ValueChanged<bool> onAllSelected;
  ValueChanged<int> onPageChanged;
  DataTableSource dataTableSource;
  late bool allSelected = false, exclusive = false;
  int currentPage = 1;
  PgDataTable(
      this.labels,
      this.title,
      this.data,
      this.columnSpacing,
      this.dataTableSource,
      this.allSelected,
      this.onPageChanged,
      this.onAllSelected,
      {Key? key,
      this.exclusive = false})
      : super(key: key);
  @override
  _PgDataTableState createState() => _PgDataTableState();
}

class _PgDataTableState extends State<PgDataTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: PaginatedDataTable(
          showFirstLastButtons: true,
          columnSpacing: widget.columnSpacing,
          rowsPerPage: PgDataTable.perPage,
          header: Center(child: Text(widget.title)),
          columns: [
                DataColumn(
                    label: InkWell(
                        onTap: () {
                          widget.onAllSelected(widget.allSelected);
                        },
                        child: widget.allSelected
                            ? const Icon(Icons.check_box_outlined)
                            : const Icon(
                                Icons.check_box_outline_blank_outlined))),
              ] +
              List.generate(widget.labels.length,
                  (index) => DataColumn(label: Text(widget.labels[index]))),
          source: widget.dataTableSource,
          onPageChanged: (page) {
            widget.onPageChanged(page ~/ PgDataTable.perPage + 1);
          },
        ));
  }
}
