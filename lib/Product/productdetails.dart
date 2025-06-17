import 'package:cached_network_image/cached_network_image.dart';
import 'package:emerge_business/Product/editproduct.dart';
import 'package:emerge_business/Product/productList.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String vendorName;
  final VoidCallback onUpdate;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.vendorName,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            Container(
              height: 250,
              child: widget.product.images.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: widget.product.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.product.images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
            ),

            if (widget.product.images.length > 1)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Colors.blue[600]
                            : Colors.blue[200],
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 20),

            // Product Name
            Text(
              widget.product.name.isNotEmpty
                  ? widget.product.name
                  : 'Unnamed Product',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Vendor
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.vendorName.isNotEmpty ? widget.vendorName : 'Unknown Vendor',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Price and Stock
            Row(
              children: [
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                Spacer(),
                if (widget.product.stockQuantity != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.product.stockQuantity! > 20
                          ? Colors.green[100]
                          : widget.product.stockQuantity! > 10
                              ? Colors.orange[100]
                              : Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.product.stockQuantity} in stock',
                      style: TextStyle(
                        color: widget.product.stockQuantity! > 20
                            ? Colors.green[800]
                            : widget.product.stockQuantity! > 10
                                ? Colors.orange[800]
                                : Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),

            // Category
            _buildDetailRow('Category', widget.product.category.isNotEmpty
                ? widget.product.category
                : 'Uncategorized'),
            SizedBox(height: 12),

            // Description
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.product.description.isNotEmpty
                  ? widget.product.description
                  : 'No description available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            // Category-specific details
            if (widget.product.category == 'Food Items') ...[
              SizedBox(height: 20),
              Text(
                'Food Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (widget.product.foodType != null)
                _buildDetailRow('Food Type', widget.product.foodType!),
              if (widget.product.cuisineType != null)
                _buildDetailRow('Cuisine Type', widget.product.cuisineType!),
              if (widget.product.ingredients != null)
                _buildDetailRow('Ingredients', widget.product.ingredients!),
              if (widget.product.preparationTime != null)
                _buildDetailRow(
                  'Preparation Time',
                  '${widget.product.preparationTime} minutes',
                ),
              if (widget.product.allergenInfo != null)
                _buildDetailRow('Allergen Info', widget.product.allergenInfo!),
            ],

            if (widget.product.category == 'E-commerce Products') ...[
              SizedBox(height: 20),
              Text(
                'Product Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (widget.product.brand != null)
                _buildDetailRow('Brand', widget.product.brand!),
              if (widget.product.size != null)
                _buildDetailRow('Size', widget.product.size!),
              if (widget.product.weight != null)
                _buildDetailRow('Weight', '${widget.product.weight} kg'),
              if (widget.product.dimensions != null)
                _buildDetailRow('Dimensions', widget.product.dimensions!),
              if (widget.product.material != null)
                _buildDetailRow('Material', widget.product.material!),
              if (widget.product.color != null)
                _buildDetailRow('Color', widget.product.color!),
            ],

            if (widget.product.category == 'Services') ...[
              SizedBox(height: 20),
              Text(
                'Service Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (widget.product.serviceType != null)
                _buildDetailRow('Service Type', widget.product.serviceType!),
              if (widget.product.serviceDuration != null)
                _buildDetailRow(
                    'Duration', '${widget.product.serviceDuration} hours'),
              if (widget.product.serviceArea != null)
                _buildDetailRow('Service Area', widget.product.serviceArea!),
              if (widget.product.experience != null)
                _buildDetailRow('Experience', '${widget.product.experience} years'),
              if (widget.product.certifications != null)
                _buildDetailRow('Certifications', widget.product.certifications!),
              if (widget.product.toolsRequired != null)
                _buildDetailRow('Tools Required', widget.product.toolsRequired!),
            ],

            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProductPage(
                product: widget.product,
                onUpdate: widget.onUpdate,
              ),
            ),
          );
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}