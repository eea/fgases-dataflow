
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheetGasSelectionValidator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'transactionYearProvider', 'gasHelper', 'objectUtil', 'arrayUtil',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory, transactionYearProvider, gasHelper, objectUtil, arrayUtil) {
            
            function SheetGasSelectionValidator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'gas-selection', label: 'Gas selection' },
                        rules: 
                                [ that._createRuleQc2056(),
                                  that._createRuleQc2444() ]
                    },
                    {
                        transaction: { id: 'mixture-definition', label: 'Mixture definition' },
                        rules: [ that._createRuleQc2086() ]
                    }
                ];
            }
            
            SheetGasSelectionValidator.prototype.validate = function(viewModel) {
                return sheetTransactionValidator.validate(viewModel, this.transactionValidations);
            };
            
            SheetGasSelectionValidator.prototype._createRuleQc2056 = function() {
                return {
                    qccode: 2056,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var flaggedGasesIds = [];
                        var that = this;
                        
                        arrayUtil.forEach(viewModel.getCompanyStocks(), function(stock) {
                            if (flaggedGasesIds.indexOf(stock.gasId) > -1) {
                                return;
                            }
                            
                            var reportedGas = viewModel.getReportedGasById(stock.gasId);
                            
                            if (!objectUtil.isNull(reportedGas)) {
                                return;
                            }
                            
                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.isNonBlocker = true;
                            error.message = that._composeErrorMessage(stock);
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag(stock.transactionCode, that.qccode, stock.gasId);
                            result.flags.push(flag);
                            flaggedGasesIds.push(stock.gasId);
                        });
                        
                        return result;
                    },
                    _composeErrorMessage: function(stock) {
                        var textKey;
                        
                        if (stock.transactionCode === '8F') {
                            textKey = "validation_messages.qc_2056.error_text_8F";
                        }
                        else {
                            textKey = "validation_messages.qc_2056.error_text";
                        }
                        
                        var msg = $translate.instant(textKey);
                        msg = msg.replace(/\[gas\]/g, stock.gasName);
                        msg = msg.replace(/\[transaction_year\]/g, transactionYearProvider.getTransactionYear().toString());
                        msg = msg.replace(/\[previous_year\]/g, (transactionYearProvider.getTransactionYear() - 1).toString());
                        msg = msg.replace(/\[stock_value\]/g, stock.amount);
                        msg = msg.replace(/\[stock_field_code\]/g, stock.transactionCode);
                        
                        return msg;
                    }
                };
            };
            
            SheetGasSelectionValidator.prototype._createRuleQc2444 = function() {
                return {
                    qccode: 2444,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var that = this;
                        var triggerGases = ['HFC-134', 'HFC-143', 'HFC-152']; 
                        arrayUtil.forEach(viewModel.getReportedGases(), function(item) {
                            if (triggerGases.indexOf(item.Code)>-1){
                                var flag = sheetValidationObjectFactory.createQcFlag(null, that.qccode, item.GasId);
                                result.flags.push(flag);
                            }
                        });
                        return result;
                    }
                };
            };
            
            SheetGasSelectionValidator.prototype._createRuleQc2086 = function() {
                return {
                    qccode: 2086,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        var predefinedMixtureList = arrayUtil.select(viewModel.getAvailableGases(), function(item) {
                            return item.IsShortlisted;
                        });
                        
                        var existingCustomMixtures = arrayUtil.select(viewModel.getReportedGases(), function(item) {
                            return item.IsCustomComposition;
                        });
                        
                        var allMixtures = [];
                        arrayUtil.pushMany(allMixtures, predefinedMixtureList);
                        arrayUtil.pushMany(allMixtures, existingCustomMixtures);
                        var that = this;
                        var duplicatesFound = { };
                        
                        arrayUtil.forEach(existingCustomMixtures, function(customMixture) {
                            if (duplicatesFound[customMixture.Code]) {
                                return;
                            }
                            
                            var duplicateMixture = arrayUtil.selectSingle(allMixtures, function(mixture) {
                                return mixture !== customMixture && gasHelper.mixtureEquals(customMixture, mixture);
                            });
                            
                            if (!objectUtil.isNull(duplicateMixture)) {
                                duplicatesFound[duplicateMixture.Code] = customMixture.Code;
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.message = $translate.instant('validation_messages.qc_2086.error_text', {
                                    duplicateMixtureName: duplicateMixture.Name,
                                    customMixtureName: customMixture.Name
                                });
                                result.errors.push(error);
                            }
                        });
                        
                        return result;
                    }
                };
            };
            
            return new SheetGasSelectionValidator();
        }
    ]);
})();
