import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:pizza_shoppe/brick/models/branch.model.dart';
import 'package:pizza_shoppe/brick/models/financing.model.dart';

// import 'package:pizza_shoppe/brick/models/customer.model.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'inventories'),
)
class Inventory extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;
  int? mainBranchId;
  int? subBranchId;

  DateTime? createdAt;
  // e.g., "pending", "approved", "partiallyApproved", "rejected", "fulfilled"
  String? status;
  DateTime? deliveryDate;
  String? deliveryNote;
  String? orderNote;
  bool? customerReceivedOrder = false;
  bool? driverRequestDeliveryConfirmation = false;
  int? driverId;

  DateTime? updatedAt;
  num? itemCounts;

  String? bhfId;
  String? tinNumber;

  // stock financing
  @Supabase(foreignKey: 'financing_id')
  Financing? financing;
  String? financingId;
  @Supabase(foreignKey: 'branch_id')
  Branch? branch;

  // @Supabase(ignore: true)
  // List<TransactionItem>? transactionItems;

  // the requester same as subBranchId but this will use uuid representation of the subBranchId
  String? branchId;
  Inventory({
    required this.id,
    this.mainBranchId,
    this.bhfId,
    this.tinNumber,
    this.itemCounts,
    this.subBranchId,
    this.createdAt,
    this.status,
    required this.branchId,
    this.branch,
    this.deliveryDate,
    this.deliveryNote,
    // required this.financingId,
    this.orderNote,
    this.customerReceivedOrder,
    this.driverRequestDeliveryConfirmation,
    this.driverId,
    // this.transactionItems,
    this.updatedAt,
    // this.financing,
  });

  Future<Inventory> copyWith({
    Branch? branch,
    Financing? financing,
  }) async {
    return Inventory(
      id: id,
      mainBranchId: mainBranchId,
      subBranchId: subBranchId,
      branchId: branchId,
      createdAt: createdAt,
      status: status,
      deliveryDate: deliveryDate,
      deliveryNote: deliveryNote,
      // financingId: financingId,
      orderNote: orderNote,
      customerReceivedOrder: customerReceivedOrder,
      driverRequestDeliveryConfirmation: driverRequestDeliveryConfirmation,
      driverId: driverId,
      // transactionItems: transactionItems,
      updatedAt: updatedAt,
      itemCounts: itemCounts,
      bhfId: bhfId,
      tinNumber: tinNumber,
      // financing: financing,
      branch: branch,
    );
  }
}
