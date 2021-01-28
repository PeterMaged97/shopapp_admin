import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'brands';

  void createBrand(String name){
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection(ref).doc(brandId).set({'brand': name});
    Future<List<DocumentSnapshot>> getBrands(){
      return _firestore.collection(ref).get().then((snaps) => snaps.docs);
    }
  }
}