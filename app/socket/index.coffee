

exports.configure = (io) ->

  ###
    Socket.IO config
  ###
  datacopy = {}
  tickreg = []
  
  countdown= ->
    if tickreg.length > 0
      for elem in tickreg
        try
          datacopy[elem.key][elem.elem]--
          
          data_k_v = {key: elem.key, val: datacopy[elem.key]}
          io.sockets.emit "data", data_k_v
          #console.log datacopy
        catch
          
      #console.log elem
  
  containsObject= (arr, item) ->
    i = 0
    for elem in arr
      if elem.key is item.key and elem.elem is item.elem
        return true
    false
    
  removeObject= (arr, item) ->
      for elem in arr
        if elem.key is item.key and elem.elem is item.elem
          arr.splice(arr.indexOf elem, 1)
  
  setInterval(countdown, 1000);            
  
  io.on "connection", (socket) ->
    console.log "New socket connected!"
    #io.emit "data", datacopy
    
    socket.on "ping", ->
      time = new Date()
      io.sockets.emit "pong", {data: "pong! Time is #{time.toString()}"}
      
    socket.on "data", (data) ->
      #console.log "data"
      #console.log data
      #console.log datacopy
      
      console.log "received " + data.key
      key = data.key
      val = data.val
      unless val is null
        datacopy[key] = val
      else
        console.log "request for " + data.key
        
      data.val = datacopy[key]
      
      
      #console.log data
      io.sockets.emit "data", data
      
    socket.on "registerTick", (data) ->
      unless containsObject(tickreg, data)
        console.log "registering"
        tickreg.push data
        
    socket.on "unregisterTick", (data) ->
      if containsObject(tickreg, data)
        console.log "unregistering"
        removeObject(tickreg, data)
        
    