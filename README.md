![Xcode: 13.0](https://img.shields.io/badge/Xcode-13.0-lightgrey.svg) ![Swift: 5.5](https://img.shields.io/badge/Swift-5.5-lightgrey.svg) ![iOS: 11 | 12 | 13 | 14| 15](https://img.shields.io/badge/iOS-11%20|%2012%20|%2013%20|%2014|%2015-lightgrey.svg) ![devices: iPhone | iPad](https://img.shields.io/badge/devices-iPad%20|%20iPhone-lightgrey.svg)

![WaterMe App Icon](/WaterMe/WaterMe/Assets.xcassets/WaterMeIcon.imageset/all-1x.png)
# WaterMe - Gardening Reminders

WaterMe is an open source iOS application that is available for free on the App Store. Its a small app by any measure, but its my baby and I love it. According to App Store analytics, the app has about 3,300 Monthly Active Devices with 42,000 Monthly Sessions. WaterMe is under active development and I welcome feature requests and pull requests.

[📲 App Store Link](https://itunes.apple.com/app/waterme/id1089742494)<br>
[🕊 TestFlight Link](https://testflight.apple.com/join/C9vDCb25)

## App Store Screenshots

1  |2  |3  |4  |5
:-:|:-:|:-:|:-:|:-:
![1](/Screenshots/2.5/5.8%20-%20iPhone%2011%20Pro/en-01.png)|![2](/Screenshots/2.5/5.8%20-%20iPhone%2011%20Pro/en-02.png)|![3](/Screenshots/2.5/5.8%20-%20iPhone%2011%20Pro/en-03.png)|![4](/Screenshots/2.5/5.8%20-%20iPhone%2011%20Pro/en-04.png)|![5](/Screenshots/2.5/5.8%20-%20iPhone%2011%20Pro/en-05.png)

## App Store Description

Never let another plant turn brown again. WaterMe reminds you when to tend to the plants in your garden:

1. Add your plants into the app.
1. Add reminders for watering, fertilizing, etc.
1. Get 1 notification every day reminding you which plants need care.
1. Take care of the plant in real life.
1. Drag and drop the reminder to mark it as complete.

Thats it! Every day you'll get one, and only one, notification that reminds you to take care of your plants.

- Supports multiple kinds of reminders per plant
- Water, Fertilize, Trim, and more
- Easy to see which plants need to be taken care of and when.
- Supports working quickly with Drag and Drop interface.
- Customize the time notifications are sent every day.
- Tip Jar In-App Purchases allow you to directly support the development of WaterMe.
- Fully supports iPhone X.
- Fully supports Split Screen and Slide Over iPad Multitasking.
- Fully supports Dynamic Type.
- Fully supports Voiceover and other iOS accessibility features.
- Does not yet support syncing plants between multiple devices.

## Why GPL License?

I want WaterMe to be open source but I don't want people to republish the app with a different name on the App Store. Please do not fork this project and submit to the App Store under your own account. The GPL requires that you give the original developer credit and it also requires that the modified app also be open source. So please don't do this.

WaterMe is a full application, not a library. The code is not generic enough to be a separate library. I would love to work on extracting the reusable code into an MIT licensed library. But right now the code can only be used to fix issues or to take as inspiration for other projects, NOT to use without modification.

## Code of Conduct

WaterMe has a [Code of Conduct](/CODE_OF_CONDUCT.md) for its community on Github. I want all people that participate in issues, comments, pull requests, or any other part of the project to feel safe from harassment. Every person must treat every other person with respect and dignity or else face banning from the community. If you feel someone has not treated you with respect, [please let me know in private](mailto:watermeconduct@jeffburg.com).
    
## Guidelines for Contributing

I am happy to have others contribute to WaterMe. Because WaterMe is a shipping app in the App Store, I won't accept just any new feature. I want the app to have a concise featureset and a consistent UI. So please adhere to the guidelines listed below so you don't contribute work that might get rejected.

### Do's

1. **Do** go through open issues and look for an issue you are interested in tackling.
1. **Do** create a new issue if one doesn't exist.
1. **Do** make sure the issue has a clear design mentioned in the issue or in a comment that I've given a 👍 to.
1. **Do** provide a visual design and/or code design in the issue if you have one.
1. **Do** mention that you intend to work on the issue.
1. **Do** implement that design and submit a pull request.

### Don'ts

1. **Don't** work on an issue that doesn't have a clear design that I've given a 👍 to
    - Just because the problem is solved, doesn't mean that its solved in a simple way with a consistent UI.
    - Making sure there is a clear design before work begins is important to making sure WaterMe stays simple and beautiful.
1. **Don't** break any App Store rules in your changes.
1. **Don't** add a new Cocoapod or other third party code/assets unless its been discussed.

## Check Existing Issues

- [Existing Issues for WaterMe](https://github.com/jeffreybergier/WaterMe2/issues)

## How to Clone and Run

### Requirements

- Xcode 12.2 or higher

### Instructions

1. Clone the Repo: 
    ```
    git clone 'https://github.com/jeffreybergier/WaterMe.git'
    ```
1. Change Team to your AppleID (needed to run on your physical device)
    1. Open `WaterMe.xcodeproj` in Xcode.
    1. Browse to the General tab of the WaterMe Target.
    1. Under Signing, change the team from its current setting to your AppleID.
1. Build and Run
    - WaterMe uses Swift Package Manager. When opening the first time, Xcode may take a few minutes to resolve dependencies.
    - WaterMe works in the simulator and on physical devices.
    
### Caveats

There are 2 files that are placeholders for storage in the repository. Please don't change these files and include them in a pull request. These files are overwritten by me when I build on my computer and for the App Store.

1. [`emojione-apple.ttc`](/WaterMe/WaterMe/emojione-apple.ttc)
    - WaterMe uses [EmojiOne](https://www.emojione.com) emoji rather than the built-in emoji. This is because Apple rejected the app for using Apple's artwork. Using this alternative emoji font avoid this rejection.
    - The font file is not mine so I don't want to commit it into the repo. The application works fine without this font, it just can't be submitted to the app store. 
1. [`PrivateKeys.swift`](/WaterMe/Frameworks/Calculate/Calculate/PrivateKeys.swift)
    - This file stores keys that I don't want commited to the repo.
    - This file has placeholder values and the app can handle not having this information without crashing.
    - However, it can't be submitted to the App Store without this information
