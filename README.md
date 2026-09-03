# IceFiSh Browser

A glacial SwiftUI iOS browser. Real pages load in `WKWebView`. There are no ads.

Open `IceFiShBrowser/IceFiShBrowser.xcodeproj` in Xcode 15 or later, choose a Development Team, and run on an iPhone or simulator (iOS 17+).

## Start page

- IceFiSh wordmark with an ice/fish mark
- Floating **Search or type a URL** pill with microphone
- Chips: **Browse for me**, **Wikipedia**, **Translate**
- 2×2 favorites: Wikipedia, Maps, Gmail, GitHub
- **Today** article cards from Wikipedia’s featured feed

## Chrome

Floating bottom bar: **Back**, **Tabs**, **New tab**, **Share**.

Search queries use DuckDuckGo. Typing a host or `https` URL loads that page. Back on the first page of a tab returns to the start page.

Voice search needs microphone and speech-recognition permission. If those are denied, you can still type in the pill.

The 2018 UIWebView wrapper lived in a screenshot only. This project replaces it.
