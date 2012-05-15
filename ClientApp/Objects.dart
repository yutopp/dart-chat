#library("dart_chat_client");
#import('dart:html');

interface Drawable
{
  void render(final CanvasRenderingContext2D ctx, int w, int h);
}

interface Effect extends Drawable
{
  int get frameCount();
  int get maxFrame();
}

class MessagePop implements Effect
{
  MessagePop(final CharactorObject this._obj, final String this._message);

  void render(final CanvasRenderingContext2D ctx, int width, int height)
  {
    if (_obj == null)
      return;
    
    ctx.beginPath();
    ctx.font = "13pt Meiryo";
    final TextMetrics tm = ctx.measureText(_message);
    final int tx = (_obj.x + tm.width > width) ? width - tm.width - 2 : _obj.x - 2;
    final int ty = (_obj.y < height / 2) ? _obj.y + _obj.sizeY + 30 : _obj.y - 14;
    final int y_offset = (_obj.y < height / 2) ? 0 : 14;
    
    ctx.strokeStyle = "rgb(64, 64, 64)";
    _drawCurveBox(ctx, tx - 4, ty - 26, tm.width + 8, 32, 10 );
    ctx.fillText(_message, tx + 2, ty - 3);
    ctx.stroke();
    
    ++_frame;
  }
  
  void _drawCurveBox(final CanvasRenderingContext2D ctx, x, y, w, h, r)
  {
    ctx.moveTo(x, y + r);
    ctx.lineTo(x, y + h - r);
    ctx.quadraticCurveTo(x, y + h, x + r, y + h);
    ctx.lineTo(x + w - r, y + h);
    ctx.quadraticCurveTo(x + w, y + h, x + w, y + h - r);
    ctx.lineTo(x + w, y + r);
    ctx.quadraticCurveTo(x + w, y, x + w - r, y);
    ctx.lineTo(x + r, y);
    ctx.quadraticCurveTo(x, y, x, y + r);
  }
  
  int get frameCount() => _frame;
  int get maxFrame() => 120;  
  
  final CharactorObject _obj;
  final String _message;
  int _frame = 0;
}


class ColorRing implements Effect
{
  ColorRing(int this._x, int this._y)
  {
    _r = (Math.random() * 200).toInt() + 55;
    _g = (Math.random() * 200).toInt() + 55;
    _b = (Math.random() * 200).toInt() + 55;
  }
  
  ColorRing.withColor(int this._x, int this._y, int this._r, int this._g, int this._b);
  
  void render(final CanvasRenderingContext2D ctx, int w, int h)
  {
    ctx.beginPath();
    ctx.strokeStyle = "rgba($_r, $_g, $_b, ${1.0-(_frame*_frame)/1200})";
    ctx.arc(_x, _y, _frame * 2.8, 0, Math.PI*2, false);
    ctx.stroke();

    //ctx.clearShadow();
    
    ++_frame;
  }
  
  int get frameCount() => _frame;
  int get maxFrame() => 60;
  
  int get r() => _r;
  int get g() => _g;
  int get b() => _b;
  
  int _x, _y;
  int _r, _g, _b;
  int _frame = 0;
}


class CharactorObject implements Drawable
{
  CharactorObject(final String this._name)
  : _x = 0 , _y = 0, _ax = 0, _ay = 0
  , _movingX = false, _movingY = false
  , _is_image_loaded = false
  {
    _image = new Element.tag("img");
    _image.src = "http://gadgtwit.appspot.com/twicon/${_name}";
    _image.on.load.add((e) { _is_image_loaded = true; });
    
    //UI.getElem("#status").innerHTML += "create $_name<br>";
  }
  
  void render(final CanvasRenderingContext2D ctx, int w, int h)
  {
    ctx.beginPath();
    ctx.shadowColor = "rgba(120, 120, 120, 0.6)";
    ctx.shadowOffsetX = 5;
    ctx.shadowOffsetY = 5;
    ctx.shadowBlur = 8;
    
    if (_is_image_loaded)
      ctx.drawImage(_image, _x, _y, _IconSizeX, _IconSizeY);
    
    ctx.font = "${_FontSize}pt Meiryo";
    ctx.fillStyle = "rgb(64, 64, 64)";
    ctx.fillText(_name, _x + _IconSizeX + 4, _y + (_IconSizeY + _FontSize ) / 2 - 2);
    
    ctx.clearShadow();
    ctx.closePath();
  }
  
  void move()
  {
    _reduce();
    
    _x += _ax;
    _y += _ay;
    
    _movingX = false;
    _movingY = false;
  }
  
  void addAccX(int dx) { _ax += dx; _ax = Math.min(Math.max(-_MaxAcc, _ax), _MaxAcc); _movingX = true; }
  void addAccY(int dy) { _ay += dy; _ay = Math.min(Math.max(-_MaxAcc, _ay), _MaxAcc); _movingY = true; }
  void reverseAccX() { _ax *= -1; }
  void reverseAccY() { _ay *= -1; }
  
  void setPosX(int px) { _x = px; }
  void setPosY(int py) { _y = py; }  
  
  bool isMoved() => _ax != 0 || _ay != 0;
  
  int get x() => _x;
  int get y() => _y;
  
  int get sizeX() =>  (_FontSize + 3) * _name.length + 2;
  int get sizeY() => _IconSizeY;
  
  void _reduce()
  {
    if (!_movingX && _ax != 0) _ax < 0 ? ++_ax : --_ax;
    if (!_movingY && _ay != 0) _ay < 0 ? ++_ay : --_ay;
  }
  
  static final int _MaxAcc = 8;
  static final int _IconSizeX = 32, _IconSizeY = 32;
  static final int _FontSize = 14;
  
  final String _name;
  int _x, _y, _ax, _ay;
  bool _movingX, _movingY;
  ImageElement _image;
  bool _is_image_loaded;
}
