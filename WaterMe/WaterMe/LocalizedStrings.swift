//
//  LocalizedStrings.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/12/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import Calculate
import Datum

// swiftlint:disable file_length

extension UIApplication {
    enum LocalizedString {
        static let appTitle =
            NSLocalizedString("WaterMe",
                              comment: "Name of the app. Shows in various places like Navigation Bars and Alerts.")
        static let editVessel =
            NSLocalizedString("Edit Plant",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the plant that owns the reminder.")
        static let editReminder =
            NSLocalizedString("Edit Reminder",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will allow the user to edit the details of the reminder.")
    }
}

extension OptionalAddButtonTableViewHeaderFooterView {
    enum LocalizedString {
        static let addReminder =
            NSLocalizedString("Add Reminder",
                              comment: "Edit Plant: Button: Add Reminder: When tapped, a reminder is added to the current plant.")
        static let addReminderShort =
            NSLocalizedString("Add",
                              comment: "Edit Plant: Button: Add Reminder: Accessible: When tapped, a reminder is added to the current plant. When very large font sizes are used, this much shorter string is used.")
    }
}

enum LocalizedString {
    enum ReminderVessel {
        static let untitledPlant =
            NSLocalizedString("My Plant",
                              comment: "Name shown to the user when they have not given the plant a specific name.")
        static let photo =
            NSLocalizedString("Photo",
                              comment: "Describes the photo or emoji that is associated with an individual plant. Each plant can have only 1 photo")
        static let name =
            NSLocalizedString("Name",
                              comment: "Describes the name associated with an individual plant. The user can choose any name they like. Each plant can have only 1 name.")
        static let reminders =
            NSLocalizedString("Reminders",
                              comment: "Describes all the reminders that are associated with an individual plant. Each plant can have many reminders.")
    }
}

extension ReminderMainViewController {
    enum LocalizedString {
        static let nextPerformLabelNow =
            NSLocalizedString("Now",
                              comment: "Displayed to the user for Reminders that need to be performed now.")
        static let timeAgoLabelNever =
            NSLocalizedString("Never",
                              comment: "When a reminder has never been performed, this shows to the user rather than how long ago they last performed the reminder.")
        static let buttonTitleReminderPerform =
            NSLocalizedString("Mark Reminder as Done",
                              comment: "Button Title in an Alert. Shows when the user taps on a reminder. After being selected, this will mark the reminder as performed.")
        static let dragAndDropInstructionalText =
            NSLocalizedString("Drag and Drop Here",
                              comment: "ReminderMainViewController: Instructional text that instructs the user and drag and drop to this location to mark the reminder as done.")
        static let reminderAlertTitle =
            NSLocalizedString("%@ – %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Title: 2 Arguments: When the user taps on a reminder, this is the title of the alert if the plant has a name. It tells the user the kind of reminder and the name of the plant. e.g. ‘Water Plant - My Cool Plant’")
        static let reminderAlertMessage1Arg =
            NSLocalizedString("Due: %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Message: 1 Argument: When the user taps on a reminder, this is the message of the alert when the reminder does not have a note. It tells the user the Due date of the reminder. The due date is provided by the system already localized.")
        static let reminderAlertMessage2Arg =
            NSLocalizedString("Due: %@\nNote: %@",
                              comment: "ReminderMainViewController: Select Reminder Alert Message: 2 Arguments: When the user taps on a reminder, this is the message of the alert when the reminder has a note. It tells the user the Due date of the reminder and the note. The due date is provided by the system already localized.")
    }
}

extension UIAlertController {
    enum LocalizedString {
        static let buttonTitleChoosePhoto =
            NSLocalizedString("Choose a Photo",
                              comment: "Button Title in an Alert that allows the user to open the Camera, Photo Picker, or Emoji Picker Screen.")
        static let titleNewEmojiPhotoExistingPhoto =
            NSLocalizedString("View the current photo or choose a new photo or emoji for your plant.",
                              comment: "Title of an Alert that tells the user that they can choose a new photo or emoji for their plant or they can view the current photo for their plant.")

