#library("dart_chat_client");
#import("dart:html");
#import("UIController.dart", prefix:"UI");
#import("GameManager.dart");

class GameInitializer
{
  GameInitializer(final String uri)
  : _socket = new WebSocket(uri)
  , _gameMan = new GameManager()
  {
    _socket.on.open.add(_onConnectionEstablished);
  }
  
  //
  _onConnectionEstablished(e)
  {
    UI.hideLoadingDialog();   
    _gameMan.start(_socket);
  }
  
  final WebSocket _socket;
  final GameManager _gameMan;
}
