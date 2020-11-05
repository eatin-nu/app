import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectedAddress {
  final String weergavenaam;
  final String id;

  SelectedAddress({this.weergavenaam, this.id});
}

typedef void AddressSelected(SelectedAddress address);

class AddressSelector extends StatefulWidget {
  final AddressSelected onAddressSelected;

  @override
  _AddressSelectorState createState() => _AddressSelectorState();

  @override
  AddressSelector({Key key, this.onAddressSelected}) : super(key: key);
}



class _AddressSelectorState extends State<AddressSelector> {
  final _controller = TextEditingController();
  SelectedAddress selectedAddress;

  void initState() {
    super.initState();
    // Add handler to reset selected address if it's edited again.
    _controller.addListener(() {
      if (this.selectedAddress != null) {
        if (this._controller.text != this.selectedAddress.weergavenaam) {
          this.setState(() {
            this.selectedAddress = null;
          });

          if (this.widget.onAddressSelected != null) {
            this.widget.onAddressSelected(null);
          }
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: this._controller,
            style: DefaultTextStyle.of(context).style.copyWith(
                fontStyle: FontStyle.italic
            ),
            decoration: InputDecoration(
                border: OutlineInputBorder()
            ),

        ),
        suggestionsCallback: (String pattern) async {
          if (pattern.length < 3) {
            return [];
          }

          final params = <String,String>{ "q": pattern };
          var uri = Uri.https("geodata.nationaalgeoregister.nl","/locatieserver/v3/suggest", params);
          print(uri);
          final response = await http.get(uri);
          return jsonDecode(response.body)["response"]["docs"];
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            //leading: Icon(Icons.shopping_cart),
            title: Text(suggestion['weergavenaam']),
          );
        },
        onSuggestionSelected: (suggestion) {
          this.selectedAddress = SelectedAddress(weergavenaam: suggestion["weergavenaam"], id: suggestion["id"]);

          this.setState(() {
            this._controller.text = this.selectedAddress.weergavenaam;
          });

          if (this.widget.onAddressSelected != null) {
            this.widget.onAddressSelected(this.selectedAddress);
          }
        },
      ),
    );
  }
}