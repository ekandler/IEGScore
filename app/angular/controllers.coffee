"use strict"

###
  Controllers
###

AppCtrl = ($scope) ->
  $scope.name = "Espresso"

AppCtrl.$inject = ["$scope"]


UsersCtrl = ($scope, User) ->
  $scope.loadUsers = ->
    $scope.users = {}
    User.list {}
    , (data) ->
      $scope.users = data.message

UsersCtrl.$inject = ["$scope", "User"]

UserDetailCtrl = ($scope, $routeParams, User) ->
  $scope.user =
    User.get {userId: $routeParams.userId}
    , (data) ->
      $scope.user = data.user

UserDetailCtrl.$inject = ["$scope", "$routeParams", "User"]

SocketCtrl = ($scope, Socket) ->

  Socket.on "pong", (data) ->
    $scope.response = data.data

  $scope.ping = ->
    Socket.emit("ping", {})

SocketCtrl.$inject = ["$scope", "Socket"]


RouteController = ($scope, $routeParams) ->
  $scope.templateUrl = '/partials/manage/'+$routeParams.part
  

  
  
  console.log($scope.templateUrl)
 
 
RosterController = ($scope, $routeParams) ->
  $scope.team = $routeParams.team.toLowerCase()
  
  if $scope.team is "home"
    new HomeTeam($scope)
  else if $scope.team is "guests"
    new GuestTeam($scope)
  else
    $scope.team = "---INVALID---"
  

HeaderController = ($scope, $location) ->
    $scope.isActive =  (viewLocation) ->
        viewLocation is $location.path()



class DataElement
  key: "unkownElement"

  constructor:  ($scope) ->
    $scope.doNotSend = true
    $scope.model = null
    $scope.key =  @key
    
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
      
    $scope.getFile =  ->
      reader = new FileReader()
      reader.onload = ->
        #TODO add some security
        text = reader.result
        newmodel = JSON.parse(text)
        $scope.model = newmodel
        $scope.update()
        
        
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
    }  
    
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
      $scope.update()
      
      
    $scope.getDistance = ->
      $scope.model.distance
      
    $scope.$watch('enteredDistance', -> (
      unless 100 >= $scope.enteredDistance >= 0
        $scope.enteredDistance = ''
    ))
    
    $scope.setDistance = (distance) ->
      if distance is undefined
        if $scope.enteredDistance
          distance = $scope.enteredDistance
        else
          distance = 10
      
      if 100 >= distance >= 0
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
      roster: []
    } 
    
    
    $scope.positions = [
      {value: 'HC', text: 'Headcoach'},
      {value: 'QB', text: 'Quarterback'},
      {value: 'RB', text: 'Runningback'},
    ]; 
    
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
      
      
    $scope.addPlayer = ->
      $scope.inserted = {
        id: $scope.model.roster.length+1
        number: $scope.model.roster.length+1
        name: ''
        position: null
        dob: null
        size: null
        weight: null
        exp: null
        nat: "AT"
      }
      $scope.model.roster.push($scope.inserted)
      
    $scope.removePlayer = (index) ->
      $scope.model.roster.splice(index, 1)
      $scope.update()
      
    $scope.checkName = (data, id) ->
      if data is ""
        return "Empty name not allowed"
        
    

class HomeTeam extends Team
  key: "HomeTeam"
class GuestTeam extends Team
  key: "GuestTeam"
  
class TeamRouter
  constructor:  ($scope) ->
    console.log $scope.team
    if $scope.team is "home"
      new HomeTeam($scope)
    else
      new GuestTeam($scope)
  
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
      

    

#ManageCtrl.$inject = ["$scope", "Socket"]

