
(function() {
    
    window.angular.module('FGases.services.data').factory('reportStructureNormalizer', [
        
        'jsonNormalizer', 'reportStructureHelper', 'arrayUtil', 'objectUtil',
        
        function(jsonNormalizer, reportStructureHelper, arrayUtil, objectUtil) {
            
            function ReportStructureNormalizer() { }
            
            ReportStructureNormalizer.prototype.normalize = function(instance) {
                this._normalizeGasSelectionLists(instance);
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.GeneralReportData.Company.ContactPersons, 'ContactPerson');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting, 'ReportedGases');
                this._normalizeCompanyAffiliations(instance);
                this._normalizeTradePartnerContainers(instance);
                this._normalizeGasIncludingSheets(instance);
                this._normalizeTradePartnerTransactions(instance);
                this._normalizeSheet4(instance);
                this._normalizeSheet5(instance);
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting, 'unusualGasChoises');
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting, 'attachedCompanyData');
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.attachedCompanyData, 'stocks');
            };
            
            ReportStructureNormalizer.prototype._normalizeGasSelectionLists = function(instance) {
                arrayUtil.forEach(reportStructureHelper.getGasSelectionLists(), function(gasSelectionListName) {
                    jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.GeneralReportData, gasSelectionListName);
                    jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.GeneralReportData[gasSelectionListName], 'GasName');
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeCompanyAffiliations = function(instance) {
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.GeneralReportData.Company, 'Affiliations');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.GeneralReportData.Company.Affiliations, 'Affiliation', function(affiliation) {
                    return objectUtil.isNull(affiliation.CompanyName);
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeTradePartnerContainers = function(instance) {
                var tradePartnerContainersBySheet = reportStructureHelper.getTradePartnerContainers();
                
                arrayUtil.forEach(Object.getOwnPropertyNames(tradePartnerContainersBySheet), function(sheetName) {
                    jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting, sheetName);
                    var sheet = instance.FGasesReporting[sheetName];
                    var tradePartnerContainerNames = tradePartnerContainersBySheet[sheetName];
                    
                    arrayUtil.forEach(tradePartnerContainerNames, function(tradePartnerContainerName) {
                        jsonNormalizer.normalizeObjectProperty(sheet, tradePartnerContainerName);
                        jsonNormalizer.normalizeArrayProperty(sheet[tradePartnerContainerName], 'Partner');
                    });
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeGasIncludingSheets = function(instance) {
                arrayUtil.forEach(reportStructureHelper.getGasIncludingSheets(), function(sheetName) {
                    jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting, sheetName);
                    jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting[sheetName], 'Gas', function(gas) {
                        return objectUtil.isNull(gas.GasCode);
                    });
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeTradePartnerTransactions = function(instance) {
                var tradePartnerTransactionsBySheet = reportStructureHelper.getTradePartnerTransactions();
                
                arrayUtil.forEach(Object.getOwnPropertyNames(tradePartnerTransactionsBySheet), function(sheetName) {
                    jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting, sheetName);
                    var sheet = instance.FGasesReporting[sheetName];
                    var tradePartnerTransactionNames = tradePartnerTransactionsBySheet[sheetName];
                    
                    arrayUtil.forEach(sheet.Gas, function(gasAmount) {
                        arrayUtil.forEach(tradePartnerTransactionNames, function(transactionName) {
                            jsonNormalizer.normalizeObjectProperty(gasAmount, transactionName);
                            jsonNormalizer.normalizeArrayProperty(gasAmount[transactionName], 'TradePartner', function(tradePartnerAmount) {
                                return objectUtil.isNull(tradePartnerAmount.TradePartnerID);
                            });
                        });
                    });
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeSheet4 = function(instance) {
                this._normalizeSheet4TradePartnerField(instance, '09A_imp');
                this._normalizeSheet4TradePartnerField(instance, '09A_add');
                this._normalizeSheet4_9A(instance);

                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F4_S9_IssuedAuthQuata, 'SupportingDocuments');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F4_S9_IssuedAuthQuata.SupportingDocuments, 'Document', function(doc) {
                    return objectUtil.isNull(doc.Url);
                });
            };
            
            ReportStructureNormalizer.prototype._normalizeSheet4TradePartnerField = function(instance, transactionCode) {
                var transactionFieldName = 'tr_' + transactionCode;
                
                if (objectUtil.isNull(instance.FGasesReporting.F4_S9_IssuedAuthQuata[transactionFieldName])) {
                    instance.FGasesReporting.F4_S9_IssuedAuthQuata[transactionFieldName] = {
                        Code: transactionCode,
                        SumOfPartnerAmounts: null,
                        Unit: null,
                        Comment: null,
                        TradePartner: []
                    };
                }
                else {
                    jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F4_S9_IssuedAuthQuata[transactionFieldName], 'TradePartner', function(tradePartnerAmount) {
                        return objectUtil.isNull(tradePartnerAmount.TradePartnerID);
                    });
                }
                
                var tradePartnerFieldName = transactionFieldName + '_TradePartners';
                
                if (objectUtil.isNull(instance.FGasesReporting.F4_S9_IssuedAuthQuata[tradePartnerFieldName])) {
                    instance.FGasesReporting.F4_S9_IssuedAuthQuata[tradePartnerFieldName] = { Partner: [] };
                }
                else {
                    jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F4_S9_IssuedAuthQuata, tradePartnerFieldName);
                    jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F4_S9_IssuedAuthQuata[tradePartnerFieldName], 'Partner');
                }
            };

            ReportStructureNormalizer.prototype._normalizeSheet4_9A = function(instance) {
                // remove deprecated 9A Trade Partner values
                if ( instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A.TradePartner)
                     delete instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A.TradePartner ;

                instance.FGasesReporting.F4_S9_IssuedAuthQuata['tr_09A_TradePartners'] = {} ;

            };


            ReportStructureNormalizer.prototype._normalizeSheet5 = function(instance) {
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F5_S10_Auth_NER, 'SupportingDocuments');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F5_S10_Auth_NER.SupportingDocuments, 'tr_10A');
                
                arrayUtil.forEach(instance.FGasesReporting.F5_S10_Auth_NER.SupportingDocuments.tr_10A, function(docs) {
                    jsonNormalizer.normalizeArrayProperty(docs, 'Document', function(doc) {
                        return objectUtil.isNull(doc.Url);
                    });
                });
                
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F5_S10_Auth_NER, 'SumOfAllHFCsS1');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS1, 'tr_10A');
                
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F5_S10_Auth_NER, 'SumOfAllHFCsS2');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS2, 'tr_10A');
            };
            
            ReportStructureNormalizer.prototype._normalizeSheet7 = function(instance) {
                jsonNormalizer.normalizeObjectProperty(instance.FGasesReporting.F7_s11EquImportTable, 'SupportingDocuments');
                jsonNormalizer.normalizeArrayProperty(instance.FGasesReporting.F7_s11EquImportTable.SupportingDocuments, 'Document', function(doc) {
                    return objectUtil.isNull(doc.Url);
                });
            };
            
            return new ReportStructureNormalizer();
        }
    ]);
})();
