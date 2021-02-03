
import 'dart:async';

import 'package:flutter/services.dart';


class StaticWebViewConfig {
    final Uri uri;
    final String title;

    StaticWebViewConfig(this.uri, this.title);

    Map<String, String> asJSON(){
       return {"url": uri.toString(), "title": title};
    }
}

class StaticWebView {
  static const MethodChannel _channel =
      const MethodChannel('studio.techpro.static_webview');

  static Future<void> showStaticWebView(StaticWebViewConfig config) async {
    await _channel.invokeMethod('show', config.asJSON());
  }
}
