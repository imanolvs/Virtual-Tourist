# Virtual-Tourist

Virtual Tourist is a location-aware iOS app to get Flickr photos through a selected location by the user.

##Import and Install
Steps to import, build and run the project:

- Clone the repository using the following command: 

```
$ git clone https://github.com/imanolvs/Virtual-Tourist.git
```
- Open the project (`Places Finder.xcodeproj` file)
- Build the project: 
    - Select Product -> Build (⌘B)
- Run the project in the simulator:
    - Select the iOS device in the toolbar
    - Select Product -> Run (⌘R)
    - If there're no errors, simulator will open and run the app

You can also download the app into your own iOS device:
  - Go to XCode -> Preferences (⌘,)
  - Add your Apple ID Account
  - Connect your iOS Device
  - Select your iOS Device in the toolbar
  - Build and Run the project (⌘R)
  
##How the app works

- **Selecting Locations**
    - Perform a long pressed gesture on the map. This action put a pin in the selected location.
    - You can remove the pins tapping first the Edit button in the right top corner, and then, tapping the pins.
- **Watching the Photos**
  - Tap a pin and app will download the photos for Flickr.
  - You could refresh and get another collection of photos tapping the bottom button.
  - You could see the photo with more details, tapping in the wanted photo of the collection.
  - You could remove or share the photos. Tap Select button in the right top corner, select the photos you want, and tap Share/Trash button for the action you want.


