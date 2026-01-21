import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/user/order/bloc/order_bloc.dart';
import 'package:raising_india/features/user/order/widgets/on_completed_widget.dart';
import 'package:raising_india/features/user/order/widgets/on_going_widget.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int index = 1;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadUserCompletedOrderEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('My Orders', style: simple_text_style(fontSize: 20)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          index = 0;
                          context.read<OrderBloc>().add(
                            LoadUserOngoingOrderEvent(),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Ongoing',
                            style: simple_text_style(
                              color: index == 0
                                  ? AppColour.primary
                                  : AppColour.lightGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          index = 1;
                          context.read<OrderBloc>().add(
                            LoadUserCompletedOrderEvent(),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'History',
                            style: simple_text_style(
                              color: index == 1
                                  ? AppColour.primary
                                  : AppColour.lightGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColour.lightGrey.withOpacity(0.5)),
              state is OngoingOrderLoadedState
                  ? onGoingWidget(state.orderList)
                  : state is CompletedOrderLoadedState
                  ? onCompletedWidget(state.orderList)
                  : Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColour.primary,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
