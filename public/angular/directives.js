// Generated by CoffeeScript 1.9.0
"use strict";

/*
  Directives
 */
var module;

angular.module("myApp.directives", ["ngResource"]).directive("appVersion", [
  "version", function(version) {
    return function(scope, elm, attrs) {
      return elm.text(version);
    };
  }
]);

module = angular.module("ScoreApp.directives", ["ngResource"]);

module.directive('selectOnClick', function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function() {
        return this.select();
      });
    }
  };
});

module.directive('downloadData', function($compile, $interval) {
  return {
    restrict: 'E',
    link: function(scope, elm, attrs) {
      var setData;
      setData = function() {
        var key, url;
        url = URL.createObjectURL(scope.getDownloadData());
        key = scope.key;
        console.log("new download");
        elm.empty();
        return elm.append($compile('<a class="btn btn-sm btn-primary" download="' + key + '.json"' + 'href="' + url + '">' + 'Download' + '</a>')(scope));
      };
      return scope.$watch('model', setData, true);
    }
  };
});

module.directive("ngFileSelect", function() {
  return {
    link: function($scope, el) {
      return el.bind("change", function(e) {
        var element, error;
        element = e.srcElement || e.target;
        $scope.file = element.files[0];
        $scope.getFile();
        try {
          return element.value = null;
        } catch (_error) {
          error = _error;
          return element.parentNode.replaceChild(element.cloneNode(true), element);
        }
      });
    }
  };
});

module.directive('animateOnChange', function($animate) {
  return function(scope, elem, attr) {
    return scope.$watch(attr.animateOnChange, function(nv, ov) {
      var c;
      if (nv !== ov) {
        c = 'change';
        return $animate.addClass(elem, c, function() {
          return $animate.removeClass(elem, c);
        });
      }
    });
  };
});

module.directive('ngControlAudio', function($audio) {
  return function(scope, elem, attr) {
    return scope.$watch(attr.ngControlAudio, function(nv, ov) {
      if (nv !== ov) {
        return console.log("change");
      }
    });
  };
});