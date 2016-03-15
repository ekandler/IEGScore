
class Scoreboard extends DataElement
  key: "Scoreboard"
  
		
  constructor:  ($scope) ->
    super $scope
    $scope.model = {
      timeOutsHome: 3
      timeOutsGuests: 3
      pointsHome: 0
      pointsGuests: 0
      down: 0
      distance: 10
      posessionHome: true
      visibleSmall: false
      visibleBig: false
    } 
    
    $scope.getBallPossession = ->
      $scope.model.posessionHome
      
    $scope.toggleBallPossession = ->
      if $scope.model.posessionHome
        $scope.model.posessionHome = false
      else
        $scope.model.posessionHome = true
      $scope.update()
        
    $scope.getScorebardVisibleSmall = ->
      $scope.model.visibleSmall
    $scope.getScorebardVisibleBig = ->
      $scope.model.visibleBig
      
    $scope.showScoreboardSmall = ->
      $scope.model.visibleSmall = true
      $scope.model.visibleBig = false
      $scope.update()
    $scope.showScoreboardBig = ->
      $scope.model.visibleSmall = false
      $scope.model.visibleBig = true
      $scope.update()
    $scope.hideScoreboard = ->
      $scope.model.visibleSmall = false
      $scope.model.visibleBig = false
      $scope.update()
    
        
    $scope.getTimoutsHome = ->
      $scope.model.timeOutsHome
      
    $scope.$watch('enteredTimeoutsHome', -> (
      if  $scope.enteredTimeoutsHome is '-'
        return
      
      unless 3 >= $scope.enteredTimeoutsHome >= -1
        $scope.enteredTimeoutsHome = ''
    ))
    
    $scope.setTimoutsHome = (nrTimeouts) ->
      if nrTimeouts is undefined
        if $scope.enteredTimeoutsHome
          nrTimeouts = $scope.enteredTimeoutsHome
        else
          return false
      
      if 3 >= nrTimeouts >= -1
        $scope.model.timeOutsHome = parseInt nrTimeouts
      
      $scope.enteredTimeoutsHome = ''
      $scope.update()
      
    $scope.getTimoutsGuests = ->
      $scope.model.timeOutsGuests
      
    $scope.$watch('enteredTimeoutsGuests', -> (
      if  $scope.enteredTimeoutsGuests is '-'
        return
      
      unless 3 >= $scope.enteredTimeoutsGuests >= -1
        $scope.enteredTimeoutsGuests = ''
    ))
    
    $scope.setTimoutsGuests = (nrTimeouts) ->
      if nrTimeouts is undefined
        if $scope.enteredTimeoutsGuests
          nrTimeouts = $scope.enteredTimeoutsGuests
        else
          return false
      
      if 3 >= nrTimeouts >= -1
        $scope.model.timeOutsGuests = parseInt nrTimeouts
      
      $scope.enteredTimeoutsGuests = ''
      $scope.update()
      
    $scope.getPoints = (home) ->
      if home
        $scope.model.pointsHome
      else
        $scope.model.pointsGuests
        
    $scope.$watch('model.pointsHome', -> (
      $scope.tmpHomePoints = $scope.model.pointsHome
    ))
    
    $scope.$watch('model.pointsGuests', -> (
      $scope.tmpGuestPoints = $scope.model.pointsGuests
    ))
    
    $scope.$watch('tmpHomePoints', -> (
      if isNaN($scope.tmpHomePoints) or parseInt($scope.tmpHomePoints) < 0
        $scope.tmpHomePoints = $scope.model.pointsHome
    ))
    
    $scope.$watch('tmpGuestPoints', -> (
      if isNaN($scope.tmpGuestPoints) or parseInt($scope.tmpGuestPoints) < 0
        $scope.tmpGuestPoints = $scope.model.pointsGuests
    ))
        
    $scope.setPoints = (home, points) -> 
      if home is undefined
        if $scope.tmpHomePoints
          $scope.setPoints true, parseInt $scope.tmpHomePoints
        if $scope.tmpGuestPoints
          $scope.setPoints false, parseInt $scope.tmpGuestPoints
        return
      
      points = parseInt points
      unless points > -1
        return
        
      if home
        $scope.model.pointsHome = points
      else
        $scope.model.pointsGuests = points
        
      $scope.update()
      
      
    $scope.getDown = ->
      $scope.model.down
      
    
    $scope.setDown = (down) ->
      if 4 >= down >= 0
        $scope.model.down = parseInt down
      $scope.setDistance -2
      $scope.update()
      
      
    $scope.getDistance = ->
      $scope.model.distance
      
    $scope.$watch('enteredDistance', -> (
      if  $scope.enteredDistance is '-'
        return
      unless 100 >= $scope.enteredDistance >= -2
        $scope.enteredDistance = ''
    ))
    
    $scope.setDistance = (distance) ->
      if distance is undefined
        if $scope.enteredDistance
          distance = $scope.enteredDistance
        else
          distance = 10
      
      if 100 >= distance >= -2
        $scope.model.distance = parseInt distance
      
      $scope.enteredDistance = ''
      $scope.update()