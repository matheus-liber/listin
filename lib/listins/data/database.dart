import "dart:io";

import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" as path;
import "package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart";

import "../models/listin.dart";

part 'database.g.dart';

class ListinTable extends Table {
  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get name => text().named('name').withLength(min: 4, max: 30)();
  TextColumn get obs => text().named('obs')();
  DateTimeColumn get dateCreate => dateTime().named('dateCreate')();
  DateTimeColumn get dateUpdate => dateTime().named('dateUpdate')();
}

@DriftDatabase(tables: [ListinTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertListin(Listin listin) async {
    ListinTableCompanion novaLinha = ListinTableCompanion(
        name: Value(listin.name),
        obs: Value(listin.obs),
        dateCreate: Value(listin.dateCreate),
        dateUpdate: Value(listin.dateUpdate));
    return await into(listinTable).insert(novaLinha);
  }

  Future<bool> updateListin(Listin listin) async {
    return await update(listinTable).replace(ListinTableCompanion(
        id: Value(int.parse(listin.id)),
        name: Value(listin.name),
        obs: Value(listin.obs),
        dateCreate: Value(listin.dateCreate),
        dateUpdate: Value(listin.dateUpdate)));
  }

  Future<int> deleteListin(int id) async {
    return await (delete(listinTable)..where((row) => row.id.equals(id))).go();
  }

  Future<List<Listin>> getListins({String orderBy = ''}) async {
    List<Listin> temp = [];

    final query = select(listinTable);

    if (orderBy == 'name') {
      query.orderBy(
          [(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);
    } else if (orderBy == 'dateUpdate') {
      query.orderBy([
        (t) => OrderingTerm(expression: t.dateUpdate, mode: OrderingMode.desc)
      ]);
    }

    List<ListinTableData> listinData = await query.get();

    for (ListinTableData row in listinData) {
      temp.add(Listin(
        id: row.id.toString(),
        name: row.name,
        obs: row.obs,
        dateCreate: row.dateCreate,
        dateUpdate: row.dateUpdate,
      ));
    }

    return temp;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, "db.sqlite"));

// Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
