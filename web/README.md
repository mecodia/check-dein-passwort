# Check Dein Passwort

This is a web application which visualizes the strength of your passwort in a web browser.
You can find it deployed at [checkdeinpasswort.de](http://checkdeinpasswort.de).

## Setup

The app is built with [Brunch](http://brunch.io). To get running you have to:

* Install [Brunch](http://brunch.io): `npm install -g brunch`.
* Go to the cdplib folder and Install Brunch plugins: `npm install`.
* Go to the web folder and Link the cdp library to this project: `ln -sf ../../cdplib/build/cdplib.js app/cdplib.js`.
* Watch the project with continuous rebuild by `brunch watch --server`. This will also launch an HTTP server.
* You can build the minified project with `brunch build --production`.

Open the `public/` dir to see the result.
