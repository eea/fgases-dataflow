
(function() {
    angular.module('FGases.services.ui').service('commentModalService', ['$modal', function ($modal) {
        return {
            open: function ($scope, size, templateUrl, controller, modalData, onConfirmCallback, onCancelCallback, extras) {
                // if no callback is set , set empty function
                onConfirmCallback = onConfirmCallback || angular.noop;
                onCancelCallback = onCancelCallback || angular.noop;
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
                        modalData: function () {
                            return modalData;
                        },
                        modalExtras: function () {
                            return extras && typeof extras !== 'undefined' ? extras : {};
                        }
                    }
                });
                modalInstance.result.then(onConfirmCallback, onCancelCallback);
            }
        };
    }]);
})();
