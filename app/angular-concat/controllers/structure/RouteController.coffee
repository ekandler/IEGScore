
RouteController = ($scope, $routeParams) ->
  $scope.templateUrl = '/partials/manage/'+$routeParams.part
  

  
  
  console.log($scope.templateUrl)