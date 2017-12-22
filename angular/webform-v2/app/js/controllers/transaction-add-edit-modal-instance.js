
(function() {
    // Definition of transaction add/edit modal instance Controller
    angular.module('FGases.controllers').controller('TransactionAddEditModalInstanceController', function($rootScope, $scope, $modalInstance, modalData, modalExtras, FormConstants){
        //define controller variables
        $scope.transactionAddEditModalTitle = modalExtras && typeof modalExtras.title !== 'undefined' ? modalExtras.title : 'common.transaction-add-modal-title';
        $scope.modalExtras = angular.copy(modalExtras);
        //define controller variables
        $scope.alerts = [];
        $scope.transactions = {};
        $scope.txid={};
        $scope.cur_tx = [];
        var tx;
        // Create transaction(s)
        for (var i = 0; i < modalExtras.gasArray.length; i++) {
            $scope.transactions[modalExtras.gasArray[i].GasCode] = modalExtras.gasArray[i].tr_12A.Transactions;
            $scope.txid[modalExtras.gasArray[i].GasCode] = modalExtras.gasArray[i].tr_12A.Transactions.length;
            tx = clone($scope.getInstanceByPath('emptyInstance', modalExtras.emptyInstancePath));
            $scope.cur_tx.push(tx);
            $scope.transactions[modalExtras.gasArray[i].GasCode].push(tx);
        }
        // Return true if there's a partner of type p_type in the current transactions
        $scope.has_partner = function(p_type) {
            var result = true;
            for (var i = 0; i < modalExtras.gasArray.length; i++) {
                if ($scope.transactions[modalExtras.gasArray[i].GasCode].length > 0){
                    if ($scope.transactions[modalExtras.gasArray[i].GasCode][$scope.txid[modalExtras.gasArray[i].GasCode]]) {
                        if (!$scope.transactions[modalExtras.gasArray[i].GasCode][$scope.txid[modalExtras.gasArray[i].GasCode]][p_type].TradePartnerID) {
                            result = false
                        }
                    }
                } else {
                    result = false;
                }
            }
            return result;
        }
        // Return the company name of the partner of type p_type
        $scope.get_partner_name = function(p_type) {
            var partner;
            for (var i=0; i<this.$parent.cur_tx.length; i++) {
                if (this.$parent.cur_tx[0][p_type].TradePartnerID) {
                    partner = this.$parent.cur_tx[0][p_type].TradePartnerID
                }
            }
            if (partner) {
                for (var j = 0; j < modalExtras[p_type].Partner.length; j++) {
                    if (partner == modalExtras[p_type].Partner[j].PartnerId) {
                        return modalExtras[p_type].Partner[j].CompanyName;
                    }
                }
            }
        }
        //define OK button action function
        $scope.ok = function(result){
            $scope.alerts = [];
            var results = {};

            if (!angular.equals({}, $scope.transaction)) {
                if ($scope.alerts.length == 0) {
                    // Remove transactions with no amount
                    for (var i = 0; i < modalExtras.gasArray.length; i++) {
                        for (var j=0; j< $scope.transactions[modalExtras.gasArray[i].GasCode].length; j++) {
                            if (!$scope.transactions[modalExtras.gasArray[i].GasCode][j].Amount) {
                                $scope.transactions[modalExtras.gasArray[i].GasCode].splice(j, 1);
                            }
                        }
                    }
                    results.transactions = $scope.transactions;
                    results.modalExtras = $scope.modalExtras;
                    $modalInstance.close(results);
                }
            }
            // //if null then user may want to delete comment
            // if ($scope.commentValue != null){
            //     var commentsRegEx = FormConstants.CommentsRegEx;
            //     if (!commentsRegEx.test($scope.commentValue) || $scope.commentValue.length < 2){
            //         var alert = {};
            //         alert.type = 'danger';
            //         alert.msg = 'common.comment-should-contain-alpha-numeric-characters';
            //         $scope.alerts.push(alert);
            //     }
            // }

        };//end of ok function

        //define CANCEL button action function
        $scope.cancel = function(){
            for (var i = 0; i < modalExtras.gasArray.length; i++) {
                $scope.transactions[modalExtras.gasArray[i].GasCode].splice($scope.txid[modalExtras.gasArray[i].GasCode], 1);
            }
            $modalInstance.dismiss('cancel');
        };//end of cancel function
    });//end of app controller 'CommentAddEditModalInstanceController'
})();
