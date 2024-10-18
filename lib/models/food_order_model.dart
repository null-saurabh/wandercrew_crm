import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusUpdate {
  String status;         // e.g., Pending, Confirmed, Preparing, Delivered etc.
  DateTime updatedTime;   // The time the status was updated
  String updatedBy;       // The person who updated the status (e.g., admin, user)

  OrderStatusUpdate({
    required this.status,
    required this.updatedTime,
    required this.updatedBy,
  });

  factory OrderStatusUpdate.fromMap(Map<String, dynamic> data) {
    return OrderStatusUpdate(
      status: data['status'],
      updatedTime: (data['updatedTime'] as Timestamp).toDate(),
      updatedBy: data['updatedBy'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'updatedTime': updatedTime,
      'updatedBy': updatedBy,
    };
  }
}



  class OrderedItemModel {
  String menuItemId;  // Reference to the MenuItem
  String menuItemName; // Name of the item
  int quantity;       // Quantity of the item ordered
  double price;       // Price of the item
  double totalPrice;  // quantity * price

  OrderedItemModel({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.price,
  }) : totalPrice = price * quantity;

  // Convert to map for Firebase or any other database storage
  Map<String, dynamic> toMap() {
    return {
      'menuItemId': menuItemId,
      'menuItemName': menuItemName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory OrderedItemModel.fromMap(Map<String, dynamic> data) {
    return OrderedItemModel(
      menuItemId: data['menuItemId'],
      menuItemName: data['menuItemName'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
    );
  }
}





class FoodOrderModel {

  String id;                       // Unique ID for each order
  String orderId;                       // Unique ID for each order
  String transactionId;                 // from razorpay
  String dinerName;// Reference to the user placing the order
  List<OrderStatusUpdate> orderStatusHistory;  // Track order status changes with time
  // String orderStatus;                   // e.g., Pending, Confirmed, Delivered, Cancelled
  List<OrderedItemModel> items;         // List of ordered items with details
  double totalAmount;                   // Total amount for the order
  String paymentMethod;                 // e.g., Card, Cash, UPI
  String orderDate;                     // Date and time of the order
  String deliveryAddress;               // Address where the order should be delivered
  String contactNumber;                 // Contact number for delivery updates
  String? specialInstructions;          // Any special instructions for the order
  double? discount;                     // Any discount applied to the order
  String? couponCode;                   // Coupon code applied, if any
  // String deliveryStatus;                // Status of delivery (e.g., Preparing, Out for Delivery, Delivered)
  String? estimatedDeliveryTime;         // Estimated time for delivery
  String paymentStatus;                 // e.g., Paid, Unpaid, Pending
  DateTime? createdAt;                  // Timestamp when the order was created
  DateTime? updatedAt;                  // Timestamp when the order was last updated
  bool isCancelled;
  String? isRefunded;
  int? refundAmount;
  FoodOrderModel({
    required this.id,
    required this.orderId,
    required this.transactionId,
    required this.dinerName,
    required this.orderStatusHistory,
    // required this.orderStatus,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.deliveryAddress,
    required this.contactNumber,
    this.specialInstructions,
    this.discount,
    this.couponCode,
    // required this.deliveryStatus,
    this.estimatedDeliveryTime,
    required this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.isCancelled = false,
    this.isRefunded,
    this.refundAmount
  });

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'transactionId': transactionId,
      'dinerName': dinerName,
      // 'orderStatus': orderStatus,
      'orderStatusHistory': orderStatusHistory.map((status) => status.toMap()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate,
      'deliveryAddress': deliveryAddress,
      'contactNumber': contactNumber,
      'specialInstructions': specialInstructions,
      'discount': discount,
      'couponCode': couponCode,
      // 'deliveryStatus': deliveryStatus,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'paymentStatus': paymentStatus,
      'isCancelled': isCancelled,
      'isRefunded': isRefunded,
      'refundAmount': refundAmount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }


  factory FoodOrderModel.fromMap(Map<String, dynamic> data) {
    return FoodOrderModel(
      orderId: data['orderId'],
      id: data['id'],
      transactionId: data['transactionId'],
      dinerName: data['dinerName'],
      orderStatusHistory: List<OrderStatusUpdate>.from(
          data['orderStatusHistory'].map((status) => OrderStatusUpdate.fromMap(status))
      ),
      items: List<OrderedItemModel>.from(
          data['items'].map((item) => OrderedItemModel.fromMap(item))
      ),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      paymentMethod: data['paymentMethod'],
      orderDate: data['orderDate'],
      deliveryAddress: data['deliveryAddress'],
      contactNumber: data['contactNumber'],
      specialInstructions: data['specialInstructions'],
      discount: data['discount'] != null ? (data['discount'] as num).toDouble() : null,
      refundAmount: data['refundAmount'] != null ? (data['refundAmount'] as num).toInt() : null,
      couponCode: data['couponCode'],
      // deliveryStatus: data['deliveryStatus'],
      estimatedDeliveryTime: data['estimatedDeliveryTime'],
      isRefunded: data['isRefunded'],
      paymentStatus: data['paymentStatus'],
      isCancelled: data['isCancelled'] != null ? data['isCancelled'] : false,
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }


}
