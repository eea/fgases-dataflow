
(function() {
    // Definition of generic modal controller
    angular.module('FGases.controllers').controller('ModalController', function($scope, $rootScope, $modal){
        //define open function
        $scope.open = function(size, templateUrl, controller, modalDataInitialValue, closeCallBackFn, extras){
            closeCallBackFn =  closeCallBackFn || angular.noop;
            //create modalInstance
            var modalInstance = $modal.open({
                templateUrl: templateUrl,
                controller: controller,
                keyboard: true,
                backdrop: 'static',
                size: size,
                scope: $scope,
                windowClass: 'app-modal-window',
                resolve: {
                    modalData: function(){
                        //return angular.copy(modalDataInitialValue);
                        return modalDataInitialValue;
                    },
                    modalExtras: function(){
                        return extras && typeof extras !== 'undefined' ? extras : {};
                    }
                }
            });
            //define close and dismiss functions respectively
            modalInstance.result.then(closeCallBackFn,
            //TODO dismiss call back can also be defined
            function(){
                //modal dismissed!
            });
        }; //end of open function definition
    }); //end of app controller 'ModalController'
})();