        static let titleNewEmojiPhoto =
            NSLocalizedString("Choose a new emoji or photo for your plant.",
                              comment: "Title of an Alert that tells the user that they can choose a new photo or emoji for their plant.")
        static let buttonTitleEmoji =
            NSLocalizedString("Emoji",
                              comment: "Button Title in an Alert that allows the user to open a screen where they can choose from various emoji instead of a photo for their plant.")
        static let buttonTitlePhotos =
            NSLocalizedString("Photos",
                              comment: "Button Title in an Alert that allows the user to open the photo library on their phone to choose a photo.")
        static let buttonTitleViewPhoto =
            NSLocalizedString("View Current Photo",
                              comment: "Button Title in an Alert that allows the user to view the existing photo full-screen.")
        static let buttonTitleCamera =
            NSLocalizedString("Camera",
                              comment: "Button Title in an Alert that allows the user to open the camera and take a new photo.")
        static let buttonTitleCameraLocked =
            NSLocalizedString("Camera 🔒",
                              comment: "Button Title in an Alert that allows the user to open the camera and take a new photo. In this case, the user has denied access to the camera.")
        static let buttonTitlePause =
            NSLocalizedString("Pause Notifications",
                              comment: "Button Title in an Alert that allows the user to pause notifications for a reminder")
        static let buttonTitlePauseShort =
            NSLocalizedString("Pause",
                              comment: "Button Title in an Alert that allows the user to pause notifications for a reminder")
        static let buttonTitleUnpauseShort =
            NSLocalizedString("Unpause",
                              comment: "Button Title in an Alert that allows the user to unpause/resume notifications for a reminder")
        static let buttonTitleDelete =
            NSLocalizedString("Delete",
                              comment: "Button that allows the user to delete a reminder or a plant.")
        static let buttonTitleAddPlant =
            NSLocalizedString("Add Plant",
                              comment: "Button that allows the user to add a new plant.")
        static let buttonTitleDismiss =
            NSLocalizedString("Dismiss",
                              comment: "Button Title in an Alert to close the alert. This button title normally only appears when there are no other options in the alert.")
        static let buttonTitleDontDelete =
            NSLocalizedString("Don’t Delete",
                              comment: "Alert: Delete Confirmation: Button Title: When the user is being asked to confirm to delete an item, this button lets them not delete it.")
        static let buttonTitleCancel =
            NSLocalizedString("Cancel",
                              comment: "Button Title in an Alert to close the alert without saving any changes.")
        static let buttonTitleSaveAnyway =
            NSLocalizedString("Save Anyway",
                              comment: "Button Title in an Alert to save the reminder or plant even though all of the fields have not been filled in yet. Fields not yet filled in could include Name, Photo, Reminders.")
        static let titleUnsolvedIssues =
            NSLocalizedString("There are some issues you might want to resolve.",
                              comment: "Title of an Alert that tells the user that they are trying to save a Plant or Reminder and they have not filled in all the fields. They may want to cancel the save and go back and fill them in. Or they may want to Save the changes anyway. Fields not filled in could include, Name, Photo, Reminders.")
        static let newPermissionTitle: String =
            NSLocalizedString("Push Notifications",
                              comment: "Alert: New Permission: Title: Title of the alert that asks the user if they want to grant notification permissions.")
        static let newPermissionMessage: String =
            NSLocalizedString("Do you want WaterMe to send notifications when your plants need attention? WaterMe sends no more than 1 per day.",
                              comment: "Alert: New Permission: Message: Message of the alert that asks the user if they want to grant notification permissions.")
        static let newPermissionButtonTitleSendNotifications: String =
            NSLocalizedString("Send Notifications",
                              comment: "Alert: New Permission: Button Title: Send Notifications: Title of the button that will result in the user being presented the system dialog to grant notification permissions.")
        static let newPermissionButtonTitleDontSendNotifications: String =
            NSLocalizedString("Don’t Send Notifications",
                              comment: "Alert: New Permission: Button Title: Don’t Send Notifications: Title of the button that will result in the user not being asked for permissions ever again.")
        static let permissionDeniedAlertTitle =
            NSLocalizedString("Can’t Send Push Notifications",
                              comment: "Alert: Permission Denied: Title: Title of the alert that tells the user that notification permissions are denied.")
        static let permissionDeniedAlertMessage =
            NSLocalizedString("Permissions to send notifications have been denied. If you would like to receive notifications when your plants need to be attened to, tap the ‘Open Settings’ button below.",
                              comment: "Alert: Permission Denied: Message: Message of the alert that tells the user that notification permissions are denied. It asks the user to open Settings.")
        static let buttonTitleDontAskAgain: String =
            NSLocalizedString("Don’t Ask Again",
                              comment: "Alert: New Permission: Button Title: Don’t Ask Again: Button title that will stop the app from asking the user to do this action again in the future.")
        static let deleteAlertMessage: String =
            NSLocalizedString("Are you sure you want to delete this?",
                              comment: "Alert: Delete: Message: Message of the alert that asks the user if they want to delete this item.")
        static let copyEmailAlertButtonTitle: String =
            NSLocalizedString("Copy Email Address",
                              comment: "Alert: Email Copy: Button Title and Alert Title: When the user taps this button, the developers email address is copied into the users clipboard so the user can paste it into their favorite email app.")
        static let copyEmailAlertMessage: String =
            NSLocalizedString("Copy my email address into your clipboard, then paste it in your favorite email app.",
                              comment: "Alert: Email Copy: Message: Alert message that tells the user that they can copy my email address into their clipboard and paste it in their favorite email app.")
        static let updateAvailableAlertTitle: String =
            NSLocalizedString("Update Available",
                              comment: "Alert: App Update: Title: Alert title that tells the user that an update is available for WaterMe")
        static let updateAvailableAlertMessage: String =
            NSLocalizedString("Thank you for using WaterMe. A newer version is now available on the App Store. There’s no rush, you can update now or later.",
                              comment: "Alert: App Update: Message: Alert title that tells the user that an update is available for WaterMe")
        static let updateAvailableTestFlightAlertMessage: String =
            NSLocalizedString("Thank you for beta testing WaterMe. A newer version is now available on the App Store. There’s no rush, you can update now or later.",
                              comment: "Alert: App Update: Message: Alert title that tells TestFlight beta users that an update is available for WaterMe")
        static let updateAvailableButtonTitleOpenAppStore: String =
            NSLocalizedString("Open App Store",
                              comment: "Alert: App Update: Button Title: Button title that allows the user to open the app store in order to update WaterMe.")
        static let darkModeImproperTitle: String =
            NSLocalizedString("Dark Mode",
                              comment: "Alert: Dark Mode Improper: Title: Title of alert that is presented when Dark Mode settings are configured on iOS 11 or 12.")
        static let darkModeImproperMessage: String =
            NSLocalizedString("The dark mode settings for WaterMe only work when running iOS 13 or higher.",
                              comment: "Alert: Dark Mode Improper: Message: Message of alert that is presented when Dark Mode settings are configured on iOS 11 or 12.")

    }
}

extension EmailDeveloperViewController {
    enum LocalizedString {
        static let subject =
            NSLocalizedString("I have an idea for WaterMe!",
                              comment: "Email Compose: Subject: Shows in the subject line when an iOS in-app mail sheet is presented.")
    }
}

extension ReminderKind {
    enum LocalizedString {
        static let waterLong =
            NSLocalizedString("Water Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to water their plant.")
        static let fertilizeLong =
            NSLocalizedString("Fertilize Soil",
                              comment: "Reminder Kind: Long Description: This type reminds the user to fertilize their plant.")
        static let trimLong =
            NSLocalizedString("Trim Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to trim their plant.")
        static let mistLong =
            NSLocalizedString("Mist Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to mist their plant.")
        static let moveLong =
            NSLocalizedString("Move Plant",
                              comment: "Reminder Kind: Long Description: This type reminds the user to move their plant.")
        static let waterShort =
            NSLocalizedString("Water",
                              comment: "Reminder Kind: Short Description: This type reminds the user to water their plant.")
        static let fertilizeShort =
            NSLocalizedString("Fertilize",
                              comment: "Reminder Kind: Short Description: This type reminds the user to fertilize their plant.")
        static let trimShort =
            NSLocalizedString("Trim",
                              comment: "Reminder Kind: Short Description: This type reminds the user to trim their plant.")
        static let mistShort =
            NSLocalizedString("Mist",
                              comment: "Reminder Kind: Short Description: This type reminds the user to mist their plant.")
        static let moveShort =
            NSLocalizedString("Move",
                              comment: "Reminder Kind: Short Description: This type reminds the user to move their plant.")
        static let other =
            NSLocalizedString("Other",
                              comment: "Reminder Kind: This type reminds the user to do something the user entered.")
    }
}

extension ReminderVesselMainViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Plants",
                              comment: "Title of the screen where the user can manage their plants. Also, title of the button that opens this screen.")
    }
}

