
class DataClass
  data: []
  @scope: null

  constructor: (scope) ->
    DataClass.scope = scope
    
  
  registerElem: (key, obj) ->
    console.log "Element " + key + " registered"
    @data[key] = obj
    console.log @data
    
  recv: (key, value, callApply) ->
    callApply ?= false
    console.log "receiving " + key
    #console.log value
    #console.log @data[key]
    try
      model = @data[key].model
      $.extend model, value
      #if callApply
      @data[key].refreshGUI()
    catch error
      console.error "error while receiving, probably the module that should receive data was not properly initialized"
    

  send: (obj) ->
    DataClass.scope.sendDataElem(obj)
    
  getObj: (key) ->
    @data[key]
    
  isDataEmpty: ->
    console.log Object.keys(@data).length
    Object.keys(@data).length is 0
  

class GameDataCtrl

  constructor: ($scope, Socket) ->
    $scope.name = "Espresso"
    $scope.data = new DataClass $scope
    receivedPacket = false
    
    
    Socket.on "data", (data_k_v) ->
      if data_k_v is null
        return
      
      # delay first packet, so the view can establish
      #if not receivedPacket
      #  receivedPacket = true
      #  setTimeout ( ->
      #    $scope.data.recv data_k_v.key, data_k_v.val, true
      #  ), 200
      #else
      
      #if not receivedPacket
      #  receivedPacket = true
      #  $scope.data.recv data_k_v.key, data_k_v.val
      #else
      
      $scope.data.recv data_k_v.key, data_k_v.val
      
    $scope.sendDataElem = (obj) ->
      data_k_v = {key: obj.key, val: obj.model}
      Socket.emit("data", data_k_v)
      
    $scope.requestCurrentData =  (key) ->
      data_k_v = {key: key, val: null}
      Socket.emit("data", data_k_v)
      
    $scope.getDataElem = (obj) ->
      $scope.data.getObj(obj)
      
    $scope.registerTick= (key, elem) ->
      console.log "registering tick"
      data_k_v = {key: key, elem: elem}
      Socket.emit('registerTick', data_k_v)
    
    $scope.unregisterTick= (key, elem) ->
      console.log "unregistering tick"
      data_k_v = {key: key, elem: elem}
      Socket.emit('unregisterTick', data_k_v)
      
    $scope.calcAge = (dateString) ->
      birthday = +new Date(dateString);
      return~~ ((Date.now() - birthday) / (31557600000));
      
    $scope.connectionLosses = 0
    $scope.connectedOld = false
    $scope.isConnected = ->
      if Socket.isConnected()
        $scope.connectedOld = true
      if not Socket.isConnected() and $scope.connectedOld
        $scope.connectionLosses += 1
        $scope.connectedOld = false
      Socket.isConnected()
        
      

class DataElement
  key: "unkownElement"
  scope = null

  constructor:  ($scope) ->
    $scope.doNotSend = true
    $scope.model = null
    $scope.key =  @key
    @scope = $scope
    
    $scope.update = ->
      #@updatefn this
      if $scope.doNotSend
        console.log "sending not allowed now"
      else
        $scope.data.send $scope
        
    $scope.actionAllowed = ->
      not $scope.doNotSend
      
    $scope.refreshGUI = ->
      $scope.doNotSend = false
      #$scope.$apply()
      
    $scope.getDownloadData =  ->
      json = JSON.stringify($scope.model)
      return new Blob([json], {type: "application/json"})
      
    $scope.updateModelAfterUpload = ->
      $scope.update()
      
    $scope.getFile =  ->
      reader = new FileReader()
      reader.onload = ->
        #TODO add some security #FIXME hometeam guest team does not get updted
        text = reader.result
        newmodel = JSON.parse(text)
        $scope.model = newmodel
        $scope.updateModelAfterUpload()
      reader.readAsText($scope.file);
      
      
    $scope.data.registerElem($scope.key, $scope)
    $scope.requestCurrentData($scope.key)

