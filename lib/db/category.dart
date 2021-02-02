import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ref = 'categories';

  void createCategory(String name){
    var id = Uuid();
    String categoryId = id.v1();

    _firestore.collection(ref).doc(categoryId).set({'category': name}).then((v) => print('Done'));
  }

  Future<List<DocumentSnapshot>> getCategories() async{
    List<DocumentSnapshot> data = await _firestore.collection(ref).get().then((snaps) => snaps.docs);
    print(data.length);
    return data;
  }

  Future<List<DocumentSnapshot>> getSuggestions(String suggestion) async{
    return _firestore.collection(ref).where('category', arrayContains: suggestion).get().then((snap) => snap.docs);
  }
}