#library("dart_chat_client_ui_util");
#import("dart:html");

void showTag(final String tag) { document.query(tag).style.display = 'block'; }
void hideTag(final String tag) { document.query(tag).style.display = 'none'; }
Element getElem(final String tag) => document.query(tag);

void showLoadingDialog() { showTag('#loading'); }
void hideLoadingDialog() { hideTag('#loading'); }