//import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:startup_namer/dbHelper/constant.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    userCollection = db.collection(USER_COLLECTION);
  }

  static query(month, day, time) async {
    
    List<voltageData> columnData = <voltageData>[];

    await userCollection
        .find(where.eq("day", day).eq("month", month).lt("time", time))
        .forEach((v) =>
            columnData.add(voltageData(double.parse(v["volt"]), v["time"])));

    /* for (var i = 0; i < columnData.length; i++) {
      print(columnData[i].volt);
      print(columnData[i].time);
    } */

    return columnData;
  }
}

class voltageData {
  voltageData(this.volt, this.time);
  final double volt;
  final String time;
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
