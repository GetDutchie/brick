import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:pizza_shoppe/brick/models/inventory.model.dart';

// Date,Item Name,Price,Profit,Units Sold,Tax Rate,Traffic Count
// https://aistudio.google.com/app/prompts/1vt4fnINIbiy_qmgSIHQHxa5YoNGXEjM9
@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'transaction_items'),
)
class TransactionItem extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;

  String name;
  int? quantityRequested;
  int? quantityApproved;
  int? quantityShipped;
  @Sqlite(index: true)
  String? transactionId;
  @Sqlite(index: true)
  String? variantId;
  // quantity
  double qty;
  double price;
  double discount;
  double? remainingStock;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isRefunded;

  /// property to help us adding new item to transaction
  bool? doneWithTransaction;
  bool? active;

  // RRA fields
  // discount rate
  double? dcRt;
  // discount amount
  double? dcAmt;

  double? taxblAmt;
  double? taxAmt;

  double? totAmt;

  /// properties from respective variants
  /// these properties will be populated when adding a variant to transactionItem from a variant
  /// I believe there can be a smart way to clean this duplicate code
  /// but I want things to work in first place then I can refactor later.
  /// add RRA fields
  int? itemSeq;
  // insurance code
  String? isrccCd;
  // insurance name
  String? isrccNm;
  // premium rate
  int? isrcRt;
  // insurance amount
  int? isrcAmt;
  // taxation type code.
  String? taxTyCd;
  // bar code
  String? bcd;
  // Item code
  String? itemClsCd;
  // Item type code
  String? itemTyCd;
  // Item standard name
  String? itemStdNm;
  // Item origin
  String? orgnNatCd;
  // packaging unit code
  String? pkg;
  // item code
  String? itemCd;

  String? pkgUnitCd;

  String? qtyUnitCd;
  // same as name but for rra happiness
  String itemNm;
  // unit price
  // check if prc is saved as same as retailPrice again this property is same as price on this model!
  double prc;
  // supply amount
  double? splyAmt;
  int? tin;
  String? bhfId;
  double? dftPrc;
  String? addInfo;
  String? isrcAplcbYn;
  String? useYn;
  String? regrId;
  String? regrNm;
  String? modrId;
  String? modrNm;

  DateTime? lastTouched;

  String? branchId;
  bool? ebmSynced;
  bool? partOfComposite;
  double? compositePrice;

  @Supabase(foreignKey: 'inventory_request_id')
  Inventory? inventoryRequest;

  // If the association will be created by the app, specify
  // a field that maps directly to the foreign key column
  // so that Brick can notify Supabase of the association.
  // @Sqlite(ignore: true)
  String? inventoryRequestId;

  @Sqlite(defaultValue: '0')
  bool? ignoreForReport;
  TransactionItem({
    this.splyAmt,
    this.inventoryRequest,
    required this.id,
    this.taxTyCd,
    this.bcd,
    this.itemClsCd,
    this.itemTyCd,
    this.itemStdNm,
    this.orgnNatCd,
    this.pkg,
    this.itemCd,
    this.pkgUnitCd,
    this.qtyUnitCd,
    required this.itemNm,
    this.tin,
    this.bhfId,
    this.dftPrc,
    this.addInfo,
    this.isrcAplcbYn,
    this.useYn,
    this.regrId,
    this.regrNm,
    this.modrId,
    this.modrNm,
    DateTime? lastTouched,
    this.branchId,
    this.ebmSynced,
    this.partOfComposite,
    this.compositePrice,
    required this.name,
    this.quantityRequested,
    this.quantityApproved,
    this.quantityShipped,
    this.transactionId,
    this.variantId,
    required this.qty,
    required this.price,
    required this.discount,
    this.remainingStock,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isRefunded,
    this.doneWithTransaction,
    this.active,
    this.dcRt,
    this.dcAmt,
    this.taxblAmt,
    this.taxAmt,
    this.totAmt,
    this.itemSeq,
    this.isrccCd,
    this.isrccNm,
    this.isrcRt,
    this.isrcAmt,
    String? inventoryRequestId,
    required this.prc,
    bool? ignoreForReport,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        ignoreForReport = false,
        lastTouched = lastTouched ?? DateTime.now().toUtc(),
        inventoryRequestId = inventoryRequest?.id,
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  // toJson method
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'transactionId': transactionId,
        'variantId': variantId,
        'qty': qty,
        'price': price,
        'discount': discount,
        'remainingStock': remainingStock,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'isRefunded': isRefunded,
        'doneWithTransaction': doneWithTransaction,
        'active': active,
        'dcRt': dcRt,
        'dcAmt': dcAmt,
        'taxblAmt': taxblAmt,
        'taxAmt': taxAmt,
        'totAmt': totAmt,
        'itemSeq': itemSeq,
        'isrccCd': isrccCd,
        'isrccNm': isrccNm,
        'isrcRt': isrcRt,
        'isrcAmt': isrcAmt,
        'taxTyCd': taxTyCd,
        'bcd': bcd,
        'itemClsCd': itemClsCd,
        'itemTyCd': itemTyCd,
        'itemStdNm': itemStdNm,
        'orgnNatCd': orgnNatCd,
        'pkg': pkg,
        'itemCd': itemCd,
        'pkgUnitCd': pkgUnitCd,
        'qtyUnitCd': qtyUnitCd,
        'itemNm': itemNm,
        'prc': prc,
        'splyAmt': splyAmt,
        'tin': tin,
        'bhfId': bhfId,
        'dftPrc': dftPrc,
        'addInfo': addInfo,
        'isrcAplcbYn': isrcAplcbYn,
        'useYn': useYn,
        'regrId': regrId,
        'regrNm': regrNm,
        'modrId': modrId,
        'modrNm': modrNm,
        'lastTouched': lastTouched,
        'branchId': branchId,
      };
  TransactionItem copyWith({
    String? id,
    double? qty,
    double? discount,
    double? remainingStock,
    String? itemCd,
    String? transactionId,
    String? variantId,
    String? qtyUnitCd,
    double? prc,
    String? regrId,
    String? regrNm,
    String? modrId,
    String? modrNm,
    String? name,
    int? quantityRequested,
    int? quantityApproved,
    int? quantityShipped,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRefunded,
    bool? doneWithTransaction,
    bool? active,
    double? dcRt,
    double? dcAmt,
    double? taxblAmt,
    double? taxAmt,
    double? totAmt,
    int? itemSeq,
    String? isrccCd,
    String? isrccNm,
    int? isrcRt,
    int? isrcAmt,
    String? taxTyCd,
    String? bcd,
    String? itemClsCd,
    String? itemTyCd,
    String? itemStdNm,
    String? orgnNatCd,
    String? pkg,
    String? pkgUnitCd,
    String? itemNm,
    double? splyAmt,
    int? tin,
    String? bhfId,
    double? dftPrc,
    String? addInfo,
    String? isrcAplcbYn,
    String? useYn,
    DateTime? lastTouched,
    String? branchId,
    bool? ebmSynced,
    bool? partOfComposite,
    double? compositePrice,
    Inventory? inventoryRequest,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      qty: qty ?? this.qty,
      discount: discount ?? this.discount,
      remainingStock: remainingStock ?? this.remainingStock,
      itemCd: itemCd ?? this.itemCd,
      transactionId: transactionId ?? this.transactionId,
      variantId: variantId ?? this.variantId,
      qtyUnitCd: qtyUnitCd ?? this.qtyUnitCd,
      prc: prc ?? this.prc,
      regrId: regrId ?? this.regrId,
      regrNm: regrNm ?? this.regrNm,
      modrId: modrId ?? this.modrId,
      modrNm: modrNm ?? this.modrNm,
      name: name ?? this.name,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      quantityApproved: quantityApproved ?? this.quantityApproved,
      quantityShipped: quantityShipped ?? this.quantityShipped,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRefunded: isRefunded ?? this.isRefunded,
      doneWithTransaction: doneWithTransaction ?? this.doneWithTransaction,
      active: active ?? this.active,
      dcRt: dcRt ?? this.dcRt,
      dcAmt: dcAmt ?? this.dcAmt,
      taxblAmt: taxblAmt ?? this.taxblAmt,
      taxAmt: taxAmt ?? this.taxAmt,
      totAmt: totAmt ?? this.totAmt,
      itemSeq: itemSeq ?? this.itemSeq,
      isrccCd: isrccCd ?? this.isrccCd,
      isrccNm: isrccNm ?? this.isrccNm,
      isrcRt: isrcRt ?? this.isrcRt,
      isrcAmt: isrcAmt ?? this.isrcAmt,
      taxTyCd: taxTyCd ?? this.taxTyCd,
      bcd: bcd ?? this.bcd,
      itemClsCd: itemClsCd ?? this.itemClsCd,
      itemTyCd: itemTyCd ?? this.itemTyCd,
      itemStdNm: itemStdNm ?? this.itemStdNm,
      orgnNatCd: orgnNatCd ?? this.orgnNatCd,
      pkg: pkg ?? this.pkg,
      pkgUnitCd: pkgUnitCd ?? this.pkgUnitCd,
      itemNm: itemNm ?? this.itemNm,
      splyAmt: splyAmt ?? this.splyAmt,
      tin: tin ?? this.tin,
      bhfId: bhfId ?? this.bhfId,
      dftPrc: dftPrc ?? this.dftPrc,
      addInfo: addInfo ?? this.addInfo,
      isrcAplcbYn: isrcAplcbYn ?? this.isrcAplcbYn,
      useYn: useYn ?? this.useYn,
      lastTouched: lastTouched ?? this.lastTouched,
      branchId: branchId ?? this.branchId,
      ebmSynced: ebmSynced ?? this.ebmSynced,
      partOfComposite: partOfComposite ?? this.partOfComposite,
      compositePrice: compositePrice ?? this.compositePrice,
      inventoryRequest: inventoryRequest ?? this.inventoryRequest,
    );
  }
}
