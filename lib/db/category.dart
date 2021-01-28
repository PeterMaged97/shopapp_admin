import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

class CategoryService{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void createCategory(String name){
  var id = Uuid();
  String categoryId = id.v1();

  try{
    _firestore.collection('categories').doc(categoryId).set({'category': name});
  }catch(e){
    print(e);
  }

  }
}