extension ReminderSummaryViewController {
    enum LocalizedString {
        static let subheadPlantName =
            NSLocalizedString("Plant",
                              comment: "View Reminder: Section Header: Shows the plant name.")
        static let subheadReminderKind =
            NSLocalizedString("Reminder",
                              comment: "View Reminder: Section Header: Shows the kind of reminder.")
        static let subheadNextPerformDate =
            NSLocalizedString("Due Next",
                              comment: "View Reminder: Section Header: Shows the next perform date")
        static let subheadMoveTo =
            NSLocalizedString("Location",
                              comment: "View Reminder: Section Header: Shows where the user has selected to move their plant.")
    }
}

extension SettingsMainViewController {
    enum LocalizedString {
        static let settingsTitle =
            NSLocalizedString("Settings",
                              comment: "Button title that opens both the in-app settings screen and the iOS settings screen for WaterMe.")
        static let title =
            NSLocalizedString("Tip Jar",
                              comment: "Screen title for the settings screen. Also used for button titles to open the Settings screen.")
        static let cellTitleOpenSettings =
            NSLocalizedString("Open Settings",
                              comment: "Settings: Cell Title: Open Settings: When tapped this opens the iOS settings app to the WaterMe screen.")
        static let cellTitleEmailDeveloper =
            NSLocalizedString("Email Developer",
                              comment: "Settings: Cell Title: Email Developer: When tapped, this opens an email screen to email the developer.")
        static let cellTitleTipJarFree =
            NSLocalizedString("Write App Review",
                              comment: "Settings: Cell Title: Tip Jar Free: When tapped, this opens an screen to review the app.")
        static let cellPriceTipJarFree =
            NSLocalizedString("Free",
                              comment: "Settings: Cell Price: Price of leaving a review on the app store... Free")
        static let cellTitleInfo =
            NSLocalizedString("I’m Jeff, a professional iOS Developer and UX Designer. I like making small and polished apps in my spare time. If you find WaterMe useful and would like to fund its development, consider supporting the app with the buttons below.",
                              comment: "Settings: Info Cell: Title: Text in the tip jar area that explains why someone should give money.")

    }
}

