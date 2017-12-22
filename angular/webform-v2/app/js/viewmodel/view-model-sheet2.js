
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet2', [
        
        'ViewModelObjectBase', 'ViewModelSheet2Section5', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet2Section5, objectUtil) {
            
            function ViewModelSheet2(viewModel) {
                if (!(this instanceof ViewModelSheet2)) {
                    return new ViewModelSheet2(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section5 = new ViewModelSheet2Section5(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet2);
            
            return ViewModelSheet2;
        }
    ]).factory('ViewModelSheet2Section5', [
        
        'ViewModelSectionBase', 'sheet2Validator', 'gasHelper', 'objectUtil', 'arrayUtil',
        
        function(ViewModelSectionBase, sheet2Validator, gasHelper, objectUtil, arrayUtil) {
            
            function ViewModelSheet2Section5(sheet2ViewModel) {
                if (!(this instanceof ViewModelSheet2Section5)) {
                    return new ViewModelSheet2Section5(sheet2ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet2ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet2Section5);
            
            ViewModelSheet2Section5.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F2_S5_exempted_HFCs;
            };
            
            ViewModelSheet2Section5.prototype.isAcceptableGas = function(gasId) {
                var reportedGas = this.getRoot().getReportedGasById(gasId);
                
                return gasHelper.isHfcBasedGas(reportedGas);
            };
            
            ViewModelSheet2Section5.prototype.getTr05AOwnTradePartner = function() {
                return this._getTrOwnTradePartner(this.getSectionData().tr_05A_TradePartners.Partner);
            };
            
            ViewModelSheet2Section5.prototype.getTr05BTradePartners = function() {
                return this.getSectionData().tr_05B_TradePartners.Partner;
            };
            
            ViewModelSheet2Section5.prototype.getTr05BOwnTradePartner = function() {
                return this._getTrOwnTradePartner(this.getTr05BTradePartners());
            };
            
            ViewModelSheet2Section5.prototype.hasTr05C_ExemptedNonZeroValues = function() {
                var result = false;
                
                arrayUtil.forEach(this.getSectionData().Gas, function(gas, loopContext) {
                    var foundInPartner = arrayUtil.contains(gas.tr_05C.TradePartner, function(tradePartnerInfo) {
                        return !objectUtil.isNull(tradePartnerInfo.amount) && tradePartnerInfo.amount > 0;
                    });
                    loopContext.breakLoop = foundInPartner;
                    result = result || foundInPartner;
                });

                return result;
            };
            
            ViewModelSheet2Section5.prototype.isValidQc2044 = function() {
                var qc2044Transaction = arrayUtil.selectSingle(sheet2Validator.transactionValidations, function(transactionValidation) {
                    return transactionValidation.transaction.id === 'tr_05C';
                });
                var qc2044Rule = arrayUtil.selectSingle(qc2044Transaction.rules, function(rule) {
                    return rule.qccode === 2044;
                });
                
                return qc2044Rule.isValid(this.getRoot());
            };
            
            ViewModelSheet2Section5.prototype._getTrOwnTradePartner = function(transactionPartners) {
                var root = this.getRoot();
                return arrayUtil.selectSingle(transactionPartners, function(tradePartner) {
                    return root.isOwnCompany(tradePartner);
                });
            };
            
            return ViewModelSheet2Section5;
        }
    ]);
})();
