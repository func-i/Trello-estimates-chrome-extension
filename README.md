*IMPORTANT: You must open the server app and authenticate with Trello before opening Trello with the Chrome extension*

### Usage

#### 1. Open the [server app](https://estimation-fi.herokuapp.com/) and authenticate with Trello

#### 2. Load the Chrome extension:

- In the browser, open chrome://extensions/
- Enable Developer Mode (checkbox on the top right)
- Click "Load unpacked extension..."
- Select the chrome extension folder

#### 3. Open the Trello board/card in Chrome

#### 4. Track time on Harvest from the Trello cards
- Install the Harvest Time Tracker [Chrome extension](https://chrome.google.com/webstore/detail/harvest-time-tracker/fbpiglieekigmkeebmeohkelfpjjlaia)


### Development

- In the terminal, go to the chrome extension folder
- grunt build

### Deploy

The Chrome extension loads app.js from GitHub and all other files from the local extension package.

- Updates to app.js: push to GitHub, users don't need to update pakcage
- Updates to other files: users must load the updated package
