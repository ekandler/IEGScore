
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