extension ReminderIntervalPickerViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Reminder Interval",
                              comment: "Reminder Interval Chooser: Title")
    }
}

extension ReminderVesselEditViewController {
    enum LocalizedString {
        static let rowLabelInterval =
            NSLocalizedString("Every: ",
                              comment: "Data Label: Reminder Interval: Value of the text next to the label is how often the user wants to be reminded to tend to their plant.")
        static let rowLabelLocation =
            NSLocalizedString("Location: ",
                              comment: "Data Label: Location: Value of the text next to the label is the location where the user wants to be reminded to move their plant.")
        static let rowLabelDescription =
            NSLocalizedString("Description: ",
                              comment: "Data Label: Description: Value of the text next to the label is what the user wants to be reminded to do to their plant.")
        static let rowValueLabelLocationNoValue =
            NSLocalizedString("No Location Entered",
                              comment: "Data Value: Location not entered: This is the placeholder value if the user does not enter a location for their move plant reminder.")
        static let rowValueLabelDescriptionNoValue =
            NSLocalizedString("No Description Entered",
                              comment: "Data Value: Description not entered: This is the placeholder value if the user does not enter a description for what they want to be reminded to do to their plant.")
        static let alertTitleCameraRestricted =
            NSLocalizedString("Camera Restricted",
                              comment: "Alert Title: Camera Restricted: We can’t access the camera because it is not allowed by an IT policy / parent control.")
        static let alertBodyCameraRestricted =
            NSLocalizedString("WaterMe cannot access your camera. This feature has been restricted by this device’s administrator.",
                              comment: "Alert Body: Camera Restricted: We can’t access the camera because it is not allowed by an IT policy / parent control. This text needs to explain the problem.")
        static let alertTitlePermissionDenied =
            NSLocalizedString("Permission Denied",
                              comment: "Alert Title: Permission Denied: We can’t access a feature of the device because the user has denied permission.")
        static let alertBodyCameraDenied =
            NSLocalizedString("WaterMe cannot access your camera. You can grant access in Settings",
                              comment: "Alert Body: Camera Denied: We can’t access the camera because it has been denied by the user. The text needs to explain they can fix this by tapping the Settings button on the alert.")
    }
}

extension EmojiPickerViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Choose an Emoji",
                              comment: "Title of the view controller that allows a user to choose an emoji for the photo of their plant. Is shown in navigation bar.")
    }
}

