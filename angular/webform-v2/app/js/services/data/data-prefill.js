
(function() {
    
    window.angular.module('FGases.services.data').factory('dataPrefill', [
        
        'transactionYearProvider', 'reportStructureHelper', 'objectUtil', 'arrayUtil', 'numericUtil',
        
        function(transactionYearProvider, reportStructureHelper, objectUtil, arrayUtil, numericUtil) {
            
            function DataPrefill() { }
            
            DataPrefill.prototype.isPreviousReport = function(instance) {
                /*
                 * Disable data pre-fill as current implementation is not compatible with 
                 * re-submissions for past transaction years.
                 * 
                var instanceTransactionYear = numericUtil.toNum(instance.FGasesReporting.GeneralReportData.TransactionYear);
                
                if (objectUtil.isNull(instanceTransactionYear)) {
                    return false;
                }
                
                return instanceTransactionYear < transactionYearProvider.getTransactionYear();
                */
               
                return false;
            };
            
            DataPrefill.prototype.prefil = function(source, target, context) {
                this._copyAffiliations(source, target);
                this._copyActivities(source, target);
                this._copyTradePartners(source, target, context);
                this._copyReportedGases(source, target, context);
                this._copySection11TransactionSelection(source, target);
            };
            
            DataPrefill.prototype._copyAffiliations = function(source, target) {
                target.FGasesReporting.GeneralReportData.Company.Affiliations = source.FGasesReporting.GeneralReportData.Company.Affiliations;
            };
            
            DataPrefill.prototype._copyActivities = function(source, target) {
                target.FGasesReporting.GeneralReportData.Activities = source.FGasesReporting.GeneralReportData.Activities;
            };
            
            DataPrefill.prototype._copyTradePartners = function(source, target, context) {
                var tradePartnerContainersBySheet = reportStructureHelper.getTradePartnerContainers();
                
                arrayUtil.forEach(Object.getOwnPropertyNames(tradePartnerContainersBySheet), function(sheetName) {
                    var sourceSheet = source.FGasesReporting[sheetName];
                    var targetSheet = target.FGasesReporting[sheetName];
                    var tradePartnerContainerNames = tradePartnerContainersBySheet[sheetName];
                    
                    arrayUtil.forEach(tradePartnerContainerNames, function(tradePartnerContainerName) {
                        targetSheet[tradePartnerContainerName] = sourceSheet[tradePartnerContainerName];
                    });
                });
                
                arrayUtil.forEach(source.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_TradePartners.Partner, function(tradePartner) {
                    var dummyModalResults = {
                        tempPartnerDefinition: tradePartner,
                        index: -1,
                        modalExtras: {
                            arrayToPush: target.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_TradePartners.Partner,
                            emptyInstancePath: 'FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A.TradePartner',
                            baseElement: target.FGasesReporting.F4_S9_IssuedAuthQuata,
                            fieldName: 'tr_09A'
                        }
                    };
                    context.scope.tradingPartnerModalWindowCloseCallBackForNonGasForm(dummyModalResults);
                });
                
                arrayUtil.forEach(target.FGasesReporting.F5_S10_Auth_NER.tr_10A_TradePartners.Partner, function(tradePartner) {
                    context.scope.createSumsArrayItem(tradePartner.PartnerId);
                    context.scope.createNewSupportingDocument(tradePartner.PartnerId);
                });
            };
            
            DataPrefill.prototype._copyReportedGases = function(source, target, context) {
                arrayUtil.forEach(source.FGasesReporting.ReportedGases, function(reportedGas) {
                    context.scope.addGasForReporting(reportedGas);
                });
                
                arrayUtil.forEach(reportStructureHelper.getGasSelectionLists(), function(gasSelectionListName) {
                    target.FGasesReporting.GeneralReportData[gasSelectionListName] = source.FGasesReporting.GeneralReportData[gasSelectionListName];
                });
            };
            
            DataPrefill.prototype._copySection11TransactionSelection = function(source, target) {
                target.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions = source.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions;
            };
            
            return new DataPrefill();
        }
    ]);
})();
