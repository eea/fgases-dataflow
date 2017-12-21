
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheetActivitiesValidator', [
        
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory',
        
        function($translate, sheetTransactionValidator, sheetValidationObjectFactory) {
            
            function SheetActivitiesValidator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'act-UndertakingAuthorisationNER', label: 'auth-NER' },
                        rules: [ that._createRuleQc2015() ]
                    }
                ];
            }
            
            SheetActivitiesValidator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                
                return transactionErrors;
            };
            
            SheetActivitiesValidator.prototype._createRuleQc2015 = function() {
                return {
                    qccode: 2015,
                    validate: function(viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        
                        if (viewModel.isReporterInNerList()) {
                            if (viewModel.sheetActivities.isAuth() && !viewModel.sheetActivities.isAuth_NER()) {
                                var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                                error.message = $translate.instant('validation_messages.qc_2015.error_text_ner');
                                result.errors.push(error);
                            }
                        }
                        else {
                            if (viewModel.sheetActivities.isAuth_NER()) {
                                var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                                error.message = $translate.instant('validation_messages.qc_2015.error_text_not_ner');
                                result.errors.push(error);
                            }
                        }
                        
                        return result;
                    }
                };
            };
            
            return new SheetActivitiesValidator();
        }
    ]);
})();
