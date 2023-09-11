#!/bin/sh

# Disable Google Chrome print preview and use system default
defaults write com.google.Chrome DisablePrintPreview -boolean true

# Turn on Safari Develop Menu and disable autofill
defaults write com.apple.Safari IncludeDevelopMenu -boolean true
defaults write com.apple.Safari AutoFillCreditCardData -boolean false
defaults write com.apple.Safari AutoFillFromAddressBook -boolean false
defaults write com.apple.Safari AutoFillMiscellaneousForms -boolean false
defaults write com.apple.Safari AutoFillPasswords -boolean false

# Finder: Settings
# [x] Show all filename extensions
# [ ] Show warning before changing an extension
# [ ] Show warning before removing from iCloud Drive
# [ ] Show warning before emptying the Trash
# [x] Remove items from the Trash after 30 days
# [x] Keep folders on top when sorting by name
# [x] Show path bar
# [x] Show status bar
# [x] Show full path in finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# [x] Show Hard Disks on Desktop
# [x] Show External Disks on Desktop
# [x] Show Removable Media on Desktop
# [x] Show Mounted Servers on Desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# Sidebar: Settings
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowRecentsFolderInSidebar -bool true
defaults write com.apple.finder ShowAirDropInSidebar -bool true
defaults write com.apple.finder ShowApplicationsFolderInSidebar -bool true
defaults write com.apple.finder ShowDesktopInSidebar -bool true
defaults write com.apple.finder ShowDownloadsFolderInSidebar -bool true
defaults write com.apple.finder ShowDocumentsFolderInSidebar -bool true
defaults write com.apple.finder ShowHomeFolderInSidebar -bool true
defaults write com.apple.finder ShowMusicFolderInSidebar -bool false
defaults write com.apple.finder ShowPicturesFolderInSidebar -bool true
defaults write com.apple.finder ShowMoviesFolderInSidebar -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnSidebar -bool true
defaults write com.apple.finder ShowHardDrivesOnSidebar -bool true
defaults write com.apple.finder ShowMountedServersOnSidebar -bool true
defaults write com.apple.finder ShowRemovableMediaOnSidebar -bool true
