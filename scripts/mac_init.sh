#!/bin/sh

# Disable Google Chrome print preview and use system default
# I've turned this off because I recently bought a google cloud print ready
# printer
# defaults write com.google.Chrome DisablePrintPreview -boolean true
defaults write com.apple.Safari AutoFillCreditCardData -boolean false
defaults write com.apple.Safari AutoFillFromAddressBook -boolean false
defaults write com.apple.Safari AutoFillMiscellaneousForms -boolean false
defaults write com.apple.Safari AutoFillPasswords -boolean false