extension ReminderEditViewController {
    enum LocalizedString {
        static let sectionTitleKind =
            NSLocalizedString("Kind of Reminder",
                              comment: "Edit Reminder: Section Title: Describes the section that asks them pick the kind of reminder. Possibilities are Water, Fertilize, Move, Other.")
        static let sectionTitleDetails =
            NSLocalizedString("Details",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter details for Move or Other reminder types.")
        static let sectionTitleInterval =
            NSLocalizedString("Remind Every",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter how often they want to be reminded.")
        static let sectionTitleNotifications =
            NSLocalizedString("Notifications",
                              comment: "Edit Reminder: Section Title: Describes the section that allows the user to edit notification settings")
        static let sectionTitleNotes =
            NSLocalizedString("Notes",
                              comment: "Edit Reminder: Section Title: Describes the section that asks the user to enter any optional notes.")
        static let sectionTitleLastPerformed =
            NSLocalizedString("Last Performed",
                              comment: "Edit Reminder: Section Title: Describes the section that displays when the reminder was last performed.")
        static let dataEntryLabelMove =
            NSLocalizedString("Move to",
                              comment: "Edit Reminder: Data Entry Label: The label to the left of a text field. The user should type where they want to move their plant to in the textfield.")
        static let dataEntryLabelDescription =
            NSLocalizedString("Description",
                              comment: "Edit Reminder: Data Entry Label: The label to the left of a text field. The user should type a description of what they want to be reminded to do to their plant.")
        static let dataEntryPlaceholderMove =
            NSLocalizedString("Other side of the yard.",
                              comment: "Edit Reminder: Data Entry Placeholder: Placeholder text in a textfield. The user should type in where they want to move their plant.")
        static let dataEntryPlaceholderDescription =
            NSLocalizedString("Trim the leaves and throw out the clippings.",
                              comment: "Edit Reminder: Data Entry Placeholder: Placeholder text in a textfield. The user should type in what they want to be reminded to do to their plant.")
        static let viewReminderShortcutLabelText =
            NSLocalizedString("View Summary of Reminder",
                              comment: "Edit Reminder: Siri Shortcut Title: Label for a cell that when tapped, lets the user add a Siri Shortcut for viewing the reminder summary.")
    }
}

extension ReminderUserNotificationController {
    enum LocalizedString {
        static let bodyOneItem =
            NSLocalizedString("‘%@’ needs attention today.",
                              comment: "Notification Body: 1 Item: When 1 plant needs to be taken care of in a day, this is the body text of the notification.")
        static let bodyTwoItems =
            NSLocalizedString("‘%@’ and ‘%@’ need attention today.",
                              comment: "Notification Body: 2 Items: When 2 plants needs to be taken care of in a day, this is the body text of the notification.")
        static let bodyManyItems =
            NSLocalizedString("‘%@’ and %d more plants need attention today.",
                              comment: "Notification Body: Many Items: When more than 2 plants needs to be taken care of in a day, this is the body text of the notification.")
    }
}

extension CoreDataMigratorViewController {
    enum LocalizedString {
        static let subtitle =
            NSLocalizedString("Data Migration",
                              comment: "MigratorScreen: Subtitle: Explains what is happening on the screen.")
        static let subtitleFailure =
            NSLocalizedString("Migration Error",
                              comment: "MigratorScreen: Subtitle: Explains an error ocurred while migrating")
        static let body =
            NSLocalizedString("Sorry for the interruption. A one-time data migration is needed in order to continue using WaterMe.",
                              comment: "MigratorScreen: Body: Body text that explains the one time migration needed to upgrade to the new WaterMe.")
        static let bodyMigrating =
            NSLocalizedString("Don't go to the home screen, change apps, or lock the screen.",
                              comment: "MigratorScreen: Body: Body text that explains that the user should not lock the screen or switch apps until the migration is complete.")
        static let bodySuccess =
            NSLocalizedString("Success! Your plants have been migrated.",
                              comment: "MigratorScreen: Body: Body text that explains that the migration succeeded.")
        static let bodyFailure1 =
            NSLocalizedString("Migration could not be started due to an error. Please try again later.",
                              comment: "MigratorScreen: Body: An error ocurred before migration started.")
        static let bodyFailure2 =
            NSLocalizedString("An error ocurred when cleaning up after migration. Please double-check all of your plants are in WaterMe.",
                              comment: "MigratorScreen: Body: Body text that explains that all data should be migrated but there was an error cleaning up at the end.")
        static let bodyFailure3 =
            NSLocalizedString("One or more plants could not be migrated. Please double-check all of your plants are in WaterMe.",
                              comment: "MigratorScreen: Body: Body text that explains that migration may be incomplete.")
        static let migrateButtonTitle =
            NSLocalizedString("Start Migration",
                              comment: "MigratorScreen: Start Button Title: When the user clicks this button the migration starts.")
        static let migratingButtonTitle =
            NSLocalizedString("Migrating…",
                              comment: "MigratorScreen: Migrating Button Title: After the user starts the migration, the text of the button changes to this to show that migration is in progress.")
        static let cancelButtonTitle =
            NSLocalizedString("Skip for Now",
                              comment: "MigratorScreen: Cancel Button Title: When the user clicks this button the screen is dismissed and the migration does not happen, but next time the app is started, it will ask again.")
        static let deleteButtonTitle =
            NSLocalizedString("Don’t Migrate My Plants",
                              comment: "MigratorScreen: Delete Button Title: When the user clicks this button, the screen is dismissed and it will never appear again and they will not have access to their previous plants. This action is destructive.")
        static let finishButtonTitle =
            NSLocalizedString("Finish",
                              comment: "MigratorScreen: Finish Button Title: After the migration is done, this button allows the user to finish the migration and go back to using the app as normal.")
        static let bodyDeleteConfirmation =
            NSLocalizedString("This cannot be undone",
                              comment: "MigratorScreen: Confirmation that the user does not want to migrate their plants.")
    }
}

extension PurchaseThanksViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Thank You!",
                              comment: "Purchase Thanks: Title: A thank you to the user for supporting WaterMe via In-App Purchase.")
        static let subtitle =
            NSLocalizedString("In-App Purchase",
                              comment: "Purchase Thanks: Subtitle: Reminding the user what we’re thanking them for.")
        static let body =
            NSLocalizedString("Thank you for your purchase. Your support is critical to the continued development of WaterMe.",
                              comment: "Purchase Thanks: Body: Body text thanking the user for their support.")
        static let errorAlertTitle =
            NSLocalizedString("Purchase Error",
                              comment: "Alert: Purchase Error: Title: The title for all purchase error alerts.")
        static let errorNetworkAlertMessage =
            NSLocalizedString("A network error ocurred. Check your data connection and try to purchase again.",
                              comment: "Alert: Purchase Network Error: Message: Message when there was a networking error during the purchase process.")
        static let errorNotAllowedAlertMessage =
            NSLocalizedString("You’re not allowed to make purchases on this device. Thank you for the thought, though ❤️",
                              comment: "Alert: Purchase Not Allowed Error: Message: Message when the user was not allowed to make a purchase.")
        static let errorUnknownAlertMessage =
            NSLocalizedString("An unknown error ocurred during the purchase. Please try again later.",
                              comment: "Alert: Purchase Not Allowed Error: Message: Message when an unknown error ocurred during the purchase.")
    }
}

