
(function() {
    // Definition of comment add/edit modal instance Controller
    angular.module('FGases.controllers').controller('CommentAddEditModalInstanceController', function($rootScope, $scope, $modalInstance, modalData, modalExtras, FormConstants){
        //define controller variables
        $scope.commentAddEditModalTitle = modalExtras && typeof modalExtras.title !== 'undefined' ? modalExtras.title : 'common.comment-add-modal-title';
        $scope.commentValue = null;
        if (modalData != null && angular.isDefined(modalData.Comment) && modalData.Comment){
            $scope.commentValue = angular.copy(modalData.Comment);
            $scope.commentAddEditModalTitle = 'common.comment-edit-modal-title';
        }

        //define controller variables
        $scope.alerts = [];

        //define OK button action function
        $scope.ok = function(result){
            $scope.alerts = [];
            var results = {};
            if ($scope.commentValue != null){
                $scope.commentValue = $scope.commentValue.trim();
                if ($scope.commentValue.length == 0){
                    $scope.commentValue = null;
                }
            }

            //if null then user may want to delete comment
            if ($scope.commentValue != null){
                var commentsRegEx = FormConstants.CommentsRegEx;
                if (!commentsRegEx.test($scope.commentValue) || $scope.commentValue.length < 2){
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.comment-should-contain-alpha-numeric-characters';
                    $scope.alerts.push(alert);
                }
            }

            if ($scope.alerts.length == 0) {
                if (modalData != null) {
                    modalData.Comment = $scope.commentValue;
                }
                results.Comment = $scope.commentValue;
                $modalInstance.close(results);
            }
        };//end of ok function

        //define CANCEL button action function
        $scope.cancel = function(){
            $modalInstance.dismiss('cancel');
        };//end of cancel function
    });//end of app controller 'CommentAddEditModalInstanceController'
})();
