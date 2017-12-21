
(function() {
    
    angular.module('FGases.services.ui').service('messageBox', [
        
        '$window', 'objectUtil',
        
        function($window, objectUtil) {
            function MessageBox() { }
            
            MessageBox.prototype.alert = function(message, callback) {
                $window.alert(message);
                objectUtil.call(callback);
            };
            
            MessageBox.prototype.confirm = function(message, callback) {
                var result = $window.confirm(message);
                objectUtil.call(callback, result);
            };
            
            return new MessageBox();
        }
    ]);
    
})();


