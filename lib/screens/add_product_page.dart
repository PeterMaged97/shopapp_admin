import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shop_app_admin/db/brand.dart';
import 'package:shop_app_admin/db/category.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown = <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String selectedCategory;
  String selectedBrand;

  @override
  void initState() {
    super.initState();
    _getCategories().then((value){
      categoriesDropDown = getCategoriesDropDown();
      selectedCategory = categoriesDropDown[0].value;
    });
    _getBrands().then((value){
      brandsDropDown = getBrandsDropDown();
      selectedBrand = brandsDropDown[0].value;
    });
  }

  _getCategories() async{
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    setState(() {
      categories = data;
    });
  }
  _getBrands() async{
    List<DocumentSnapshot> data = await _brandService.getBrands();
    setState(() {
      brands = data;
    });
  }

  List<DropdownMenuItem<String>> getCategoriesDropDown(){
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
    for (DocumentSnapshot category in categories){
      items.add(DropdownMenuItem(child: Text(category['category']), value: category['category'],));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown(){
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
    for (DocumentSnapshot brand in brands){
      items.add(DropdownMenuItem(child: Text(brand['brand']), value: brand['brand'],));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return categoriesDropDown.length != 0 && brandsDropDown.length != 0 ? Theme(
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
                child: Column(
                  children: [
                    TextFormField(
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
                    DropdownButtonFormField(items: categoriesDropDown,
                        value: selectedCategory,
                        onChanged: changeSelectedCategory
                    ),
                    DropdownButtonFormField(items: brandsDropDown,
                        value: selectedBrand,
                        onChanged: changeSelectedBrand
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ) : Center(child: CircularProgressIndicator(strokeWidth: 2,));
  }
  changeSelectedCategory(String cat){
    setState(() {
      selectedCategory = cat;
    });
  }

  changeSelectedBrand(String brand){
    setState(() {
      selectedBrand = brand;
    });
  }

}
