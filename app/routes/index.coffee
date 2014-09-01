
###
  GET home page
###

exports.index = (request, response) ->
  response.render "index"

###
  GET partial templates
###

exports.partials = (request, response) ->
  response.render "partials/" + request.params.name
  
exports.partialdirs = (request, response) ->
  response.render "partials/" + request.params.dir + "/" + request.params.name
  
exports.manage = (request, response) ->
  response.render "manage"
  
exports.view = (request, response) ->
  response.render "view"
  
exports.overview = (request, response) ->
  response.render "overview"
  
exports.smartwatch = (request, response) ->
  response.render "smartwatch"