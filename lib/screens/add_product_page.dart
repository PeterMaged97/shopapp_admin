import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shop_app_admin/db/brand.dart';
import 'package:shop_app_admin/db/category.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop_app_admin/db/product.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  bool isLoading = false;
  BrandService _brandService = BrandService();
  ProductService _productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem<String>> categoriesDropDown =
      <DropdownMenuItem<String>>[];
  List<DropdownMenuItem<String>> brandsDropDown = <DropdownMenuItem<String>>[];
  String selectedCategory;
  String selectedBrand;
  List<String> selectedSizes = <String>[];
  List<File> images = List<File>(3);
  Widget defaultOutlineButtonChild = Container(
    child: Icon(Icons.add),
    height: 150,
    decoration: BoxDecoration(border: Border.all()),
  );
  bool onSale = false;
  bool featured = false;

  @override
  void initState() {
    super.initState();
    _getCategories().then((value) {
      categoriesDropDown = getCategoriesDropDown();
      selectedCategory = categoriesDropDown[0].value;
    });
    _getBrands().then((value) {
      brandsDropDown = getBrandsDropDown();
      selectedBrand = brandsDropDown[0].value;
    });
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    setState(() {
      categories = data;
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    setState(() {
      brands = data;
    });
  }

  List<DropdownMenuItem<String>> getCategoriesDropDown() {
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
    for (DocumentSnapshot category in categories) {
      items.add(DropdownMenuItem(
        child: Text(category['category']),
        value: category['category'],
      ));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
    for (DocumentSnapshot brand in brands) {
      items.add(DropdownMenuItem(
        child: Text(brand['brand']),
        value: brand['brand'],
      ));
    }
    return items;
  }

  void validateAndUpload() async {
    //print('------------CALLED---------------');
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      if (images[0] != null && images[1] != null && images[2] != null) {
        if (selectedSizes.isNotEmpty) {
          final FirebaseStorage storage = FirebaseStorage.instance;
          String imageURL1;
          String imageURL2;
          String imageURL3;

          final String picture1 =
              "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task1 = storage.ref().child(picture1).putFile(images[0]);

          final String picture2 =
              "2${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task2 = storage.ref().child(picture2).putFile(images[1]);

          final String picture3 =
              "3${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task3 = storage.ref().child(picture3).putFile(images[2]);

          // TaskSnapshot snapshot1 = await task1
          // TaskSnapshot snapshot2 = await task2.whenComplete(() => null).then((snapshot) => snapshot);

          imageURL1 = await (await task1).ref.getDownloadURL();
          imageURL2 = await (await task2).ref.getDownloadURL();
          imageURL3 = await (await task3).ref.getDownloadURL();
          // imageURL1 = await snapshot1.ref.getDownloadURL();
          // imageURL2 = await snapshot2.ref.getDownloadURL();
          // imageURL3 = await snapshot3.ref.getDownloadURL();

          print(imageURL1.toString());
          print(imageURL2.toString());
          print(imageURL3.toString());

          _productService.uploadProduct(
              name: productNameController.text,
              brand: selectedBrand,
              category: selectedCategory,
              sizes: selectedSizes,
              images: [imageURL1, imageURL2, imageURL3],
              price: double.parse(priceController.text),
              quantity: int.parse(quantityController.text),
              featured: featured,
              onSale: onSale,
          );
          //_formKey.currentState.reset();

          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'New product added');
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'You must select at least on size');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'You must provide 3 images for the product');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return categoriesDropDown.length != 0 && brandsDropDown.length != 0
        ? Theme(
            data: FlexColorScheme.light(scheme: FlexScheme.red).toTheme,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Scaffold(
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
                          child: Text(
                            'Product Images',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Source"),
                                              content:
                                                  Text("Choose image source"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Gallery"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .gallery),
                                                        0);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("Camera"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .camera),
                                                        0);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      //borderSide: BorderSide(color: Colors.grey, width: 2.5),
                                      child: images[0] == null
                                          ? defaultOutlineButtonChild
                                          : Container(
                                              child: Image.file(images[0]),
                                              height: 150,
                                              decoration: BoxDecoration(
                                                  border: Border.all()),
                                            )),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Source"),
                                              content:
                                                  Text("Choose image source"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Gallery"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .gallery),
                                                        1);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("Camera"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .camera),
                                                        1);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: images[1] == null
                                          ? defaultOutlineButtonChild
                                          : Container(
                                              child: Image.file(images[1]),
                                              height: 150,
                                              decoration: BoxDecoration(
                                                  border: Border.all()),
                                            )),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Source"),
                                              content:
                                                  Text("Choose image source"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Gallery"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .gallery),
                                                        2);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("Camera"),
                                                  onPressed: () {
                                                    selectImage(
                                                        ImagePicker().getImage(
                                                            source: ImageSource
                                                                .camera),
                                                        2);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: images[2] == null
                                          ? defaultOutlineButtonChild
                                          : Container(
                                              child: Image.file(images[2]),
                                              height: 150,
                                            )),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            hintText: 'Product Name',
                                            fillColor: Colors.white),
                                        controller: productNameController,
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
                                    Expanded(
                                        child: Row(
                                      children: [
                                        Checkbox(
                                            value: onSale,
                                            onChanged: (value) {
                                              setState(() {
                                                onSale = !onSale;
                                              });
                                            }),
                                        Container(child: Text('On Sale'))
                                      ],
                                    )),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Checkbox(
                                              value: featured,
                                              onChanged: (value) {
                                                setState(() {
                                                  featured = !featured;
                                                });
                                              }),
                                          Container(child: Text('Featured'))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    //mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Category: ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField(
                                            items: categoriesDropDown,
                                            value: selectedCategory,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white),
                                            onChanged: changeSelectedCategory),
                                      ),
                                      Expanded(
                                          child: Text('Brand: ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.red))),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField(
                                            items: brandsDropDown,
                                            value: selectedBrand,
                                            decoration: InputDecoration(
                                                fillColor: Colors.white),
                                            onChanged: changeSelectedBrand),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: quantityController,
                                          decoration: InputDecoration(
                                              hintText: 'Quantity',
                                              fillColor: Colors.white),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'You must enter a quantity';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: TextFormField(
                                          controller: priceController,
                                          decoration: InputDecoration(
                                              hintText: 'Price',
                                              fillColor: Colors.white),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                          ],
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'You must enter a price';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Available Sizes',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('S'),
                                            onChanged: (value) =>
                                                changeSelectedState('S')),
                                        Container(
                                          child: Text('S'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('M'),
                                            onChanged: (value) =>
                                                changeSelectedState('M')),
                                        Container(
                                          child: Text('M'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('L'),
                                            onChanged: (value) =>
                                                changeSelectedState('L')),
                                        Container(
                                          child: Text('L'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('XL'),
                                            onChanged: (value) =>
                                                changeSelectedState('XL')),
                                        Container(
                                          child: Text('XL'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('XL'),
                                            onChanged: (value) =>
                                                changeSelectedState('XL')),
                                        Container(
                                          child: Text('XXL'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('30'),
                                            onChanged: (value) =>
                                                changeSelectedState('30')),
                                        Container(
                                          child: Text('30'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('32'),
                                            onChanged: (value) =>
                                                changeSelectedState('32')),
                                        Container(
                                          child: Text('32'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('34'),
                                            onChanged: (value) =>
                                                changeSelectedState('34')),
                                        Container(
                                          child: Text('34'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('36'),
                                            onChanged: (value) =>
                                                changeSelectedState('36')),
                                        Container(
                                          child: Text('36'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                            value: selectedSizes.contains('38'),
                                            onChanged: (value) =>
                                                changeSelectedState('38')),
                                        Container(
                                          child: Text('38'),
                                          width: 30,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                MaterialButton(
                                  onPressed: validateAndUpload,
                                  child: Text('Add Product'),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        : Center(
            child: CircularProgressIndicator(
            strokeWidth: 2,
          ));
  }

  changeSelectedCategory(String cat) {
    setState(() {
      selectedCategory = cat;
    });
  }

  changeSelectedBrand(String brand) {
    setState(() {
      selectedBrand = brand;
    });
  }

  changeSelectedState(String s) {
    if (selectedSizes.contains(s)) {
      setState(() {
        selectedSizes.remove(s);
      });
    } else {
      setState(() {
        selectedSizes.add(s);
      });
    }
    print(selectedSizes);
  }

  void selectImage(Future<PickedFile> image, int index) async {
    images[index] = File(await image.then((value) => value.path));
    setState(() {});
  }
}
