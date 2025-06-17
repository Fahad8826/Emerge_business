import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emerge_business/Product/productList.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProductPage extends StatefulWidget {
  final Product product;
  final VoidCallback onUpdate;

  const EditProductPage({
    Key? key,
    required this.product,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _weightController;
  late TextEditingController _foodTypeController;
  late TextEditingController _ingredientsController;
  late TextEditingController _preparationTimeController;
  late TextEditingController _cuisineTypeController;
  late TextEditingController _allergenInfoController;
  late TextEditingController _serviceTypeController;
  late TextEditingController _serviceDurationController;
  late TextEditingController _serviceAreaController;
  late TextEditingController _experienceController;
  late TextEditingController _certificationsController;
  late TextEditingController _toolsRequiredController;

  bool _isAvailable = true;
  bool _isLoading = false;
  List<File> _selectedImages = [];
  List<String> _imageUrls = [];
  bool _isUploadingImages = false;

  List<String> categories = [
    'Food Items',
    'E-commerce Products',
    'Services',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Sports',
    'Books',
    'Toys',
    'Beauty',
    'Automotive',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _categoryController = TextEditingController(text: widget.product.category);
    _stockQuantityController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '',
    );
    _brandController = TextEditingController(text: widget.product.brand ?? '');
    _sizeController = TextEditingController(text: widget.product.size ?? '');
    _weightController = TextEditingController(
      text: widget.product.weight?.toString() ?? '',
    );
    _foodTypeController = TextEditingController(
      text: widget.product.foodType ?? '',
    );
    _ingredientsController = TextEditingController(
      text: widget.product.ingredients ?? '',
    );
    _preparationTimeController = TextEditingController(
      text: widget.product.preparationTime?.toString() ?? '',
    );
    _cuisineTypeController = TextEditingController(
      text: widget.product.cuisineType ?? '',
    );
    _allergenInfoController = TextEditingController(
      text: widget.product.allergenInfo ?? '',
    );
    _serviceTypeController = TextEditingController(
      text: widget.product.serviceType ?? '',
    );
    _serviceDurationController = TextEditingController(
      text: widget.product.serviceDuration?.toString() ?? '',
    );
    _serviceAreaController = TextEditingController(
      text: widget.product.serviceArea ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.product.experience?.toString() ?? '',
    );
    _certificationsController = TextEditingController(
      text: widget.product.certifications ?? '',
    );
    _toolsRequiredController = TextEditingController(
      text: widget.product.toolsRequired ?? '',
    );

    _isAvailable = widget.product.isAvailable;
    _imageUrls = List<String>.from(widget.product.images);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockQuantityController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _weightController.dispose();
    _foodTypeController.dispose();
    _ingredientsController.dispose();
    _preparationTimeController.dispose();
    _cuisineTypeController.dispose();
    _allergenInfoController.dispose();
    _serviceTypeController.dispose();
    _serviceDurationController.dispose();
    _serviceAreaController.dispose();
    _experienceController.dispose();
    _certificationsController.dispose();
    _toolsRequiredController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImage(File? imageFile, String? currentUrl) async {
    if (imageFile == null) return currentUrl;

    setState(() => _isUploadingImages = true);
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/delatrx6q/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'emerge'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData)['secure_url'];
      }
      throw Exception('Upload failed with status ${response.statusCode}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return currentUrl;
    } finally {
      if (mounted) setState(() => _isUploadingImages = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index, {bool isUrl = false}) {
    setState(() {
      if (isUrl) {
        _imageUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index);
      }
    });
  }

  Widget _buildImageSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              Spacer(),
              if (_isUploadingImages)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          SizedBox(height: 12),

          // Display existing images from URLs
          if (_imageUrls.isNotEmpty) ...[
            Text(
              'Current Images:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _imageUrls[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(Icons.image, color: Colors.grey[400]),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index, isUrl: true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],

          // Display selected new images
          if (_selectedImages.isNotEmpty) ...[
            Text(
              'New Images to Upload:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],

          // Add image button
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[400]!,
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add Image',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images to Cloudinary
      List<String> uploadedUrls = [];
      for (File imageFile in _selectedImages) {
        String? uploadedUrl = await _uploadImage(imageFile, null);
        if (uploadedUrl != null) {
          uploadedUrls.add(uploadedUrl);
        }
      }

      // Combine existing URLs with new uploaded URLs
      List<String> allImageUrls = [..._imageUrls, ...uploadedUrls];

      // Create updated product
      Product updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        isAvailable: _isAvailable,
        images: allImageUrls,
        vendorId: widget.product.vendorId,
        createdAt: widget.product.createdAt,
        // Category-specific fields
        foodType: _foodTypeController.text.isEmpty
            ? null
            : _foodTypeController.text,
        ingredients: _ingredientsController.text.isEmpty
            ? null
            : _ingredientsController.text,
        preparationTime: _preparationTimeController.text.isEmpty
            ? null
            : int.tryParse(_preparationTimeController.text),
        cuisineType: _cuisineTypeController.text.isEmpty
            ? null
            : _cuisineTypeController.text,
        allergenInfo: _allergenInfoController.text.isEmpty
            ? null
            : _allergenInfoController.text,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        stockQuantity: _stockQuantityController.text.isEmpty
            ? null
            : int.tryParse(_stockQuantityController.text),
        size: _sizeController.text.isEmpty ? null : _sizeController.text,
        weight: _weightController.text.isEmpty
            ? null
            : double.tryParse(_weightController.text),
        serviceType: _serviceTypeController.text.isEmpty
            ? null
            : _serviceTypeController.text,
        serviceDuration: _serviceDurationController.text.isEmpty
            ? null
            : int.tryParse(_serviceDurationController.text),
        serviceArea: _serviceAreaController.text.isEmpty
            ? null
            : _serviceAreaController.text,
        experience: _experienceController.text.isEmpty
            ? null
            : int.tryParse(_experienceController.text),
        certifications: _certificationsController.text.isEmpty
            ? null
            : _certificationsController.text,
        toolsRequired: _toolsRequiredController.text.isEmpty
            ? null
            : _toolsRequiredController.text,
      );

      // Update in Firestore
      await _firestore
          .collection('Products')
          .doc(widget.product.id)
          .update(updatedProduct.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onUpdate();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProduct,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: categories.contains(_categoryController.text)
                                ? _categoryController.text
                                : categories.first,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              _categoryController.text = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockQuantityController,
                            decoration: InputDecoration(
                              labelText: 'Stock Quantity',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: SwitchListTile(
                            title: Text('Available'),
                            value: _isAvailable,
                            onChanged: (value) {
                              setState(() {
                                _isAvailable = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Image Section
                    _buildImageSection(),
                    SizedBox(height: 24),

                    // Category-specific fields
                    if (_categoryController.text == 'Food Items') ...[
                      Text(
                        'Food Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[600],
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _foodTypeController,
                        decoration: InputDecoration(
                          labelText: 'Food Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fastfood),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _cuisineTypeController,
                        decoration: InputDecoration(
                          labelText: 'Cuisine Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _ingredientsController,
                        decoration: InputDecoration(
                          labelText: 'Ingredients',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.eco),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _preparationTimeController,
                              decoration: InputDecoration(
                                labelText: 'Preparation Time (minutes)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _allergenInfoController,
                        decoration: InputDecoration(
                          labelText: 'Allergen Information',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.warning),
                        ),
                      ),
                    ],

                    if (_categoryController.text == 'E-commerce Products') ...[
                      Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _brandController,
                        decoration: InputDecoration(
                          labelText: 'Brand',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sizeController,
                              decoration: InputDecoration(
                                labelText: 'Size',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_categoryController.text == 'Services') ...[
                      Text(
                        'Service Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[600],
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _serviceTypeController,
                        decoration: InputDecoration(
                          labelText: 'Service Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.build),
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _serviceDurationController,
                              decoration: InputDecoration(
                                labelText: 'Duration (hours)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _experienceController,
                              decoration: InputDecoration(
                                labelText: 'Experience (years)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _serviceAreaController,
                        decoration: InputDecoration(
                          labelText: 'Service Area',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _certificationsController,
                        decoration: InputDecoration(
                          labelText: 'Certifications',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.verified),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _toolsRequiredController,
                        decoration: InputDecoration(
                          labelText: 'Tools Required',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.handyman),
                        ),
                      ),
                    ],

                    SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'UPDATE PRODUCT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
