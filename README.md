# What is Nearby?

Nearby is an iOS peer-to-peer chat app that works offline via Bluetooth and WiFi with the help of Apple's MultipeerConnectivity framework.

It supports two parallel sessions, one hosted on each device, and anther that can be used to join other peers. It also has configurable user profiles with avatars and display names which are visible in chat. 

# Why did I make this?

The main goal is to show off some of my code publicly, though it's still very much work in progress 😊 

I also think there's something pretty cool about the offline/peer-to-peer nature of MultipeerConnectivity, and there aren't that many open source projects that use it. 

# Technical stuff

I've implemented everything from scratch using only 2 libraries (added via Swift Package Manager) - [ReSwift](https://github.com/ReSwift/ReSwift) (for Redux architectural backbone) and [SnapKit](https://github.com/SnapKit/SnapKit) (for programatic UI/constraints). 

I find ReSwift/Redux useful because it forces you to conceptualize the app's various states (AppState < BrowserState, ChatState, etc.) and consider what actions are possible. Because of its unidirectional data flow and immutable nature it can be really helpful for testing - simply dispatch an action and verify the state change.

I added a `ChatManager` singleton to manage the "discovery" (i.e. browsing and advertising) and the two `ChatClients` - host and guest. It communicates with the rest of the app via the `Store` (Redux layer, containing/managing the state). The View layer is built programatically using SnapKit and currently uses MVC. Most of the logic happens in the various states' `middleware`s (for side effects, like sending/handling invitations and messages) and `reducer`s (for actually updating the state).
  
# Demo (YouTube)
<div align="center">
      <a href="https://www.youtube.com/watch?v=nVeQ5MOtQE8">
         <img src="https://img.youtube.com/vi/nVeQ5MOtQE8/0.jpg" style="width:100%;">
      </a>
</div>
