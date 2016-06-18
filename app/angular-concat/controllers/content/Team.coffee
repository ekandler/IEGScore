
        
class Team extends DataElement
  key: "unknownTeam"
		
  constructor:  ($scope) ->
    super $scope
    $scope.model = {
      teamNameLong: null
      teamNameShort: null
      showRoster: false
      teamColor: "#000000"
      roster: []
      hue: 0
    } 
    
    #$scope.$watch("model", (newValue, oldValue) ->
    #    $scope.model.hue = $scope.getHue()
    #    console.log("set team of " + $scope.model.teamNameShort + " hue to " + $scope.model.hue)
    #)
    
    $scope.$watch((scope) ->
      scope.model.teamColor
    , () ->
      if ($scope.model.teamColor == "#000000")
        return true
      $scope.model.hue = $scope.getHue()
      console.log("set team of " + $scope.model.teamNameShort + " hue to " + $scope.model.hue)
    )

    
    # Types:
    # 0: Coach/coordinator
    # 1: Offense
    # 2: Defense
    # 3: Special Team
    $scope.positions = [
      {value: 'HC', text: 'Headcoach', type: 1}
      {value: 'OC', text: 'Offense Coordinator', type: 1}
      {value: 'DC', text: 'Defense Coordinator', type: 1}
      {value: 'SC', text: 'Special Coordinator', type: 1}
      
      {value: 'OL', text: 'Offensive Line', type: 2}
      {value: 'QB', text: 'Quarterback', type: 2}
      {value: 'RB', text: 'Runningback', type: 2}
      {value: 'WR', text: 'Wide Receiver', type: 2}
      {value: 'TE', text: 'Tight End', type: 2}
      
      {value: 'DL', text: 'Defensive Line', type: 3}
      {value: 'LB', text: 'Linebacker', type: 3}
      {value: 'DB', text: 'Defensive Back', type: 3}
      
      {value: 'P', text: 'Punter', type: 4}
      {value: 'K', text: 'Kicker', type: 4}
      {value: 'ST', text: 'other Special', type: 4}
    ]; 
    $scope.getTeamNameLong = ->
      $scope.model.teamNameLong
    $scope.getTeamNameShort = ->
      $scope.model.teamNameShort
      
    $scope.toggleRosterVisibility = ->
      $scope.model.showRoster = not $scope.model.showRoster
      $scope.update()
      
    $scope.getRosterVisible = ->
      $scope.model.showRoster
      
    $scope.getTeamColor = ->
      $scope.model.teamColor
      
    `function rgbToHsl(r, g, b){
      r /= 255, g /= 255, b /= 255;
      var max = Math.max(r, g, b), min = Math.min(r, g, b);
      var h, s, l = (max + min) / 2;
  
      if(max == min){
          h = s = 0; // achromatic
      }else{
          var d = max - min;
          s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
          switch(max){
              case r: h = (g - b) / d + (g < b ? 6 : 0); break;
              case g: h = (b - r) / d + 2; break;
              case b: h = (r - g) / d + 4; break;
          }
          h /= 6;
      }
  
      return [h, s, l];
    }`  
    
    $scope.getHue = ->
      color = $scope.model.teamColor
      r = parseInt(color.substr(1,2), 16) # Grab the hex representation of red (chars 1-2) and convert to decimal (base 10).
      g = parseInt(color.substr(3,2), 16)
      b = parseInt(color.substr(5,2), 16)
      
      hsl =  rgbToHsl r, g, b
      
      return parseInt(hsl[0] * 360)
    
    $scope.showPositions = (player) ->
      selected = [];
      try
        angular.forEach($scope.positions, (s) -> 
          if (player.position.indexOf(s.value) >= 0) 
            selected.push(s.text);
        )
        if selected.length
          selected.join(', ')
        else
          'Not set'
      catch error
        'Not set'
        
    $scope.isCoach = (player) ->
      foundCoach = false
      try
        angular.forEach($scope.positions, (s) -> 
          if (player.position.indexOf(s.value) >= 0) 
            if s.type is 1
              foundCoach = true
        )
        foundCoach
      catch error
        false
        
    $scope.isPlayer = (player) ->
      foundPlayer = false
      if !player.position or player.position.length is 0
        return true
      try
        angular.forEach($scope.positions, (s) -> 
          if (player.position.indexOf(s.value) >= 0) 
            if s.type != 1
              foundPlayer = true
        )
        foundPlayer
      catch error
        false
        
    $scope.usePositions = ->
      useThem = false
      try
        angular.forEach($scope.model.roster, (p) -> 
          if ($scope.isPlayer(p))
            if (p.position.length>0)
              useThem = true
        )
        useThem
      catch error
        false
        
        
    $scope.updateModelAfterUpload = ->
      for player in $scope.model.roster # update team parameter
        player.team = $scope.key
      $scope.update()
      
    $scope.addPlayer = ->
      $scope.inserted = {
        id: $scope.model.roster.length+1
        number: null
        name: ''
        position: null
        dob: null
        size: null
        weight: null
        exp: null
        nat: "AT"
        team: $scope.key
      }
      $scope.model.roster.push($scope.inserted)
      
    $scope.predicate = 'number';
      
    $scope.removePlayer = (item) ->
      #$scope.model.roster.splice(index, 1)
      $scope.model.roster.splice($scope.model.roster.indexOf(item),1);
      $scope.update()
      
    $scope.sendPlayer = (player) ->
      $scope.getDataElem("LowerThirds").model.Player = player
      $scope.getDataElem("LowerThirds").update()
      location = "/#lower-thirds";
      true
      
    $scope.checkName = (data, id) ->
      if data is ""
        return "Empty name not allowed"
        
    

class HomeTeam extends Team
  key: "HomeTeam"
  constructor:  ($scope) ->
    super $scope
class GuestTeam extends Team
  key: "GuestTeam"
  constructor:  ($scope) ->
    super $scope