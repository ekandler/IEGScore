"use strict"

###
  Directives
###

angular.module("myApp.directives", ["ngResource"])
.directive "appVersion", ["version", (version) ->
  (scope, elm, attrs) ->
    elm.text version
]

module = angular.module("ScoreApp.directives", ["ngResource"])

module.directive 'selectOnClick',  ->
  restrict: 'A'
  link: (scope, element, attrs) -> 
    element.on('click', -> 
      this.select()
    )

module.directive 'downloadData', ($compile, $interval) ->
  restrict:'E'
  #scope:{ getData: '&'}
  link: (scope, elm, attrs) ->
    
    
    setData = ->
      url = URL.createObjectURL(scope.getDownloadData())
      key = scope.key
      console.log "new download"
      elm.empty()
      elm.append($compile(
          '<a class="btn btn-sm btn-primary" download="'+key+'.json"' +
              'href="' + url + '">' +
              'Download' +
              '</a>'
      )(scope));
      
    #timeoutId = $interval( ( -> 
    #  setData()
    #), 1000);
              
    scope.$watch('model', setData, true);
    
module.directive "ngFileSelect", ->
    link: ($scope,el) ->
      
      el.bind("change", (e) ->
      
        element = (e.srcElement || e.target);
        $scope.file = element.files[0]
        $scope.getFile();
        
        # try to get rid of file in input
        try
          element.value = null
        catch error
          element.parentNode.replaceChild(element.cloneNode(true), element);
        
      )


module.directive('animateOnChange', ($animate) ->
  return (scope, elem, attr) ->
      scope.$watch(attr.animateOnChange, (nv,ov) ->
        if (nv!=ov)
          c = 'change'
          $animate.addClass(elem,c, ->
            $animate.removeClass(elem,c)
          )
      )  
)

module.directive('ngControlAudio', ($audio) ->
  return (scope, elem, attr) ->
      scope.$watch(attr.ngControlAudio, (nv,ov) ->
        if (nv!=ov)
          console.log "change"
      )  
)