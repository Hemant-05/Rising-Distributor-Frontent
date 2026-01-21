import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/user/address/screens/select_address_screen.dart';
import 'package:raising_india/features/user/payment/screens/payment_checkout_screen.dart';
import 'package:raising_india/features/user/product_details/bloc/product_funtction_bloc/product_fun_bloc.dart';
import 'package:raising_india/models/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductFunBloc>().add(GetCartProductPressed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFunBloc, ProductFunState>(
      builder: (context, state) {
        var total = state.getCartProduct
            .fold(
              0,
              (total, product) =>
                  total +
                  ((product['product'].price).toInt() * product['quantity']
                      as int),
            )
            .toString();
        var mrpTotal = state.getCartProduct
            .fold(
              0,
              (total, product) =>
                  total +
                  ((product['product'].mrp ?? (product['product'].price + 5))
                              .toInt() *
                          product['quantity']
                      as int),
            )
            .toString();
        var save = (double.parse(mrpTotal) - double.parse(total));
        return Scaffold(
          backgroundColor: AppColour.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Text(
                  'Cart',
                  style: simple_text_style(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColour.black,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      if (state.cartProductCount == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Cart is already Empty')),
                        );
                        return;
                      }
                      context.read<ProductFunBloc>().add(ClearCartPressed());
                      context.read<ProductFunBloc>().add(
                        GetCartProductPressed(),
                      );
                    },
                    child: Text(
                      'CLEAR CART',
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColour.white,
          ),
          body: Center(
            child: state.isLoadingCartProduct
                ? CircularProgressIndicator(color: AppColour.primary)
                : state.error != null
                ? Center(child: Text(state.error!))
                : Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: state.getCartProduct.isEmpty
                            ? Center(
                                child: Text(
                                  'Your cart is empty',
                                  style: simple_text_style(fontSize: 24),
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.getCartProduct.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      state.getCartProduct[index]['product']
                                          as ProductModel;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColour.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColour.grey.withOpacity(
                                            0.3,
                                          ),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ListTile(
                                          leading: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: product.photosList[0],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.error_outline_rounded,
                                                  ),
                                            ),
                                          ),
                                          title: Text(
                                            product.name,
                                            style: simple_text_style(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                '${product.price}',
                                                style: simple_text_style(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '₹${product.mrp ?? (product.price + 5)}',
                                                style: TextStyle(
                                                  fontFamily: 'Sen',
                                                  decorationThickness: 2,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 26,
                                                width: 26,
                                                decoration: BoxDecoration(
                                                  color: AppColour.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    if (state
                                                            .getCartProduct[index]['quantity'] >
                                                        1) {
                                                      context
                                                          .read<
                                                            ProductFunBloc
                                                          >()
                                                          .add(
                                                            UpdateProductQuantityPressed(
                                                              productId:
                                                                  product.pid,
                                                              quantity: --state
                                                                  .getCartProduct[index]['quantity'],
                                                            ),
                                                          );
                                                    }
                                                    state.copyWith(
                                                      quantity: state
                                                          .getCartProduct[index]['quantity'],
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: AppColour.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              state.isUpdatingProductQuantity
                                                  ? Container(
                                                      height: 20,
                                                      width: 20,
                                                      alignment:
                                                          Alignment.center,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color:
                                                                AppColour.black,
                                                            strokeWidth: 3,
                                                          ),
                                                    )
                                                  : Text(
                                                      '${state.getCartProduct[index]['quantity']}',
                                                      style: simple_text_style(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              const SizedBox(width: 10),
                                              Container(
                                                height: 26,
                                                width: 26,
                                                decoration: BoxDecoration(
                                                  color: AppColour.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    context.read<ProductFunBloc>().add(
                                                      UpdateProductQuantityPressed(
                                                        productId: product.pid,
                                                        quantity: ++state
                                                            .getCartProduct[index]['quantity'],
                                                      ),
                                                    );
                                                    state.copyWith(
                                                      quantity: state
                                                          .getCartProduct[index]['quantity'],
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: AppColour.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        InkWell(
                                          onTap: () {
                                            context.read<ProductFunBloc>().add(
                                              RemoveFromCartPressed(
                                                productId: product.pid,
                                              ),
                                            );
                                            context.read<ProductFunBloc>().add(
                                              GetCartProductPressed(),
                                            );
                                            context.read<ProductFunBloc>().add(
                                              CheckIsInCart(
                                                productId: product.pid,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Remove from cart',
                                            style: simple_text_style(
                                              color: AppColour.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      Visibility(
                        visible: state.getCartProduct.isNotEmpty,
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColour.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColour.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                  0,
                                  -3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Free Delivery Above ₹99',
                                style: simple_text_style(
                                  fontSize: 14,
                                  color: double.parse(total.toString()) > 99
                                      ? AppColour.green
                                      : AppColour.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cart Total',
                                        style: simple_text_style(fontSize: 20),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '₹$total',
                                            style: simple_text_style(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '₹$mrpTotal',
                                            style: TextStyle(
                                              decorationThickness: 2,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontFamily: 'Sen',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (save != 0)
                                        Text(
                                          'You Save: ₹$save',
                                          style: simple_text_style(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      AuthService authService = AuthService();
                                      if (state.getCartProduct.isNotEmpty) {
                                        final result =
                                            await PersistentNavBarNavigator.pushNewScreen(
                                              context,
                                              screen: SelectAddressScreen(
                                                isFromProfile: false,
                                              ),
                                              withNavBar: false,
                                              pageTransitionAnimation:
                                                  PageTransitionAnimation
                                                      .cupertino,
                                            );
                                        if (result != null) {
                                          LatLng location = result['latLng'];
                                          String address = result['address'];
                                          final user = await authService
                                              .getCurrentUser();
                                          String totalPrice = state
                                              .getCartProduct
                                              .fold(
                                                0,
                                                (total, product) =>
                                                    total +
                                                    ((product['product'].price)
                                                                .toInt() *
                                                            product['quantity']
                                                        as int),
                                              )
                                              .toString();
                                          PersistentNavBarNavigator.pushNewScreen(
                                            context,
                                            screen: PaymentCheckoutScreen(
                                              address: address,
                                              addressCode: location,
                                              total: totalPrice,
                                              mrpTotal: mrpTotal,
                                              email: user!.email,
                                              contact: user.mobileNumber?? "No number",
                                              name: user.name,
                                              cartProductList:
                                                  state.getCartProduct,
                                              isVerified:
                                                  user.isMobileVerified ?? false,
                                            ),
                                            withNavBar: false,
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: AppColour.white,
                                              content: Text(
                                                'Location Not Fetched !!',
                                                style: simple_text_style(),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColour.white,
                                            content: Text(
                                              'Add Product then continue !!',
                                              style: simple_text_style(),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: elevated_button_style(width: 120),
                                    child: Text(
                                      state.cartProductCount == 0
                                          ? 'NO ITEM'
                                          : 'CONTINUE',
                                      style: simple_text_style(
                                        color: AppColour.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
