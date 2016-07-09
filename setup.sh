#!/bin/sh
echo "Installing global dependencies..."
npm install cake -g
npm install less -g
npm install coffee-script -g
npm install coffeescript-concat -g
npm install bower -g

echo "Installing node modules..."
npm install

echo "Installing bower modules..."
bower install

echo "Setting up required folders..."
mkdir public/styles


echo "Building project..."
cake build

echo "Done! now run your project with 'node app' or 'cake run' and build something awesome!"
