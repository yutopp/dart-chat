#library("dart_chat_server");
#import("dart:io");
#import("dart:json");
#import("ServerManager.dart");

class Session
{
  Session(final ServerManager this._manager,
    final String this._key,
    final WebSocketConnection this._connection);

  void send(final Map value)
  {
    _connection.send(JSON.stringify(value));
  }
  
  void _event(final String type, final String msg)
  {
    switch(type) {
      case "create_user":
        _name = msg;
        break;
        
      case "pos_x":
        _x = Math.parseInt(msg);
        break;
        
      case "pos_y":
        _y = Math.parseInt(msg);
        break;
    }
    _manager.sendOther(_key, {"id" : _key, "$type" : msg});
  }
  
  //
  void onMessage(msg)
  {
    final Map<String, String> data = JSON.parse(msg.toString());
    data.forEach((k, v) => _event(k, v));
  }
  
  void onClosed(int i, String s) => print("closed!");
  
  void onError(e) => print(e.toString());
  
  String get name() => _name;
  String get key() => _key;
  
  final ServerManager _manager;
  final String _key;
  final WebSocketConnection _connection;
  
  String _name;
  int _x = 0, _y = 0;
}
