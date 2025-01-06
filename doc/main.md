# Documentation

[[_TOC_]]

## Database Models

### Chat

```typescript
type Chat = {
  last_message: TimeStamp
  users:        string[]
}
```

#### Chat.messages

> Every chat document contains a `messages` collection which stores the messages in this format:

```typescript
type Message = {
  from:      string
  images:    string[]
  status:    "read" | "delivered" | "sent"
  text:      string
  timestamp: Timestamp
}

```

> The message either contains an Array of images or a text (currently the images array only stores one image, but it could be extended in the future)

### Notifications

When someone creates a new document in this collection, it triggers a cloud function that sends a fcm message with the parameters provided in the document.

```typescript
type Notification = {
  title: string
  token: string
  body?: string
  imageUrl?: string
  data?: { [key: string]: string } | undefined
}
```

The data field is used to treat the notification different in the frontend and the backend.

If the Notification is a new chat message, the data field looks like this:

```typescript
const data = {
  chatId: "<chatId>",
  click_action: "FLUTTER_NOTIFICATION_CLICK",
  type: "chatMessage"
}
```

This tells the App to open the chat with the given id when the user clicks on the Notification.

### Users

```typescript
type User = {
  // all the user ids that winked to this user
  current_winks: string[]
  // the display name
  name: string
  // the phone number
  phoneNumber: string
  // url for the profile picture
  imageUrl: string
  // url to the thumbnail of the profile picture
  thumbnail: string
  // current position
  position: {
    // We use geohashing to efficiently
    // query close users
    geohash:  string
    // The precise location
    geopoint: GeoPoint
  }
  // number of received winks
  winksCount: number;
  // number of purchased winks
  premiumWinks: number;
  // number of currently remaining winks,
  // which renew each month
  remainingWinks: number;
  // currently pinned user
  pinnedUsers: PinnedUser[];
  // GhostMode
  ghostMode: boolean;
  // all the user ids this user has winked to
  winkedTo: string[];
  // the zodiac sign
  zodiac: string;
  // A object that saves when you last pinned
  // a user and how many users you have
  // currently pinned
  pinnedInfo: {
    count: number
    day:   Timestamp
  };
  // the fcm token of the device
  // (used to send Notifications)
  fcmToken: string;
  // true if the user purchased the unlimited
  // subscription
  unlimited: bool;
  // true if the account has root privileges
  admin: bool;
}

type PinnedUser = {
  // Timestamp when the user for pinned
  // (so we can remove them after 2 hours)
  timestamp: Timestamp
  // the id of the pinned user
  id: string
  // The position of the pinned user when the
  // user pinned them
  position: {
    geohash: string
    geopoint: GeoPoint
  }
}
```

## Notification handling

When the user receives a notification while the app is open, the [Messaging Service](/lib/app/global/messaging.dart) handles the notifications depending on the data.

The messaging service displays a Snackbar at the top of the screen with the content, and if it's a chat message, you can click on the Snackbar to open the chat.

## Updating the location in realtime

We use the package [Flutter Background Geolocation](https://pub.dev/packages/flutter_background_geolocation) to update the location, even if the app is closed or in the background.

The location tracking gets initialized in the `onInit()` function of the [Home Controller](/lib/app/modules/home/controllers/home_controller.dart)

### Ghost Mode

Ghost mode is a special feature that turns off the location tracking and makes you invisible to every user, but the app won't update other users while you have ghost mode on.

## Home Controller

The [Home Controller](/lib/app/modules/home/controllers/home_controller.dart) manages most of the Apps logic, like winking to a user, updating the location etc.

## Account Controller

The [Account Controller](/lib/app/modules/auth/controllers/account_controller.dart) keeps track of the current user's data and updated it when something on the backend changes.
