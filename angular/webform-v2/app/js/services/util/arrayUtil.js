
(function() {
    angular.module('FGases.services.util').factory('arrayUtil', [
        
        'objectUtil',
        
        function(objectUtil) {
            function ArrayUtil() { }
            
            ArrayUtil.prototype.forEach = function(array, callback) {
                var loopContext = { breakLoop: false };
                
                for (var i = 0; i < array.length; ++i) {
                    loopContext.index = i;
                    objectUtil.call(callback, array[i], loopContext);
                    
                    if (loopContext.breakLoop) {
                        break;
                    }
                }
            };
            
            ArrayUtil.prototype.pushMany = function(array, items) {
                this.forEach(items, function(item) {
                    array.push(item);
                });
            };
            
            ArrayUtil.prototype.select = function(array, predicate) {
                var matches = [];
                this.forEach(array, function(item) {
                    if (objectUtil.call(predicate, item)) {
                        matches.push(item);
                    }
                });
                
                return matches;
            };
            
            ArrayUtil.prototype.selectSingle = function(array, predicate) {
                var index = this.indexOf(array, predicate);

                return index < 0 ? null : array[index];
            };
            
            ArrayUtil.prototype.contains = function(array, predicate) {
                return !objectUtil.isNull(this.selectSingle(array, predicate));
            };
            
            ArrayUtil.prototype.indexOf = function(array, predicate) {
                var index = -1;
                
                this.forEach(array, function(item, loopContext) {
                    if (objectUtil.call(predicate, item)) {
                        index = loopContext.index;
                        loopContext.breakLoop = true;
                    }
                });
                
                return index;
            };
            
            ArrayUtil.prototype.map = function(array, mapper) {
                var mapped = [];
                
                this.forEach(array, function(arrayItem, loopContext) {
                    var mappedItem = objectUtil.call(mapper, arrayItem, loopContext);
                    
                    if (!objectUtil.isNull(mappedItem)) {
                        mapped.push(mappedItem);
                    }
                });
                
                return mapped;
            };
            
            return new ArrayUtil();
        }
    ]);
})();
