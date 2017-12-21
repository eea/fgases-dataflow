
(function() {
    angular.module('FGases.services.validation.qcs').factory('sheetTransactionValidator', [
        
        'sheetValidationObjectFactory', 'objectUtil', 'arrayUtil',
        
        function(sheetValidationObjectFactory, objectUtil, arrayUtil) {
            function sheetTransactionValidator() { }
            
            sheetTransactionValidator.prototype.validate = function(viewModel, transactionValidations) {
                var transactionErrorContainers = [];
                
                arrayUtil.forEach(transactionValidations, function(transactionValidation) {
                    if (!objectUtil.isNull(transactionValidation.isValidationRequired) && !transactionValidation.isValidationRequired(viewModel)) {
                        return;
                    }
                    
                    var ruleErrors = [];
                    var ruleFlags = [];
                    
                    arrayUtil.forEach(transactionValidation.rules, function(qcRule) {
                        var result = qcRule.validate(viewModel);
                        arrayUtil.pushMany(ruleErrors, result.errors);
                        arrayUtil.pushMany(ruleFlags, result.flags);
                    });
                    
                    if (ruleErrors.length > 0 || ruleFlags.length > 0) {
                        var id = transactionValidation.transaction.id;
                        var label = transactionValidation.transaction.label;
                        var transactionErrorContainer = sheetValidationObjectFactory.createTransactionErrorContainer(id, label);
                        transactionErrorContainer.errors = ruleErrors;
                        transactionErrorContainer.flags = ruleFlags;
                        transactionErrorContainers.push(transactionErrorContainer);
                    }
                });
                
                return transactionErrorContainers;
            };
            
            return new sheetTransactionValidator();
        }
    ]);
})();