extension DatumError {
    enum LocalizedString {
        static let realmIsEnabledFalseUnsupportedMessage =
            NSLocalizedString("Pausing notifications not available.",
                              comment: "Realm Error: Pause: Message: Pausing reminders not supported.")
        static let deleteTitle =
            NSLocalizedString("Error Deleting",
                              comment: "Realm Error: Delete: Title: Unable to delete the last reminder associated with a plant.")
        static let deleteMessage =
            NSLocalizedString("Unable to delete this reminder because its the only reminder for this plant. Each plant must have at least one reminder.",
                              comment: "Realm Error: Delete: Message: Unable to delete the last reminder associated with a plant.")
        static let loadTitle =
            NSLocalizedString("Error Loading",
                              comment: "Realm Error: Loading: Title: Error loading the database from disk. The app is probably not usable with this error.")
        static let loadMessage =
            NSLocalizedString("Error loading save file. Check to make sure there is free space available on this device.",
                              comment: "Realm Error: Loading: Message: Error loading the database from disk. The app is probably not usable with this error.")
        static let saveImageTitle =
            NSLocalizedString("Error Saving Photo",
                              comment: "Realm Error: Save Image: Title: Error saving the photo the user took of their plant. User has to take another photo.")
        static let saveImageMessage =
            NSLocalizedString("The selected photo couldn’t be saved. Please take a different photo or choose an emoji.",
                              comment: "Realm Error: Save Image: Message: Error saving the photo the user took of their plant. User has to take another photo.")
        static let saveTitle =
            NSLocalizedString("Error Saving",
                              comment: "Realm Error: Save: Title: There was an error saving changes. The app is probably not usable if this error happens.")
        static let saveMessage =
            NSLocalizedString("Error saving changes. Check to make sure there is free space available on this device.",
                              comment: "Realm Error: Save: Message: There was an error saving changes. The app is probably not usable if this error happens.")
        static let objectDeletedMessage =
            NSLocalizedString("Unable to save changes because the item was deleted. Possibly from another device.",
                              comment: "Realm Error: Object Deleted: Message: Error saving because the object that is being saved has already been deleted.")
        static let maintenanceMessage =
            NSLocalizedString("Error performing maintenance. Check to make sure there is free space available on this device.",
                              comment: "Realm Error: Save: Message: There was an error performing maintenance. The app is probably not usable if this error happens.")
    }
}

extension ReminderSection {
    enum LocalizedString {
        static let late =
            NSLocalizedString("Late",
                              comment: "Reminder Main List: Section Header: Title")
        static let today =
            NSLocalizedString("Today",
                              comment: "Reminder Main List: Section Header: Title")
        static let tomorrow =
            NSLocalizedString("Tomorrow",
                              comment: "Reminder Main List: Section Header: Title")
        static let thisWeek =
            NSLocalizedString("This Week",
                              comment: "Reminder Main List: Section Header: Title")
        static let later =
            NSLocalizedString("Later",
                              comment: "Reminder Main List: Section Header: Title")
        static let pause =
            NSLocalizedString("Paused",
                              comment: "Reminder Main List: Section Header: Title")
    }
}

