
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
      