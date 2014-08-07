"use strict"

###
  Declare app level module which depends on filters, services, and directives
###

angular.module("myApp", ["ngRoute", "myApp.filters", "myApp.services", "myApp.directives"])
.config ["$routeProvider",
  ($routeProvider) ->
    $routeProvider.when "/home", {templateUrl: "partials/home", controller: UsersCtrl}
    $routeProvider.when "/user/:userId", {templateUrl: "partials/user", controller: UserDetailCtrl}
    $routeProvider.when "/socket", {templateUrl: "partials/socket", controller: SocketCtrl}
    $routeProvider.when "/:part", {templateUrl: "partials/router", controller: RouteController}
    $routeProvider.otherwise {redirectTo: "/home"}
  ]


angular.module("ScoreApp", ["ngRoute", "myApp.filters", "myApp.services", "ScoreApp.directives", "xeditable"])
.config ["$routeProvider",
  ($routeProvider) ->
    $routeProvider.when "/roster/:team", {templateUrl: "partials/manage/roster", controller: RosterController}
    $routeProvider.when "/:part", {templateUrl: "partials/router", controller: RouteController}
    $routeProvider.otherwise {redirectTo: "/clock"}
  ]
.config ["$logProvider",
  ($logProvider) ->
    $logProvider.debugEnabled(true);
  ]
.run((editableOptions, editableThemes) -> (
  editableOptions.theme = 'bs3';
  editableThemes.bs3.inputClass = 'input-sm';
  editableThemes.bs3.buttonsClass = 'btn-sm';
))
