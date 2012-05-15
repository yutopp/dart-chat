#library("dart_chat_client");
#import("dart:html");
#import("dart:json");
#import("UIController.dart", prefix:"UI");
#import("UsernameInputField.dart");
#import("Renderer.dart");
#import("Objects.dart");

class GameManager
{
  GameManager()
  : _renderer = new Renderer(_CanvasTagName, 640, 480)
  , _userNum = 0
  , _charactors = new Map()
  , _key_map = new Map()
  , _effects = [];
  
  void start(final WebSocket socket)
  {
    _socket = socket;
    _socket.on.message.add(_onMessage);
  }

  void _send(final Map<String, String> msg )
  {
    _socket.send(JSON.stringify(msg));
  }
  
  void _userEvent(final String id, final String type, final String msg)
  {   
    switch(type)
    {
      case "create_user":
        _charactors[id] = new CharactorObject(msg);
        // 自身の位置を新しいクライアントへ設定させるため
        _send({"pos_x" : _self.x.toString()});
        _send({"pos_y" : _self.y.toString()});
        break;
        
      case "delete_user":
        _charactors.remove(id);
        break;
        
      case "pos_x":
        _charactors[id].setPosX(Math.parseInt(msg));
        break;
        
      case "pos_y":
        _charactors[id].setPosY(Math.parseInt(msg));
        break;
        
      case "effect":
        final map = JSON.parse(msg);
        final int t = Math.parseInt(map["type"]);
        final int x = Math.parseInt(map["x"]);
        final int y = Math.parseInt(map["y"]);
        final int r = Math.parseInt(map["r"]);
        final int g = Math.parseInt(map["g"]);
        final int b = Math.parseInt(map["b"]);
        _effects.add(new ColorRing.withColor(x, y, r, g, b));
        break;
        
      case "message":
        _effects.add(new MessagePop(_charactors[id], msg));
        break;
    }
  }
  
  void _event(final String type, final String msg)
  {
    switch(type) {
      case "user_entry_id":
        _myId = msg;
        new UsernameInputField(_ignitionMainLoop);
        break;
        
      case "user_num":
        _userNum = Math.parseInt(msg);
        UI.getElem(_UserNumTagName).innerHTML = msg;
        break;
        
      case "error":
        UI.getElem("#status").innerHTML = msg;
        break;
    }
  }
  
  void _mainLoop()
  {
    _renderer.renderBackGround();
    
    // 
    _controlSelf();
    
    //
    _charactors.getValues().forEach((v) => v.move());
    
    // Render
    _charactors.getValues().forEach((v) => _renderer.renderObject(v));
    _effects.forEach((v) => _renderer.renderObject(v));
    _effects = _effects.filter((v) => v.frameCount < v.maxFrame);
    
    //
    window.setTimeout(() => _mainLoop(), 1000 ~/ 30);
  }
  
  void _controlSelf()
  {
    bool moved = false;
    if (_key_map[37]) {  // left
      _self.addAccX(-1);
      _send({"acc_x" : "-1"});
    }
    
    if (_key_map[38]) {  // up
      _self.addAccY(-1);
      _send({"acc_y" : "-1"});
    }
    
    if (_key_map[39]) {  // right
      _self.addAccX(1);
      _send({"acc_x" : "1"});
    }
    
    if (_key_map[40]) {  // down
      _self.addAccY(1);
      _send({"acc_y" : "1"});
    }
    
    if (_self.isMoved()) {
      if (_self.x < 0 || _self.x + _self.sizeX >= _renderer.width) {
        _self.setPosX(Math.min(Math.max(0, _self.x), _renderer.width - _self.sizeX - 1));
        _self.reverseAccX();
      }
      if (_self.y < 0 || _self.y + _self.sizeY >= _renderer.height) {
        _self.setPosY(Math.min(Math.max(0, _self.y), _renderer.height - _self.sizeY - 1));
        _self.reverseAccY();
      }
      
      _send({"pos_x" : _self.x.toString()});
      _send({"pos_y" : _self.y.toString()});
    }
  }
  
  void _onKeyDown(final KeyboardEvent e)
  {
    _key_map[e.keyCode] = true;
  }
  
  void _onKeyUp(final KeyboardEvent e)
  {
    _key_map[e.keyCode] = false;
  }  
  
  void _onMouseDown(final MouseEvent e)
  {
    final int x = e.x - 20, y = e.y - 20;
    final ColorRing ef = new ColorRing(x, y);
    _effects.add(ef);
    _send(
      {"effect" : JSON.stringify(
        {
          "type" : "1", 
          "x" : "$x",
          "y" : "$y",
          "r" : "${ef.r}",
          "g" : "${ef.g}",
          "b" : "${ef.b}"
        }
        )
      }
      );
  }
  
  void _chatBoxKeyPress(final KeyboardEvent e)
  {
    if (e.keyCode != 13/*Enter*/)
      return;
    
    final InputElement chat = UI.getElem(_ChatBoxTagName);
    _effects.add(new MessagePop(_self, chat.value));
    _send({"message" : chat.value});
    chat.value = "";
  }
  
  void _ignitionMainLoop(final String username)
  {
    _self = new CharactorObject(username);
    _charactors[_myId] = _self;
    _send({"create_user" : username});
    
    //
    window.on.keyDown.add(_onKeyDown);
    window.on.keyUp.add(_onKeyUp);
    window.on.mouseDown.add(_onMouseDown);
    
    //
    UI.getElem(_ChatBoxTagName).on.keyPress.add(_chatBoxKeyPress);
    
    //
    window.setTimeout(_mainLoop, 1000 ~/ 30);
  }
  
  void _onMessage(MessageEvent e)
  {
    final Map<String, String> data = JSON.parse(e.data);
    final func = () {
      if ( data.containsKey("id") ) {
        final String user_id = data["id"];
        data.remove("id");
        return (k, v) => _userEvent(user_id, k, v); 
      } else {
        return (k, v) => _event(k, v);
      }
    }();
    data.forEach(func);
  }
  
  static final String
    _CanvasTagName = "#canvas_area",
    _ChatBoxTagName = "#chat_text",
    _UserNumTagName = "#user_num";
  final Renderer _renderer;
  WebSocket _socket;
  String _myId;
  int _userNum;
  
  Map<int, bool> _key_map;
  
  Map<String, CharactorObject> _charactors;
  CharactorObject _self;
  
  List<Effect> _effects;
}