
(function() {
    // get instance data and save instance data
    angular.module('FGases.services.data').factory('dataRepository', [

        '$rootScope', '$http', 'FormConstants', 'dataProxy', 'jsonNormalizer', 'objectUtil', 'arrayUtil', 'numericUtil', 'stringUtil',

        function($rootScope, $http, FormConstants, dataProxy, jsonNormalizer, objectUtil, arrayUtil, numericUtil, stringUtil) {
            var codeLists = {};
            //var fgasesVocabularySetBaseUri = "http://localhost:8080/datadict/vocabulary/fgases/"; //DD_VOCABULARY_BASE_URI + 'fgases/';
            //var vocabularies = ['HFCGases', 'PFCGases', 'SF6Gases', 'UnsaturatedHFCAndHCFCGases', 'FluorinatedEthersAlcohols', 'OtherPrefluorinatedCompounds', 'CommonlyUsedMixtures', 'GasListForMixtureDefinition'];
            var commonVocabularySetBaseUri = "https://dd.eionet.europa.eu/vocabulary/common/"; //DD_VOCABULARY_BASE_URI + 'common/'
            var commonVocabularies = ['countries'];
            //create a container
            var codeListDefinitionVocabSets = [{"base": commonVocabularySetBaseUri, "vocabs": commonVocabularies}];

            //define undefined members
            codeLists.FGasesCodelists = {};
            for (var i = 0; i < codeListDefinitionVocabSets.length; i++){
                for (var j = 0; j < codeListDefinitionVocabSets[i].vocabs.length; j++) {
                    codeLists.FGasesCodelists[codeListDefinitionVocabSets[i].vocabs[j]] = {};
                }
            }
            codeLists.FGasesCodelists.FGases = {};
            codeLists.FGasesCodelists.FGasesOrderedAndFilteredForMixtureDefinition = {};
            codeLists.FGasesCodelists.FGasesOrderedAndFilteredForMixtureDefinition.Gas = [];

            return {
                _registryDataPerYear: { },
                _authorisationData: null,

                getInstance: function() {
                    return dataProxy.getInstance();
                },
                saveInstanceXml: function (data) {
                    return dataProxy.saveInstance(data);
                },
                getCodeList: function() {
                    return codeLists;
                },
                loadCodeList: function(language) {
                    //finds file in project folder
                    var defaultlanguage = 'en';
                    var currentLanguage = !language? defaultlanguage : language;

                    //get codelists of fgases webform
                    for (var i = 0; i < codeListDefinitionVocabSets.length; i++){
                        var baseUriOfVocabulary = codeListDefinitionVocabSets[i].base;
                        for (var j = 0; j < codeListDefinitionVocabSets[i].vocabs.length; j++) {
                            var vocabularyIdentifier = codeListDefinitionVocabSets[i].vocabs[j];
                            var url =  baseUriOfVocabulary + vocabularyIdentifier + '/json?lang=' + currentLanguage;

                            if ($rootScope.isIE9 || window.isIE9){
                                url = baseUri + '/restProxy?uri=' + encodeURIComponent(url);
                            }

                            $http.get(url, {tracker: $rootScope.loadingTracker})
                                .error((function(vocabularyIdentifier){return function(data, status, headers, config){
                                    alert("Failed to read code lists '" + vocabularyIdentifier + "'. Data = " +  data + ", status = " + status);
                                    angular.copy(dummyGasList, codeLists.FGasesCodelists[vocabularyIdentifier]);
                                }})(vocabularyIdentifier))
                                .success((function(vocabularyIdentifier){return function (newCodeList) {
                                    codeLists.FGasesCodelists[vocabularyIdentifier] = {concepts:[]};
                                    if (vocabularyIdentifier == 'countries') {
                                        // ignore EU countries - QC 1066
                                        angular.forEach(newCodeList.concepts, function (concept) {
                                            if ($rootScope.euCountries.indexOf(concept['@id']) == -1) {
                                                this.push(concept);
                                            }
                                        }, codeLists.FGasesCodelists[vocabularyIdentifier].concepts);
                                        //$rootScope.nonEuCountries = angular.copy(codeLists.FGasesCodelists[vocabularyIdentifier]);
                                    }
                                    else {
                                        angular.copy(newCodeList, codeLists.FGasesCodelists[vocabularyIdentifier]);
                                    }
                                }})(vocabularyIdentifier));
                        }
                    }
                },
                loadFGases: function() {
                    dataProxy.getFGases().success(function (data) {
                        angular.copy(data.FGases, codeLists.FGasesCodelists.FGases);
                        var fgasGroups = [FormConstants.HFCsGasGroupId, FormConstants.UnsaturatedHFCsHCFCGasGroupId, FormConstants.PFCsGasGroupId, FormConstants.SF6GasGroupId,  FormConstants.FluorinatedEthersAlcoholsGasGroupId, FormConstants.OtherPrefluorinatedCompoundsGasGroupId];
                        // Filter for mixture definition gases
                        for (var i = 0; i < fgasGroups.length; i++){
                            var groupId = fgasGroups[i];
                            for (var j = 0; j < codeLists.FGasesCodelists.FGases.Gas.length; j++){
                                var gas = codeLists.FGasesCodelists.FGases.Gas[j];
                                if (gas.GasGroupId == groupId){
                                    codeLists.FGasesCodelists.FGasesOrderedAndFilteredForMixtureDefinition.Gas.push(gas);
                                }
                            }
                        }
                    }).error(function (data) {
                        alert("Failed to read FGases 2015 lists. Data = " +  data + ", status = " + status);
                    });
                },
                getEmptyInstance: function() {
                    return dataProxy.getEmptyInstance();
                },
                loadInstanceInfo: function() {
                    return dataProxy.getInstanceMetadata();
                },
                getCompanyData: function(companyId) {
                    return dataProxy.getCompanyData(companyId);
                },
                checkCompanyExistById: function(companyId) {
                    return dataProxy.checkCompanyExistById(companyId);
                },
                checkCompanyExistByIdAndName: function(companyId, companyName) {
                    return dataProxy.checkCompanyExistByIdAndName(companyId, companyName);
                },
                checkCompanyExistByIdAndCountryCodeOrVat: function(companyId, countryCode, vat) {
                    return dataProxy.checkCompanyExistByIdAndCountryCodeOrVat(companyId, countryCode, vat);
                },
                checkCompanyExistByIdOrNameOrVat: function(companyId, legalRepresentativeName, legalRepresentativeVat) {
                    return dataProxy.checkCompanyExistByIdOrNameOrVat(companyId, legalRepresentativeName, legalRepresentativeVat);
                },
                checkCompanyExistByVat: function(vatCode) {
                    return dataProxy.checkCompanyExistByVat(vatCode);
                },
                checkCompanyExistByVatAndName: function(vatCode, companyName) {
                    return dataProxy.checkCompanyExistByVatAndName(vatCode, companyName);
                },
                checkCompanyExistByNameAndCountryCode: function(companyName, countryCode) {
                    return dataProxy.checkCompanyExistByNameAndCountryCode(companyName, countryCode);
                },
                getRegistryData: function(companyId, transactionYear, onSuccess, onError) {
                    if (!objectUtil.isNull(this._registryDataPerYear[transactionYear])) {
                        objectUtil.call(onSuccess, this._registryDataPerYear[transactionYear]);
                        return;
                    }

                    var that = this;
                    dataProxy.getRegistryData(companyId, transactionYear, function(data) {
                        if (objectUtil.isNull(data.registryData)) {
                            objectUtil.call(onError);
                            return;
                        }

                        var registryData = {
                            stocks: that._fixStocks(data.registryData),
                            quota: that._fixQuota(data.registryData),
                            large: that._fixLargeStatus(data.registryData),
                            ner: that._fixNerStatus(data.registryData)
                        };
                        that._registryDataPerYear[transactionYear] = registryData;
                        objectUtil.call(onSuccess, registryData);
                    }, onError);
                },
                getAuthorisationData: function(companyId, onSuccess, onError) {
                    if (!objectUtil.isNull(this._authorisationData)) {
                        objectUtil.call(onSuccess, this._authorisationData);
                        return;
                    }
                    var that = this;
                    dataProxy.getAuthorisationData(companyId, function(data) {
                        if (objectUtil.isNull(data)) {
                            objectUtil.call(onError);
                            return;
                        }

                        that._authorisationData = data.authorisation;
                        objectUtil.call(onSuccess, data);
                    }, onError);
                },
                _fixStocks: function(companyData) {
                    jsonNormalizer.normalizeObjectProperty(companyData, 'stocks');
                    jsonNormalizer.normalizeArrayProperty(companyData.stocks, 'stock');
                    return arrayUtil.map(companyData.stocks.stock, function(stock) {
                        return {
                            transactionCode: stock.transactionCode,
                            gasId: numericUtil.toNum(stock.gasId),
                            gasName: stock.gasName,
                            amount: numericUtil.toNum(stock.amount)
                        };
                    });
                },
                _fixQuota: function(companyData) {
                    jsonNormalizer.normalizeObjectProperty(companyData, 'quota');
                    var quota = { };
                    quota.allocatedQuota = numericUtil.toNum(companyData.quota.allocatedQuota); // 9A_registry
                    quota.allocatedQuotaDate = companyData.quota.allocatedQuotaDate;
                    quota.availableQuota = numericUtil.toNum(companyData.quota.availableQuota); // 9G
                    quota.availableQuotaDate = companyData.quota.availableQuotaDate;

                    jsonNormalizer.normalizeArrayProperty(companyData.quota, 'quota9A_imp');
                    quota.quota9A_imp = companyData.quota.quota9A_imp;
                    var baseDate = Date.now();

                    arrayUtil.forEach(quota.quota9A_imp, function(quotaEntry) {
                        quotaEntry.amount = Number(quotaEntry.amount);
                        quotaEntry.tradePartner.PartnerId = "TradePartner_" + baseDate++;
                        quotaEntry.tradePartner.isEUBased = !stringUtil.isBlank(quotaEntry.tradePartner.EUVAT);
                        quotaEntry.tradePartner.QCWarning = [];
                    });

                    return quota;
                },
                _fixLargeStatus: function(companyData) {
                    return objectUtil.isNull(companyData.large) ? false : companyData.large;
                },
                _fixNerStatus: function(companyData) {
                    return objectUtil.isNull(companyData.ner) ? false : companyData.ner;
                }
            };
        }
    ]);
})();
