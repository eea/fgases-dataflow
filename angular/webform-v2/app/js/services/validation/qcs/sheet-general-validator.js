
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheetGeneralValidator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory) {
            
            function sheetGeneralValidator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'ext-company-data', label: 'Additional company data' },
                        rules: [ that._createRule() ]
                    }
                ];
            }
            
            sheetGeneralValidator.prototype.validate = function(viewModel) {
                return sheetTransactionValidator.validate(viewModel, this.transactionValidations);
            };
            
            sheetGeneralValidator.prototype._createRule = function() {
                return {
                    qccode: '2501',
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (!viewModel.isStocksInfoDefined() || !viewModel.isQuotaInfoDefined() || !viewModel.isCompanySizeInfoDefined() || !viewModel.isNerStatusDefined()) {
                            var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                            result.errors.push(error);
                        }
                        
                        return result;
                    }
                };
            };
            
            return new sheetGeneralValidator();
        }
    ]);
})();
