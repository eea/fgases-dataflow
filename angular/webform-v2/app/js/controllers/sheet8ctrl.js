(function() {
    // Definition of transaction add/edit modal instance Controller
    angular.module('FGases.controllers').controller('Sheet8Ctrl', function($rootScope, $scope){

        $scope.txids=[];
        $scope.onlyNumbers = /\d+\.?\d*/;
        $scope.emptyTransaction;

        $scope.init = function(args) {
            $scope.args = args;

            if (!$scope.transactions) {
                $scope.transactions = {};
                if (!$scope.emptyTransaction) {
                    $scope.emptyTransaction = clone(this.getInstanceByPath('emptyInstance', this.args.emptyInstancePath));
                }
                for (var i = 0; i < $scope.args.gasArray.length; i++) {
                    var transactions = $scope.args.gasArray[i].tr_12A.Transaction;
                    if (!Array.isArray(transactions)) {
                        transactions = [];
                        $scope.args.gasArray[i].tr_12A.Transaction = transactions;
                    }
                    $scope.transactions[$scope.args.gasArray[i].GasCode] = transactions;
                    for (var j = 0; j < $scope.transactions[$scope.args.gasArray[i].GasCode].length; j++) {
                        if (!$scope.txids[j]) {
                            $scope.txids[j] = {};
                        }
                        var txinfo = $scope.txids[j];
                        txinfo[$scope.args.gasArray[i].GasCode] = $scope.transactions[$scope.args.gasArray[i].GasCode][j].TransactionID;
                    }

                }
            }

            $scope.$watch(function() { return $scope.args.s11Array; }, function(){
                for (var i = 0; i < $scope.args.gasArray.length; i++) {
                    $scope.args.gasArray[i].Totals.tr_12B = $scope.args.s11Array[i].tr_11G.Amount;
                }
            }, true);

            $scope.$watch(function() {return $scope.args.gasArray.length;}, function(){
                var gas_txs;
                for (var i = 0; i < $scope.args.gasArray.length; i++) {
                    if (!$scope.transactions[$scope.args.gasArray[i].GasCode]) {
                        if (!$scope.transactions[$scope.args.gasArray[0].GasCode]) {
                            $scope.transactions[$scope.args.gasArray[i].GasCode] = [];
                        } else {
                            $scope.transactions[$scope.args.gasArray[i].GasCode] = angular.copy($scope.transactions[$scope.args.gasArray[0].GasCode]);
                        }
                        if ($scope.transactions[$scope.args.gasArray[i].GasCode]) {
                            for (var j = 0; j < $scope.transactions[$scope.args.gasArray[i].GasCode].length; j++) {
                                var new_tx_id = 'transaction_' + Date.now();
                                $scope.transactions[$scope.args.gasArray[i].GasCode][j].TransactionID = new_tx_id;
                                $scope.transactions[$scope.args.gasArray[i].GasCode][j].Amount = null;
                                $scope.transactions[$scope.args.gasArray[i].GasCode][j].Comment = null;
                                $scope.txids[j][$scope.args.gasArray[i].GasCode] = new_tx_id;
                            }
                        $scope.args.gasArray[i].tr_12A.Transaction = $scope.transactions[$scope.args.gasArray[i].GasCode];
                        }
                    }
                }
                if (Object.keys($scope.transactions).length > $scope.args.gasArray.length) {
                    var gascodes = $scope.get_gascodes();
                    var to_remove = [];
                    angular.forEach($scope.transactions, function(value, key) {
                        if (gascodes.indexOf(parseInt(key, 10)) === -1) {
                            to_remove.push(parseInt(key, 10));
                        }
                    });
                    for (var i = 0; i < to_remove.length; i++) {
                        delete $scope.transactions[to_remove[i]];
                        for (var j = 0; j < $scope.txids; j++) {
                            delete $scope.txids[j][to_remove[i]];
                        }
                    }
                }
            });

        }

        $scope.get_gascodes = function() {
            var gascodes = [];
            for (var i = 0; i < $scope.args.gasArray.length; i++) {
                gascodes.push($scope.args.gasArray[i].GasCode);
            }
            return gascodes;
        }


        $scope.has_partner = function(p_type, txid) {
            var result = false;
            for (var i = 0; i < this.args.gasArray.length; i++) {
                if ($scope.transactions[this.args.gasArray[i].GasCode].length > 0){
                    for (var j = 0; j < $scope.transactions[this.args.gasArray[i].GasCode].length; j++) {
                        if ($scope.transactions[this.args.gasArray[i].GasCode][j].TransactionID == txid[this.args.gasArray[i].GasCode]) {
                            if ($scope.transactions[this.args.gasArray[i].GasCode][j][p_type].TradePartnerID) {
                                result = true;
                            }
                        }
                    }
                }
            }
            return result;
        }

        $scope.get_partner = function(p_type, partner_id) {
            for (var j = 0; j < this.args['Partners'].Partner.length; j++) {
                if (partner_id == this.args['Partners'].Partner[j].PartnerId) {
                    return {
                            "partner": this.args['Partners'].Partner[j],
                            "p_type": p_type,
                            "index": j
                            };
                }
            }
        }
        // Return the company name of the partner of type p_type
        $scope.get_tx_partner = function(p_type, txid) {
            var partner_id = null;
            var tx_year = null;
            for (var i = 0; i < this.args.gasArray.length; i++) {
                if ($scope.transactions[this.args.gasArray[i].GasCode].length > 0){
                    for (var j = 0; j < $scope.transactions[this.args.gasArray[i].GasCode].length; j++) {
                        if ($scope.transactions[this.args.gasArray[i].GasCode][j].TransactionID == txid[this.args.gasArray[i].GasCode]) {
                            partner_id = $scope.transactions[this.args.gasArray[i].GasCode][j][p_type].TradePartnerID;
                            tx_year = $scope.transactions[this.args.gasArray[i].GasCode][j][p_type].Year;
                            $scope.calculate_sums();
                        }
                    }
                }
            }

            if (partner_id) {
                var partner = this.get_partner(p_type, partner_id);
                if (partner) {
                    return {
                            'partner': partner.partner,
                            'year': tx_year
                        };
                }
            }
        }

        $scope.get_transactions_pairs = function(excl_tx) {
            var gases = this.args.gasArray;
            var pairs = {};
            for (var i = 0; i < gases.length; i++) {
                pairs[gases[i].GasCode] = [];
                for (var j = 0; j < gases[i].tr_12A.Transaction.length; j++) {
                    if (gases[i].tr_12A.Transaction[j].POM.TradePartnerID && gases[i].tr_12A.Transaction[j].Exporter.TradePartnerID) {
                        var pom_partner = $scope.get_partner('POM', gases[i].tr_12A.Transaction[j].POM.TradePartnerID);
                        var exp_partner = $scope.get_partner('Exporter', gases[i].tr_12A.Transaction[j].Exporter.TradePartnerID);
                        if (pom_partner && exp_partner && excl_tx[gases[i].GasCode] !== gases[i].tr_12A.Transaction[j].TransactionID) {
                            pairs[gases[i].GasCode].push(JSON.stringify({
                                'POM': pom_partner.partner.CompanyName,
                                'POMYear': parseInt(gases[i].tr_12A.Transaction[j].POM.Year),
                                'EXP': exp_partner.partner.CompanyName,
                                'EXPYear': parseInt(gases[i].tr_12A.Transaction[j].Exporter.Year)
                                }));
                        }
                    }
                }
            }
            return pairs;
        };

        $scope.calculate_sums = function() {
            for (var i = 0; i < this.args.gasArray.length; i++) {
                var sum = 0;
                txs = this.args.gasArray[i].tr_12A.Transaction;
                this.args.gasArray[i].tr_12A.Unit = 'metrictonnes';
                for (var j = 0; j < txs.length; j++) {
                    var val = (isEmpty(txs[j].Amount) || isNaN(txs[j].Amount)) ? 0.0 : parseFloat(txs[j].Amount);
                    sum += val;
                }
                this.args.gasArray[i].tr_12A.SumOfPartnersAmount = parseFloat(sum).toFixed(3);
                var tr_12b_val = this.args.gasArray[i].Totals.tr_12B;
                var tr_12c_val = parseFloat(tr_12b_val - sum).toFixed(3);
                this.args.gasArray[i].Totals.tr_12C = tr_12c_val;
            }
        }

        $scope.add_transaction = function() {
            var tx;
            var txid = 'transaction_' + Date.now();
            for (var i = 0; i < this.args.gasArray.length; i++) {
                this.transactions[this.args.gasArray[i].GasCode] = this.args.gasArray[i].tr_12A.Transaction;
                tx = clone(this.emptyTransaction);
                tx.TransactionID = txid;
                var index = this.transactions[this.args.gasArray[i].GasCode].push(tx) - 1;
                if (!this.txids[index]) {
                    this.txids[index] = {};
                }
                var txinfo = this.txids[index];
                txinfo[this.args.gasArray[i].GasCode] = txid;
            }
        }

        $scope.remove_transaction = function(transaction) {
            var txid;
            for (var i = 0; i < this.args.gasArray.length; i++) {
                if (this.transactions[this.args.gasArray[i].GasCode].length > 0){
                    for (var j = 0; j < this.transactions[this.args.gasArray[i].GasCode].length; j++) {
                        if (this.transactions[this.args.gasArray[i].GasCode][j].TransactionID == transaction[this.args.gasArray[i].GasCode]) {
                            txid = j;
                        }
                    }
                    if (txid !== undefined) {
                        this.transactions[this.args.gasArray[i].GasCode].splice(txid, 1);
                    }
                }
            }
            // Delete the tx from txids
            this.$parent.txids = this.$parent.txids.filter(function(item) { 
                return item !== transaction;
            });
            // Re-Calculate SumOfPartnersAmount
            this.$parent.calculate_sums();
        }
    });
})();
