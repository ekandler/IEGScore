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
      $scope.model.info
    
  
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