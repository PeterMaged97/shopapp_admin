import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'products';

  void uploadProduct(
      {
        @required String name,
        @required String brand,
        @required String category,
        @required List sizes,
        @required String imageURL,
        @required double price,
        @required int quantity,
        @required bool onSale,
        @required bool featured,
      })
  {
    var id = Uuid();
    String productId = id.v1();

    _firestore.collection(ref).doc(productId).set(
      {
        'name': name,
        'brand': brand,
        'category': category,
        'sizes': sizes,
        'image': imageURL,
        'price': price,
        'quantity': quantity,
        'on sale': onSale,
        'featured': featured,
        'id': productId,
      }
    );
  }

  Future<List<DocumentSnapshot>> getBrands(){
    return _firestore.collection(ref).get().then((snaps) => snaps.docs);
  }
}