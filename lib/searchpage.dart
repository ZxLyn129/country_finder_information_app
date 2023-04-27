import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import 'package:audioplayers/audioplayers.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController inputController = TextEditingController();
  String name = '';
  String countryCode = '';
  double surfArea = 0.0;
  String currencyCode = '';
  String currencyName = '';
  String capital = '';
  double population = 0.0;
  String result = " ";
  String flagUrl = '';
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 254, 225),
        appBar: AppBar(
          title: const Text("Country Finder Information App"),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 5),
              child: Column(children: [
                Image.asset(
                  'assets/images/countries_map.jpg',
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: Text(
                    "There are 195 countries in the world today. This total comprises 193 countries that are member states of the United Nations and 2 countries that are non-member observer states: the Holy See and the State of Palestine.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Please enter a country name:",
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: TextField(
                            controller: inputController,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText:
                                  "Malaysia, China, India, United States...",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(8, 10, 8, 10),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 3, 0, 10),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              getDetails();
                            },
                            icon: const Icon(
                              Icons.search,
                              size: 23,
                            ),
                            label: const Text("Search",
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    width: 380,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      color: Colors.white70,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 13, 13, 20),
                      child: Column(children: [
                        Image.network(
                          flagUrl,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Text('');
                          },
                        ),
                        Text(result,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent)),
                      ]),
                    ))
              ]),
            )
          ],
        )));
  }

  Future<void> getDetails() async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Progress"), title: const Text("Searching..."));

    String country = inputController.text;
    if (country.isNotEmpty) {
      progressDialog.show();
      var apiKey = "N+Hk5zzaOx4g6ko7m9w8jQ==ChvimG1fdZO55JiU";
      var url =
          Uri.parse('https://api.api-ninjas.com/v1/country?name=$country');
      var response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if (response.statusCode == 200) {
        var jsonData = response.body;
        var parsedJson = json.decode(jsonData);

        if (parsedJson.isEmpty) {
          setState(() {
            player.play(AssetSource('audios/fail.mp3'));
            result = "No records found. Please enter again.";
            flagUrl = '';
            countryCode = '';
          });
          progressDialog.dismiss();
        } else {
          //display the searched country information and flag
          player.play(AssetSource('audios/success.mp3'));

          setState(() {
            name = parsedJson[0]["name"];
            surfArea = parsedJson[0]["surface_area"];
            currencyCode = parsedJson[0]["currency"]["code"];
            currencyName = parsedJson[0]["currency"]["name"];
            capital = parsedJson[0]["capital"];
            population = parsedJson[0]["population"];
            countryCode = parsedJson[0]["iso2"];
            flagUrl = 'https://flagsapi.com/$countryCode/shiny/64.png';
            result =
                "This country is call $name and the country code is $countryCode. The surface area of this country is $surfArea km², which has $population people reside there and the capital is $capital. Its currency used is $currencyCode, $currencyName.";
          });
          progressDialog.dismiss();
        }
      } else {
        setState(() {
          player.play(AssetSource('audios/fail.mp3'));
          result = "Error. Please try again.";
          flagUrl = '';
          countryCode = '';
        });
        progressDialog.dismiss();
      }
    } else {
      setState(() {
        player.play(AssetSource('audios/fail.mp3'));
        flagUrl = '';
        result = "No data was entered. Please enter the country name. ";
        countryCode = '';
      });
    }
  }
}
