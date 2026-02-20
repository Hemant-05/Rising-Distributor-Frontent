import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/cart_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConPath.dart';

// Services
import 'package:raising_india/data/services/product_service.dart';

// Screens
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';

// Model
import 'package:raising_india/models/model/product.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _searchResults = [];
  bool _hasSearched = false;

  void _onSearch(String query) async {
    if (query.isEmpty) return;

    // Clear previous results
    setState(() {
      _searchResults = [];
      _hasSearched = true;
    });

    // Call Service
    final results = await context.read<ProductService>().search(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        leading: null,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 10),
            Text("Search", style: simple_text_style(fontSize: 18)),
            const Spacer(),
            cart_button(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColour.lightGrey.withOpacity(0.25),
                hintText: "Search for products",
                hintStyle: simple_text_style(color: AppColour.lightGrey, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColour.lightGrey),
                suffixIcon: InkWell(
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _searchResults = [];
                      _hasSearched = false;
                    });
                  },
                  child: Icon(Icons.cancel, color: AppColour.lightGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    // Check loading state from service if needed, or rely on local async logic
    // For simplicity, we just check lists
    if (!_hasSearched) {
      return Center(child: Text("Search for a product.", style: simple_text_style()));
    }

    if (_searchResults.isEmpty) {
      return Center(child: Text("No products found.", style: simple_text_style()));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        final String imageUrl = (product.photosList != null && product.photosList!.isNotEmpty)
            ? product.photosList![0]
            : "";

        return ListTile(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ProductDetailsScreen(product: product),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => const Icon(Icons.error),
            ),
          ),
          title: Text(
            product.name ?? "Product",
            style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("₹ ${product.price}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(star_svg, height: 16, width: 16), // Ensure asset exists
              Text(
                " ${product.rating ?? 0.0}",
                style: simple_text_style(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}