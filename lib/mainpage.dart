// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

import 'sql_connection.dart';

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  List<Map<String, dynamic>> _myList = [];

  bool _isLoading = true;

  void _refreshmyList() async {
    final data = await SqlCodes.getItems();
    setState(() {
      _myList = data;
      _isLoading = false;
    });
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  bool _validate = false;

  //DDAWAWDYBJDWABDAWDAWBDWUABDAWWDDWDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  Future<void> _addElement() async {
    await SqlCodes.createItem(_nameController.text, _numberController.text);
    _refreshmyList();
  }

  Future<void> _updateElement(int id) async {
    await SqlCodes.updateItem(id, _nameController.text, _numberController.text);
    _refreshmyList();
  }

  Future<void> _deleteItem(int id) async {
    await SqlCodes.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleted to a member'),
      ),
    );
    _refreshmyList();
  }

  @override
  void initState() {
    super.initState();

    _refreshmyList();
  }

  void _displayContent(int? id) async {
    if (id != null) {
      final existingmyList =
          _myList.firstWhere((element) => element['id'] == id);
      _nameController.text = existingmyList['name'];
      _numberController.text = existingmyList['number'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 0,
      isScrollControlled: true,
      builder: (_) => Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 0, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => mainPage()));
                  },
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              color: Colors.lightGreen,
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white))),
                    ],
                  )),
              Image.asset('images/logo.png', width: 150),
              const Text(
                  'Please enter a name and a phone number for your \ncontact list also if you will enter empty values \nfor this forms, it will not save on this system '),
              const SizedBox(height: 10),
              TextField(
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },

                controller: _nameController,
                // The validator receives the text that the user has entered.

                decoration: InputDecoration(
                  errorText: _validate ? "Value Can not Be Empty" : null,
                  labelText: 'please enter a name',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                controller: _numberController,
                decoration: InputDecoration(
                    labelText: 'please enter a phone number',
                    errorText: _validate ? "Value Can't Be Empty" : null,
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (id == null &&
                      _nameController.text.isEmpty &&
                      _numberController.text.isEmpty) {
                    setState(() {
                      _nameController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      _numberController.text.isEmpty
                          ? _validate = true
                          : _validate = false;
                      Navigator.of(context).pop();
                    });
                  }
                  if (id == null &&
                      _nameController.text.isNotEmpty &&
                      _numberController.text.isNotEmpty) {
                    await _addElement();
                    Navigator.of(context).pop();
                  }
                  if (id != null) {
                    await _updateElement(id);
                    Navigator.of(context).pop();
                  }

                  _nameController.text = '';
                  _numberController.text = '';
                  //close display content
                  // Navigator.of(context).pop();
                },
                child: Text(id == null ? 'SAVE' : 'UPDATE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 45,
          title: const Center(
            child: Text('CONTACTLISTAPP',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
          ),
          backgroundColor: Colors.greenAccent[400],
          leading: Image.asset(
            'images/logo.png',
          ),
          leadingWidth: 50,
          actions: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                onPressed: () {},
                disabledColor: Colors.white,
                hoverColor: Colors.white,
                icon: Icon(Icons.settings_outlined,
                    color: Colors.black, size: 32),
              )
            ])
          ],
        ),
        body: Container(
          // BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: )),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('MY CONTACT LIST',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Colors.green)),
              ),
              Container(
                child: Expanded(
                  flex: 1,
                  child: Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _myList.length,
                        itemBuilder: (context, index) => Card(
                              color: Colors.greenAccent[100],
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                  title: Text(_myList[index]['name']),
                                  subtitle: Text(_myList[index]['number']),
                                  trailing: SizedBox(
                                    width: 212,
                                    child: Row(
                                      children: [
                                        IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _displayContent(
                                                _myList[index]['id'])),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _deleteItem(
                                                _myList[index]['id'])),
                                        IconButton(
                                            icon: const Icon(
                                              Icons.phone_in_talk_rounded,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              FlutterPhoneDirectCaller
                                                  .callNumber(
                                                      _myList[index]['number']);
                                            }),
                                        TextButton(
                                            child: Text(
                                              'CALL&\nRecord',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            ),
                                            onPressed: () {}),
                                      ],
                                    ),
                                  )),
                            )),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[700],
          onPressed: () => _displayContent(null),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
