
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
  