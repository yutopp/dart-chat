#library("dart_chat_server");
#import("dart:io");
#import("Session.dart");

//
class ServerManager
{
  ServerManager(final String addr, final int port)
  : _server = new HttpServer()
  , _wsHandler = new WebSocketHandler()
  , _clients = new Map()
  {
    _server.defaultRequestHandler = _wsHandler.onRequest;
    _wsHandler.onOpen = (c) => _onNewConnection(c);

    // start listening
    _server.listen(addr, port);
  }
  
  void sendAll(final Map<String, String> msg)
  {
    _clients.forEach((k, v) => v.send(msg));
  }
  
  void sendOther(final String selfKey, final Map<String, String> msg)
  {
    _clients.forEach((k, v) { if (k != selfKey) v.send(msg); });
  }
  
  // called when the new connection established
  void _onNewConnection(WebSocketConnection connection)
  {
    final String key = () {
      for(int i=0; i<5; ++i) {
        final String key = (Math.random() * Clock.now()).toString();
        if (!_clients.containsKey(key))
          return key;
        }
      return "";
    }();
    if ( key.isEmpty() ) {
      print("error");
      return;
    }
    
    // create new session
    final Session ses = new Session(this, key, connection);  
    if (_userNum >= MaxUserNum) {
      connection.onClosed = (i, s) {};
      connection.onError = (e) {};
      ses.send({"error" : "サーバーの最大人数(${MaxUserNum}) を超えたためアクセス出来ません。"});
      
      return;
    }
    
    //
    ++_userNum;
    _clients[key] = ses;
    
    // set event handlers
    connection.onMessage = ses.onMessage;
    connection.onClosed = (int i, String s) {
      ses.onClosed(i, s);
      _onDestoroyConnection(key);
    };
    connection.onError = (e) {
      ses.onError(e);
      _onDestoroyConnection(key);
    };
    
    //
    ses.send({"user_entry_id" : key});
    sendAll({"user_num" : "$_userNum"});
    _clients.forEach(
      (k, v) {
        if (k != key && v.name != null)
          ses.send({"id" : k, "create_user" : v.name});
      });

    //
    print("connected!");
  }
  
  // called when the connection destroyed
  void _onDestoroyConnection(final String key)
  {
    --_userNum;
    _clients.remove(key);
    _clients.forEach(
      (k, v) {
        v.send({"id" : key, "delete_user" : ""});
      });    
    sendAll({"user_num" : "$_userNum"});
  }
  
  //
  final HttpServer _server;
  final WebSocketHandler _wsHandler;
  final Map<String, Session> _clients;
  
  static final int MaxUserNum = 30;
  int _userNum = 0;
}