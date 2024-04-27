library flutter_web;

//referred:https://codeburst.io/how-to-use-javascript-libraries-in-your-dart-applications-e44668b8595d
import 'package:js/js.dart';

import 'dart:js';
import 'package:intl/intl.dart';

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

*/

@JS('webengage.user.setAttribute')
external void _setAttribute(String attr, dynamic val);

@JS('webengage.track')
external void _track(String eventName, dynamic data);

@JS('Date') // Define external JavaScript Date constructor
external DateTime jsDate(String time);

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
      // log(DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(value)); //parsing dart date to JS date is yet to be done
      // return jsDate('1714076284000');
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
  RegExp pattern = RegExp(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$|^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}Z)$'); //please ignore, added for testing date inputs

  /// Converts a Dart Map into a corresponding JavaScript object.
  dynamic mapToJsObject(Map map) {
    var object = newObject();

    map.forEach((key, value) {
      if (value is Map) {
        setProperty(object, key, mapToJsObject(value));
      } else if (value is List) {
        var jsArray = jsify(value);
        setProperty(object, key, jsArray);
      } else if (pattern.hasMatch(value)) {
        log("vale us" + value);
        //var date1 = jsDate('1714076284000');

        String dartDateString = "2021-04-25T20:18:04Z";
        var a = jsDate(dartDateString);
        setProperty(object, key, a);
        // var formattedDate =
        //     DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(value);

        // JsObject jsDate1 =
        //     JsObject.jsify({'dateVal': value.toUtc().toIso8601String()});
        // log(jsDate1);
        // JsObject jsDateInstance = JsObject(context['Date'], [jsDate1]);
        // setProperty(object, key, jsDateInstance);
        // int millisecondsSinceEpoch = value.millisecondsSinceEpoch;
        // JsFunction jsDateConstructor = context['Date'] as JsFunction;
        // JsObject jsDate =
        //     jsDateConstructor.apply([millisecondsSinceEpoch]) as JsObject;
        // setProperty(object, key, jsDate);
        // JsObject jsDate = JsObject.jsify(
        //     {'millisecondsSinceEpoch': value.millisecondsSinceEpoch});
        // JsObject jsDateInstance = JsObject(context['Date'], [jsDate]);
        // setProperty(object, key, jsDateInstance);
        //setProperty(object, key, jsNew<JsObject>('Date', value.toUtc().toIso8601String()));
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