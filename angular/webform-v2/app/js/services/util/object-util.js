
(function() {
    angular.module('FGases.services.util').factory('objectUtil', [
        function() {
            function ObjectUtil() { }
            
            ObjectUtil.prototype.isNull = function(value) {
                return angular.isUndefined(value) || value === null;
            };
            
            ObjectUtil.prototype.defaultIfNull = function(value, defaultValue) {
                return this.isNull(value) ? defaultValue : value;
            };
            
            ObjectUtil.prototype.call = function(func) {
                if (!func) return;

                var args = [];

                for (var i = 1; i < arguments.length; ++i) {
                    args.push(arguments[i]);
                }

                return func.apply(null, args);
            };
            
            ObjectUtil.prototype.chainConstructor = function(sourceConstructor, targetConstructor) {
                this.chainPrototype(sourceConstructor.prototype, targetConstructor);
            };
            
            ObjectUtil.prototype.chainPrototype = function(sourcePrototype, targetConstructor) {
                targetConstructor.prototype = Object.create(sourcePrototype, {
                    constructor: {
                        configurable: true,
                        enumerable: true,
                        writable: true,
                        value: targetConstructor
                    }
                });
            };
            
            return new ObjectUtil();
        }
    ]);
})();
