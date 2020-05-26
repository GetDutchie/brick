import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';

abstract class RequestSqliteDbInteractor {
  /// Access the [SQLite](https://github.com/tekartik/sqflite/tree/master/sqflite_common_ffi),
  /// instance agnostically across platforms. If [databaseFactory] is null, the default
  /// Flutter SQFlite will be used.
  @protected
  final DatabaseFactory databaseFactory;

  /// The file name for the database used.
  ///
  /// When [databaseFactory] is present, this is the **entire** path name.
  /// With [databaseFactory], this is most commonly the
  /// `sqlite_common` constant `inMemoryDatabasePath`.
  final String databaseName;

  Database _db;

  RequestSqliteDbInteractor({
    this.databaseName,
    this.databaseFactory,
  });

  @protected
  Future<Database> getDb() async {
    if (_db?.isOpen == true) return _db;

    if (databaseFactory != null) {
      return _db = await databaseFactory.openDatabase(databaseName);
    }

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, databaseName);

    return _db = await openDatabase(path);
  }
}
