RosterController = ($scope, $routeParams) ->
  $scope.team = $routeParams.team.toLowerCase()
  
  if $scope.team is "home"
    new HomeTeam($scope)
  else if $scope.team is "guests"
    new GuestTeam($scope)
  else
    $scope.team = "---INVALID---"