// Generated by CoffeeScript 1.9.0
"use strict";

/*
  Filters
 */
angular.module("myApp.filters", []).filter("title", function() {
  return function(user) {
    return user.id + " - " + user.name;
  };
});
