importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  databaseURL: "https://jayma-88682-default-rtdb.europe-west1.firebasedatabase.app/",
  authDomain: "jayma-88682.firebaseapp.com",
  projectId: "jayma-88682",
  storageBucket: "jayma-88682.appspot.com",
  messagingSenderId: "484779040551",
  appId: "1:484779040551:web:fcc1614cfd2dfd52341302",
  measurementId: "G-FNV6D046C0",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});