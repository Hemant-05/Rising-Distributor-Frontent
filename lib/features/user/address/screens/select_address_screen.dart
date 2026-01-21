import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/features/auth/bloc/auth_bloc.dart';
import 'package:raising_india/features/auth/services/auth_service.dart';
import 'package:raising_india/features/services/location_service.dart';
import 'package:raising_india/features/user/address/screens/map_screen.dart';
import 'package:raising_india/models/address_model.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key,required this.isFromProfile});
  final bool isFromProfile;

  @override
  _SelectAddressScreenState createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  bool isLoading = false;
  String? address;
  LatLng? latLng;
  _refresh() {
    context.read<UserBloc>().add(GetLocationList());
  }

  @override
  void initState() {
    super.initState();
    _refresh();
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
            Text('Addresses', style: simple_text_style(fontSize: 20)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  var user = await AuthService().getCurrentUser();
                  var id = user!.uid;
                  bool isPermission = await LocationService.checkPermissions();
                  if (isPermission && user.addressList.length < 5) {
                    bool refresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(userId: id),
                      ),
                    );
                    if (refresh) {
                      _refresh();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColour.primary,
                        content: Text(
                          'Maximum 5 Address can Add\nDelete other and try again... ',
                          style: simple_text_style(color: AppColour.white),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'ADD LOCATION',
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
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: state is LocationListLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColour.primary,
                          ),
                        )
                      : state is LocationListSuccess
                      ? state.addressList.isNotEmpty
                            ? ListView.builder(
                                itemCount: state.addressList.length,
                                itemBuilder: (context, index) {
                                  AddressModel model = state.addressList[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColour.lightGrey.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      /*leading: Container(
                                        decoration: BoxDecoration(color: AppColour.white,borderRadius: BorderRadius.circular(50)),
                                        padding: EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(map_svg,color: AppColour.primary,),),*/
                                      onTap: () {
                                        Navigator.pop(context, {
                                          'address': model,
                                        });
                                      },
                                      trailing: IconButton(
                                        onPressed: () {
                                          context.read<UserBloc>().add(
                                            DeleteLocation(addressId: model.id!),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.delete_outlined,
                                          color: AppColour.primary,
                                        ),
                                      ),
                                      title: Text(
                                        model.title,
                                        style: simple_text_style(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        model.streetAddress,
                                        style: TextStyle(fontFamily: 'Sen'),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No Location Added',
                                  style: simple_text_style(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                      : state is UserError
                      ? Center(
                          child: Text(
                            'Some issue ${state.message}',
                            style: simple_text_style(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Center(
                          child: Text("Restart the app....", style: simple_text_style()),
                        ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: false,
                  child: ElevatedButton(
                    style: elevated_button_style(),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      var currentPosition =
                          await LocationService.getCurrentPosition();
                      latLng = LatLng(
                        currentPosition!.latitude,
                        currentPosition.longitude,
                      );
                      address = await LocationService.getReadableAddress(latLng!);
                      Navigator.pop(context, {
                        'address': address,
                        'latLng': latLng,
                      });
                    },
                    child: isLoading
                        ? CircularProgressIndicator(color: AppColour.white)
                        : Text(
                            'Continue with current location',
                            style: simple_text_style(
                              color: AppColour.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
