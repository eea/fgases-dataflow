
(function() {
    angular.module('FGases.filters').filter('thousandSeparator', [
        
        'objectUtil',
        
        function(objectUtil) {
            var THOUSAND_SEPARATOR = ' ';
            var DECIMAL_SEPARATOR = '.';
            
            return function(input) {
                if (objectUtil.isNull(input) || isNaN(input)) {
                    return input;
                }
                
                var text = input.toString().trim();
                var parts = text.split(DECIMAL_SEPARATOR);
                var intPart = parts[0];
                var result = '';
                
                for (var i = 0; i < intPart.length; ++i) {
                    var digit = intPart.charAt(i);
                    
                    if ((intPart.length - i) % 3 === 0) {
                        result += THOUSAND_SEPARATOR;
                    }
                    
                    result += digit;
                }
                
                if (parts.length > 1) {
                    result += DECIMAL_SEPARATOR + parts[1];
                }
                
                return result;
            };
        }
    ]);
})();
