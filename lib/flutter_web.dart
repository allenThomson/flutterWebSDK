library flutter_web;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('webengage.debug')
external void _debug(bool val);

@JS('webengage.user.login')
external void _login(String s);

@JS('webengage.user.logout')
external void _logout();

@JS('console.log')
external void log(var a);

//void setAttribute(String attr, var val) => _setAttribute(attr, val);

// WIP: Currently setAttribute is working with string, number, bool type of values (val)
// Currently working to make it feasible to work with JSON as well.

/*
Below are the modifications made from my side
referred:https://codeburst.io/how-to-use-javascript-libraries-in-your-dart-applications-e44668b8595d
*/

@JS('webengage.user.setAttribute')
external void _setAttribute(String attr, dynamic val);

@JS('webengage.track')
external void _track(String eventName, dynamic data);

@JS('Date')
class DateJS {
  //referred: https://github.com/dart-lang/sdk/issues/25886
  external factory DateJS(String dateString);
}

class User {
  void login(String cuid) => _login(cuid);

  void logout() => _logout();

  dynamic convertToJs(dynamic value) {
    // This function is to recursively iterate over the type of value received; Logic referred from https://stackoverflow.com/questions/51804476/dynamically-convert-a-dart-2-map-to-a-javascript-object
    if (value is List) {
      // Convert List to JavaScript array
      var jsArray = [];
      value.forEach((item) {
        jsArray.add(convertToJs(item));
      });
      return jsArray;
    } else if (value is Map) {
      // Convert Map to JavaScript object
      var jsObject = newObject();
      value.forEach((k, v) {
        setProperty(jsObject, k, convertToJs(v));
      });
      return jsObject;
    } else if (value is DateTime) {
      var dateString = value.toString();
      return DateJS(dateString);
    } else {
      // For other types (String, int, double, bool), return as-is
      return value;
    }
  }

  void setAttribute(String attr, dynamic val) {
    var attrVal = convertToJs(val);
    _setAttribute(attr, attrVal);
    log(val);
  }
}

class WebEngage {
  var user = new User();

  /// Converts a Dart Map into a corresponding JavaScript object.
  dynamic mapToJsObject(Map map) {
    var object = newObject();
    map.forEach((key, value) {
      if (value is Map) {
        setProperty(object, key, mapToJsObject(value));
      } else if (value is List) {
        var jsArray = jsify(value);
        setProperty(object, key, jsArray);
      } else if (value is DateTime) {
        var dateString = value.toString();
        setProperty(object, key, DateJS(dateString));
      } else {
        setProperty(object, key, value);
      }
    });
    return object;
  }

  void track(String eventName, Map<String, dynamic> eventData) {
    // Convert the Dart map to a nested JavaScript object
    var jsEventData = mapToJsObject(eventData);

    _track(eventName, jsEventData);
  }

  void debug(bool val) => _debug(val);
}
