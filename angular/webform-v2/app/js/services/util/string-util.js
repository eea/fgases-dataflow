
(function() {
    angular.module('FGases.services.util').factory('stringUtil', [
        'objectUtil',
        function(objectUtil) {
            function StringUtil() { }
            
            StringUtil.prototype.isEmpty = function(text) {
                return objectUtil.isNull(text) || text === '';
            };
            
            StringUtil.prototype.isBlank = function(text) {
                return this.isEmpty(text) || text.trim() === '';
            };
            
            StringUtil.prototype.toLowerCase = function(string) {
                if (this.isEmpty(string)) {
                    return string;
                }
                
                return string.toLowerCase();
            };
            
            StringUtil.prototype.toUpperCase = function(string) {
                if (this.isEmpty(string)) {
                    return string;
                }
                
                return string.toUpperCase();
            };
            
            StringUtil.prototype.equalsIgnoreCase = function(string1, string2) {
                return this.toUpperCase(string1) === this.toUpperCase(string2);
            };
            
            StringUtil.prototype.contains = function(text, searchText) {
                return text.indexOf(searchText) > -1;
            };
            
            StringUtil.prototype.startsWith = function(text, preffix) {
                if (preffix.length > text.length) {
                    return false;
                }
                
                return text.substring(0, preffix.length) === preffix;
            };
            
            return new StringUtil();
        }
    ]);
})();
