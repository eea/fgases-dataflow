
(function() {
    angular.module('FGases.services.data').factory('transactionYearProvider', [
        
        'viewModel', 'objectUtil', 'numericUtil',
        
        function(viewModel, objectUtil, numericUtil){
            var TransactionYearProvider = function() { };

            TransactionYearProvider.prototype.getTransactionYear = function() {
                var instanceYear = numericUtil.toNum(viewModel.getDataSource().FGasesReporting.GeneralReportData.TransactionYear);
                
                return objectUtil.isNull(instanceYear) ? this._maxTransactionYear() : instanceYear;
            };
            
            TransactionYearProvider.prototype.getValidTransactionYears = function() {
                var years = [];
                
                for (var year = 2015; year <= this._maxTransactionYear(); year++) {
                    years.push(year);
                }
                
                return years;
            };
            
            TransactionYearProvider.prototype._maxTransactionYear = function() {
                return new Date().getFullYear() - 1;
            };

            return new TransactionYearProvider();
        }
    ]);
})();
