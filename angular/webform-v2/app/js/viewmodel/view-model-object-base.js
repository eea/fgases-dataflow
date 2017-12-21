
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelObjectBase', [
        
        'objectUtil',
        
        function(objectUtil) {
            function ViewModelObjectBase(parentViewModelObject) { 
                this._parent = parentViewModelObject;
            }
            
            ViewModelObjectBase.prototype.getParent = function() {
                return this._parent;
            };
            
            ViewModelObjectBase.prototype.getRoot = function() {
                if (objectUtil.isNull(this._root)) {
                    var viewModelObject = this;
                
                    while(!objectUtil.isNull(viewModelObject.getParent())) {
                        viewModelObject = viewModelObject.getParent();
                    }

                    this._root = viewModelObject;
                }
                
                return this._root;
            };
            
            return ViewModelObjectBase;
        }
    ]).factory('ViewModelSectionBase', [
        
        'ViewModelObjectBase', 'objectUtil', 'arrayUtil',
        
        function(ViewModelObjectBase, objectUtil, arrayUtil) {
            
            function ViewModelSectionBase(parentViewModelObject) {
                ViewModelObjectBase.call(this, parentViewModelObject);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSectionBase);
            
            ViewModelSectionBase.prototype.getSectionGases = function() {
                var that = this;
                return arrayUtil.select(this.getRoot().getReportedGases(), function(gas) {
                    return that._isSectionGas(gas.GasId);
                });
            };
            
            ViewModelSectionBase.prototype.getSectionGasEntries = function() {
                var that = this;
                return arrayUtil.select(this.getSectionData().Gas, function(gasEntry) {
                    return that._isSectionGas(gasEntry.GasCode);
                });
            };
            
            ViewModelSectionBase.prototype.getBindableGasAmount = function(transactionField, gasId) {
                var gasData = arrayUtil.selectSingle(this.getSectionGasEntries(), function(gasEntry) {
                    return gasEntry.GasCode === gasId;
                });
                
                if (objectUtil.isNull(gasData)) {
                    return null;
                }
                
                return gasData[transactionField];
            };
            
            ViewModelSectionBase.prototype.getBindableGasAmountOfTradePartner = function(transactionField, tradePartnerId, gasId) {
                var gasData = arrayUtil.selectSingle(this.getSectionGasEntries(), function(gasEntry) {
                    return gasEntry.GasCode === gasId;
                });
                
                if (objectUtil.isNull(gasData)) {
                    return null;
                }
                
                var result = arrayUtil.selectSingle(gasData[transactionField].TradePartner, function(tradePartnerAmount) {
                    return tradePartnerAmount.TradePartnerID === tradePartnerId;
                });
                
                return result;
            };
            
            ViewModelSectionBase.prototype.getGasAmount = function(transactionField, gasId) {
                if (!this._isSectionGas(gasId)) {
                    return null;
                }
                    
                var gasEntryIndex = arrayUtil.indexOf(this.getSectionData().Gas, function(gasEntry) {
                    return gasEntry.GasCode === gasId;
                });
                
                if (gasEntryIndex < 0) {
                    return null;
                }
                
                var gasEntry = this.getSectionData().Gas[gasEntryIndex];
                var transactionAmount = gasEntry[transactionField];
                
                return this._createGasAmount(gasEntry.GasCode, gasEntryIndex, transactionAmount.Amount, transactionAmount.Comment);
            };
            
            ViewModelSectionBase.prototype.getGasAmounts = function(transactionField) {
                var that = this;
                
                return arrayUtil.map(this.getSectionData().Gas, function(gasEntry, loopContext) {
                    if (!that._isSectionGas(gasEntry.GasCode)) {
                        return null;
                    }
                    
                    var transactionAmount = gasEntry[transactionField];
                    
                    return that._createGasAmount(gasEntry.GasCode, loopContext.index, transactionAmount.Amount, transactionAmount.Comment);
                });
            };
            
            ViewModelSectionBase.prototype.getTradePartnerSumGasAmounts = function(transactionField) {
                var that = this;
                
                return arrayUtil.map(this.getSectionData().Gas, function(gasEntry, loopContext) {
                    if (!that._isSectionGas(gasEntry.GasCode)) {
                        return null;
                    }
                    
                    var transactionAmount = gasEntry[transactionField];
                    
                    return that._createGasAmount(gasEntry.GasCode, loopContext.index, transactionAmount.SumOfPartnerAmounts, transactionAmount.Comment);
                });
            };
            
            ViewModelSectionBase.prototype.getGasAmountsOfTradePartner = function(transactionField, tradePartnerId) {
                var that = this;
                
                return arrayUtil.map(this.getSectionData().Gas, function(gasEntry, loopContext) {
                    if (!that._isSectionGas(gasEntry.GasCode)) {
                        return null;
                    }
                    
                    var partnerAmount = arrayUtil.selectSingle(gasEntry[transactionField].TradePartner, function(tradePartnerAmount) {
                        return tradePartnerAmount.TradePartnerID === tradePartnerId;
                    });

                    return that._createGasAmount(gasEntry.GasCode, loopContext.index, partnerAmount.amount, partnerAmount.Comment);
                });
            };
            
            ViewModelSectionBase.prototype._isSectionGas = function(gasId) {
                return objectUtil.isNull(this.isAcceptableGas) || this.isAcceptableGas(gasId);
            };
            
            ViewModelSectionBase.prototype._createGasAmount = function(gasId, gasIndex, amount, comment) {
                return {
                    id: gasId,
                    index: gasIndex,
                    amount: isNaN(amount) || objectUtil.isNull(amount) ? null : Number(amount),
                    comment: comment
                };
            };
            
            return ViewModelSectionBase;
        }
    ]);
})();
