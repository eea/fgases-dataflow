
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheet4Validator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'objectUtil', 'arrayUtil', 'stringUtil', 'numericUtil',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory, objectUtil, arrayUtil, stringUtil, numericUtil) {
            
            function Sheet4Validator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'tr_09A_imp', label: '09A_imp'},
                        rules: [ that._createRuleQc2404() ]
                    },
                    {
                        transaction: { id: 'tr_09A_add', label: '09A_add'},
                        rules: [ that._createRuleQc2405(), that._createRuleQc24041(), that._createRuleQc24042(),  that._createRuleQc24043() ]
                    },
                    // {
                    //     transaction: { id: 'tr_09A', label: '09A'},
                    //     isValidationRequired: function(viewModel) {
                    //         return viewModel.sheetActivities.isAuth();
                    //     },
                    //     rules: [ that._createRuleQc2007() ]
                    // },
                    {
                        transaction: { id: 'tr_09C', label: '09C' },
                        rules: [ that._createRuleQc2044() ]
                    },
                    {
                        transaction: { id: 'tr_09F', label: '09F' },
                        rules: [ that._createRuleQc2403() ]
                    },
                    {
                        transaction: { id: 'tr_09F', label: '09F' },
                        rules: [ that._createRuleQc24031() ]
                    }
                ];
            }
            
            Sheet4Validator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                
                return transactionErrors;
            };

            Sheet4Validator.prototype._createRuleQc2007 = function() {
                return {
                    qccode: 2007,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();

                        if (!this.isValid(viewModel)) {
                            result.errors.push(sheetValidationObjectFactory.createValidationError(this.qccode));
                        }

                        return result;
                    },
                    isValid: function(viewModel) {
                        var sum09A = viewModel.sheet4.section9.getTr09ASum();

                        return viewModel.getReportedGases().length > 0 && (!objectUtil.isNull(sum09A) && sum09A > 0);
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc2405 = function() {
                return {
                    qccode: 2405,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        var sum09A = viewModel.sheet4.section9.getTr09ASum();
                        
                        if (objectUtil.isNull(sum09A) || sum09A === 0) {
                            return result;
                        }
                        
                        var invalidTradePartner = arrayUtil.selectSingle(viewModel.sheet4.section9.getTr09ATradePartners(), function(tradePartner) {
                            if (!viewModel.isOwnCompany(tradePartner)) {
                                return false;
                            }
                            
                            var tradePartnerAmount = viewModel.sheet4.section9.getTr09AAmountOfTradePartner(tradePartner.PartnerId);
                            
                            return !objectUtil.isNull(tradePartnerAmount.amount) && tradePartnerAmount.amount > 0;
                        });
                        
                        if (!objectUtil.isNull(invalidTradePartner)) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('9A_add', this.qccode, null, invalidTradePartner.PartnerId);
                            result.flags.push(flag);
                        }
                        
                        return result;
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc2404 = function() {
                return {
                    qccode: 2404,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this.isValid(viewModel)) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('9A_Registry', this.qccode);
                            result.flags.push(flag);
                        }
                        
                        return result;
                    },
                    isValid: function(viewModel) {
                        var amount09ARegistry = viewModel.sheet4.section9.getTr09ARegistryAmount();
                        
                        if (objectUtil.isNull(amount09ARegistry) || amount09ARegistry === 0) {
                            return true;
                        }
                        
                        if (viewModel.sheetActivities.isNilReport()) {
                            return false;
                        }
                        
                        if (!viewModel.sheetActivities.isAuth()) {
                            return false;
                        }
                        
                        return true;
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc2044 = function() {
                return {
                    qccode: 2044,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this.isValid(viewModel)) {
                            result.errors.push(sheetValidationObjectFactory.createValidationError(this.qccode));
                        }
                        
                        return result;
                    },
                    isValid: function(viewModel) {
                        var amount09C = viewModel.sheet4.section9.getTr09CAmount();
                        
                        if (objectUtil.isNull(amount09C) || amount09C < 10000) {
                            return true;
                        }
                        
                        return viewModel.sheet4.section9.getSectionData().Verified;
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc2403 = function() {
                return {
                    qccode: 2403,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this.isValid(viewModel)) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('9G', this.qccode);
                            result.flags.push(flag);
                        }
                        
                        return result;
                    },
                    isValid: function(viewModel) {
                        var amount09F = viewModel.sheet4.section9.getTr09FAmount();
                        return objectUtil.isNull(amount09F) || amount09F <= viewModel.sheet4.section9.getTr09GAmount();
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc24031 = function() {
                return {
                    qccode: 24031,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var amount09F = viewModel.sheet4.section9.getTr09FAmount();
                        
                        if (numericUtil.toNum(amount09F, 0)  < 0) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('9F', this.qccode);
                            result.flags.push(flag);
                        }
                        return result;
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc24041 = function() {
                return {
                    qccode: 24041,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var that = this;
                        
                        arrayUtil.forEach(viewModel.sheet4.section9.getTr09ATradePartners(), function(tradePartner, ctx) {
                            var tpAmount = viewModel.sheet4.section9.getTr09A_addAmountOfTradePartner(tradePartner.PartnerId);
                            
                            if (objectUtil.isNull(tpAmount.amount) || tpAmount.amount === 0) {
                                return;
                            }
                            if ( stringUtil.isBlank(tpAmount.comment)){
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                result.errors.push(error);
                                ctx.breakLoop = true; // show only once
                            }
                        });
                        return result;
                    }
                };
            };

            Sheet4Validator.prototype._createRuleQc24042 = function() {
                return {
                    qccode: 24042,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var that = this;
                        var found = 0;

                        arrayUtil.forEach(viewModel.sheet4.section9.getTr09ATradePartners(), function(tradePartner) {
                            var tpAmount = viewModel.sheet4.section9.getTr09A_addAmountOfTradePartner(tradePartner.PartnerId);

                            if (objectUtil.isNull(tpAmount.amount) || tpAmount.amount === 0) {
                                return;
                            }

                            if (!stringUtil.isBlank(tpAmount.comment)) {
                                if (!( found) ++ ) {
                                    var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                    error.isNonBlocker = true;
                                    result.errors.push(error);
                                }

                                var flag = sheetValidationObjectFactory.createQcFlag('9A_add', 24041, null, tradePartner.PartnerId); // WARNING THE FLAG IS WITH OTHER QC CODE
                                result.flags.push(flag);

                            }
                        });

                        return result;
                    }
                };
            };
            
            Sheet4Validator.prototype._createRuleQc24043 = function() {
                return {
                    qccode: 24043,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var sum09A_add = numericUtil.toNum(viewModel.sheet4.section9.getSectionData().tr_09A_add.SumOfPartnerAmounts, 0);
                        
                        if (sum09A_add < 0) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var that = this;
                            var vm = viewModel;
                            
                            arrayUtil.forEach(viewModel.sheet4.section9.getTr09ATradePartners(), function(tradePartner) {
                                if (numericUtil.toNum( vm.sheet4.section9.getTr09A_addAmountOfTradePartner(tradePartner.PartnerId).amount , 0) !== 0 ) {
                                    var flag = sheetValidationObjectFactory.createQcFlag('9A_add', that.qccode, null, tradePartner.PartnerId);
                                    result.flags.push(flag);
                                }
                            });
                        }
                        
                        return result;
                    }
                };
            };
            
            return new Sheet4Validator();
        }
    ]);
})();
