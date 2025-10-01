import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/constant/ConString.dart';
import 'package:raising_india/features/user/order/screens/order_details_screen.dart';
import 'package:raising_india/features/user/review/screens/review_screen.dart';
import 'package:raising_india/models/order_model.dart';

Widget onCompletedWidget(List<OrderModel> list) {
  return Expanded(
    child: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12),
      child: list.isEmpty
          ? Center(child: Text('No History Orders..'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                String title = '';
                List imageList = [];
                List itemList = list[index].items;
                for (int i = 0; i < itemList.length; i++) {
                  var element = itemList[i];
                  var x = element['name'] ?? 'Not define';
                  title += x + ((i < itemList.length - 1) ? ', ' : ' ');
                  (element['image'] != null)
                      ? imageList.add(element['image'])
                      : print('hay');
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColour.lightGrey,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: imageList.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: Image.network(
                                          imageList[0],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Visibility(
                                          visible: list[index].items.length > 1,
                                          child: Container(
                                            height: 15,
                                            width: 80,
                                            alignment: Alignment.center,
                                            color: AppColour.lightGrey,
                                            child: Text(
                                              '+${list[index].items.length - 1} more',
                                              style: simple_text_style(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : Center(
                                    child: Text(
                                      'Error',
                                      style: simple_text_style(),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title ?? 'Not Define',
                                  style: simple_text_style(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '₹${list[index].total.toStringAsFixed(0)}',
                                      style: simple_text_style(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      height: 14,
                                      width: 2,
                                      color: AppColour.lightGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '${list[index].items.length} Items',
                                      style: simple_text_style(
                                        color: AppColour.lightGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Container(
                                      height: 14,
                                      width: 2,
                                      color: AppColour.lightGrey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      DateFormat(
                                        'd/M/yy | hh:mm a',
                                      ).format(list[index].createdAt),
                                      style: simple_text_style(
                                        color: AppColour.lightGrey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Status : ${list[index].orderStatus}',
                                  style: simple_text_style(
                                    color: AppColour.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: elevated_button_style(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrderDetailsScreen(order: list[index]),
                                  ),
                                );
                              },
                              child: Text(
                                'Order Details',
                                style: simple_text_style(
                                  color: AppColour.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if(list[index].orderStatus == OrderStatusDeliverd)...[
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: elevated_button_style(),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReviewScreen(orderId: list[index].orderId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Review',
                                  style: simple_text_style(
                                    color: AppColour.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    ),
  );
}
