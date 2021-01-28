import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void createBrand(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection('brands').doc(brandId).set({'brand': name});
  }
}