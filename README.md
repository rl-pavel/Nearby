# What is Nearby?

Nearby is an iOS peer-to-peer chat app that works offline via Bluetooth and WiFi with the help of Apple's MultipeerConnectivity framework.

It supports two parallel sessions, one hosted on each device, and anther that can be used to join other peers. It also has configurable user profiles with avatars and display names which are visible in chat. 

The app is still a work in progress, so more features are coming 🙂

# Technical Stuff

I've designed and implemented everything from scratch using 2 libraries (added via Swift Package Manager) - [ReSwift](https://github.com/ReSwift/ReSwift) (for Redux architectural backbone) and [SnapKit](https://github.com/SnapKit/SnapKit) (for programatic UI/constraints). 

I find ReSwift/Redux useful because it forces you to conceptualize the app's various states and consider what actions are required. It's also pretty helpful with managing parallel sessions using separate reducers, so the user can host/receive messages in their chat while participating in another user's session. Because of its unidirectional data flow and immutable nature, it can be really helpful for testing - simply dispatch an action and verify the state change.

I added a `ChatManager` singleton to manage the "discovery" (i.e. browsing and advertising) and the two `ChatClient`s - host and guest. It communicates with the rest of the app via the `Store` (Redux layer, containing/managing the state). The view layer is built programmatically using SnapKit and currently uses MVC. Most of the logic happens in the various states' `middleware`s (for side effects, like sending/handling invitations and messages) and `reducer`s (for actually updating the state).
  
# 30s Demo on YouTube:
[![](http://img.youtube.com/vi/nVeQ5MOtQE8/0.jpg)](http://www.youtube.com/watch?v=nVeQ5MOtQE8 "Nearby Demo")
