import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shop_app_admin/db/brand.dart';
import 'package:shop_app_admin/db/category.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  List<String> selectedSizes = <String>[];

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
              padding: const EdgeInsets.only(top: 8),
              child: Text('Product Images', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 18),),
            ),
            Flexible(
              child: Padding(
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
            ),
            //Divider(color: Colors.black, thickness: 2,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Product Name',
                          fillColor: Colors.white
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
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text('Category: ', textAlign: TextAlign.center, style: TextStyle(color: Colors.red),),),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField(items: categoriesDropDown,
                                value: selectedCategory,
                                decoration: InputDecoration(
                                    fillColor: Colors.white
                                ),
                                onChanged: changeSelectedCategory
                            ),
                          ),
                          Expanded(child: Text('Brand: ', textAlign: TextAlign.center, style: TextStyle(color: Colors.red))),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField(items: brandsDropDown,
                                value: selectedBrand,
                                decoration: InputDecoration(
                                    fillColor: Colors.white
                                ),
                                onChanged: changeSelectedBrand
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Quantity',
                            fillColor: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'You must enter a quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Available Sizes', style: TextStyle(color: Colors.red),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: selectedSizes.contains('S'), onChanged: (value)=> changeSelectedState('S')),
                            Text('S')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(value: selectedSizes.contains('M'), onChanged: (value)=> changeSelectedState('M')),
                            Text('M')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(value: selectedSizes.contains('L'), onChanged: (value)=> changeSelectedState('L')),
                            Text('L')
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(value: selectedSizes.contains('XL'), onChanged: (value)=> changeSelectedState('XL')),
                            Text('XL')
                          ],
                        ),

                      ],
                    )
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

  changeSelectedState(String s) {
    if(selectedSizes.contains(s)){
      setState(() {
        selectedSizes.remove(s);
      });
    }else{
      setState(() {
        selectedSizes.add(s);
      });
    }
    print(selectedSizes);
  }

}
