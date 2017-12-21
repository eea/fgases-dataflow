
(function() {

    angular.module('FGases.services.validation.qcs').factory('sheetValidationObjectFactory', [
        
        'objectUtil',
        
        function(objectUtil) {
            function SheetValidationObjectFactory() { }
            
            SheetValidationObjectFactory.prototype.createTransactionErrorContainer = function(transaction, transactionLabel) {
                return {
                    transaction: angular.isUndefined(transaction) ? null : transaction, 
                    transactionLabel: angular.isUndefined(transactionLabel) ? null : transactionLabel, 
                    errors: []
                };
            };
            
            SheetValidationObjectFactory.prototype.createValidationError = function(qcCode) {
                return {
                    QCCode: angular.isUndefined(qcCode) ? null : qcCode, 
                    gasIndex: null, 
                    tradePartnerId: null, 
                    type: null, 
                    message: null,
                    isNonBlocker: false
                };
            };
            
            SheetValidationObjectFactory.prototype.createValidationResult = function() {
                return {
                    errors: [],
                    flags: []
                };
            };
            
            SheetValidationObjectFactory.prototype.createQcFlag = function(transactionCode, qcCode, gasId, tradePartnerId, comment) {
                return {
                    transactionCode: objectUtil.isNull(transactionCode) ? null : transactionCode,
                    qcCode: objectUtil.isNull(qcCode) ? null : qcCode,
                    gasId: objectUtil.isNull(gasId) ? null : gasId,
                    tradePartnerId: objectUtil.isNull(tradePartnerId) ? null : tradePartnerId,
                    comment: objectUtil.isNull(comment) ? null : comment,
                };
            };
            
            return new SheetValidationObjectFactory();
        }
    ]);
    
})();
