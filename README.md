# Flickr Trackr

### Requirements

- iOS 11.4+
- Xcode 10.0+
- Swift 4.2+

### How to run the project

This project does not use any additional package manager. Simply open the main project file `KomootChallenge.xcodeproj` in Xcode and click Run. Please note that you might need to change selected developer certificate and provisioning profile in order to make it build.

In order actually generate some location data in the simulator in order to test the app, you can use the file `Bike-Ride-Prague-12km.gpx` from Xcode project which was generated by a real bike ride near Prague.

## Project description

This application shows a list of images from Flickr collected every 100 meters during walks.

The user is starting the app and presses the start button. After that he puts the phone into his pocket and starts walking, every 100 meters a picture for his location is requested from the flickr photo search api and added to his stream. New pictures are added on top.
Any time he takes a look at his phone he sees the most recent picture and can scroll through a stream of pictures which shows him impressions of where he has been. It should work at least for a two hour walk.
The user interface should be simple as shown on the left of this page.

## Architecture

When possible (and suitable), Flickr Trackr follows MVVM architecture. In order to simplify things, no additional framework for reactive-programing (e.g.: RxSwift) is used. Bidning is implemented with Swift closures.

## Project structure

The whole project is structured around just one scene which represents one screen in the app. This one scene consits of at one `ViewController` and `ViewModel`.

All the other files are structure in their particular category, e.g. `Views`, `Model`, `Networking`, etc.

## Testing

The project has several unit tests and a few integration tests implemented. No UI tests. The tests are written using the standart `XCTest` framework and are mainly focused on JSON parsing.


