#!/bin/bash

# 1. Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# 2. Login to Google
firebase login

# 3. Install FlutterFire CLI
dart pub global activate flutterfire_cli

flutterfire configure