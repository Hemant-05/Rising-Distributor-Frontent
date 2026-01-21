import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/constant/AppColour.dart';

import '../../../../comman/back_button.dart';
import '../../../../comman/elevated_button_style.dart';
import '../../../../comman/simple_text_style.dart';
import '../../../auth/bloc/auth_bloc.dart';

class FillAddressDetailsScreen extends StatelessWidget {
  FillAddressDetailsScreen({super.key, required this.data});
  Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController recipientNameController = TextEditingController();
    final TextEditingController recipientPhoneController = TextEditingController();
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Address Details', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColour.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColour.primary, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      'Home, Work etc..',
                      style: simple_text_style(color: AppColour.lightGrey),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 10,
            ),
            Container(
                decoration: BoxDecoration(
                  color: AppColour.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColour.primary, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: recipientNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      'Name',
                      style: simple_text_style(color: AppColour.lightGrey),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 10,
            ),
            Container(
                decoration: BoxDecoration(
                  color: AppColour.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColour.primary, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: recipientPhoneController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(
                      'Number',
                      style: simple_text_style(color: AppColour.lightGrey),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 10,
            ),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return ElevatedButton(
                  style: elevated_button_style(width: 200),
                  child: state is UserLocationLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColour.white,
                      constraints: BoxConstraints(
                        maxWidth: 40,
                        maxHeight: 40,
                      ),
                    ),
                  )
                      : Text(
                    "ADD ADDRESS",
                    style: simple_text_style(
                      color: AppColour.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    String title = titleController.text.trim();
                    String recipientName = recipientNameController.text.trim();
                    String recipientPhone = recipientPhoneController.text.trim();
                    if(title.isNotEmpty) {
                      Map<String,dynamic> model = {
                        'title': title,
                        'latitude': data['latitude'],
                        'longitude': data['longitude'],
                        'recipientName': recipientName,
                        'phoneNumber': recipientPhone,
                        'streetAddress': data['street'],
                        'city': data['city'],
                        'state': data['state'],
                        'zipCode': data['zipCode'],
                        'userId': data['userId'],
                      };
                      context.read<UserBloc>().add(
                        AddLocation(
                          model: model,
                        ),
                      );
                      Navigator.pop(context, true);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColour.primary,
                            content: Text('Title is required...', style: simple_text_style(color: AppColour.white),),));
                    }
                  },
                );
              },
            ),
          ],
        ),
      )
    );
  }
}
