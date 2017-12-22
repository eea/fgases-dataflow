
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet8', [
        
        'ViewModelObjectBase', 'ViewModelSheet8Section12', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet8Section12, objectUtil) {
            
            function ViewModelSheet8(viewModel) {
                if (!(this instanceof ViewModelSheet8)) {
                    return new ViewModelSheet8(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section12 = new ViewModelSheet8Section12(this);
            }

            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet8);
            
            return ViewModelSheet8;
        }
    ]).factory('ViewModelSheet8Section12', [
        
        'ViewModelSectionBase', 'objectUtil', 'gasHelper', 'arrayUtil',
        
        function (ViewModelSectionBase, objectUtil, gasHelper, arrayUtil) {
            
            function ViewModelSheet8Section12(sheet8ViewModel) {
                if (!(this instanceof ViewModelSheet8Section12)) {
                    return new ViewModelSheet8Section12(sheet8ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet8ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet8Section12);
            
            ViewModelSheet8Section12.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F8_S12;
            };

            ViewModelSheet8Section12.prototype.getTr12ATransactions = function() {
                return this._getTrOwnTransactions(this.getSectionData().tr_12A_Transactions);
            };
            ViewModelSheet8Section12.prototype.getTr12AOwnTradePartner = function() {
                return this._getTrOwnTradePartner(this.getSectionData().tr_12A_TradePartners.Partner);
            };
            ViewModelSheet8Section12.prototype.getTr12APOM = function() {
                return this._getTrOwnTradePartner(this.getSectionData().tr_12A_POMS.POM);
            };

            ViewModelSheet8Section12.prototype._getTrOwnTransactionsTradePartner = function(transaction) {
                var root = this.getRoot();
                
                return arrayUtil.selectSingle(transactionPartners, function(tradePartner) {
                    return root.isOwnCompany(tradePartner);
                });
            };
            return ViewModelSheet8Section12;
        }
    ]);
})();