class GameClock extends DataElement
  key: "GameClock"
  
  @timeToSeconds: (time) ->
    time = time.split(/:/)
    minutes = parseInt(time[0])
    seconds = parseInt(time[1])
    minutes * 60 + seconds
		
  constructor:  ($scope) ->
    super $scope
    $scope.model = {
      showClock: false
      clockRunning: false
      curTime: 0
      info: 0
      quarter: 0
      timeOutsHome: 3
      timeOutsGuests: 3
    }

    $scope.toggleClockVisibility = ->
      $scope.model.showClock = not $scope.model.showClock
      $scope.update()
      
    $scope.startClock = ->
      if $scope.model.curTime <= 0
        return
      $scope.model.clockRunning = true
      $scope.update()
      if $scope.actionAllowed()
        $scope.registerTick($scope.key, 'curTime')
    $scope.stopClock = ->
      $scope.model.clockRunning = false
      $scope.update()
      if $scope.actionAllowed()
        $scope.unregisterTick($scope.key, 'curTime')
      
      
    $scope.toggleClockRunning = ->
      if $scope.model.clockRunning
        $scope.stopClock()
      else
        $scope.startClock()
      
    $scope.getClockVisible = ->
      $scope.model.showClock
      
    $scope.getClockRunning = ->
      $scope.model.clockRunning
      
    $scope.setTime = ->
      if not $scope.enteredTime
        totalseconds = 720 # 12 minutes
      else
        try 
          input = $scope.enteredTime
          totalseconds = GameClock.timeToSeconds input
          if (isNaN(totalseconds)) 
            throw "input is NaN"
          console.log 'setting time to ' + totalseconds
          
        catch e
          console.error 'could not set time'
          return
        

      
      $scope.model.curTime = totalseconds
      $scope.enteredTime = ''
      $scope.update()
      
    $scope.getTime = ->
      value = $scope.model.curTime
      
      seconds = value % 60;
      if (seconds < 10)
        seconds = '0' + seconds;
        
      minutes = Math.floor(value / 60);
      if (minutes < 10)
        minutes = '0' + minutes;
        
      (minutes + ":" + seconds)
      
    $scope.$watch('model.curTime', -> (
        if $scope.model.curTime <= 0
          $scope.model.curTime = 0
          $scope.stopClock()
      ))
      
    $scope.$watch('enteredTime', -> (
        $scope.enteredTime ?= ''
        time = $scope.enteredTime.split(':').join('') # remove colons from string
        
        OPERATOR = /// ^
              (\d*?)      # discard digits before that
              (\d{0,2}?)  # minutes: zero, one or two digits
              :?          # optional colon (unnecessray as colons get removed), so just to be sure
              (\d{0,2})   # seconds: zero, one or two digits
              $
              ///
        OPERATOR.exec(time)
        minutes = RegExp.$2
        seconds = RegExp.$3
        
        unless seconds
          $scope.enteredTime = ''
          console.log "invalid time specified"
          return
          
          
        unless minutes
          minutes = '00'
        if seconds.length < 2
          seconds = '0' + seconds
          
        timeToBeEntered = minutes + ":" + seconds
        $scope.enteredTime = timeToBeEntered
      ))
      
    $scope.setInfo = (id) ->
      $scope.model.info = id
      $scope.update()
      
    $scope.getInfo = ->
      try
        parseInt($scope.model.info)
      catch e
        0
    
    $scope.getQuarter = ->
      $scope.model.quarter
      
    $scope.tmpQuarterTxt = ""
    $scope.getQuarterTxt = ->
      if $scope.model.quarter is 0
        return $scope.tmpQuarterTxt
      switch $scope.model.quarter
        when 1 then $scope.tmpQuarterTxt = "1st"
        when 2 then $scope.tmpQuarterTxt = "2nd"
        when 3 then $scope.tmpQuarterTxt = "3rd"
        when 4 then $scope.tmpQuarterTxt = "4th"
        when 5 then $scope.tmpQuarterTxt = "OVT"
       $scope.tmpQuarterTxt
      
      
      
    $scope.$watch('enteredQuarter', -> (
      unless 5 >= $scope.enteredQuarter >= 0
        $scope.enteredQuarter = ''
    ))
    
    $scope.setQuarter = (quarter) ->
      if quarter is undefined
        if $scope.enteredQuarter
          quarter = $scope.enteredQuarter
        else
          return false
          
      if 5 >= quarter >= 0
        $scope.model.quarter = parseInt quarter
      
      $scope.enteredQuarter = ''
      $scope.update()
      

      
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

AppCtrl = ($scope) ->
  $scope.name = "Espresso"

AppCtrl.$inject = ["$scope"]
HeaderController = ($scope, $location) ->
    $scope.isActive =  (viewLocation) ->
        viewLocation is $location.path()
RosterController = ($scope, $routeParams) ->
  $scope.team = $routeParams.team.toLowerCase()
  
  if $scope.team is "home"
    new HomeTeam($scope)
  else if $scope.team is "guests"
    new GuestTeam($scope)
  else
    $scope.team = "---INVALID---"

RouteController = ($scope, $routeParams) ->
  $scope.templateUrl = '/partials/manage/'+$routeParams.part
  

  
  
  console.log($scope.templateUrl)
###
   Generated via coffescript-concat
   files in angular-concat/controllers
###

















