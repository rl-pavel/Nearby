# What is Nearby? 

Nearby is an iOS peer-to-peer chat app that works offline via Bluetooth and WiFi with the help of Apple's `MultipeerConnectivity` framework.

It supports two parallel sessions, one hosted on each device, and anther that can be used to join other peers. It also has configurable user profiles with avatars and display names which are visible in chat. The app is built using appearance adaptive colors and dynamic type for text accessibility.

You can [watch a 30s demo on YouTube](http://www.youtube.com/watch?v=nVeQ5MOtQE8).

# Technical Stuff

I've designed and implemented everything from scratch using 2 libraries added via Swift Package Manager - [ReSwift](https://github.com/ReSwift/ReSwift) (for Redux architectural backbone) and [SnapKit](https://github.com/SnapKit/SnapKit) (for programatic UI/constraints). 

### About Redux 
This is where the majority of the business logic is written. The way Redux works is that there's a `Store` object that manages the app's states, reducers and middlewares. To alter the states or emit a side-effect, you dispatch `Action`s, which goes through the `Store`'s layers, update the state and notify the observers. 

Middleware is a layer in between the dispatched action and reducers, and gets called first. It takes an action and returns an _optional_ action. This is intended for side-effects, like asynchronous tasks, or accessing preferences, and can also dispatch (or break off) additional actions.

Reducers get called after, which take an action and the current state and return a new state. To observe the state, objects can subscribe to the `Store` and get notified about a state (or sub-state) changes.

Nearby currently has 3 state types (along with the respective middlewares, reducers):
1. AppState, which is the main state and manages the other sub-states.
2. BrowserState, which manages the list of chats the user can join.
3. ChatState, which manages the active chat(s).

I really like how Redux forces you to conceptualize the app's various states and consider what actions are possible/required to alter it. One of the biggest upsides of Redux is how it makes testing the business logic quite simple due to its unidirectional data flow - you dispatch and action and validate the state change. There's also potential to inject custom middlewares to verify which actions have been dispatched and when, which helps testing things _outside_ of the state, like controllers, view models, etc.

### Testing
One of the most important things for testability is dependency injection. I decided to implement something like a Service Locator Pattern, which I learned about in this [talk](https://www.youtube.com/watch?v=dA9rGQRwHGs)/[article](https://noahgilmore.com/blog/swift-dependency-injection/) but never used before. What I like about it is the simplicity, both in terms of implementation and (lack of) added boilerplate in code. It's quite flexible, allowing injection of anything from singleton instances (or mocks thereof) to custom initializers like `Date`. I also like how easy it is to add into a pre-existing project gradually. 

So far I've implemented tests for the core logic in each of the states, which covers things like discovery, invitation and connection handling, profile updates and sending/receiving messages in both the hosting and guest sessions. And all the tests are executed using Bitrise CI.
