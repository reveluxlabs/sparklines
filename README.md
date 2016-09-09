# sparklines
Sparklines and Whisker Sparklines for Swift

A complete rewrite of [Andy Belsey's](https://github.com/abelsey/Sparklines) objective-c implementation of sparklines with the addition of whisker sparklines.

See [Tufte](http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=0001OR)

So far, the only documentation is the sample app.

## App Architecture

The app makes broad use protocols, extensions, and structures. An understanding of [protocol-oriented programming](https://developer.apple.com/videos/play/wwdc2015/408/) will aid greatly in hacking on this codebase.

The six key files are:

* LineSparkLine.swift--struct that implements the LineSparkLinePlotter protocol
* LineSparkLinePlotter.swift--the protocol and extension for line sparklines
* WhiskerSparkLine.swift--struct that implements the WhiskerSparkLinePlotter protocol
* WhiskerSparkLinePlotter.swift--the protocol and extension for whisker sparklines
* SparkLinePlotter.swift--the protocol and extension for the shared functions, inherited by line & whisker
* Renderer.swift--the renderer for drawing

## Building the App & tests

The app should run as is...

The only scheme the sample app display has been tested on is a landscape 6s Plus.

The tests depend on Nimble expectations. Carthage is used to load the framework.

A 

```shell
carthage update --platform "ios"
```

will do wonders.

## TO DOs

* More tests
* Add line sparkline data source
