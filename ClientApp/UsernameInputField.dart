#library("dart_chat_client_username_util");
#import('dart:html');
#import("UIController.dart", prefix:"UI");

class UsernameInputField
{
  UsernameInputField(this._handler)
  : _setted = false
  {
    UI.showTag(InputAreaTagName);
    
    UI.getElem(UsernameInputTagName).focus();
    
    UI.getElem(UsernameInputTagName).on.keyPress.add(_onKeyPress);
    UI.getElem(SubmitButtonTagName).on.click.add(_onSubmitted);
  }
  
  void _onKeyPress(final KeyboardEvent e)
  {
    if (e.keyCode == 13/*Enter*/)
      _onSubmitted(null);
  }
  
  void _onSubmitted(e)
  {
    if (_setted)
      return;
    
    UI.hideTag(InputAreaTagName);
    _setted = true;
    
    final InputElement elem = document.query(UsernameInputTagName);
    _handler(elem.value);
  }
  
  final _handler;
  bool _setted;
  static final String
    InputAreaTagName = "#username_fieled",
    SubmitButtonTagName = "#submit_username",
    UsernameInputTagName = "#username_input";
}
