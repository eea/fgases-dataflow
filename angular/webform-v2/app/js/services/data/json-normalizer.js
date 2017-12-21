
(function() {
    
    window.angular.module('FGases.services.data').factory('jsonNormalizer', [
        
        'objectUtil',
        
        function(objectUtil) {
            
            function JsonNormalizer() { }
            
            JsonNormalizer.prototype.normalizeObjectProperty = function(obj, propertyName) {
                if (objectUtil.isNull(obj[propertyName])) {
                    obj[propertyName] = new Object();
                }
            };
            
            JsonNormalizer.prototype.normalizeArrayProperty = function(obj, propertyName, excludeValuePredicate) {
                var propertyValue = obj[propertyName];

                if (objectUtil.isNull(propertyValue)) {
                    obj[propertyName] = [];
                    return;
                }

                if (window.angular.isArray(propertyValue)) {
                    return;
                }

                var arrayValue = [];
                
                if (objectUtil.isNull(excludeValuePredicate) || !excludeValuePredicate.call(null, propertyValue)) {
                    arrayValue.push(propertyValue);
                }
                
                obj[propertyName] = arrayValue;
            };
            
            JsonNormalizer.prototype.getArrayPropertyValue = function(obj, propertyName) {
                var propertyValue = obj[propertyName];

                if (objectUtil.isNull(propertyValue)) {
                    return [];
                }

                if (window.angular.isArray(propertyValue)) {
                    return propertyValue;
                }

                return [ propertyValue ];
            };
            
            return new JsonNormalizer();
        }
    ]);
})();
