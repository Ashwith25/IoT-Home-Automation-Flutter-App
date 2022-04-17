import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:mm_app/toast.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  final Map<String, HighlightedWord> _highlights = {
    'bulb': HighlightedWord(
      onTap: () => print('bulb'),
      textStyle: const TextStyle(
        fontSize: 32,
        color: Colors.yellowAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'fan': HighlightedWord(
      onTap: () => print('fan'),
      textStyle: const TextStyle(
        fontSize: 32,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'on': HighlightedWord(
      onTap: () => print('on'),
      textStyle: const TextStyle(
        fontSize: 32,
        color: Colors.greenAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'off': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        fontSize: 32,
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'all': HighlightedWord(
      onTap: () => print('comment'),
      textStyle: const TextStyle(
        fontSize: 32,
        color: Colors.cyanAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = [];
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;

      ToastService.showToast("Device connected", context);
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  sendData(bulb, fan) async {
    var url = Uri.parse(
        'https://api.thingspeak.com/update?api_key=10L1AOMOXBHMFL3T&field1=$bulb&field2=$fan');

    Map<String, String> header = {
      "Content-type": "application/json",
    };
    try {
      http.Response response = await http
          .get(
            url,
            headers: header,
          )
          .catchError((err) {});
      if (response.statusCode != 201 && response.statusCode != 200) {
        return null;
      } else {
        var data = jsonDecode(response.body);
        print(data);
      }
    } catch (error) {
      rethrow;
    }
  }

  bool bulbOn = false;
  bool fanOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: (isConnecting
              ? Text('Connecting to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Connected to ' + widget.server.name)
                  : Text('Chat log with ' + widget.server.name))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        // glowColor: Colors.blueAccent,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          tooltip: "Press the button and start speaking",
          backgroundColor: Colors.blueAccent,
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 150.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.40,
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (bulbOn) {
                            _sendMessage("bulb off");
                            await sendData(0, null);
                            bulbOn = false;
                          } else {
                            _sendMessage("bulb on");
                            await sendData(1, null);
                            bulbOn = true;
                          }
                          setState(() {});
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                          bulbOn ? Colors.greenAccent : Colors.blueAccent,
                        )),
                        child: Icon(FontAwesomeIcons.lightbulb)),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.40,
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (fanOn) {
                            _sendMessage("fan off");
                            await sendData(null, 0);
                            fanOn = false;
                          } else {
                            _sendMessage("fan on");
                            await sendData(null, 1);
                            fanOn = true;
                          }
                          setState(() {});
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                          fanOn ? Colors.greenAccent : Colors.blueAccent,
                        )),
                        child: Icon(FontAwesomeIcons.fan)),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              TextHighlight(
                text: _text,
                words: _highlights,
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      print(_text);
      if (_text.toLowerCase().contains("bulb")) {
        if (_text.toLowerCase().contains("on")) {
          _sendMessage("bulb on");
          await sendData(1, null);
          setState(() {
            bulbOn = true;
          });
        } else {
          _sendMessage("bulb off");
          await sendData(0, null);
          setState(() {
            bulbOn = false;
          });
        }
      } else if (_text.toLowerCase().contains("fan")) {
        if (_text.toLowerCase().contains("on")) {
          _sendMessage("fan on");
          await sendData(null, 1);
          setState(() {
            fanOn = true;
          });
        } else {
          _sendMessage("fan off");
          await sendData(null, 0);
          setState(() {
            fanOn = false;
          });
        }
      } else {
        if (_text.toLowerCase().contains("on")) {
          _sendMessage("all on");
          await sendData(1, 1);
          setState(() {
            bulbOn = true;
            fanOn = true;
          });
        } else {
          _sendMessage("all off");
          await sendData(0, 0);
          setState(() {
            bulbOn = false;
            fanOn = false;
          });
        }
      }
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        print("----HERE----");
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //   listScrollController.animateTo(
        //       listScrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 333),
        //       curve: Curves.easeOut);
        // });
      } catch (e) {
        print("ERROR: " + e.toString());
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
