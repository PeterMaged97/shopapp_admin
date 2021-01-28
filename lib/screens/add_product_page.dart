import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropDownMenuItem>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropDownMenuItem>[];
  String selectedCategory;
  String selectedBrand;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlexColorScheme.light(scheme: FlexScheme.red).toTheme,
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          //backgroundColor: Colors.white,
          leading: InkWell(
            child: Icon(Icons.close),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Add Product',
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      child: Icon(Icons.add),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.8), width: 1)),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Container(
                      height: 150,
                      child: Icon(Icons.add),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.8), width: 1)),
                    ),
                  ),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Container(
                      height: 150,
                      child: Icon(Icons.add),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(0.8), width: 1)),
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                      hintText: 'Product Name',
                      ),
                  //controller: _passwordEditingController,
                  //obscureText: !showPassword,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You must enter a product name';
                    } else if (value.length > 10) {
                      return 'The product name must not exceed 10 characters';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
