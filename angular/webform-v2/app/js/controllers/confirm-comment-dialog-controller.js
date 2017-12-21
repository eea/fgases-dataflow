
(function() {
    angular.module('FGases.controllers').controller('ConfirmCommentDialogController', [
        '$scope', '$modalInstance', 'modalExtras',
        
        function($scope, $modalInstance, modalExtras){
            $scope.ok = function(){
                $modalInstance.close();
            };
            $scope.cancel = function(){
                $modalInstance.dismiss('cancel');
            };
            
            $scope.title = modalExtras.title;
            $scope.body = modalExtras.body;
        }
    ]);
})();
