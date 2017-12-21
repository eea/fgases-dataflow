

(function() {
    angular.module('FGases.filters').filter('amountTonnes', [
        
        'objectUtil',
        
        function(objectUtil) {
            return function(input) {
                if (objectUtil.isNull(input) || isNaN(input)) {
                    return '';
                }
                
                return Number(input).toFixed(3);
            };
        }
    ]);
})();
