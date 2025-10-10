import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/cart_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/cart/screens/cart_screen.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/features/user/product_details/screens/product_details_screen.dart';
import 'package:raising_india/features/user/search/bloc/product_search_bloc/product_search_bloc.dart';
import '../../../../constant/ConPath.dart';

class ProductSearchScreen extends StatefulWidget {
  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _controller = TextEditingController();

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
                focusColor: AppColour.lightGrey.withOpacity(0.5),
                hintText: "Search for products",
                hintStyle: simple_text_style(
                  color: AppColour.lightGrey,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: AppColour.lightGrey),
                suffixIcon: InkWell(
                  onTap: () => _controller.clear(),
                  child: Icon(Icons.cancel, color: AppColour.lightGrey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<ProductSearchBloc>().add(SearchProducts(query));
                }
              },
            ),
            Expanded(
              child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                builder: (context, state) {
                  if (state is ProductSearchLoading) {
                    return Center(child: CircularProgressIndicator(color: AppColour.primary,));
                  } else if (state is ProductSearchLoaded) {
                    if (state.results.isEmpty) {
                      return Center(child: Text("No products found.",style: simple_text_style(),));
                    }
                    return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (context, index) {
                        final product = state.results[index];
                        return ListTile(
                          onTap: (){
                            context.read<ProductFunBloc>().add(GetProductByID(productId: product.pid));
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ProductDetailsScreen(product: product,),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.photos_list[0],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: simple_text_style(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("₹ ${product.price.toString()}"),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(star_svg),
                              Text(
                                " ${product.rating.toString()}",
                                style: simple_text_style(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is ProductSearchError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text("Search for a product."));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
