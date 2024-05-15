# Flutter Web

Sample Website: https://flutterwebsite-5c146.web.app/

Flutter support for WebSDK

Integration docs: https://webengage.atlassian.net/wiki/spaces/SOP/pages/2651258925/Flutter+Web+SDK+integration+testing+steps

supports tracking events https://docs.webengage.com/docs/web-tracking-events  and user attributes https://docs.webengage.com/docs/web-tracking-users. 

Note: To Track Date data type, you need to use dart DateTime object. Eg: webengage.track("Purchase", { "Purchase Date": DateTime.parse("2024-04-25T20:18:04Z") }); , webengage.user.setAttribute("firstClicked", DateTime.parse("2020-01-09T00:00:00.000Z"));

