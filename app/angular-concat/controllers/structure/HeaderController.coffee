HeaderController = ($scope, $location) ->
    $scope.isActive =  (viewLocation) ->
        viewLocation is $location.path()