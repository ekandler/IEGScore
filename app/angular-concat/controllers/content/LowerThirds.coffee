
      
class LowerThirds extends DataElement
  key: "LowerThirds"
    
		
  constructor:  ($scope) ->
    super $scope
    $scope.model = {
      GPvisible: false
      GPcontent: '' 
      GPtemplates: []
      RefVisible: false
      RefDecision: null
      PlayerVisible: false
      PlayerDetailed: false
      Player: null
      loopNr: 0
    }
    
    
    
    refereeDecisions = [
      #{num: 0, name: "Replay"}
      {num: 1, name: "Untimed down"}
      {num: 1, name: "Ball ready for play"}
      {num: 2, name: "Start Clock"}
      {num: 3, name: "Time out"}
      {num: 4, name: "TV/Radio time out"}
      {num: 5, name: "Touchdown"}
      {num: 5, name: "Field goal"}
      {num: 5, name: "Point(s) after touchdown"}
      {num: 6, name: "Safety"}
      {num: 7, name: "Ball dead"}
      {num: 7, name: "Touchback"}
      {num: 8, name: "First down"}
      {num: 9, name: "Loss of down"}
      {num: 10, name: "Incomplete pass"}
      {num: 10, name: "Penalty declined"}
      {num: 10, name: "No play"}
      {num: 10, name: "No score"}
      {num: 10, name: "Toss option delayed"}
      {num: 11, name: "Legal touching of forward pass"}
      {num: 12, name: "Inadvertent whistle"}
      {num: 13, name: "Disregard flag"}
      {num: 14, name: "End of period"}
      {num: 15, name: "Sideline warning"}
      {num: 16, name: "Illegal touching"}
      {num: 17, name: "Uncatchable forward pass"}
      {num: 18, name: "Offside defence"}
      {num: 19, name: "False start"}
      {num: 19, name: "Illegal formation"}
      {num: 19, name: "Encroachment offense"}
      {num: 20, name: "Illegal shift"}
      {num: 20, name: "Illegal motion"}
      {num: 21, name: "Delay of game"}
      {num: 22, name: "Substitution infraction"}
      {num: 23, name: "Failure to wear required equipment"}
      {num: 24, name: "Illegal helmet contact"}
      {num: 27, name: "Unsportsmanlike conduct"}
      {num: 27, name: "Noncontact foul"}
      {num: 28, name: "Illegal participation"}
      {num: 29, name: "Sideline interference"}
      {num: 30, name: "Running into or roughing kicker or holder"}
      {num: 31, name: "Illegal batting or kicking"}
      {num: 32, name: "Illegal/invalid fair catch signal"}
      {num: 33, name: "Forward pass interference"}
      {num: 33, name: "Kick-catching interference"}
      {num: 34, name: "Roughing passer"}
      {num: 35, name: "Illegal pass"}
      {num: 35, name: "Illegal forward handling"}
      {num: 36, name: "Intentional grounding"}
      {num: 37, name: "Ineligible downfield on pass"}
      {num: 38, name: "Personal foul"}
      {num: 39, name: "Clipping"}
      {num: 40, name: "Blocking below waist"}
      {num: 40, name: "Illegal block"}
      {num: 41, name: "Chop block"}
      {num: 42, name: "Holding"}
      {num: 42, name: "Obstructing"}
      {num: 42, name: "Illegal use of hand/arms"}
      {num: 43, name: "Illegal block in the back"}
      {num: 44, name: "Helping runner"}
      {num: 44, name: "Interlocked blocking"}
      {num: 45, name: "Grasping face mask or helmet opening"}
      {num: 46, name: "Tripping"}
      {num: 47, name: "Player disqualification"}
      ]
      
    refToString = (obj) ->
      obj.num + " | " + obj.name
        
    # Instantiate the bloodhound suggestion engine
    decisions_bloodhound = new Bloodhound({
      datumTokenizer: ((d) ->
        return Bloodhound.tokenizers.whitespace(refToString(d))
      )
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      local: refereeDecisions
    })
  
    # initialize the bloodhound suggestion engine
    decisions_bloodhound.initialize();
    
    # Typeahead options object
    $scope.refOptions = {
      highlight: true
      editable: false
    }
    
    # Single dataset example
    $scope.refData = {
      displayKey: refToString,
      source: decisions_bloodhound.ttAdapter()
      #http://twitter.github.io/typeahead.js/examples/#custom-templates
    }
    
    $scope.oldRefDecision = null
    $scope.$watch('model.RefDecision', -> (
      if JSON.stringify($scope.model.RefDecision) != JSON.stringify($scope.oldRefDecision)
        $scope.update()
      $scope.oldRefDecision = $scope.model.RefDecision
    ))
    
    $scope.getRefVisible = ->
      $scope.model.RefVisible
      
    $scope.toggleRefVisibility = ->
      $scope.model.RefVisible = not $scope.model.RefVisible
      $scope.update()
      
    $scope.getRefContent = ->
      $scope.model.RefDecision
      
    $scope.getPlayerVisbileSmall = ->
      $scope.model.PlayerVisible and not $scope.model.PlayerDetailed
    $scope.getPlayerVisbileLarge = ->
      $scope.model.PlayerVisible and $scope.model.PlayerDetailed
      
    $scope.showPlayerSmall = ->
      $scope.model.PlayerVisible = true
      $scope.model.PlayerDetailed = false
      $scope.update()
    $scope.showPlayerLarge = ->
      $scope.model.PlayerVisible = true
      $scope.model.PlayerDetailed = true
      $scope.update()
    $scope.hidePlayer = ->
      $scope.model.PlayerVisible = false
      $scope.model.PlayerDetailed = false
      $scope.update()
      
    $scope.setLoop = (nr) ->
      if (nr >=0)
        $scope.model.loopNr = nr
        $scope.update()
    
    $scope.getLoopNr = ->
      $scope.model.loopNr
    
    getTeam = (team) -> # unsafe - not visible to scope
      if not $scope.getDataElem(team)
        #eval("new " + team + "($scope)") # create a hometeam object, if not already present... really bad programming. sorry
        console.error("Team not yet loaded")
      $scope.getDataElem(team).model.roster
      
    playerTokenizer = (player) ->
      player.number + " | " + player.name
      
      
      

    # Instantiate the bloodhound suggestion engine
    players_home_bloodhound = new Bloodhound({
      datumTokenizer: ((d) ->
        return Bloodhound.tokenizers.whitespace(playerTokenizer(d))
      )
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      local: ( ->
          getTeam("HomeTeam")
          
        )
    })
    
    players_guest_bloodhound = new Bloodhound({
      datumTokenizer: ((d) ->
        return Bloodhound.tokenizers.whitespace(playerTokenizer(d))
      )
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      local:  ( ->
          getTeam("GuestTeam")
        )
    })
    
    doInit = -> 
      # initialize the bloodhound suggestion engine
      if (not $scope.getDataElem("HomeTeam").actionAllowed()) or (not $scope.getDataElem("GuestTeam").actionAllowed())
        console.log "waiting for team data to be valid..."
        setTimeout(doInit, 50)
        return
      players_home_bloodhound.initialize();
      players_guest_bloodhound.initialize();

    $scope.getPlayer = ->
      $scope.model.Player
    
    $scope.setPlayer = ->
      $scope.model.Player = $scope.tmpPlayer
      $scope.tmpPlayer = ""
      $scope.update()
      
    $scope.initBloodhound =  ->
      console.log "initializing player autocomplete"
      doInit()
      
    
    # Typeahead options object
    $scope.playerOptions = {
      highlight: true
      editable: false
    }
    
    # Multiple dataset
    $scope.playerData = [{
      name: 'Home',
      displayKey: playerTokenizer,
      source: players_home_bloodhound.ttAdapter(),
      templates: {
       header: '<h4 class="team-name">Home Team</h4>'
      }
      #http://twitter.github.io/typeahead.js/examples/#custom-templates
    }, {
      name: 'Guests',
      displayKey: playerTokenizer,
      source: players_guest_bloodhound.ttAdapter(),
      templates: {
       header: '<h4 class="team-name">Guest Team</h4>'
      }
      #http://twitter.github.io/typeahead.js/examples/#custom-templates
    }]
    
    $scope.player = null;
    
    $scope.tmpGPContent = ''
    $scope.curGPtemplate = null
    $scope.$watch('model.GPcontent', -> (
      $scope.tmpGPContent = $scope.model.GPcontent
    ))
    
    
    $scope.addGPTemplate = ->
      if $scope.tmpGPContent
        for value in $scope.model.GPtemplates
          if value is $scope.tmpGPContent # do not add template twice
            return
        $scope.model.GPtemplates.push($scope.tmpGPContent)
        $scope.curGPtemplate = $scope.tmpGPContent
        $scope.update()
        
    $scope.removeGPTemplate = ->
      for value, key in $scope.model.GPtemplates
        if value is $scope.curGPtemplate
          $scope.model.GPtemplates.splice(key, 1)
          $scope.update()
        
    $scope.$watch('curGPtemplate', -> (
      $scope.tmpGPContent = $scope.curGPtemplate
    ))
    
    $scope.$watch('tmpGPContent', -> (
      $scope.curGPtemplate = $scope.tmpGPContent
    ))
    
    $scope.setGPContent = ->
      $scope.model.GPcontent = $scope.tmpGPContent
      $scope.update()
    
    $scope.toggleGPVisibility = ->
      $scope.model.GPvisible = not $scope.model.GPvisible
      $scope.update()
      
    $scope.getGPVisible = ->
      $scope.model.GPvisible
      
    $scope.getGPContent = (htmlstyled) ->
      unless htmlstyled
        return $scope.model.GPcontent
      $scope.model.GPcontent.replace(/(?:\r\n|\r|\n)/g, '<br />')
      