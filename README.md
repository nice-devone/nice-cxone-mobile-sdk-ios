# InConnect iOS SDK

This package is used to connect an application to InConnect's WebSocket

## Overview

In order to use the SDK a few things need to be done first.

### First

Import the package into an existing project by going to File -> Add Packages -> And use the url: <https://github.com/BrandEmbassy/cxone-mobile-sdk-ios.git>

### Second

Once imported, in order to use a <ws://> or <wss://> url, you must enable `Allow Arbitrary Loads` in `App Transport Security Settings` and set it to true.

```
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
</dict>
```

### Third

Now inside of your Storyboard in your project, make a UINavigationController and give it the class of ChatNavigationViewController. Et Voila! 

For further information, look at our example projects. :]
