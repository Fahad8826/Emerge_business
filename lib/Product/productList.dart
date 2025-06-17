
import 'package:emerge_business/Product/editproduct.dart';
import 'package:emerge_business/Product/productdetails.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  String name;
  String description;
  double price;
  String category;
  bool isAvailable;
  List<String> images;
  String vendorId;
  DateTime? createdAt;

  // Category-specific fields
  String? foodType;
  String? ingredients;
  int? preparationTime;
  String? cuisineType;
  String? allergenInfo;
  String? brand;
  int? stockQuantity;
  String? size;
  double? weight;
  String? dimensions;
  String? material;
  String? color;
  String? serviceType;
  int? serviceDuration;
  String? serviceArea;
  int? experience;
  String? certifications;
  String? toolsRequired;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.images,
    required this.vendorId,
    this.createdAt,
    this.foodType,
    this.ingredients,
    this.preparationTime,
    this.cuisineType,
    this.allergenInfo,
    this.brand,
    this.stockQuantity,
    this.size,
    this.weight,
    this.dimensions,
    this.material,
    this.color,
    this.serviceType,
    this.serviceDuration,
    this.serviceArea,
    this.experience,
    this.certifications,
    this.toolsRequired,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      images: List<String>.from(data['images'] ?? []),
      vendorId: data['vendorId'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      foodType: data['foodType'],
      ingredients: data['ingredients'],
      preparationTime: data['preparationTime'],
      cuisineType: data['cuisineType'],
      allergenInfo: data['allergenInfo'],
      brand: data['brand'],
      stockQuantity: data['stockQuantity'],
      size: data['size'],
      weight: data['weight']?.toDouble(),
      dimensions: data['dimensions'],
      material: data['material'],
      color: data['color'],
      serviceType: data['serviceType'],
      serviceDuration: data['serviceDuration'],
      serviceArea: data['serviceArea'],
      experience: data['experience'],
      certifications: data['certifications'],
      toolsRequired: data['toolsRequired'],
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'images': images,
      'vendorId': vendorId,
    };

    if (foodType != null) data['foodType'] = foodType;
    if (ingredients != null) data['ingredients'] = ingredients;
    if (preparationTime != null) data['preparationTime'] = preparationTime;
    if (cuisineType != null) data['cuisineType'] = cuisineType;
    if (allergenInfo != null) data['allergenInfo'] = allergenInfo;
    if (brand != null) data['brand'] = brand;
    if (stockQuantity != null) data['stockQuantity'] = stockQuantity;
    if (size != null) data['size'] = size;
    if (weight != null) data['weight'] = weight;
    if (dimensions != null) data['dimensions'] = dimensions;
    if (material != null) data['material'] = material;
    if (color != null) data['color'] = color;
    if (serviceType != null) data['serviceType'] = serviceType;
    if (serviceDuration != null) data['serviceDuration'] = serviceDuration;
    if (serviceArea != null) data['serviceArea'] = serviceArea;
    if (experience != null) data['experience'] = experience;
    if (certifications != null) data['certifications'] = certifications;
    if (toolsRequired != null) data['toolsRequired'] = toolsRequired;

    return data;
  }
}

class VendorInfo {
  final String id;
  final String name;
  final String email;

  VendorInfo({required this.id, required this.name, required this.email});
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  Map<String, VendorInfo> vendorCache = {};
  String searchQuery = '';
  String selectedVendor = 'All';
  String selectedCategory = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot productSnapshot = await _firestore
          .collection('Products')
          .orderBy('createdAt', descending: true)
          .get();

      List<Product> products = [];
      Set<String> uniqueProductKeys = Set<String>();

      for (QueryDocumentSnapshot doc in productSnapshot.docs) {
        Product product = Product.fromFirestore(doc);

        String uniqueKey =
            '${product.name.toLowerCase()}_${product.vendorId}_${product.price}';

        if (!uniqueProductKeys.contains(uniqueKey)) {
          uniqueProductKeys.add(uniqueKey);
          products.add(product);
        }
      }

      setState(() {
        allProducts = products;
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        String vendorName =
            vendorCache[product.vendorId]?.name ?? 'Unknown Vendor';

        bool matchesSearch =
            product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            vendorName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
        bool matchesVendor =
            selectedVendor == 'All' || vendorName == selectedVendor;
        bool matchesCategory =
            selectedCategory == 'All' || product.category == selectedCategory;

        return matchesSearch &&
            matchesVendor &&
            matchesCategory &&
            product.isAvailable;
      }).toList();
    });
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('Products').doc(productId).delete();

      setState(() {
        allProducts.removeWhere((product) => product.id == productId);
        _filterProducts();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(product.id);
              },
            ),
          ],
        );
      },
    );
  }

  List<String> get categories {
    List<String> categoryList = ['All'];
    Set<String> uniqueCategories = allProducts.map((p) => p.category).toSet();
    categoryList.addAll(uniqueCategories.toList()..sort());
    return categoryList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Lists'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          _filterProducts();
                        },
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                                _filterProducts();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredProducts.length} products found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final vendorName =
                                vendorCache[product.vendorId]?.name ??
                                'Unknown Vendor';

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        product: product,
                                        vendorName: vendorName,
                                        onUpdate: _loadProducts,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Product Image Thumbnail
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey[200],
                                        ),
                                        child: product.images.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  product.images[0],
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                            size: 40,
                                                          ),
                                                        );
                                                      },
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value:
                                                            loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              ),
                                      ),
                                      SizedBox(width: 12),
                                      // Product Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                product.category,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  '\$${product.price.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[600],
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                if (product.stockQuantity !=
                                                    null)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          product.stockQuantity! >
                                                              20
                                                          ? Colors.green[100]
                                                          : product.stockQuantity! >
                                                                10
                                                          ? Colors.orange[100]
                                                          : Colors.red[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'Stock: ${product.stockQuantity}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            product.stockQuantity! >
                                                                20
                                                            ? Colors.green[800]
                                                            : product.stockQuantity! >
                                                                  10
                                                            ? Colors.orange[800]
                                                            : Colors.red[800],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Action Buttons
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.visibility,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductDetailPage(
                                                        product: product,
                                                        vendorName: vendorName,
                                                        onUpdate: _loadProducts,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProductPage(
                                                        product: product,
                                                        onUpdate: _loadProducts,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _showDeleteDialog(product),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
