# Check Dein Passwort

This is a web application which visualizes the strength of your password in a web browser.
You can find it deployed at [checkdeinpasswort.de](https://checkdeinpasswort.de).

## Setup

The app is built with [Brunch](http://brunch.io). To get running you have to:

* Go to the cdplib folder and build it according to the README.
* Go to the web folder and link the cdp library to this project: `ln -sf ../../cdplib/build/cdplib.js app/cdplib.js`.
* Watch the project with continuous rebuild by `npm run dev`. This will also launch an HTTP server.
* You can build the minified project with `npm run build`.

Open the `public/` dir to see the result.
