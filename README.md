# RPODMP

LAB 3

  1. https://apidocs.imgur.com -  Auth app in imgur, get token and username.
  2. https://firebase.google.com - Register in firestore, create DB and collection (for storing Users).
  3. Fill token, username, Project id and DB collection name in UsersController.swift:
  
  ```swift
  let token = "YOUR_IMGUR_TOKEN"
  let firestore = "https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents/YOUR_USERS_COLLECTION"
  let imgurAccountName = "YOUR_IMGUR_LOGIN"
  ```
