
        
class Team extends DataElement
  key: "unknownTeam"
		
  constructor:  ($scope) ->
    super $scope
    $scope.model = {
      teamNameLong: null
      teamNameShort: null
      roster: []
    } 
    
    # Types:
    # 0: Coach/coordinator
    # 1: Offense
    # 2: Defense
    # 3: Special Team
    $scope.positions = [
      {value: 'HC', text: 'Headcoach', type: 0}
      {value: 'OC', text: 'Offense Coordinator', type: 0}
      {value: 'DC', text: 'Defense Coordinator', type: 0}
      {value: 'SC', text: 'Special Coordinator', type: 0}
      
      {value: 'OL', text: 'Offensive Line', type: 1}
      {value: 'QB', text: 'Quarterback', type: 1}
      {value: 'RB', text: 'Runningback', type: 1}
      {value: 'WR', text: 'Wide Receiver', type: 1}
      {value: 'TE', text: 'Tight End', type: 1}
      
      {value: 'DL', text: 'Defensive Line', type: 2}
      {value: 'LB', text: 'Linebacker', type: 2}
      {value: 'DB', text: 'Defensive Back', type: 2}
      
      {value: 'P', text: 'Punter', type: 3}
      {value: 'K', text: 'Kicker', type: 3}
      {value: 'ST', text: 'other Special', type: 3}
    ]; 
    $scope.getTeamNameLong = ->
      $scope.model.teamNameLong
    $scope.getTeamNameShort = ->
      $scope.model.teamNameShort
    
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