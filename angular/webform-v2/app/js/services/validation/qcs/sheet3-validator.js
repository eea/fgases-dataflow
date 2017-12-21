(function () {
    angular.module('FGases.services.validation.qcs').factory('sheet3Validator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'gasHelper', 'objectUtil', 'arrayUtil', 'stringUtil',
        
        function ($translate, sheetTransactionValidator, sheetValidationObjectFactory, gasHelper, objectUtil, arrayUtil, stringUtil) {

            function Sheet3Validator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'tr_06A', label: '06A' },
                        rules: [ that._createRuleQc2091() ]
                    },
                    {
                        transaction: { id: 'tr_06B', label: '06B' },
                        rules: [ that._createRuleQc2092() ]
                    },
                    {
                        transaction: { id: 'tr_06C', label: '06C' },
                        rules: [ that._createRuleQc2093() ]
                    },
                    {
                        transaction: { id: 'tr_06I', label: '06I' },
                        rules: [ that._createRuleQc2094() ]
                    },
                    {
                        transaction: {id: 'tr_06L', label: '06L'},
                        rules: [ that._createRuleQc2095(), that._createRuleQc2409() ]
                    },
                    {
                        transaction: { id: 'tr_06M', label: '06M' },
                        rules: [ that._createRuleQc2096() ]
                    },
                    {
                        transaction: { id: 'tr_06T', label: '06T' },
                        rules: [ that._createRuleQc2040('tr_06T') ]
                    },
                    {
                        transaction: { id: 'tr_06U', label: '06U' },
                        rules: [ that._createRuleQc2040('tr_06U') ]
                    },
                    {
                        transaction: { id: 'tr_06V', label: '06V' },
                        rules: [ that._createRuleQc2041() ]
                    },
                    {
                        transaction: { id: 'tr_06W', label: '06W' },
                        rules: [ that._createRuleQc2042() ]
                    }
                ];
            }
            
            Sheet3Validator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                return transactionErrors;
            };
            
            Sheet3Validator.prototype._createRuleQc2091 = function() {
                return this._createRuleQc2091to2096(2091, 'tr_06A', 'tr_05C');
            };
            
            Sheet3Validator.prototype._createRuleQc2092 = function() {
                return this._createRuleQc2091to2096(2092, 'tr_06B', 'tr_05A');
            };
            
            Sheet3Validator.prototype._createRuleQc2093 = function() {
                return this._createRuleQc2091to2096(2093, 'tr_06C', 'tr_05D');
            };
            
            Sheet3Validator.prototype._createRuleQc2094 = function() {
                return this._createRuleQc2091to2096(2094, 'tr_06I', 'tr_05F');
            };
            
            Sheet3Validator.prototype._createRuleQc2095 = function() {
                return this._createRuleQc2091to2096(2095, 'tr_06L', 'tr_05B');
            };
            
            Sheet3Validator.prototype._createRuleQc2096 = function() {
                return this._createRuleQc2091to2096(2096, 'tr_06M', 'tr_05E');
            };
            
            Sheet3Validator.prototype._createRuleQc2091to2096 = function(qccode, section6Transaction, section5Transaction) {
                return {
                    qccode: qccode,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts06 = viewModel.sheet3.section6.getGasAmounts(section6Transaction);
                        var gasAmounts05 = viewModel.sheet2.section5.getTradePartnerSumGasAmounts(section5Transaction);
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts06, function(gasAmount06) {
                            var reportedGas = viewModel.getReportedGasById(gasAmount06.id);
                            
                            if (gasHelper.isUnspecifiedMix(reportedGas) || !gasHelper.isHfcBasedGas(reportedGas)) {
                                return;
                            }
                            
                            var gasAmount05 = arrayUtil.selectSingle(gasAmounts05, function(item) { return item.id === gasAmount06.id; });
                            
                            if (objectUtil.isNull(gasAmount05)) {
                                return;
                            }
                            
                            var amount06 = objectUtil.defaultIfNull(gasAmount06.amount, 0);
                            var amount05 = objectUtil.defaultIfNull(gasAmount05.amount, 0);
                            
                            if (amount06 >= amount05) {
                                return;
                            }
                            
                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount06.index;
                            result.errors.push(error);
                        });
                        
                        return result;
                    }
                };
            };

            
            Sheet3Validator.prototype._createRuleQc2409 = function () {
                return {
                    qccode: 2409,
                    validate: function (viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts = viewModel.sheet3.section6.getGasAmounts('tr_06L');
                        var that = this;

                        arrayUtil.forEach(gasAmounts, function (gasAmount) {
                            var amount = gasAmount.amount;

                            if (objectUtil.isNull(amount) || amount === 0 || !stringUtil.isEmpty(gasAmount.comment))
                                return;

                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount.index;
                            error.message = $translate.instant("validation_messages.qc_2409.error_text", {
                                gas: viewModel.getReportedGasById(gasAmount.id).Name,
                                section:"6L"
                            });
                            result.errors.push(error);
                        });

                        return result;
                    }
                };
            };
            
            Sheet3Validator.prototype._createRuleQc2040 = function(transactionCode) {
                return {
                    qccode: 2040,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts = viewModel.sheet3.section6.getGasAmounts(transactionCode);
                        var that = this;

                        arrayUtil.forEach(gasAmounts, function (gasAmount) {
                            var amount = gasAmount.amount;

                            if (objectUtil.isNull(amount) || amount === 0 || !stringUtil.isEmpty(gasAmount.comment)) {
                                return;
                            }

                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount.index;
                            error.message = $translate.instant("validation_messages.qc_2040_" + transactionCode + ".error_text", {
                                gasName: viewModel.getReportedGasById(gasAmount.id).Name
                            });
                            result.errors.push(error);
                        });

                        return result;
                    }
                };
            };
            
            Sheet3Validator.prototype._createRuleQc2041 = function() {
                return {
                    qccode: 2041,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts = viewModel.sheet3.section6.getGasAmounts('tr_06V');
                        var that = this;

                        arrayUtil.forEach(gasAmounts, function (gasAmount) {
                            var amount = gasAmount.amount;

                            if (objectUtil.isNull(amount) || amount === 0 || !stringUtil.isEmpty(gasAmount.comment)) {
                                return;
                            }

                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount.index;
                            error.message = $translate.instant("validation_messages.qc_2041.error_text", {
                                gasName: viewModel.getReportedGasById(gasAmount.id).Name
                            });
                            result.errors.push(error);
                        });

                        return result;
                    }
                };
            };
            
            Sheet3Validator.prototype._createRuleQc2042 = function() {
                return {
                    qccode: 2042,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts06W = viewModel.sheet3.section6.getGasAmounts('tr_06W');
                        var gasAmounts06X = viewModel.sheet3.section6.getGasAmounts('tr_06X');
                        var that = this;

                        arrayUtil.forEach(gasAmounts06W, function (gasAmount06W) {
                            var gasAmount06X = arrayUtil.selectSingle(gasAmounts06X, function(item) { return item.id === gasAmount06W.id; });
                            var amount06W = objectUtil.defaultIfNull(gasAmount06W.amount, 0.0);
                            var amount06X = objectUtil.defaultIfNull(gasAmount06X.amount, 0.0);
                            
                            if (amount06W !== amount06X) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount06W.index;
                                result.errors.push(error);
                            }
                        });

                        return result;
                    }
                };
            };
            
            return new Sheet3Validator();
        }
    ]);
})();

