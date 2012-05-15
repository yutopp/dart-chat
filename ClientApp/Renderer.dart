#library("dart_chat_client");
#import("dart:html");
#import("UIController.dart", prefix:"UI");
#import("Objects.dart");

class Renderer
{
  Renderer(final String tag, final int this._width, final int this._height)
  : _canvas = UI.getElem(tag)
  {
    _ctx = _canvas.getContext("2d");
  }
  
  void renderBackGround()
  {
    _ctx.clearRect(0, 0, _width, _height);    
  }
  
  void renderObject(final Drawable o)
  {
    o.render(_ctx, width, height);
  }
  
  int get width() => _width;
  int get height() => _height;
  
  final CanvasElement _canvas;
  final int _width, _height;
  CanvasRenderingContext2D _ctx;
}