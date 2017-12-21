
(function() {
    //Includes method to focus and element with id
    angular.module('FGases.services.ui').factory('focus', function($timeout) {
        return function(id) {
            $timeout(function() {
                var element = document.getElementById(id);
                if(element) {
                    element.focus();
                }
            });
        };
    });
})();
