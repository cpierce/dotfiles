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
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# [ ] Show warning before changing an extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# [ ] Show warning before removing from iCloud Drive
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
# [ ] Show warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# [x] Remove items from the Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
# [x] Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# [x] Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# [x] Show full path in finder
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# [x] Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# [x] Show Hard Disks on Desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
# [x] Show External Disks on Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# [x] Show Removable Media on Desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# [x] Show Mounted Servers on Desktop
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

# Dock: Settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 68
