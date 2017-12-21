
(function() {
    //a directive to make element focused when shown
    angular.module('FGases.directives').directive('focusMe', function ($timeout) {
        return {
            restrict: 'A',
            link: function (scope, element) {
                $timeout(function () {
                    element[0].focus(); //element.focus();
                }, 700);
            }
        };
    });
})();