extension RecoveryAction {
    enum LocalizedString {
        static let missingPhoto =
            NSLocalizedString("Missing Photo",
                              comment: "Error Saving: Plant: Missing Photo: If the user has not chosen a photo or an emoji for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingName =
            NSLocalizedString("Missing Name",
                              comment: "Error Saving: Plant: Missing Name: If the user has not a name for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingReminders =
            NSLocalizedString("Missing Reminders",
                              comment: "Error Saving: Plant: Missing Reminders: If the user has not added at least one reminder for their plant and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingLocation =
            NSLocalizedString("Missing Location",
                              comment: "Error Saving: Reminder: Missing Location: If the user has no entered a location for their move reminder and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingDescription =
            NSLocalizedString("Missing Description",
                              comment: "Error Saving: Reminder: Missing Description: If the user has not entered a description for their other reminder and tries to save, an alert will warn them. This is the button title to fix the error.")
        static let missingEnabled =
            NSLocalizedString("Notifications Paused",
                              comment: "Error Saving: Reminder: Notifications Paused: If the user has paused notifications for the reminder, a warning is presented when they try to save changes to a reminder.")
    }
}

extension CoreSpotlightIndexer {
    enum LocalizedString {
        static var description: String {
            let localizedString = NSLocalizedString("Mark as done, view notes, or edit information.",
                                                    comment: "Spotlight: Description: ViewReminder: Explains to the user that by tapping this spotlight entry they can view the reminder summary screen.")
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString) as String
            } else {
                return localizedString
            }
        }
    }
}

extension UserActivityConfigurator {
    enum LocalizedString {
        static func editVesselTitle(fromVesselName vesselName: String?) -> String {
            let localizedString = NSLocalizedString("Edit %@",
                                                    comment: "SiriShortcut: Title: EditPlant: Shows the plant name that the siri shortcut corresponds to.")
            let vesselName = vesselName ?? WaterMe.LocalizedString.ReminderVessel.untitledPlant
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString, vesselName) as String
            } else {
                return String.localizedStringWithFormat(localizedString, vesselName)
            }
        }
        static func editReminderTitle(for reminderKind: ReminderKind,
                                      andVesselName vesselName: String?) -> String
        {
            let localizedString = NSLocalizedString("Edit %@ %@ Reminder",
                                                    comment: "SiriShortcut: Title: ViewReminder: Shows the reminder kind and the name of the plant so the user knows what the SiriShortcut applies to.")
            let vesselName = vesselName ?? WaterMe.LocalizedString.ReminderVessel.untitledPlant
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString, reminderKind.localizedSpotlightString, vesselName) as String
            } else {
                return String.localizedStringWithFormat(localizedString, reminderKind.localizedSpotlightString, vesselName)
            }
        }
        static func viewReminderTitle(for reminderKind: ReminderKind,
                                      andVesselName vesselName: String?) -> String
        {
            let localizedString = NSLocalizedString("View %@ %@ Reminder",
                                                    comment: "SiriShortcut: Title: ViewReminder: Shows the reminder kind and the name of the plant so the user knows what the SiriShortcut applies to.")
            let vesselName = vesselName ?? WaterMe.LocalizedString.ReminderVessel.untitledPlant
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString, reminderKind.localizedSpotlightString, vesselName) as String
            } else {
                return String.localizedStringWithFormat(localizedString, reminderKind.localizedSpotlightString, vesselName)
            }
        }
        static func performReminderTitle(for reminderKind: ReminderKind,
                                         andVesselName vesselName: String?) -> String
        {
            let localizedString = NSLocalizedString("Mark %@ %@ as Done",
                                                    comment: "SiriShortcut: Title: PerformReminder: Shows the reminder kind and the name of the plant so the user knows what the SiriShortcut applies to.")
            let vesselName = vesselName ?? WaterMe.LocalizedString.ReminderVessel.untitledPlant
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString, reminderKind.localizedSpotlightString, vesselName) as String
            } else {
                return String.localizedStringWithFormat(localizedString, reminderKind.localizedSpotlightString, vesselName)
            }
        }
        static var editReminderDescription: String {
            let localizedString = NSLocalizedString("Edit reminder notes, kind, and interval.",
                                                    comment: "SiriShortcut: Description: EditReminder: Explains to the user that by using this SiriShortcut they can edit the reminder.")
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString) as String
            } else {
                return localizedString
            }
        }
        static var viewReminderDescription: String {
            let localizedString = NSLocalizedString("View notes, last performed date, mark as done.",
                                                    comment: "SiriShortcut: Description: ViewReminder: Explains to the user that by using this SiriShortcut they can view the reminder summary screen.")
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString) as String
            } else {
                return localizedString
            }
        }
        static var editReminderVesselDescription: String {
            let localizedString = NSLocalizedString("Edit plant name, photo, or reminders.",
                                                    comment: "SiriShortcut: Description: EditPlant: Explains to the user that by using this SiriShortcut they can edit their plant.")
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString) as String
            } else {
                return localizedString
            }
        }
        static var performReminderDescription: String {
            let localizedString = NSLocalizedString("Mark this reminder as done.",
                                                    comment: "SiriShortcut: Description: PerformReminder: Explains to the user that by using this SiriShortcut they mark a reminder as done.")
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: localizedString) as String
            } else {
                return localizedString
            }
        }
        static var randomLocalizedPhrase: String {
            var localizedStrings: [String] = [
                NSLocalizedString("I gardened!",
                                  comment: "SiriShortcut: Phrase: Random1"),
                NSLocalizedString("Water Me Baby!",
                                  comment: "SiriShortcut: Phrase: Random2"),
                NSLocalizedString("Thats that!",
                                  comment: "SiriShortcut: Phrase: Random3"),
                NSLocalizedString("Bam! Watered.",
                                  comment: "SiriShortcut: Phrase: Random4"),
                NSLocalizedString("Green thumb for the win!",
                                  comment: "SiriShortcut: Phrase: Random5"),
                NSLocalizedString("Live long and prosper.",
                                  comment: "SiriShortcut: Phrase: Random6")
            ]
            localizedStrings.shuffle()
            let first = localizedStrings.first!
            if #available(iOS 12.0, *) {
                return NSString.deferredLocalizedIntentsString(with: first) as String
            } else {
                return first
            }
        }
        static let siriShortcutsUnavailableTitle: String
            = NSLocalizedString("Siri Shortcuts Unavailable",
                                comment: "Alert Title: On iOS 11, Siri Shortcuts is not available, but they tapped on a button the tries to use this feature. This alert tells them whats wrong.")
        static let siriShortcutsUnavailableMessage: String
            = NSLocalizedString("Siri Shortcuts are only available in iOS 12. Please update to use this feature.",
                                comment: "Alert Title: On iOS 11, Siri Shortcuts is not available, but they tapped on a button the tries to use this feature. This alert tells them whats wrong.")
    }
}

