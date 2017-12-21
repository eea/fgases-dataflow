
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheet5Validator', [
        
        'sheetTransactionValidator', 'sheetValidationObjectFactory', 'objectUtil', 'arrayUtil',
        
        function(sheetTransactionValidator, sheetValidationObjectFactory, objectUtil, arrayUtil) {
            function Sheet5Validator() {
                var that = this;
                this.transactionValidations = [{
                    isValidationRequired: function(viewModel) { 
                        return viewModel.sheetActivities.isAuth_NER();
                    },
                    transaction: { id: 'tr_10A', label: '10A' },
                    rules: [
                        that._createRuleQc2406_2413(),
                        that._createRuleQc2407()
                    ]
                }];
            }
            
            Sheet5Validator.prototype.validate = function(viewModel) {
                return sheetTransactionValidator.validate(viewModel, this.transactionValidations);
            };
            
            Sheet5Validator.prototype._createRuleQc2406_2413 = function() {
                return {
                    qccode: [2406,2413],
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        var s2Items = viewModel.getDataSource().FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS2.tr_10A;
                        var sumS2 = 0, sumS3 = 0;

                        arrayUtil.forEach(s2Items, function(s2Item) {
                            var s3 = viewModel.sheet4.section9.getAuthorizedQuotaAmount(s2Item.TradePartnerID);
                            sumS2 += objectUtil.isNull(s2Item.Amount) ? 0 : s2Item.Amount;
                            sumS3 += objectUtil.isNull(s3) ? 0 : s3;
                        });

                        //QC2406
                        if (sumS2 < sumS3) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode[0]);
                            error.isNonBlocker = true;
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('10A', this.qccode[0]);
                            result.flags.push(flag);
                        }
                        
                        //QC2413
                        if (result.flags.length>0 && ! (sumS2 > 0) ){
                            var flag = sheetValidationObjectFactory.createQcFlag('10A', this.qccode[1]);
                            result.flags.push(flag);
                        }

                        return result;
                    }
                };
            };

            Sheet5Validator.prototype._createRuleQc2407 = function() {
                return {
                    qccode: 2407,
                    isNonBlocker: true,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        var s2Items = viewModel.getDataSource().FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS2.tr_10A;
                        var documents = viewModel.getDataSource().FGasesReporting.F5_S10_Auth_NER.SupportingDocuments.tr_10A;
                        var rule = this;

                        arrayUtil.forEach(s2Items, function(s2Item, loopContext) {
                            if (objectUtil.isNull(s2Item.Amount) || s2Item.Amount === 0) {
                                return;
                            }

                            var documentItems = documents[loopContext.index].Document;

                            if (documentItems.length === 0) {
                                var error = sheetValidationObjectFactory.createValidationError(rule.qccode);
                                result.errors.push(error);
                                loopContext.breakLoop = true;
                            }
                        });

                        return result;
                    }
                };
            };
            
            return new Sheet5Validator();
        }
    ]);
})();
