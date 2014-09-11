
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
        
      