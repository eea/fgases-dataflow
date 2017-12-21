
(function() {
    angular.module('FGases.services.util').factory('numericUtil', [
        
        'objectUtil',
        
        function(objectUtil) {
            
            function NumericUtil() { }
            
            NumericUtil.prototype.isNum = function(value) {
                return !objectUtil.isNull(value) && !isNaN(value);
            };
            
            NumericUtil.prototype.toNum = function(value, defaultValue) {
                if (!this.isNum(value)) {
                    return this.isNum(defaultValue) ? defaultValue : null;
                }
                
                return Number(value);
            };
            
            NumericUtil.prototype.sum = function(/* varargs */) {
                var result = null;
                
                for (var i = 0; i < arguments.length; i++) {
                    var value = arguments[i];
                    
                    if (!this.isNum(value)) {
                        continue;
                    }
                    
                    if (!this.isNum(result)) {
                        result = 0;
                    }
                    
                    result += value;
                }
                
                return result;
            };
            
            return new NumericUtil();
        }
    ]);
})();
