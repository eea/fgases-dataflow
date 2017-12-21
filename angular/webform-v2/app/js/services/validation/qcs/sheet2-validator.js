
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheet2Validator', ['$translate',
        
        'sheetTransactionValidator', 'sheetValidationObjectFactory', 'gasHelper', 'objectUtil', 'arrayUtil', 'stringUtil',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory, gasHelper, objectUtil, arrayUtil, stringUtil) {
            
            function Sheet2Validator() { 
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'tr_05A', label: '05A' },
                        rules: [ that._createRuleQc2028(), that._createRuleQc2029(), that._createRuleQc2039() ]
                    },
                    {
                        transaction: { id: 'tr_05B', label: '05B' },
                        rules: [ that._createRuleQc2031(), that._createRuleQc2071(), that._createRuleQc2409() ]
                    },
                    {
                        transaction: { id: 'tr_05C', label: '05C_exempted' },
                        rules: [ that._createRuleQc2044() ]
                    }
                ];
            }
            
            Sheet2Validator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                
                return transactionErrors;
            };
            
            Sheet2Validator.prototype._createRuleQc2028 = function() {
                return {
                    qccode: 2028,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (viewModel.sheetActivities.isD()) {
                            return result;
                        }
                        
                        var ownTradePartner = viewModel.sheet2.section5.getTr05AOwnTradePartner();
                        
                        if (objectUtil.isNull(ownTradePartner)) {
                            return result;
                        }
                        
                        var gasAmounts = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05A', ownTradePartner.PartnerId);
                        
                        if (gasHelper.calculateSum(gasAmounts) > 1 || gasHelper.calculateSumOfAllCO2Eq(viewModel.getReportedGases(), gasAmounts) > 1000) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            result.errors.push(error);
                            
                            var commentedAmount = arrayUtil.selectSingle(gasAmounts, function(gasAmount) {
                                return !stringUtil.isEmpty(gasAmount.comment);
                            });
                            
                            if (!objectUtil.isNull(commentedAmount)) {
                                error.isNonBlocker = true;
                                var flag = sheetValidationObjectFactory.createQcFlag('5A', this.qccode, commentedAmount.id, ownTradePartner.PartnerId);
                                result.flags.push(flag);
                            }
                        }
                        
                        return result;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2029 = function() {
                return {
                    qccode: 2029,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!viewModel.sheetActivities.isD()) {
                            return result;
                        }
                        
                        var ownTradePartner = viewModel.sheet2.section5.getTr05AOwnTradePartner();
                        
                        if (objectUtil.isNull(ownTradePartner)) {
                            return result;
                        }
                        
                        var gasAmounts05A = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05A', ownTradePartner.PartnerId);
                        var gasAmounts08D = viewModel.sheet6.section8.getGasAmounts('tr_08D');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts05A, function(gasAmount05A) {
                            if (objectUtil.isNull(gasAmount05A.amount)) {
                                return;
                            }
                            
                            var gasAmount08D = arrayUtil.selectSingle(gasAmounts08D, function(gas) {
                                return gas.id === gasAmount05A.id;
                            });
                            
                            if ((objectUtil.isNull(gasAmount08D.amount) || gasAmount05A.amount > gasAmount08D.amount)) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount05A.index;
                                result.errors.push(error);
                                
                                if (!stringUtil.isEmpty(gasAmount05A.comment)) {
                                    error.isNonBlocker = true;
                                    var flag = sheetValidationObjectFactory.createQcFlag('5A', that.qccode, gasAmount05A.id, ownTradePartner.PartnerId);
                                    result.flags.push(flag);
                                }
                            }
                        });
                        
                        return result;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2031 = function() {
                return {
                    qccode: 2031,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (viewModel.sheetActivities.isFU()) {
                            return result;
                        }
                        
                        var ownTradePartner = viewModel.sheet2.section5.getTr05BOwnTradePartner();
                        
                        if (objectUtil.isNull(ownTradePartner)) {
                            return result;
                        }
                        
                        var gasAmounts = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05B', ownTradePartner.PartnerId);
                        
                        if (gasHelper.calculateSumOfAllCO2Eq(viewModel.getReportedGases(), gasAmounts) > 1000) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            result.errors.push(error);
                        }
                        
                        return result;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2071 = function() {
                return {
                    qccode: 2071,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!viewModel.sheetActivities.isFU()) {
                            return result;
                        }
                        
                        var ownTradePartner = viewModel.sheet2.section5.getTr05BOwnTradePartner();
                        
                        if (objectUtil.isNull(ownTradePartner)) {
                            return result;
                        }
                        
                        var gasAmounts05B = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05B', ownTradePartner.PartnerId);
                        var gasAmounts07A = viewModel.sheet6.section8.getGasAmounts('tr_07A');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts05B, function(gasAmount05B) {
                            if (objectUtil.isNull(gasAmount05B.amount)) {
                                return;
                            }
                            
                            var gasAmount07A = arrayUtil.selectSingle(gasAmounts07A, function(gas) {
                                return gas.id === gasAmount05B.id;
                            });
                            
                            if ((objectUtil.isNull(gasAmount07A.amount) || gasAmount05B.amount > gasAmount07A.amount)) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount05B.index;
                                error.isNonBlocker = !stringUtil.isEmpty(gasAmount05B.comment);
                                result.errors.push(error);
                                var flag = sheetValidationObjectFactory.createQcFlag('5B', that.qccode, gasAmount05B.id, ownTradePartner.PartnerId);
                                result.flags.push(flag);
                            }
                        });
                        
                        return result;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2409 = function() {
                return {
                    qccode: 2409,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var that = this;
                        
                        arrayUtil.forEach(viewModel.sheet2.section5.getTr05BTradePartners(), function(tradePartner) {
                            var gasAmounts05B = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05B', tradePartner.PartnerId);
                            
                            arrayUtil.forEach(gasAmounts05B, function(gasAmount05B) {
                                var amount = gasAmount05B.amount;
                                
                                if (!objectUtil.isNull(amount) && amount !== 0 && stringUtil.isEmpty(gasAmount05B.comment)) {
                                    var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                    error.gasIndex = gasAmount05B.index;
                                    error.message = $translate.instant("validation_messages.qc_2409_partner.error_text", {
                                        gas: viewModel.getReportedGasById(gasAmount05B.id).Name,
                                        partner: tradePartner.CompanyName,
                                        section:"5B"
                                    });
                                    result.errors.push(error);
                                }
                            });
                        });
                        
                        return result;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2044 = function() {
                return {
                    qccode: 2044,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this.isValid(viewModel)) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            result.errors.push(error);
                        }
                        
                        return result;
                    },
                    isValid: function(viewModel) {
                        return !viewModel.sheet2.section5.hasTr05C_ExemptedNonZeroValues() || viewModel.sheet4.section9.getSectionData().Verified;
                    }
                };
            };
            
            Sheet2Validator.prototype._createRuleQc2039 = function() {
                return {
                    qccode: 2039,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        var gasAmounts05G = viewModel.sheet2.section5.getGasAmounts('tr_05G');
                        var gasAmounts04M = viewModel.sheet1.section4.getGasAmounts('tr_04M');
                        var gasAmounts04D = viewModel.sheet1.section4.getGasAmounts('tr_04D');
                        var gasAmounts04I = viewModel.sheet1.section4.getGasAmounts('tr_04I');
                        var gasAmounts05R = viewModel.sheet2.section5.getTradePartnerSumGasAmounts('tr_05R');
                        
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts05G, function(gasAmount05G) {
                            if (objectUtil.isNull(gasAmount05G.amount)) {
                                gasAmount05G.amount = 0;
                            }
                            
                            var gasSelector = function(gasAmount) {
                                return gasAmount.id === gasAmount05G.id;
                            };
                            var gasAmount04M = arrayUtil.selectSingle(gasAmounts04M, gasSelector);
                            var gasAmount04D = arrayUtil.selectSingle(gasAmounts04D, gasSelector);
                            var gasAmount04I = arrayUtil.selectSingle(gasAmounts04I, gasSelector);
                            var gasAmount05R = arrayUtil.selectSingle(gasAmounts05R, gasSelector);
                            
                            var g04M = objectUtil.defaultIfNull(gasAmount04M.amount, 0) * 1000;
                            var g04D = objectUtil.defaultIfNull(gasAmount04D.amount, 0) * 1000;
                            var g04I = objectUtil.defaultIfNull(gasAmount04I.amount, 0) * 1000;
                            var g05R = objectUtil.defaultIfNull(gasAmount05R.amount, 0) * 1000;
                            
                            if (gasAmount05G.amount * 1000 > g04M + g04D - g04I - g05R) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount05G.index;
                                error.message = $translate.instant("validation_messages.qc_2039.error_text", {
                                    gas: viewModel.getReportedGasById(gasAmount05G.id).Name
                                });
                                result.errors.push(error);
                            }
                        });
                        
                        return result;
                    }
                };
            };
            
            return new Sheet2Validator();
        }
    ]);
})();
