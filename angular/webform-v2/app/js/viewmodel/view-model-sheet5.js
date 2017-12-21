
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet5', [
        
        'ViewModelObjectBase', 'ViewModelSheet5Section10', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet5Section10, objectUtil) {
            
            function ViewModelSheet5(viewModel) {
                if (!(this instanceof ViewModelSheet5)) {
                    return new ViewModelSheet5(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section10 = new ViewModelSheet5Section10(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet5);
            
            return ViewModelSheet5;
        }
    ]).factory('ViewModelSheet5Section10', [
        
        'ViewModelSectionBase', 'gasHelper', 'messageBox', 'objectUtil', 'arrayUtil',
        
        function(ViewModelSectionBase, gasHelper, messageBox, objectUtil, arrayUtil) {
            
            function ViewModelSheet5Section10(sheet5ViewModel) {
                if (!(this instanceof ViewModelSheet5Section10)) {
                    return new ViewModelSheet5Section10(sheet5ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet5ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet5Section10);
            
            ViewModelSheet5Section10.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F5_S10_Auth_NER;
            };
            
            ViewModelSheet5Section10.prototype.isAcceptableGas = function(gasId) {
                var reportedGas = this.getRoot().getReportedGasById(gasId);
                
                return gasHelper.isHfcBasedGas(reportedGas);
            };
            
            ViewModelSheet5Section10.prototype.getTr10ATradePartners = function() {
                return this.getSectionData().tr_10A_TradePartners.Partner;
            };
            
            ViewModelSheet5Section10.prototype.getTr10ATradePartnerIndex = function(tradePartnerId) {
                return arrayUtil.indexOf(this.getTr10ATradePartners(), function(tradePartner) {
                    return tradePartner.PartnerId === tradePartnerId;
                });
            };
            
            ViewModelSheet5Section10.prototype.removeTr10ATradePartner = function(tradePartnerId) {
                var indexToRemove = this.getTr10ATradePartnerIndex(tradePartnerId);
                var tradePartner = this.getTr10ATradePartners()[indexToRemove];
                var that = this;
                messageBox.confirm("Do you want to delete Trading Partner '" + tradePartner.CompanyName + "' ?", function(result) {
                    if (!result) {
                        return;
                    }
                    
                    that.getTr10ATradePartners().splice(indexToRemove, 1);
                    
                    arrayUtil.forEach(that.getSectionData().Gas, function(gasEntry) {
                        gasEntry.tr_10A.TradePartner.splice(indexToRemove, 1);
                    });
                    
                    that.getSectionData().SumOfAllHFCsS1.tr_10A.splice(indexToRemove, 1);
                    that.getSectionData().SumOfAllHFCsS2.tr_10A.splice(indexToRemove, 1);
                    that.getSectionData().SupportingDocuments.tr_10A.splice(indexToRemove, 1);
                });
            };
            
            ViewModelSheet5Section10.prototype.getTr10AS1 = function(tradePartnerId) {
                return arrayUtil.selectSingle(this.getSectionData().SumOfAllHFCsS1.tr_10A, function(s1Amount) { 
                    return s1Amount.TradePartnerID === tradePartnerId;
                }).Amount;
            };
            
            ViewModelSheet5Section10.prototype.getTr10AS2 = function(tradePartnerId) {
                return arrayUtil.selectSingle(this.getSectionData().SumOfAllHFCsS2.tr_10A, function(s1Amount) { 
                    return s1Amount.TradePartnerID === tradePartnerId;
                }).Amount;
            };
            
            ViewModelSheet5Section10.prototype.showTr10AUploader = function(tradePartnerId) {
                return this.getTr10AS1(tradePartnerId) > 0;
            };
            
            ViewModelSheet5Section10.prototype.getTr10ADocuments = function(tradePartnerId) {
                return arrayUtil.selectSingle(this.getSectionData().SupportingDocuments.tr_10A, function(docs) {
                    return docs.TradePartnerID === tradePartnerId;
                }).Document;
            };
            
            ViewModelSheet5Section10.prototype.hasTr10ADocuments = function(tradePartnerId) {
                return this.getTr10ADocuments(tradePartnerId).length > 0;
            };
            
            ViewModelSheet5Section10.prototype.isTr10AUploaderBlocked = function(tradePartnerId) {
                var tradePartnerIndex = this.getTr10ATradePartnerIndex(tradePartnerId);
                var allPartnerDocs = this.getSectionData().SupportingDocuments.tr_10A;
                var isBlocked = false;
                var that = this;
                
                arrayUtil.forEach(allPartnerDocs, function(partnerDocs, loopContext) {
                    var index = loopContext.index;
                    
                    if (index < tradePartnerIndex) {
                        if (partnerDocs.Document.length < 1 && that.showTr10AUploader(that.getTr10ATradePartners()[index].PartnerId)) {
                            isBlocked = true;
                            loopContext.breakLoop = true;
                        }
                    }
                    else {
                        loopContext.breakLoop = true;
                    }
                });
                
                return isBlocked;
            };
            
            ViewModelSheet5Section10.prototype.getTr10ABindableGasAmountOfTradePartner = function(tradePartnerId, gasId) {
                return this.getBindableGasAmountOfTradePartner('tr_10A', tradePartnerId, gasId);
            };
            
            ViewModelSheet5Section10.prototype.refreshTradePartnerSums = function(tradePartnerId) {
                var gasAmounts = this.getGasAmountsOfTradePartner('tr_10A', tradePartnerId);
                var s1 = gasHelper.calculateSum(gasAmounts);
                var s2 = gasHelper.calculateSumOfHfcCO2Eq(this.getRoot().getReportedGases(), gasAmounts);
                var tradePartnerIndex = this.getTr10ATradePartnerIndex(tradePartnerId);
                this.getSectionData().SumOfAllHFCsS1.tr_10A[tradePartnerIndex].Amount = s1;
                this.getSectionData().SumOfAllHFCsS2.tr_10A[tradePartnerIndex].Amount = s2;
            };
            
            ViewModelSheet5Section10.prototype.calculateSumOfS1 = function() {
                var s1Items = this.getSectionData().SumOfAllHFCsS1.tr_10A;
                var sum = 0;
                arrayUtil.forEach(s1Items, function(s1Item) {
                    sum += objectUtil.isNull(s1Item.Amount) ? 0 : Number(s1Item.Amount);
                });
                
                return sum;
            };
            
            ViewModelSheet5Section10.prototype.calculateSumOfS2 = function() {
                var s2Items = this.getSectionData().SumOfAllHFCsS2.tr_10A;
                var sum = 0;
                arrayUtil.forEach(s2Items, function(s2Item) {
                    sum += objectUtil.isNull(s2Item.Amount) ? 0 : s2Item.Amount;
                });
                
                return sum;
            };
            
            ViewModelSheet5Section10.prototype.calculateSumOfS3 = function() {
                var sheet4Section9 = this.getRoot().sheet4.section9;
                var s2Items = this.getSectionData().SumOfAllHFCsS2.tr_10A;
                var sum = 0;
                arrayUtil.forEach(s2Items, function(s2Item) {
                    var s3 = sheet4Section9.getAuthorizedQuotaAmount(s2Item.TradePartnerID);
                    sum += objectUtil.isNull(s3) ? 0 : s3;
                });
                
                return sum;
            };
            
            return ViewModelSheet5Section10;
        }
    ]);
})();