extension UserActivityError {
    enum LocalizedString {
        static let siriShortcutGenericErrorAlertTitle: String
            = NSLocalizedString("Shortcut Error",
                                comment: "Alert Title: Generic Siri Shortcuts Error")
        static let siriShortcutReminderNotFoundErrorAlertTitle: String
            = NSLocalizedString("Reminder Not Found",
                                comment: "Alert Title: Reminder Not Found when trying to execute a SiriShortcut")
        static let siriShortcutReminderNotFoundErrorAlertMessage: String
            = NSLocalizedString("The reminder for this Siri Shortcut could not be found. You may want to delete this Siri Shortcut.",
                                comment: "Alert Message: Reminder Not Found when trying to execute a SiriShortcut")
        static let siriShortcutReminderVesselNotFoundErrorAlertTitle: String
            = NSLocalizedString("Plant Not Found",
                                comment: "Alert Title: Plant Not Found when trying to execute a SiriShortcut")
        static let siriShortcutReminderVesselNotFoundErrorAlertMessage: String
            = NSLocalizedString("The plant for this Siri Shortcut could not be found. You may want to delete this Siri Shortcut.",
                                comment: "Alert Message: Plant Not Found when trying to execute a SiriShortcut")
        static let siriShortcutCreateErrorAlertMessage: String
            = NSLocalizedString("There was an error adding this Siri Shortcut. Please try again later.",
                                comment: "Alert Message: Error Ocurred when Creating a new Siri Shortcut.")
        static let siriShortcutContinuationErrorAlertMessage: String
            = NSLocalizedString("There was an error executing this Siri Shortcut. If you see this error repeatedly, it may help to delete and recreate it.",
                                comment: "Alert Message: Error ocurred when executing an existing Shortcut.")
    }
}

extension CloudSyncProgressView {
    enum LocalizedString {
        static let errorAlertTitle: String
            = NSLocalizedString("iCloud Sync Error",
                                comment: "Alert Title: Indicates there was an error with iCloud Sync.")
        static let errorPasswordAlertMessage: String
            = NSLocalizedString("Sync failed because there is an issue with your iCloud password. Check your password in Settings → Apple ID → iCloud.",
                                comment: "Alert Message: Indicates there was an issue with the password used for iCloud. This requires going to the phone's settings app.")
        static let errorStorageLimitAlertMessage: String
            = NSLocalizedString("Sync couldn't be completed because of an iCloud rate limit. Syncing will automatically resume later.",
                                comment: "Alert Message: Indicates there was an issue because iCloud reached a rate limit.")
        static let errorRateLimitAlertMessage: String
            = NSLocalizedString("Sync failed because your iCloud storage is full. You can buy more iCloud storage, delete data in iCloud, or disable iCloud sync for WaterMe in the settings app.",
                                comment: "Alert Message: Indicates there was an issue because the user's iCloud storage is full.")
        static let errorNetworkAlertMessage: String
            = NSLocalizedString("Sync failed because there was a network error. Next time there is a network connection, sync will automatically resume.",
                                comment: "Alert Message: Indicates there was a network error. Syncing will automatically resume when connected again.")
        static let notDeterminedErrorAlertMessage: String
            = NSLocalizedString("Unable to detect your iCloud account status. Turning your device off and on may resolve this issue.",
                                comment: "Alert Message: App could not detect iCloud login status. Very strange error, restarting device might help.")
        static let restrictedErrorAlertMessage: String
            = NSLocalizedString("iCloud Sync is restricted by parental or administrator controls.",
                                comment: "Alert Message: iCloud is restricted on this device. The user cannot fix this issue.")
        static let iCloudLoggedOutErrorAlertMessage: String
            = NSLocalizedString("To use iCloud Sync with WaterMe, please sign into your iCloud account and enable 'iCloud Drive.' If you do not want to see this error, disable 'Sync via iCloud' in Settings.",
                                comment: "Alert Message: The user is not signed in with iCloud and therefore cannot use iCloud Sync with WaterMe.")
        static let unsupportedDeviceErrorAlertMessage: String
            = NSLocalizedString("iCloud Sync in WaterMe is only available on devices running iOS 14 or newer. If you do not want to see this error, turn off 'Sync via iCloud' in Settings.",
                                comment: "Alert Message: The device is running an old version of iOS and cannot use iCloud Sync.")
        static let statusSyncComplete: String
            = NSLocalizedString("iCloud Sync Complete",
                                comment: "Status Bar: iCloud sync recently completed. Not a button.")
        static let statusSyncInProgress: String
            = NSLocalizedString("Syncing with iCloud…",
                                comment: "Status Bar: iCloud syncing is currently in progress. Not a button.")
        static let statusSyncError: String
            = NSLocalizedString("Sync Error",
                                comment: "Status Bar: iCloud syncing had an error. A tappable button.")
        static let statusSyncUnavailable: String
            = NSLocalizedString("iCloud Sync Unavailable",
                                comment: "Status Bar: iCloud syncing unavailable on this device. A tappable button.")
    }
}

extension CloudSyncInfoViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("iCloud Sync",
                              comment: "Cloud Sync Info: Title: Lets the user know that iCloud sync is possible")
        static let body =
            NSLocalizedString("WaterMe now automatically syncs all plants and reminders via iCloud. You can enable and disable iCloud sync from the settings screen.",
                              comment: "Cloud Sync Info: Body: Lets the user know how iCloud sync works and that it can be enabled and disabled from the settings app.")
    }
}
