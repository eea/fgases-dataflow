
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet4', [
        
        'ViewModelObjectBase', 'ViewModelSheet4Section9', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet4Section9, objectUtil) {
            
            function ViewModelSheet4(viewModel) {
                if (!(this instanceof ViewModelSheet4)) {
                    return new ViewModelSheet4(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section9 = new ViewModelSheet4Section9(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet4);
            
            return ViewModelSheet4;
        }
    ]).factory('ViewModelSheet4Section9', [
        
        'ViewModelSectionBase', 'objectUtil', 'arrayUtil', 'numericUtil',
        
        function (ViewModelSectionBase, objectUtil, arrayUtil, numericUtil) {
            
            function ViewModelSheet4Section9(sheet4ViewModel) {
                if (!(this instanceof ViewModelSheet4Section9)) {
                    return new ViewModelSheet4Section9(sheet4ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet4ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet4Section9);
            
            ViewModelSheet4Section9.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F4_S9_IssuedAuthQuata;
            };
            
            ViewModelSheet4Section9.prototype.getTr09ATradePartners = function() {
                return this.getSectionData().tr_09A_add_TradePartners.Partner;
            };
            
            ViewModelSheet4Section9.prototype.getTr09ASum = function() {
                var sum = this.getSectionData().tr_09A.SumOfPartnerAmounts;
                
                return numericUtil.toNum(sum, 0);
            };
            
            ViewModelSheet4Section9.prototype.getTr09AAmountOfTradePartner = function(tradePartnerId) {
                var tradePartnerAmount09A_imp = arrayUtil.selectSingle(this.getSectionData().tr_09A_imp.TradePartner, function(tpAmount) {
                    return tpAmount.TradePartnerID === tradePartnerId;
                });
                var tradePartnerAmount09A_add = arrayUtil.selectSingle(this.getSectionData().tr_09A_add.TradePartner, function(tpAmount) {
                    return tpAmount.TradePartnerID === tradePartnerId;
                });
                var amount09A_imp = objectUtil.isNull(tradePartnerAmount09A_imp) ? null : numericUtil.toNum(tradePartnerAmount09A_imp.amount);
                var amount09A_add = numericUtil.toNum(tradePartnerAmount09A_add.amount);
                
                return {
                    amount: numericUtil.sum(amount09A_imp, amount09A_add)
                };
            };
            
            ViewModelSheet4Section9.prototype.getTr09A_addAmountOfTradePartner = function(tradePartnerId) {
                var tradePartnerAmount09A_add = arrayUtil.selectSingle(this.getSectionData().tr_09A_add.TradePartner, function(tpAmount) {
                    return tpAmount.TradePartnerID === tradePartnerId;
                });
                
                return {
                    amount: numericUtil.toNum(tradePartnerAmount09A_add.amount),
                    comment: tradePartnerAmount09A_add.Comment
                };
            };
            
            ViewModelSheet4Section9.prototype.getTr09ARegistryAmount = function() {
                return this.getSectionData().tr_09A_Registry.Amount;
            };
            
            ViewModelSheet4Section9.prototype.getTr09CAmount = function() {
                return numericUtil.toNum(this.getSectionData().tr_09C.Amount);
            };
            
            ViewModelSheet4Section9.prototype.getTr09FAmount = function() {
                return numericUtil.toNum(this.getSectionData().tr_09F.Amount);
            };
            
            ViewModelSheet4Section9.prototype.getTr09GAmount = function() {
                return numericUtil.toNum(this.getSectionData().tr_09G.Amount);
            };
            
            ViewModelSheet4Section9.prototype.getAuthorizedQuotaAmount = function(tradePartnerId) {
                var partnerAmount09A_add = arrayUtil.selectSingle(this.getSectionData().tr_09A_add.TradePartner, function(p) {
                    return p.TradePartnerID === tradePartnerId;
                });
                
                if (objectUtil.isNull(partnerAmount09A_add)) {
                    return null;
                }
                
                var partnerAmount09A_imp = arrayUtil.selectSingle(this.getSectionData().tr_09A_imp.TradePartner, function(p) {
                    return p.TradePartnerID === tradePartnerId;
                });
                var amount09A_imp = objectUtil.isNull(partnerAmount09A_imp) ? null : numericUtil.toNum(partnerAmount09A_imp.amount);
                var amount09A_add = numericUtil.toNum(partnerAmount09A_add.amount);
                
                return numericUtil.sum(amount09A_imp, amount09A_add);
            };
            
            return ViewModelSheet4Section9;
        }
    ]);
})();
