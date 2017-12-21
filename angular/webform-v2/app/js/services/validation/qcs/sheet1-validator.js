
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheet1Validator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'transactionYearProvider', 
        'objectUtil', 'arrayUtil', 'stringUtil', 'numericUtil',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory, transactionYearProvider, 
                objectUtil, arrayUtil, stringUtil, numericUtil) {
            
            function Sheet1Validator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'tr_01B', label: '01B' },
                        rules: [ that._createRuleQc2072Plus2073() ]
                    },
                    {
                        transaction: { id: 'tr_02A', label: '02A' },
                        rules: [ that._createRuleQc2411() ]
                    },
                    {
                        transaction: { id: 'tr_02A', label: '02A' },
                        rules: [ that._createRuleQc2412() ]
                    },
                    {
                        transaction: { id: 'tr_02B', label: '02B' },
                        rules: [ that._createRuleQc2410() ]
                    },
                    {
                        transaction: { id: 'tr_04A', label: '04A' },
                        rules: [ that._createRuleQc2055('tr_04A', '4A', '4F') ]
                    },
                    {
                        transaction: { id: 'tr_04B', label: '04B' },
                        rules: [ that._createRuleQc2055('tr_04B', '4B', '4G') ]
                    },
                    {
                        transaction: { id: 'tr_04C', label: '04C' },
                        rules: [ that._createRuleQc2055('tr_04C', '4C', '4H') ]
                    },
                    {
                        transaction: { id: 'tr_04G', label: '04G' },
                        rules: [ that._createRuleQc2024() ]
                    },
                    {
                        transaction: { id: 'tr_04H', label: '04H' },
                        rules: [ that._createRuleQc2025() ]
                    },
                    {
                        transaction: { id: 'tr_04M', label: '04M' },
                        rules: [ that._createRuleQc2026() ]
                    }
                ];
            }
            
            Sheet1Validator.prototype.validate = function(viewModel) {
                return sheetTransactionValidator.validate(viewModel, this.transactionValidations);
            };
            
            Sheet1Validator.prototype._createRuleQc2072Plus2073 = function() {
                var that = this;
                
                return {
                    validate: function(viewModel) {
                        var qc2073 = that._createRuleQc2073();
                        var result = qc2073.validate(viewModel);
                        
                        if (result.errors.length > 0) {
                            return result;
                        }
                        
                        var qc2072 = that._createRuleQc2072();
                        
                        return qc2072.validate(viewModel);
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2072 = function() {
                return {
                    qccode: 2072,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this._isValidationRequired(viewModel)) {
                            return result;
                        }
                        
                        var gasAmounts01B = viewModel.sheet1.section1.getGasAmounts('tr_01B');
                        var gasAmounts08D = viewModel.sheet6.section8.getGasAmounts('tr_08D');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts01B, function(gasAmount01B) {
                            if (objectUtil.isNull(gasAmount01B.amount)) {
                                return;
                            }
                            
                            var reportedGas = viewModel.getReportedGasById(gasAmount01B.id);
                            
                            if (!viewModel.sheet1.section1.isGasApplicableToTr01B(reportedGas)) {
                                return;
                            }
                            
                            var gasAmount08D = arrayUtil.selectSingle(gasAmounts08D, function(item) {
                                return item.id === gasAmount01B.id;
                            });
                            
                            if (objectUtil.isNull(gasAmount08D.amount) || gasAmount01B.amount > gasAmount08D.amount) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount01B.index;
                                result.errors.push(error);
                                
                                if (!stringUtil.isEmpty(gasAmount01B.comment)) {
                                    error.isNonBlocker = true;
                                    var flag = sheetValidationObjectFactory.createQcFlag('1B', that.qccode, gasAmount01B.id);
                                    result.flags.push(flag);
                                }
                            }
                        });
                        
                        return result;
                    },
                    _isValidationRequired: function(viewModel) {
                        return viewModel.sheetActivities.isP() && viewModel.sheetActivities.isD();
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2073 = function() {
                return {
                    qccode: 2073,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!viewModel.sheetActivities.isD() || !viewModel.sheetActivities.isI_HFC()) {
                            return result;
                        }
                        
                        var ownTradePartner = viewModel.sheet2.section5.getTr05AOwnTradePartner();
                        
                        if (objectUtil.isNull(ownTradePartner)) {
                            return result;
                        }
                        
                        var gasAmounts01B = viewModel.sheet1.section1.getGasAmounts('tr_01B');
                        var gasAmounts05A = viewModel.sheet2.section5.getGasAmountsOfTradePartner('tr_05A', ownTradePartner.PartnerId);
                        var gasAmounts08D = viewModel.sheet6.section8.getGasAmounts('tr_08D');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts05A, function(gasAmount05A) {
                            var gasAmount01B = arrayUtil.selectSingle(gasAmounts01B, function(item) { return item.id === gasAmount05A.id; });
                            var gasAmount08D = arrayUtil.selectSingle(gasAmounts08D, function(item) { return item.id === gasAmount05A.id; });
                            
                            var amount01B = objectUtil.defaultIfNull(gasAmount01B.amount, 0);
                            var amount05A = objectUtil.defaultIfNull(gasAmount05A.amount, 0);
                            var amount08D = objectUtil.defaultIfNull(gasAmount08D.amount, 0);
                            
                            if (amount05A + amount01B <= amount08D) {
                                return;
                            }
                            
                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount01B.index;
                            result.errors.push(error);

                            if (!stringUtil.isEmpty(gasAmount01B.comment)) {
                                error.isNonBlocker = true;
                                error.message = $translate.instant('validation_messages.qc_2073.warning_text');
                                var flag = sheetValidationObjectFactory.createQcFlag('1B', that.qccode, gasAmount01B.id);
                                result.flags.push(flag);
                            }
                        });
                        
                        return result;
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2411 = function() {
                return {
                    qccode: 2411,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts02A = viewModel.sheet1.section2.getGasAmounts('tr_02A');
                        var gasAmounts11Q = viewModel.sheet7.section11.getGasAmounts('tr_11Q');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts02A, function(gasAmount02A) {
                            var amount02A = objectUtil.defaultIfNull(gasAmount02A.amount, 0);
                            
                            if (amount02A === 0) {
                                return;
                            }
                            
                            var gasAmount11Q = arrayUtil.selectSingle(gasAmounts11Q, function(item) { return item.id === gasAmount02A.id; });
                            var amount11Q = objectUtil.defaultIfNull(gasAmount11Q.amount, 0);
                            
                            if (amount11Q === 0 || Math.abs(amount02A - amount11Q) > 1) {
                                return;
                            }
                            
                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.isNonBlocker = true;
                            error.gasIndex = gasAmount02A.index;
                            error.message = $translate.instant('validation_messages.qc_2411.error_text', {
                                gasName: viewModel.getReportedGasById(gasAmount02A.id).Name
                            });
                            result.errors.push(error);
                            var flag = sheetValidationObjectFactory.createQcFlag('2A', that.qccode, gasAmount02A.id);
                            result.flags.push(flag);
                        });
                        
                        return result;
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2412 = function() {
                return {
                    qccode : 2412,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var amount09F = viewModel.sheet4.section9.getTr09FAmount();
                        var amount09G = viewModel.sheet4.section9.getTr09GAmount();
                        var gasAmounts02A = viewModel.sheet1.section2.getGasAmounts('tr_02A');
                        var that = this;
                        arrayUtil.forEach(gasAmounts02A, function (gasAmount02A) {
                            var v02A = numericUtil.toNum(gasAmount02A.amount, 0);
                            var v09F = numericUtil.toNum(amount09F, 0);
                            var v09G = numericUtil.toNum(amount09G, 0);
                            
                            if (v02A > 0 && v09F > 0 && v09G === 0){
                                var flag = sheetValidationObjectFactory.createQcFlag('2A', that.qccode, gasAmount02A.id, null, "9F: " + v09F);
                                result.flags.push(flag);
                            }
                        });
                        return result;
                    }
                };
            };
            
            
            Sheet1Validator.prototype._createRuleQc2055 = function(transactionId, transactionCode, stockTransactionCode) {
                return {
                    qccode: 2055,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts = viewModel.sheet1.section4.getGasAmounts(transactionId);
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts, function(gasAmount) {
                            var stock = viewModel.getGasStockByTransaction(stockTransactionCode, gasAmount.id);
                            
                            if (objectUtil.isNull(stock)) {
                                return;
                            }
                            
                            if (gasAmount.amount < stock.amount - 0.5) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount.index;
                                result.errors.push(error);
                                var translationKey = "validation_messages.qc_2055.error_text";
                                
                                if (!objectUtil.isNull(gasAmount.comment)) {
                                    error.isNonBlocker = true;
                                    translationKey = "validation_messages.qc_2055.warning_text";
                                    var flag = sheetValidationObjectFactory.createQcFlag(transactionCode, that.qccode, gasAmount.id);
                                    result.flags.push(flag);
                                }
                                
                                error.message = that._formatErrorMessage(translationKey, viewModel, transactionCode, stockTransactionCode, gasAmount, stock);
                            }
                        });
                        
                        return result;
                    },
                    _formatErrorMessage: function(translationKey, viewModel, transactionCode, stockTransactionCode, gasAmount, stock) {
                        var msg = $translate.instant(translationKey);
                        var reportedGas = viewModel.getReportedGasById(gasAmount.id);
                        msg = msg.replace(/\[gas\]/g, reportedGas.Name);
                        msg = msg.replace(/\[transaction_year\]/g, transactionYearProvider.getTransactionYear().toString());
                        msg = msg.replace(/\[previous_year\]/g, (transactionYearProvider.getTransactionYear() - 1).toString());
                        msg = msg.replace(/\[stock_value\]/g, stock.amount);
                        msg = msg.replace(/\[field_code\]/g, transactionCode);
                        msg = msg.replace(/\[stock_field_code\]/g, stockTransactionCode);
                        
                        return msg;
                    }
                };
            };

            Sheet1Validator.prototype._createRuleQc2410 = function() {
                return {
                    qccode: 2410,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var gasAmounts = viewModel.sheet1.section2.getGasAmounts('tr_02B');
                        var that = this;

                        arrayUtil.forEach(gasAmounts, function(gasAmount) {
                            var amount = gasAmount.amount;

                            if (objectUtil.isNull(amount) || amount === 0)
                                return;

                            if ( ! stringUtil.isEmpty(gasAmount.comment )){
                                //2B value with comment => create flag
                                var flag = sheetValidationObjectFactory.createQcFlag('2B', that.qccode, gasAmount.id);
                                result.flags.push(flag);
                                return;
                            }
                            // 2B value without comment
                            var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                            error.gasIndex = gasAmount.index;
                            error.message = $translate.instant( "validation_messages.qc_2410.error_text" , { 
                                gas : viewModel.getReportedGasById(gasAmount.id).Name 
                            });
                            result.errors.push(error);
                        });

                        return result;
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2024 = function() {
                return {
                    qccode: 2024,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this._isValidationRequired(viewModel)) {
                            return result;
                        }
                        
                        var gasAmounts04G = viewModel.sheet1.section4.getGasAmounts('tr_04G');
                        var gasAmounts01E = viewModel.sheet1.section1.getGasAmounts('tr_01E');
                        var gasAmounts02A = viewModel.sheet1.section2.getGasAmounts('tr_02A');
                        var gasAmounts04B = viewModel.sheet1.section4.getGasAmounts('tr_04B');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts04G, function(gasAmount04G) {
                            if (objectUtil.isNull(gasAmount04G.amount)) {
                                return;
                            }
                            
                            var reportedGas = viewModel.getReportedGasById(gasAmount04G.id);
                            
                            if (!viewModel.sheet1.section4.isGasApplicableToTr04G(reportedGas)) {
                                return;
                            }
                            
                            var amount01E = that._getGasAmount(gasAmounts01E, gasAmount04G.id);
                            var amount02A = that._getGasAmount(gasAmounts02A, gasAmount04G.id);
                            var amount04B = that._getGasAmount(gasAmounts04B, gasAmount04G.id);
                            
                            if (gasAmount04G.amount > amount01E + amount02A + amount04B) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount04G.index;
                                result.errors.push(error);
                                
                                if (!stringUtil.isEmpty(gasAmount04G.comment)) {
                                    error.isNonBlocker = true;
                                    var flag = sheetValidationObjectFactory.createQcFlag('4G', that.qccode, gasAmount04G.id);
                                    result.flags.push(flag);
                                }
                            }
                        });
                        
                        return result;
                    },
                    _isValidationRequired: function(viewModel) {
                        return viewModel.sheetActivities.isP() || viewModel.sheetActivities.isI();
                    },
                    _getGasAmount: function(gasAmounts, gasId) {
                        var gasAmount = arrayUtil.selectSingle(gasAmounts, function(item) {
                            return item.id === gasId;
                        });
                        
                        return objectUtil.defaultIfNull(gasAmount.amount, 0);
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2025 = function() {
                return {
                    qccode: 2025,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this._isValidationRequired(viewModel)) {
                            return result;
                        }
                        
                        var gasAmounts04H = viewModel.sheet1.section4.getGasAmounts('tr_04H');
                        var gasAmounts01E = viewModel.sheet1.section1.getGasAmounts('tr_01E');
                        var gasAmounts02A = viewModel.sheet1.section2.getGasAmounts('tr_02A');
                        var gasAmounts04C = viewModel.sheet1.section4.getGasAmounts('tr_04C');
                        var that = this;
                        
                        arrayUtil.forEach(gasAmounts04H, function(gasAmount04H) {
                            if (objectUtil.isNull(gasAmount04H.amount)) {
                                return;
                            }
                            
                            var reportedGas = viewModel.getReportedGasById(gasAmount04H.id);
                            
                            if (!viewModel.sheet1.section4.isGasApplicableToTr04G(reportedGas)) {
                                return;
                            }
                            
                            var amount01E = that._getGasAmount(gasAmounts01E, gasAmount04H.id);
                            var amount02A = that._getGasAmount(gasAmounts02A, gasAmount04H.id);
                            var amount04C = that._getGasAmount(gasAmounts04C, gasAmount04H.id);
                            
                            if (gasAmount04H.amount > amount01E + amount02A + amount04C) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount04H.index;
                                result.errors.push(error);
                                
                                if (!stringUtil.isEmpty(gasAmount04H.comment)) {
                                    error.isNonBlocker = true;
                                    var flag = sheetValidationObjectFactory.createQcFlag('4H', that.qccode, gasAmount04H.id);
                                    result.flags.push(flag);
                                }
                            }
                        });
                        
                        return result;
                    },
                    _isValidationRequired: function(viewModel) {
                        return viewModel.sheetActivities.isP() || viewModel.sheetActivities.isI();
                    },
                    _getGasAmount: function(gasAmounts, gasId) {
                        var gasAmount = arrayUtil.selectSingle(gasAmounts, function(item) {
                            return item.id === gasId;
                        });
                        
                        return objectUtil.defaultIfNull(gasAmount.amount, 0);
                    }
                };
            };
            
            Sheet1Validator.prototype._createRuleQc2026 = function() {
                return {
                    qccode: 2026,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!this._isValidationRequired(viewModel)) {
                            return result;
                        }
                        
                        var section4Gases = viewModel.sheet1.section4.getSectionGases();
                        var that = this;
                        
                        arrayUtil.forEach(section4Gases, function(section4Gas) {
                            var gasId = section4Gas.GasId;
                            var gasAmount04M = viewModel.sheet1.section4.getGasAmount('tr_04M', gasId);
                            var amount04M = numericUtil.toNum(gasAmount04M.amount, 0);
                            var amount04I = numericUtil.toNum(viewModel.sheet1.section4.getGasAmount('tr_04I', gasId).amount, 0);
                            var amount04D = numericUtil.toNum(viewModel.sheet1.section4.getGasAmount('tr_04D', gasId).amount, 0);
                            
                            if (amount04M < amount04I - amount04D) {
                                var error = sheetValidationObjectFactory.createValidationError(that.qccode);
                                error.gasIndex = gasAmount04M.index;
                                result.errors.push(error);
                            }
                        });
                        
                        return result;
                    },
                    _isValidationRequired: function(viewModel) {
                        return viewModel.sheetActivities.isP() || viewModel.sheetActivities.isI();
                    }
                };
            };
            
            return new Sheet1Validator();
        }
    ]);
})();
