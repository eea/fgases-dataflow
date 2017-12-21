
(function () {
    angular.module('FGases.controllers').controller("questionnaire", 
    
    function ($scope, $rootScope, dataRepository, languageChanger, $sce, $location, $filter, $translate,
            FormConstants, $notification, FileUploader, $timeout, $anchorScroll, tabService, focus, $http, 
            objectUtil, arrayUtil, numericUtil, stringUtil,
            commentModalService, transactionYearProvider, messageBox, modalAdapter,
            jsonNormalizer, reportStructureNormalizer, reportStructureHelper, dataPrefill,
            viewModel, sheetGeneralValidator, sheetActivitiesValidator, sheetGasSelectionValidator, 
            sheet1Validator, sheet2Validator, sheet3Validator, sheet4Validator, sheet5Validator,sheet6Validator,
            tradePartnerCompanyMatcher) {
        $scope.viewModel = viewModel;
        $scope.base = $location.host() + $location.port() + getParameterByName('base_uri');
        $scope.availableLanguages = languageChanger.getAvailableLanguages();
        $scope.companyInfoConfirmed = false;
        $scope.uploadFile = '';
        $scope.uploader = new FileUploader();
        $scope.valMsgIndex = 0;
        $rootScope.euCountries = ['AT', 'BE', 'BG', 'CY', 'CZ', 'DE', 'DK', 'EE', 'EL', 'ES', 'FI', 'FR', 'GB', 'GR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LU', 'LV', 'MT', 'NL', 'PL', 'PT', 'RO', 'SE', 'SI', 'SK', 'UK'];
        $rootScope.currentLanguage = 'en';
        
        //determine ie version, code snippet is taken from: http://msdn.microsoft.com/en-us/library/ms537509%28v=vs.85%29.aspx
        var rv = -1; // Return value assumes failure.
        if (navigator.appName == 'Microsoft Internet Explorer')
        {
            var ua = navigator.userAgent;
            var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null)
                rv = parseFloat(RegExp.$1);
        }
        //see: http://stackoverflow.com/questions/17907445/how-to-detect-ie11
        else if (navigator.appName == 'Netscape')
        {
            var ua = navigator.userAgent;
            var re = new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})");
            if (re.exec(ua) != null)
                rv = parseFloat(RegExp.$1);
        }

        $rootScope.ieVersionNumberOutOfCuriosityVariable = rv;
        if (rv > 0 && rv <= 9.0) {
            $rootScope.isIE9 = true;
        } else {
            $rootScope.isIE9 = false;
        }
        $scope.isIE9 = $rootScope.isIE9;
        $rootScope.showConfirmationForThreashold = true;

        //define patterns used with ng-pattern
        $scope.decimalNumberWith3DigitsPattern = /^\d{1,4}(\.\d{1,3})?$/;
        $scope.integerNumber = /^\d+$/;
        $scope.moreThanTwoLetters = /^.{2}.*/;
        $scope.showConfirmationForValueGreaterThanThreshold = true;

        // Definition of gas including elements in instance.FGasesReporting. ADD MORE WHEN NECESSARY
        $scope.gasIncludingElements = reportStructureHelper.getGasIncludingSheets();
        $scope.tradePartnerElements = reportStructureHelper.getTradePartnerTransactions();

        if (!Date.now) {
            Date.now = function () {
                return new Date().getTime();
            };
        }

        $scope.start = function() {
            dataRepository.getEmptyInstance().error(function () {
                $notification.error("", "Failed to fetch critical webform resources. Please close the form and try to report again later.");
            }).success(function (instance) {
                $scope.emptyInstance = instance;
                $scope.loadInstance();
            });
        };
        
        $scope.loadInstance = function() {
            dataRepository.getInstance().error(function () {
                $notification.error("", "Failed to load reporting data. Please close the form and try to report again later.");
            }).success(function (instance) {
                reportStructureNormalizer.normalize(instance);

                if (dataPrefill.isPreviousReport(instance)) {
                    dataRepository.getEmptyInstance().error(function () {
                        $notification.error("", "Failed to read empty instance XML file.");
                    }).success(function(emptyInstance) {
                        reportStructureNormalizer.normalize(emptyInstance);
                        $scope.setInstance(emptyInstance);
                        dataPrefill.prefil(instance, emptyInstance, {
                            scope: $scope
                        });
                        $scope.onInstanceReady(emptyInstance);
                    });
                }
                else {
                    $scope.setInstance(instance);
                    $scope.onInstanceReady(instance);
                }
            });
        };

        $scope.setInstance = function(instance) {
            $scope.instance = instance;
            viewModel.setDataSource(instance);
        };

        $scope.onInstanceReady = function(instance) {
            $rootScope.currentLanguage = $scope.instance.FGasesReporting['@xml:lang'];
            $scope.initTransactionYear();

            if (!companyId) {
                if ($scope.instance.FGasesReporting.GeneralReportData.Company.CompanyId) {
                    companyId = $scope.instance.FGasesReporting.GeneralReportData.Company.CompanyId;
                } else {
                    //companyId is unknown, use test company- just for testing
                    if (!testCompanyId) {
                        companyId = "1111";
                    } else {
                        companyId = testCompanyId;
                    }
                }
            }

            // INITIALIZATIONS ...
            //these variables are used to store temporarily selected gas ids for 6 list
            //this is used since multiselect directive does not send new and old values
            $scope.selectedGasIds = {};
            
            arrayUtil.forEach(reportStructureHelper.getGasSelectionLists(), function(gasSelectionListName) {
                $scope.selectedGasIds[gasSelectionListName] = clone($scope.instance.FGasesReporting.GeneralReportData[gasSelectionListName].GasName);
            });

            $scope.filteredReportedGasesForHFCLength = 0;
            
            arrayUtil.forEach($scope.instance.FGasesReporting.ReportedGases, function(reportedGas) {
                if ($scope.containsHFC(reportedGas)) {
                    $scope.filteredReportedGasesForHFCLength++;
                }
            });
            
            // load company info, if it is a first time form loading
            if (isEmpty($scope.instance.FGasesReporting.GeneralReportData.Company['@status'])) {
                $scope.instance.FGasesReporting.GeneralReportData.Company['@status'] = 'incomplete';
            }
            if ($scope.instance.FGasesReporting.GeneralReportData.Company['@status'] === 'incomplete') {
                $scope.instance.FGasesReporting.GeneralReportData.Company.CompanyId = companyId;
                $scope.loadCompanyData();
            } else {
                $scope.companyInfoConfirmed = true;
                $scope.onCompanyDataLoaded();
            }
        };

        // set defaults from constants
        $scope.HFCsGasGroupId = FormConstants.HFCsGasGroupId;
        $scope.PFCsGasGroupId = FormConstants.PFCsGasGroupId;
        $scope.SF6GasGroupId = FormConstants.SF6GasGroupId;
        $scope.UnsaturatedHFCsHCFCGasGroupId = FormConstants.UnsaturatedHFCsHCFCGasGroupId;
        $scope.FluorinatedEthersAlcoholsGasGroupId = FormConstants.FluorinatedEthersAlcoholsGasGroupId;
        $scope.OtherPrefluorinatedCompoundsGasGroupId = FormConstants.OtherPrefluorinatedCompoundsGasGroupId;
        //there is no 6
        $scope.NonFGasesGroupId = FormConstants.NonFGasesGroupId;
        $scope.CommonlyUsedMixturesGasGroupId = FormConstants.CommonlyUsedMixturesGasGroupId;
        /*
         "GasGroupId": 8,
         "GasGroupName": null,
         
         "GasGroupId": 7,
         "GasGroupName": "HFC mixtures",
         
         "GasGroupId": 9,
         "GasGroupName": "Non-HFC mixtures",
         */
        $scope.commentLimit = FormConstants.CommentLimit;
        $scope.loadCompanyData = function () {
            var companyId = $scope.instance.FGasesReporting.GeneralReportData.Company.CompanyId;
            dataRepository.getCompanyData(companyId).error(function () {
                $notification.error("", "Failed to read company data from the registry. Please close the form and try to report again later.");
            }).success(function (companyInstance) {
                var organisation = companyInstance;
                if (angular.isArray(organisation)) {
                    organisation = $filter('filter')(companyInstance, {id: companyId})[0];
                }

                if (organisation) {
                    var company = $scope.instance.FGasesReporting.GeneralReportData.Company;
                    $scope.instance.FGasesReporting.GeneralReportData.Company.CompanyName = organisation.name;
                    company.CompanyName = organisation.name;
                    company.PostalAddress.StreetAddress = organisation.address.street;
                    company.PostalAddress.Number = organisation.address.number;
                    company.PostalAddress.PostalCode = organisation.address.zipCode;
                    company.PostalAddress.City = organisation.address.city;
                    company.Country.Code = organisation.address.country.code;
                    company.Country.Type = organisation.address.country.type;
                    company.Country.Name = organisation.address.country.name;
                    company.Website = organisation.website;
                    company.Telephone = organisation.phone;
                    company.VATNumber = organisation.vat;
                    if (!angular.isUndefined(organisation.euLegalRepresentativeCompany) && !isEmpty(organisation.euLegalRepresentativeCompany)) {
                        company.EuLegalRepresentativeCompany.CompanyId = organisation.euLegalRepresentativeCompany.id;
                        company.EuLegalRepresentativeCompany.CompanyName = organisation.euLegalRepresentativeCompany.name;
                        company.EuLegalRepresentativeCompany.PostalAddress.StreetAddress = organisation.euLegalRepresentativeCompany.address.street;
                        company.EuLegalRepresentativeCompany.PostalAddress.Number = organisation.euLegalRepresentativeCompany.address.number;
                        company.EuLegalRepresentativeCompany.PostalAddress.PostalCode = organisation.euLegalRepresentativeCompany.address.zipCode;
                        company.EuLegalRepresentativeCompany.PostalAddress.City = organisation.euLegalRepresentativeCompany.address.city;
                        company.EuLegalRepresentativeCompany.Country.Code = organisation.euLegalRepresentativeCompany.address.country.code;
                        company.EuLegalRepresentativeCompany.Country.Type = organisation.euLegalRepresentativeCompany.address.country.type;
                        company.EuLegalRepresentativeCompany.Country.Name = organisation.euLegalRepresentativeCompany.address.country.name;
                        company.EuLegalRepresentativeCompany.Website = organisation.euLegalRepresentativeCompany.website;
                        company.EuLegalRepresentativeCompany.Telephone = organisation.euLegalRepresentativeCompany.phone;
                        company.EuLegalRepresentativeCompany.VATNumber = organisation.euLegalRepresentativeCompany.vatNumber;
                        company.EuLegalRepresentativeCompany.ContactPerson.FirstName = organisation.euLegalRepresentativeCompany.contactPersonFirstName;
                        company.EuLegalRepresentativeCompany.ContactPerson.LastName = organisation.euLegalRepresentativeCompany.contactPersonLastName;
                        company.EuLegalRepresentativeCompany.ContactPerson.Email = organisation.euLegalRepresentativeCompany.contactPersonEmailAddress;
                    }
                    company.ContactPersons.ContactPerson = [];
                    if (organisation.contactPersons) {
                        for (var i = 0; i < organisation.contactPersons.length; i++) {
                            company.ContactPersons.ContactPerson.push(
                                    {
                                        UserName: organisation.contactPersons[i].userName,
                                        FirstName: organisation.contactPersons[i].firstName,
                                        LastName: organisation.contactPersons[i].lastName,
                                        Email: organisation.contactPersons[i].emailAddress
                                    }
                            );
                        }
                    }
                    company.Former_CompanyId_2104 = organisation['Former_Company_no_2007-2010'];

                    $scope.onCompanyDataLoaded();
                }
            });
        };

        $scope.onCompanyDataLoaded = function() {
            var company = $scope.instance.FGasesReporting.GeneralReportData.Company;
            $rootScope.companyId = company.CompanyId;
            $rootScope.vat = company.VATNumber;
            $scope.loadExtraCompanyData(false);
        };

        $scope.loadExtraCompanyData = function(forceStockOverwrite, onSuccess, onError) {
            var companyId = $scope.instance.FGasesReporting.GeneralReportData.Company.CompanyId;
            
            if (objectUtil.isNull(companyId)) {
                return;
            }
            
            dataRepository.getRegistryData(companyId, transactionYearProvider.getTransactionYear(), function(extraCompanyData) {
                $scope.applyStocks(extraCompanyData.stocks, forceStockOverwrite);
                $scope.applyQuota(extraCompanyData.quota);
                $scope.applyCompanySize(extraCompanyData.large);
                $scope.applyNerStatus(extraCompanyData.ner);
                objectUtil.call(onSuccess);
            }, function() {
                $notification.error("", "Failed to load company info required for reporting. Please try again later.");
                objectUtil.call(onError);
            });
        };

        $scope.applyStocks = function(stocks, forceOverwrite) {
            $scope.stocks = stocks;
            viewModel.initCompanyStocks(stocks);
            $scope.instance.FGasesReporting.attachedCompanyData.stocks.stock = stocks;

            arrayUtil.forEach($scope.instance.FGasesReporting.ReportedGases, function(reportedGas) {
                $scope.tryApplyStockValues(reportedGas, forceOverwrite);
            });
        };
        
        $scope.applyQuota = function(quota) {
            var section9Data = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata;
            jsonNormalizer.normalizeObjectProperty(section9Data, 'tr_09A_Registry');
            jsonNormalizer.normalizeObjectProperty(section9Data, 'tr_09G');
            section9Data.tr_09A_Registry.Amount = quota.allocatedQuota;
            section9Data.tr_09A_Registry.Comment = quota.allocatedQuotaDate;
            section9Data.tr_09G.Amount = quota.availableQuota;
            section9Data.tr_09G.Comment = quota.availableQuotaDate;
            viewModel.initCompanyQuota(quota);
            
            while (section9Data.tr_09A_imp_TradePartners.Partner.length > 0) {
                var partner = section9Data.tr_09A_imp_TradePartners.Partner[0];
                $scope.removeTradingPartner('F4_S9_IssuedAuthQuata', 'tr_09A_imp_TradePartners', 0, 'tr_09A_imp', true);
                
                arrayUtil.forEach(quota.quota9A_imp, function(quota9A_imp, loopContext) {
                    if (tradePartnerCompanyMatcher.areEqual(partner, quota9A_imp.tradePartner)) {
                        quota9A_imp.tradePartner.PartnerId = partner.PartnerId;
                        loopContext.breakLoop = true;
                    }                    
                });
            }
            
            arrayUtil.forEach(quota.quota9A_imp, function(quota9A_imp) {
                $scope.autoInsertSection9TradePartner('tr_09A_imp', quota9A_imp.tradePartner, quota9A_imp.amount, true);
                $scope.autoInsertSection9TradePartner('tr_09A_add', quota9A_imp.tradePartner, null, false);
            });
            $scope.calculateTradingPartnerTotalAmountInteger($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_imp);
            $scope.calculateTradingPartnerTotalAmountInteger($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_add);
            $scope.calculate9ADependingFields();
        };
        
        $scope.applyCompanySize = function(isLarge) {
            viewModel.setLargeCompany(isLarge);
        };
        
        $scope.applyNerStatus = function(isNer) {
            viewModel.setReporterInNerList(isNer);
            $scope.instance.FGasesReporting.attachedCompanyData.nerStatus = isNer;
        };

        $scope.autoInsertSection9TradePartner = function(transaction, tradePartner, amount, overwriteAmount) {
            var tradePartnerArray = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata[transaction + '_TradePartners'].Partner;
            var index = arrayUtil.indexOf(tradePartnerArray, function(tp) {
                return tradePartner.PartnerId === tp.PartnerId;
            });
            
            if (index < 0) {
                var dummyModalResults = {
                    tempPartnerDefinition: tradePartner,
                    index: -1,
                    modalExtras: {
                        arrayToPush: tradePartnerArray,
                        emptyInstancePath: 'FGasesReporting.F4_S9_IssuedAuthQuata.' + transaction + '.TradePartner',
                        baseElement: $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata,
                        fieldName: transaction
                    }
                };
                $scope.tradingPartnerModalWindowCloseCallBackForNonGasForm(dummyModalResults);
                index = tradePartnerArray.length - 1;
            }
            
            var partnerAmount = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata[transaction].TradePartner[index];
            
            if (!numericUtil.isNum(partnerAmount.amount) || overwriteAmount) {
                partnerAmount.amount = amount;
            }
        };

        $scope.modifyCompanyInfo = function () {
            if (confirm('The reporting will end at this stage and you are forwarded to another webpage where company information can be changed. \n Are you sure you want to proceed with modifying company information?')) {
                $scope.instance.FGasesReporting.GeneralReportData.Company['@status'] = 'modified';
                $scope.saveInstance();
                window.location = "https://webgate.ec.europa.eu/ods2/";
            }
        };

        // TODO: What is this function for???
        $scope.confirmCompanyInfo = function () {
            $scope.instance.FGasesReporting.GeneralReportData.Company['@status'] = 'infoconfirmed';
            $scope.companyInfoConfirmed = true;
        };

        $scope.reportingYears = function () {
            return transactionYearProvider.getValidTransactionYears();
        };

        $scope.initTransactionYear = function () {
            $scope.instance.FGasesReporting.GeneralReportData.TransactionYear = transactionYearProvider.getTransactionYear();
            $scope.previousTransactionYearSelection = transactionYearProvider.getTransactionYear();
        };

        $scope.onTransactionYearChanged = function(cb) {
            $scope.loadExtraCompanyData(true, function() {
                $scope.previousTransactionYearSelection = transactionYearProvider.getTransactionYear();
                if (typeof cb === "function") cb();
            }, function() {
                $scope.instance.FGasesReporting.GeneralReportData.TransactionYear = $scope.previousTransactionYearSelection;
                $notification.warning("", "Due to company info fetch failure, transaction year selection change was reverted.");
            });
        };

        $scope.updateActivityUpperCB = function (upperCBPath, innerCBs) {
            var tempUpperCBValue = false;
            for (var i = 0; i < innerCBs.length && tempUpperCBValue == false; i++) {
                var innerCBValue = $scope.instance.FGasesReporting.GeneralReportData.Activities[innerCBs[i]];
                innerCBValue = innerCBValue == null ? false : innerCBValue;
                tempUpperCBValue = tempUpperCBValue || innerCBValue;
            }
            $scope.instance.FGasesReporting.GeneralReportData.Activities[upperCBPath] = tempUpperCBValue;
        };

        // ask for confirmation for deselecting activity, if confirmed related values are cleared.
        $scope.activitySelectionChanged = function (activity) {
            // return when initing
            if ($scope.instance.FGasesReporting.GeneralReportData.Activities[activity] == null) {
                return;
            }

            if (!$scope.instance.FGasesReporting.GeneralReportData.Activities[activity]) {
                if (confirm('Warning: Please note that all data entered for transactions specific to this activity will be lost. Confirm deselection?')) {
                    //clear values
                    $scope.clearValuesBasedOnActivityDeSelection(activity);
                    //check if special gas 'unspecfied mix' requirements are still valid
                    if (!($scope.instance.FGasesReporting.GeneralReportData.Activities['I'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['E'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['D'])) {
                        var unspecifiedMixIndex = $scope.instance.FGasesReporting.GeneralReportData.CommonlyUsedMixtures.GasName.indexOf(FormConstants.UnspecifiedGasMixId);
                        if (unspecifiedMixIndex >= 0) {

                            //find reported gas
                            var gasIndex = 0;
                            for (; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length &&
                                    $scope.instance.FGasesReporting.ReportedGases[gasIndex].GasId != FormConstants.UnspecifiedGasMixId;
                                    gasIndex++) {
                            }

                            $scope.removeGasFromReportedGases(gasIndex, false);

                            $scope.removeGasFromSelection($scope.instance.FGasesReporting.GeneralReportData.CommonlyUsedMixtures.GasName, unspecifiedMixIndex);
                            alert('Quantities of an unspecified mix of F-gases can only be reported for destruction, import for destruction or export for destruction. Gas is removed from selection.');
                        }
                    }
                    //re-calculate forms
                    if ($scope.isTabVisible(FormConstants.TabIds[4])) {
                        $scope.reCalculateSheet1();
                    }
                    if ($scope.isTabVisible(FormConstants.TabIds[5])) {
                        $scope.reCalculateSheet2();
                    }
                    if ($scope.isTabVisible(FormConstants.TabIds[6])) {
                        $scope.reCalculateSheet3();
                    }
                    if ($scope.isTabVisible(FormConstants.TabIds[7])) {
                        $scope.reCalculateSheet4();
                    }
                    if ($scope.isTabVisible(FormConstants.TabIds[8])) {
                        $scope.reCalculateSheet6();
                    }
                    if ($scope.isTabVisible(FormConstants.TabIds[9])) {
                        $scope.calculateForm7Totals();
                    }
                } else {
                    //select again
                    $scope.instance.FGasesReporting.GeneralReportData.Activities[activity] = true;
                }
            }
            else {
                arrayUtil.forEach($scope.instance.FGasesReporting.ReportedGases, function(reportedGas) {
                    $scope.tryApplyStockValues(reportedGas);
                });
            }
        }; // end of function activitiySelectionChanged

        // Definition of activity field dependency map
        // clear statements consists of a condition and list of fields to be cleared
        // Map structure is basically:
        // '<activityKey>': {
        //      'clearStatements': [], dependents: []
        // }
        // dependents is an array to include only keys in the map
        // clearStatements is an array consisting of following object type,
        // <clearStatementObject>: {'condition': '<An angular condition to satisfy to clear fields>', fields:[<array of form - rows to be cleared>]}
        $scope.activityFieldDepedencyMap = {
            'P-HFC': {'clearStatements': [], 'dependents': ['P']},
            'P-other': {'clearStatements': [], 'dependents': ['P']},
            'P': {'clearStatements':
                        [
                            {'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] == false',
                                'fields':
                                        [
                                            {'form': 'F1_S1_4_ProdImpExp', 'rows': ['tr_01A', 'tr_01B', 'tr_01C', 'tr_01D', 'tr_01E']},
                                            {'form': 'F1_S1_4_ProdImpExp', 'subForm': 'Totals', 'rows': ['tr_01ASumAllGases', 'tr_01ASumAllGasesCO2Eq']}
                                        ]}
                        ],
                'dependents': ['P_I_E', 'P_I', 'P_I_E_Calculated']},
            'I-HFC': {'clearStatements':
                        [], 'dependents': ['I']},
            'I-other': {'clearStatements': [], 'dependents': ['I']},
            'I': {'clearStatements':
                        [
                            {'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["I"] == false',
                                'fields':
                                        [
                                            {'form': 'F1_S1_4_ProdImpExp', 'rows': ['tr_02A']},
                                            {'form': 'F1_S1_4_ProdImpExp', 'subForm': 'Totals', 'rows': ['tr_02ASumAllGases', 'tr_02ASumAllGasesCO2Eq']}
                                        ]}
                        ],
                'dependents': ['P_I_E', 'P_I', 'P_I_E_Calculated']},
            'P_I': {'clearStatements':
                        [
                            {'condition': '!$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I"]',
                                'fields':
                                        [
                                            {'form': 'F1_S1_4_ProdImpExp', 'rows': ['tr_03B', 'tr_04A', 'tr_04B', 'tr_04C', 'tr_04D', 'tr_04E', 'tr_04F', 'tr_04G', 'tr_04H', 'tr_04I', 'tr_04J'], 'calculatedFields': ['tr_01K', 'tr_03C', 'tr_04M']},
                                            {'form': 'F3A_S6A_IA_HFCs', 'rows': ['tr_06A', 'tr_06B', 'tr_06C', 'tr_06D', 'tr_06E', 'tr_06F', 'tr_06G', 'tr_06H', 'tr_06I', 'tr_06J', 'tr_06K', 'tr_06L', 'tr_06M', 'tr_06N', 'tr_06O', 'tr_06P', 'tr_06Q', 'tr_06R', 'tr_06S', 'tr_06T', 'tr_06U', 'tr_06V', 'tr_06W', 'tr_06X']}
                                        ]
                            },
                            {
                                condition: '!$scope.instance.FGasesReporting.GeneralReportData.Activities["P-HFC"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I-HFC"]',
                                fields: [
                                    {'form': 'F2_S5_exempted_HFCs', 'rows': ['tr_05A', 'tr_05B', 'tr_05C', 'tr_05D', 'tr_05E', 'tr_05F', 'tr_05G', 'tr_05H', 'tr_05I', 'tr_05J', 'tr_05R']},
                                    {'form': 'F2_S5_exempted_HFCs', 'subForm': 'SumOfAllHFCsS1', 'rows': ['tr_05G', 'tr_05H', 'tr_05I', 'tr_05J']},
                                    {'form': 'F2_S5_exempted_HFCs', 'subForm': 'SumOfAllHFCsS2', 'rows': ['tr_05G', 'tr_05H', 'tr_05I', 'tr_05J']}
                                ]
                            }
                        ]},
            'E': {
                'clearStatements': [
                    {
                        'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["E"] == false',
                        'fields': [
                            {'form': 'F1_S1_4_ProdImpExp', 'rows': ['tr_03A', 'tr_03B', 'tr_03C', 'tr_03D', 'tr_03E', 'tr_03F'], 'calculatedFields': ['tr_01K', 'tr_04M', 'tr_06X']},
                            {'form': 'F1_S1_4_ProdImpExp', 'subForm': 'Totals', 'rows': ['tr_03ASumAllGases', 'tr_03ASumAllGasesCO2Eq']}
                        ]
                    }
                ],
                dependents: ['P_I_E', 'P_I_E_Calculated']
            },
            P_I_E: {
                clearStatements: [ 
                    {
                        condition: '!$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["E"]',
                        fields: [
                            { 
                                form: 'F1_S1_4_ProdImpExp',
                                rows: [
                                    'tr_01F', 'tr_01G', 'tr_01H', 'tr_01I', 'tr_01J', 'tr_01K', 
                                    'tr_02B', 
                                    'tr_04K', 'tr_04L', 'tr_04M'
                                ]
                            }
                        ]
                    }
                ]
            },
            P_I_E_Calculated: {
                clearStatements: [ 
                    {
                        condition: '!$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I"] && !$scope.instance.FGasesReporting.GeneralReportData.Activities["E"]',
                        fields: [
                            { 
                                form: 'F1_S1_4_ProdImpExp',
                                rows: [
                                    'tr_01K', 'tr_03C', 'tr_04M'
                                ]
                            }
                        ]
                    }
                ]
            },
            'FU': {'clearStatements': [{'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["FU"] == false', 'fields': [{'form': 'F6_FUDest', 'rows': ['tr_07A']}, {'form': 'F6_FUDest', 'subForm': 'Totals', 'rows': ['tr_07ASumAllGases', 'tr_07ASumAllGasesCO2Eq']}]}]},
            'D': {'clearStatements': [{'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["D"] == false', 'fields': [
                            {
                                'form': 'F6_FUDest',
                                'rows': ['tr_08A', 'tr_08B', 'tr_08C', 'tr_08D', 'tr_08E', 'tr_08F']
                            },
                            {
                                'form': 'F6_FUDest',
                                'subForm': 'Totals',
                                'rows': ['tr_08DSumAllGases', 'tr_08DSumAllGasesCO2Eq']
                            }
                        ]
                    }
                ]
            },
            'Eq-I-RACHP-HFC': {'clearStatements': [], 'dependents': ['Eq-I']},
            'Eq-I-other': {
                'clearStatements': [], 
                'dependents': ['Eq-I'],
                onPostExecute: function() {
                    var transactionSelection = $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions;
                    var toClear = ['H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];
                    
                    arrayUtil.forEach(Object.getOwnPropertyNames(transactionSelection), function(transaction) {
                        var mustClear = arrayUtil.contains(toClear, function(toClearItem) {
                            return stringUtil.contains(transaction, toClearItem);
                        });
                        
                        if (mustClear) {
                            transactionSelection[transaction] = false;
                        }
                    });
                }
            },
            'Eq-I': {'clearStatements':
                        [
                            {'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["Eq-I"] == false',
                                'fields':
                                        [
                                            {'form': 'F7_s11EquImportTable', 'rows': ['tr_11A', 'tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14', 'tr_11B', 'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14', 'tr_11C', 'tr_11D', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04', 'tr_11F', 'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09', 'tr_11H', 'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q']},
                                            {'form': 'F7_s11EquImportTable', 'subForm': 'AmountOfImportedEquipment', 'rows': ['tr_11A', 'tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14', 'tr_11B', 'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14', 'tr_11C', 'tr_11D', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04', 'tr_11F', 'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09', 'tr_11G', 'tr_11H', 'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q']},
                                            {'form': 'F7_s11EquImportTable', 'subForm': 'SumOfAllGasesS1', 'rows': ['tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14', 'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14', 'tr_11C', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04', 'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09', 'tr_11G', 'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q']},
                                            {'form': 'F7_s11EquImportTable', 'subForm': 'SumOfAllGasesS2', 'rows': ['tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14', 'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14', 'tr_11C', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04', 'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09', 'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q']}
                                        ]
                            }
                        ],
                onPostExecute: function() {
                    if ($scope.instance.FGasesReporting.GeneralReportData.Activities["Eq-I"]) {
                        return;
                    }
                    
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.transactionsConfirmed = false;
                    var transactionSelection = $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions;
                    
                    arrayUtil.forEach(Object.getOwnPropertyNames(transactionSelection), function(transaction) {
                        transactionSelection[transaction] = false;
                    });
                }
            },
            'auth': {
                clearStatements: [
                    {
                        condition: '$scope.instance.FGasesReporting.GeneralReportData.Activities["auth"] == false',
                        fields: [
                            {
                                form: 'F4_S9_IssuedAuthQuata',
                                subForm: null,
                                rows: ['tr_09A', 'tr_09A_add', 'tr_09B', 'tr_09C', 'tr_09D', 'tr_09E', 'tr_09F']
                            }
                        ]
                    }
                ],
                dependents: [ 'auth-NER' ],
                onPostExecute: function(instance) {
                    var formData = instance.FGasesReporting.F4_S9_IssuedAuthQuata;
                    
                    if (angular.isDefined(formData.Verified)) {
                        formData.Verified = null;
                    }
                }
            },
            'auth-NER': {
                'clearStatements': [
                    {
                        'condition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["auth-NER"] == false',
                        'fields': [ { form: 'F5_S10_Auth_NER', rows: ['tr_10A'] } ]
                    }
                ],
                onPostExecute: function() {
                    arrayUtil.forEach(viewModel.sheet5.section10.getTr10ATradePartners(), function(tradePartner) {
                        arrayUtil.selectSingle(viewModel.sheet5.section10.getSectionData().SumOfAllHFCsS1.tr_10A, function(s1Amount) {
                            return s1Amount.TradePartnerID === tradePartner.PartnerId;
                        }).Amount = null;
                    });
                    arrayUtil.forEach(viewModel.sheet5.section10.getTr10ATradePartners(), function(tradePartner) {
                        arrayUtil.selectSingle(viewModel.sheet5.section10.getSectionData().SumOfAllHFCsS2.tr_10A, function(s2Amount) {
                            return s2Amount.TradePartnerID === tradePartner.PartnerId;
                        }).Amount = null;
                    });
                    arrayUtil.forEach(viewModel.sheet5.section10.getTr10ATradePartners(), function(tradePartner) {
                        arrayUtil.selectSingle(viewModel.sheet5.section10.getSectionData().SupportingDocuments.tr_10A, function(supportDoc) {
                            return supportDoc.TradePartnerID === tradePartner.PartnerId;
                        }).Document = [];
                    });
                }
            }
        };// end of definition of activity field dependency map

        // function to clear related values when an activity deselected
        // this function heavily dependent to $scope.activityFieldDepedencyMap
        // function can be called recursively depending on entry.
        $scope.clearValuesBasedOnActivityDeSelection = function (activity) {
            var mapped = $scope.activityFieldDepedencyMap[activity];
            //if it is not in map, just return
            if (!mapped) {
                //Console.log
                return;
            }

            var clearStatements = mapped.clearStatements;
            for (var i = 0; i < clearStatements.length; i++) {
                //execute clear statements
                var statement = clearStatements[i];
                //if condition is satisfied then continue, otherwise skip clearing
                //if ($scope.$eval(statement.condition)){ Angular eval does not work :\ JS eval is used instead
                if (eval(statement.condition)) {
                    for (var j = 0; j < statement.fields.length; j++) {
                        var form = statement.fields[j].form;
                        for (var k = 0; k < statement.fields[j].rows.length; k++) {
                            var row = statement.fields[j].rows[k];

                            var subForm = 'Gas';
                            if (angular.isDefined(statement.fields[j].subForm)) {
                                subForm = statement.fields[j].subForm;
                            } else if ($scope.instance.FGasesReporting.ReportedGases.length == 0) { //check reported gases for gas subforms
                                //there is nothing to clear, just continue
                                continue;
                            }
                            //now clear all values in a row, this is based on gas of course
                            var column = subForm === null ? $scope.instance.FGasesReporting[form] : $scope.instance.FGasesReporting[form][subForm];
                            if (!angular.isArray(column)) {
                                column = [column];
                            }

                            for (var l = 0; l < column.length; l++) {
                                if (angular.isUndefined(column[l]) || angular.isUndefined(column[l][row])) {
                                    continue;
                                }
                                var gasRow = column[l][row];

                                if (angular.isUndefined(gasRow) || gasRow === null) {
                                    //if it is already null, there is nothing to clear so just continue over loop.
                                    continue;
                                }

                                if (angular.isDefined(gasRow.Comment)) {
                                    gasRow.Comment = null;
                                }
                                if (angular.isDefined(gasRow.Unit)) {
                                    gasRow.Unit = null;
                                }

                                if (angular.isDefined(gasRow.Amount)) {
                                    gasRow.Amount = null;
                                } else if (angular.isDefined(gasRow.SumOfPartnerAmounts)) {
                                    //clear also trade partner values
                                    if (angular.isDefined(gasRow.TradePartner) && gasRow.TradePartner && angular.isArray(gasRow.TradePartner)) {
                                        for (var n = 0; n < gasRow.TradePartner.length; n++) {
                                            gasRow.TradePartner[n].amount = null;
                                            if (angular.isDefined(gasRow.TradePartner[n].Comment)) {
                                                gasRow.TradePartner[n].Comment = null;
                                            }
                                        }
                                    }
                                    gasRow.SumOfPartnerAmounts = null;
                                } else {
                                    //this is used for totals
                                    //gasRow = null
                                    column[l][row] = null;
                                }
                            }
                        }

                        if (angular.isDefined(statement.fields[j].calculatedFields)) {
                            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                                $scope.doCalculationForFields(gasIndex, statement.fields[j].calculatedFields);
                            }
                        }
                    }
                }
            }

            objectUtil.call(mapped.onPostExecute, $scope.instance);

            var dependents = mapped.dependents;
            //if there is any dependent, call them one by one
            if (dependents) {
                for (var i = 0; i < dependents.length; i++) {
                    $scope.clearValuesBasedOnActivityDeSelection(dependents[i]);
                }
            }

        };// end of function clearValuesBasedOnActivityDeSelection

        dataRepository.loadCodeList();
        dataRepository.loadFGases();
        $scope.codeList = dataRepository.getCodeList();
        viewModel.initCodeLists($scope.codeList);
        $scope.conversionLink = "";
        $scope.instanceInfo = {};
        dataRepository.loadInstanceInfo().error(function () {
            console.log("Failed to readfile info from server.");
        }).success(function (info) {
            angular.copy(info, $scope.instanceInfo);
            if ($scope.instanceInfo.conversions) {
                var htmlConversionId = $filter('filter')($scope.instanceInfo.conversions, {resultType: 'HTML'})[0].id;
                $scope.conversionLink = $scope.instanceInfo.conversionLink + htmlConversionId;
            }
        })

        $scope.initArray = function (arrayElement, last) {
            var tokens = arrayElement.split(".");
            var result = $scope.instance;
            while (tokens.length) {
                result = result[tokens.shift()];
            }

            if (!(result[last] instanceof Array)) {
                result[last] = [result[last]];
            }
        };

        // Add new row to ng-repeat
        $scope.addItem = function (path, value) {
            var tokens = path.split(".");
            var result = $scope.instance;
            while (tokens.length) {
                result = result[tokens.shift()];
            }

            // Need to make copy of object otherwise it gets same $$hashkey and it cannot be used in ng-repeat.
            // Other solution would be to get empty instance every time that would be slower.
            var copyOfEmptyInstance = clone(objectUtil.isNull(value) ? $scope.getInstanceByPath('emptyInstance', path) : value);
            result.push(copyOfEmptyInstance);
            return copyOfEmptyInstance;

        };

        // function to remove selected gas from list, if users confirms.
        $scope.removeGasFromSelection = function (gasList, index) {
            gasList.splice(index, 1);//TODO remove function can be used in change attribute of multiselect directive
            return;
        };// end of function removeGasFromSelection

        // function to remove a gas from reported gases
        $scope.removeGasFromReportedGases = function (index, askForConfirmation) {
            //set up
            askForConfirmation = typeof askForConfirmation !== 'undefined' ? askForConfirmation : true;

            //confirm deletion from user, if it is set
            if (askForConfirmation) {
                //TODO: localization
                var confirmed = confirm("Warning: Please note that all data entered for this gas will be lost. Confirm deselection?");
                if (!confirmed) {
                    return false;
                }
            }

            //for defensive purposes check index
            if (index >= $scope.instance.FGasesReporting.ReportedGases.length) {
                //an unexpected error happened God knows where, so silently return
                return false;
            }

            //user confirmed for deletion, so go on!!
            //first delete from reportedgases lists
            var gasToBeRemoved = $scope.instance.FGasesReporting.ReportedGases.splice(index, 1);//returns array
            if ($scope.containsHFC(gasToBeRemoved)) {
                $scope.filteredReportedGasesForHFCLength--;
            }

            //and then continue for gas amounts
            for (var i = 0; i < $scope.gasIncludingElements.length; i++) {
                var element = $scope.gasIncludingElements[i];
                //if we always keep same order, then we dont need to search for gas code, so simply slice array
                $scope.instance.FGasesReporting[element].Gas.splice(index, 1);
            }
            
            $scope.refreshValidations();
            
            return true;
        };// end of function removeGasFromReportedGases

        //utility function to check if a fas is unspecified mix or not
        $scope.isUnspecifiedMix = function (reportedGas) {
            if (reportedGas.GasId) {
                return reportedGas.GasId == FormConstants.UnspecifiedGasMixId;
            }
            return false;
        };// end of function isUnspecifiedMix

        //synchronises selected gases with reported gases, also form inputs are updated
        $scope.gasSelectionChanged = function (gasGroup) {
            //create copy of gasIds
            var gasIdsCopy = angular.copy($scope.instance.FGasesReporting.GeneralReportData[gasGroup].GasName);
            //create copy of gasIds before change
            var previousGasIdsCopy = angular.copy($scope.selectedGasIds[gasGroup]);

            var unspecifiedMixIndex = gasIdsCopy.indexOf(FormConstants.UnspecifiedGasMixId);
            //!($scope.instance.FGasesReporting.GeneralReportData.Activities['I'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['E'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['D'])
            if (unspecifiedMixIndex >= 0) {
                if (!($scope.instance.FGasesReporting.GeneralReportData.Activities['I'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['E'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['D'])) {
                    alert('Quantities of an unspecified mix of F-gases can only be reported for destruction, import for destruction or export for destruction. Before selecting this gas, please first select "Destruction company", "Importer" and/or "Exporter" in the activity selection.');
                    gasIdsCopy.splice(unspecifiedMixIndex, 1);
                    $scope.instance.FGasesReporting.GeneralReportData[gasGroup].GasName.splice(unspecifiedMixIndex, 1);
                }
                else {
                    var msg = $translate.instant('gases.discourage-unspecified-mix-msg');
                    messageBox.confirm(msg, function(accept) {
                        if (!accept) {
                            return;
                        }
                        
                        gasIdsCopy.splice(unspecifiedMixIndex, 1);
                        $scope.instance.FGasesReporting.GeneralReportData[gasGroup].GasName.splice(unspecifiedMixIndex, 1);
                        var predefinedMixtureList = arrayUtil.select($scope.codeList.FGasesCodelists.FGases.Gas, function(item) {
                            return item.IsShortlisted;
                        });
                        var existingCustomMixtures = arrayUtil.select($scope.instance.FGasesReporting.ReportedGases, function(item) {
                            return item.IsCustomComposition;
                        });
                        modalAdapter.open($scope, 'lg', 'MixtureDefinitionModalContent.html', 'MixtureDefinitionModalInstanceController', 
                                            null, $scope.mixtureEditModalWindowCloseCallBack, $scope.mixtureEditModalWindowCloseCallBack, {
                            preDefinedMixtureList: predefinedMixtureList, 
                            existingCustomMixtures: existingCustomMixtures
                        });
                    });
                }
            }

            var j = gasIdsCopy.length;
            while (j--) {
                var foundIndex = previousGasIdsCopy.indexOf(gasIdsCopy[j]);
                if (foundIndex >= 0) {
                    gasIdsCopy.splice(j, 1);
                    previousGasIdsCopy.splice(foundIndex, 1);
                }
            }

            if (previousGasIdsCopy.length > 0) {
                //delete from list
                for (var i = 0; i < previousGasIdsCopy.length; i++) {
                    var gasId = previousGasIdsCopy[i];

                    //find reported gas
                    j = 0;
                    for (; j < $scope.instance.FGasesReporting.ReportedGases.length &&
                            $scope.instance.FGasesReporting.ReportedGases[j].GasId != gasId;
                            j++) {
                    }

                    if (j < $scope.instance.FGasesReporting.ReportedGases.length && !$scope.removeGasFromReportedGases(j)) {
                        //user does not confirm, add it back to list
                        $scope.instance.FGasesReporting.GeneralReportData[gasGroup].GasName.push(gasId);
                    }
                }
            } else if (gasIdsCopy.length > 0) {
                //add new values
                for (var i = 0; i < gasIdsCopy.length; i++) {
                    var gasId = gasIdsCopy[i];

                    //Check if gas is in confirmation list, if it is then ask for confirmation to keep value
                    var confirmationListIndex = FormConstants.ToBeConfirmedGasesIds.indexOf(gasId);
                    if (confirmationListIndex > -1) {
                        var gas = FormConstants.ToBeConfirmedGasesCodes[confirmationListIndex];
                        var gasA = FormConstants.ToBeConfirmedGasesCodesA[confirmationListIndex];
                        var msg = "Caution: Please make sure you don't confuse " + gas + " with the more commonly used " + gasA + " Continue with selection of " + gas + "?"
                        if (!confirm(msg)) {
                            var indexInIdsList = gasIdsCopy.indexOf(gasId);
                            gasIdsCopy.splice(indexInIdsList, 1);
                            // also inform the model
                            var hfcGasNameIndex = $scope.instance.FGasesReporting.GeneralReportData.HFCs.GasName.indexOf(gasId);
                            if(hfcGasNameIndex > -1) {
                                $scope.instance.FGasesReporting.GeneralReportData.HFCs.GasName.splice(hfcGasNameIndex, 1);
                            }
                            continue;
                        }
                    }

                    //when found, copy of gas from list is set (instead of direct reference assignment)
                    var gasFromList = null;
                    for (j = 0; j < $scope.codeList.FGasesCodelists.FGases.Gas.length; j++) {
                        if (gasId == $scope.codeList.FGasesCodelists.FGases.Gas[j].GasId) {
                            gasFromList = angular.copy($scope.codeList.FGasesCodelists.FGases.Gas[j]);
                            break;
                        }
                    }

                    var reportedGas = {};
                    reportedGas.GasGroup = gasFromList.GasGroupName;
                    reportedGas.GasGroupId = gasFromList.GasGroupId;
                    reportedGas.GasId = gasFromList.GasId;
                    reportedGas.Code = gasFromList.Code;
                    reportedGas.Name = gasFromList.Name;
                    reportedGas.IsBlend = gasFromList.IsBlend;
                    //IsCustomComposition field is used to determine if a gas is created by user during reporting session
                    reportedGas.IsCustomComposition = false; //gasFromList.IsCustom;
                    reportedGas.PreparationCompositions = gasFromList.IsBlend ? gasFromList.BlendComposition : null;
                    reportedGas.GWP_AR4_AnnexIV = gasFromList.GWP_AR4_AnnexIV;
                    reportedGas.GWP_AR4_HFC = gasFromList.GWP_AR4_HFC;
                    reportedGas.BlendComponents = {};
                    reportedGas.BlendComponents.Component = [];

                    //Note: very very interestingly, code below causes multiselect to close if gasFromList is used by reference.
                    //But if gasdFromList is used by value (aka, cloned into new variable) then magic occurs.

                    //if it is not defined then just add an empty list.
                    if (!angular.isDefined(gasFromList.BlendComponents.Component)) {
                        gasFromList.BlendComponents.Component = [];
                    }

                    if (!angular.isArray(gasFromList.BlendComponents.Component)) {
                        gasFromList.BlendComponents.Component = [gasFromList.BlendComponents.Component];
                    }

                    //iterate over components
                    for (j = 0; j < gasFromList.BlendComponents.Component.length; j++) {
                        var component = {};
                        component.GasGroupId = gasFromList.BlendComponents.Component[j].GasGroupId;
                        component.GasGroup = gasFromList.BlendComponents.Component[j].GasGroupName;
                        component.ComponentId = gasFromList.BlendComponents.Component[j].ComponentId;
                        component.Code = gasFromList.BlendComponents.Component[j].Code;
                        component.IsOther = component.ComponentId === FormConstants.OtherComponentId;
                        component.Percentage = gasFromList.BlendComponents.Component[j].Percentage;
                        component.GWP_AR4_AnnexIV = gasFromList.BlendComponents.Component[j].GWP_AR4_AnnexIV;
                        component.GWP_AR4_HFC = gasFromList.BlendComponents.Component[j].GWP_AR4_HFC;
                        reportedGas.BlendComponents.Component.push(component);
                    }

                    //add new gas for reporting
                    $scope.addGasForReporting(reportedGas);
                }
            }

            $scope.selectedGasIds[gasGroup] = angular.copy($scope.instance.FGasesReporting.GeneralReportData[gasGroup].GasName);
        };// end of function gasSelectionChanged

        // function to add new gas to reporting gas array and to forms, see removeGasFromReportedGases for reverse
        $scope.addGasForReporting = function (reportedGas) {
            if (angular.isUndefined(reportedGas) || reportedGas == null) {
                return;
            }

            if ($scope.instance.FGasesReporting.ReportedGases == null || $scope.instance.FGasesReporting.ReportedGases.length == null) {
                $scope.instance.FGasesReporting.ReportedGases = [];
            }

            //add new gas to reported gases
            $scope.instance.FGasesReporting.ReportedGases.push(reportedGas);
            var lastIndex = $scope.instance.FGasesReporting.ReportedGases.length - 1;

            //add gas for reporting
            for (j = 0; j < $scope.gasIncludingElements.length; j++) {
                var element = $scope.gasIncludingElements[j];
                $scope.addItem('FGasesReporting.' + element + '.Gas');
                //var lastIndex = $scope.instance.FGasesReporting[element].Gas.length - 1;
                $scope.instance.FGasesReporting[element].Gas[lastIndex].GasCode = reportedGas.GasId;
                var tradePartnerElement = $scope.tradePartnerElements[element];
                if (angular.isDefined(tradePartnerElement)) {
                    if (!angular.isArray(tradePartnerElement)) {
                        tradePartnerElement = [tradePartnerElement];
                    }

                    //check for trading partners
                    for (var k = 0; k < tradePartnerElement.length; k++) {
                        $scope.instance.FGasesReporting[element].Gas[lastIndex][tradePartnerElement[k]].TradePartner = [];

                        var tradePartnerDefinitionElement = tradePartnerElement[k] + '_TradePartners';
                        //if it has defined trade partners add them as well
                        if ($scope.instance.FGasesReporting[element][tradePartnerDefinitionElement] && $scope.instance.FGasesReporting[element][tradePartnerDefinitionElement].Partner) {
                            var tradePartnersForElement = $scope.instance.FGasesReporting[element][tradePartnerDefinitionElement].Partner;
                            if (!angular.isArray(tradePartnersForElement)) {
                                tradePartnersForElement = [tradePartnersForElement];
                            }
                            for (var n = 0; n < tradePartnersForElement.length; n++) {
                                var copyOfEmptyInstance = clone($scope.emptyInstance.FGasesReporting[element].Gas[tradePartnerElement[k]].TradePartner);
                                copyOfEmptyInstance.TradePartnerID = tradePartnersForElement[n].PartnerId;
                                $scope.instance.FGasesReporting[element].Gas[lastIndex][tradePartnerElement[k]].TradePartner.push(copyOfEmptyInstance);
                            }
                        }
                    }
                }
            }

            if ($scope.containsHFC(reportedGas)) {
                $scope.filteredReportedGasesForHFCLength++;
            }
            
            $scope.tryApplyStockValues(reportedGas);
        };// end of function addGasForReporting

        $scope.tryApplyStockValues = function(reportedGas, forceOverwrite) {
            if (viewModel.sheet1.section4.applyStockValues(reportedGas, forceOverwrite)) {
                $scope.reCalculateSheet1();
                $notification.info("", $translate.instant("common.stocks-auto-import-info", {
                    gasName: reportedGas.Name
                }));
            }
        };

        //Callback function for mixture edit modal window
        $scope.mixtureEditModalWindowCloseCallBack = function (results) {
            if (results.index > -1) {
                $scope.instance.FGasesReporting.ReportedGases.splice(results.index, 1, results.mixture);
            } else {
                $scope.addGasForReporting(results.mixture);
            }
        };//end of function mixtureEditModalWindowCloseCallBack

        //Callback function for trading partner modal window
        $scope.tradingPartnerModalWindowCloseCallBack = function (results) {
            if (results.index > -1) {
                results.modalExtras.arrayToPush.splice(results.index, 1, results.tempPartnerDefinition);
            } else {
                results.modalExtras.arrayToPush.push(results.tempPartnerDefinition);
                if (results.modalExtras.emptyInstancePath) {
                    var copyOfEmptyInstance = clone($scope.getInstanceByPath('emptyInstance', results.modalExtras.emptyInstancePath));
                    copyOfEmptyInstance.TradePartnerID = results.tempPartnerDefinition.PartnerId;
                    for (var i = 0; i < results.modalExtras.gasArray.length; i++) {
                        results.modalExtras.gasArray[i][results.modalExtras.fieldName].TradePartner.push(clone(copyOfEmptyInstance));
                    }
                }
            }
        };//end of function tradingPartnerModalWindowCloseCallBack

        $scope.tradingPartnerModalWindowCloseCallBackForSheet5 = function (results) {
            $scope.tradingPartnerModalWindowCloseCallBack(results);
            $scope.createSumsArrayItem(results.tempPartnerDefinition.PartnerId);
            $scope.createNewSupportingDocument(results.tempPartnerDefinition.PartnerId);
        };

        //Callback function for trading partner modal window for non gas forms
        $scope.tradingPartnerModalWindowCloseCallBackForNonGasForm = function (results) {
            if (results.index > -1) {
                results.modalExtras.arrayToPush.splice(results.index, 1, results.tempPartnerDefinition);
            } else {
                results.modalExtras.arrayToPush.push(results.tempPartnerDefinition);
                if (results.modalExtras.emptyInstancePath) {
                    var copyOfEmptyInstance = clone($scope.getInstanceByPath('emptyInstance', results.modalExtras.emptyInstancePath));
                    copyOfEmptyInstance.TradePartnerID = results.tempPartnerDefinition.PartnerId;
                    results.modalExtras.baseElement[results.modalExtras.fieldName].TradePartner.push(clone(copyOfEmptyInstance));
                }
            }
        };//end of function tradingPartnerModalWindowCloseCallBackForNonGasForm

        // Remove row from ng-repeat.
        $scope.remove = function (array, index, rowElement, showConfirmation) {
            //console.log(rowElement);
            //console.log(countNonEmptyProperties(rowElement));
            showConfirmation = typeof showConfirmation !== 'undefined' ? showConfirmation : false;
            if (showConfirmation && countNonEmptyProperties(rowElement) > 0) {
                if (!confirm('Are you sure you want to delete the data in this row?')) {
                    return;
                }
            }
            array.splice(index, 1);
        };

        $scope.removeTradingPartnerAndUpdateCalculations = function (form, rootArray, index, gasRow, fieldsToBeUpdated) {
            var tradingPartner = $scope.instance.FGasesReporting[form][rootArray].Partner[index];
            //TODO localization
            if (confirm("Do you want to delete Trading Partner '" + tradingPartner.CompanyName + "' ?")) {
                //first remove from root array where trading partner info is stored
                $scope.remove($scope.instance.FGasesReporting[form][rootArray].Partner, index, tradingPartner);

                //then remove from all gases and re-calculate
                for (var i = 0; i < $scope.instance.FGasesReporting[form].Gas.length; i++) {
                    var row = $scope.instance.FGasesReporting[form].Gas[i][gasRow];
                    $scope.remove(row.TradePartner, index, row.TradePartner[index]);
                    $scope.calculateTradingPartnerTotalAmount(row);
                    $scope.doCalculationForFields(i, fieldsToBeUpdated);
                }
            }
        }; //end of function removeTradingPartnerAndUpdateCalculations

        //almost same as method above, but used in form4, since it has different structure. Actually form4 could have been designed to include one gas.
        $scope.removeTradingPartner = function (form, rootArray, index, gasRow, skipConfirmation) {
            var tradingPartner = $scope.instance.FGasesReporting[form][rootArray].Partner[index];
            if (skipConfirmation || confirm("Do you want to delete Trading Partner '" + tradingPartner.CompanyName + "' ?")) {
                //first remove from root array where trading partner info is stored
                $scope.remove($scope.instance.FGasesReporting[form][rootArray].Partner, index, tradingPartner);

                //then remove from row
                var row = $scope.instance.FGasesReporting[form][gasRow];
                $scope.remove(row.TradePartner, index, row.TradePartner[index]);
                $scope.calculateTradingPartnerTotalAmount(row);
            }
        }; //end of function removeTradingPartner

        //--- Starting from this point function definitions and variables are used for calculations for gases in a COLUMN (see: Sheet1 for examples)
        // Utilty function which returns valid value for reported element
        $scope.getValueForReportedGasAmount = function (gasRow) {
            var retval = gasRow.Amount ? gasRow.Amount : (gasRow.SumOfPartnerAmounts ? gasRow.SumOfPartnerAmounts : 0.0);
            retval = isEmpty(retval) || isNaN(retval) ? 0.0 : parseFloat(retval);
            return retval;
        };// end of function getValueForReportedGasAmount

        // function to find a gas element for given column and row
        $scope.getGasElementFor = function (gasColumn, gasRow) {
            for (var i = 0; i < $scope.gasIncludingElements.length; i++) {
                var elem = $scope.gasIncludingElements[i];
                if (angular.isArray($scope.instance.FGasesReporting[elem].Gas)) {
                    var column = $scope.instance.FGasesReporting[elem].Gas[gasColumn];
                    if (angular.isDefined(column[gasRow]) && column[gasRow]) {
                        return column[gasRow];
                    }
                }
            }
            return null;
        };// end of function getGasElementFor

        // function to find a value of a gas element for given column and row
        $scope.getValueForReportedGasAmountFrom = function (gasColumn, gasRow) {
            var retVal = $scope.getGasElementFor(gasColumn, gasRow);
            if (retVal) {
                retVal = $scope.getValueForReportedGasAmount(retVal);
            } else {
                retVal = 0.0;
            }
            return retVal
        };// end of function getValueForReportedGasAmountFrom

        // Gas calculation operator definitions
        $scope.gasCalculationOperators = {
            "+": function (a, b) {
                return a + b
            },
            "-": function (a, b) {
                return a - b
            }
        };// end of operator definition for gas calculations

        //TODO solution can be updated for fields and affecting fields. Further improvement.
        // Variable to stores formulas. Since all row has unique identifiers, we don't need to keep hierarchical key
        $scope.formulasForRows = {
            'tr_01D': {'formula': ['tr_01B', '+', 'tr_01C'], 'dependents': 'tr_01E'},
            'tr_01E': {'formula': ['tr_01A', '-', 'tr_01D'], 'dependents': ['tr_04M', 'tr_06X']},
            'tr_01H': {'formula': ['tr_01F', '-', 'tr_01G']},
            'tr_01K': {'formula': ['tr_01A', '-', 'tr_01B', '-', 'tr_01C', '+', 'tr_01I', '+', 'tr_02A', '-', 'tr_03A', '+', 'tr_04A', '-', 'tr_04F', '-', 'tr_07A']},
            'tr_03C': {'formula': ['tr_03A', '-', 'tr_03B']},
            'tr_04D': {'formula': ['tr_04B', '-', 'tr_04C']},
            'tr_04E': {'formula': ['tr_04A', '-', 'tr_04B']},
            'tr_04I': {'formula': ['tr_04G', '-', 'tr_04H']},
            'tr_04J': {'formula': ['tr_04F', '-', 'tr_04G']},
            'tr_04M': {'formula': ['tr_01E', '+', 'tr_02A', '-', 'tr_02B', '-', 'tr_03B', '+', 'tr_04C', '-', 'tr_04H'], 'dependents': 'tr_05H'},
            'tr_05G': {'formula': ['tr_05A', '+', 'tr_05B', '+', 'tr_05C', '+', 'tr_05D', '+', 'tr_05E', '+', 'tr_05F'], 'dependents': 'tr_05I'},
            'tr_05H': {'formula': ['tr_04M'], 'dependents': 'tr_05J'},
            'tr_05I': {'formula': ['tr_05G', '-', 'tr_05F'], 'dependents': 'tr_05J'},
            'tr_05J': {'formula': ['tr_05H', '-', 'tr_05I']},
            'tr_06W': {'formula': ['tr_06A', '+', 'tr_06B', '+', 'tr_06C', '+', 'tr_06D', '+', 'tr_06E', '+', 'tr_06F', '+', 'tr_06G', '+', 'tr_06H', '+', 'tr_06I', '+', 'tr_06J', '+', 'tr_06K', '+', 'tr_06L', '+', 'tr_06M', '+', 'tr_06N', '+', 'tr_06O', '+', 'tr_06P', '+', 'tr_06Q', '+', 'tr_06R', '+', 'tr_06S', '+', 'tr_06T', '+', 'tr_06U', '+', 'tr_06V']},
            'tr_06X': {'formula': ['tr_01E', '+', 'tr_02A', '-', 'tr_02B', '-', 'tr_03B', '+', 'tr_04B', '-', 'tr_04G', '+', 'tr_04K']},
            'tr_08D': {'formula': ['tr_08A', '+', 'tr_08B', '+', 'tr_08C']},
            'tr_11A': {'formula': ['tr_11A01', '+', 'tr_11A02', '+', 'tr_11A03', '+', 'tr_11A04', '+', 'tr_11A05', '+', 'tr_11A06', '+', 'tr_11A07', '+', 'tr_11A08', '+', 'tr_11A09', '+', 'tr_11A10', '+', 'tr_11A11', '+', 'tr_11A12', '+', 'tr_11A13', '+', 'tr_11A14'], 'dependents': ['tr_11G', 'tr_11Q']},
            'tr_11B': {'formula': ['tr_11B01', '+', 'tr_11B02', '+', 'tr_11B03', '+', 'tr_11B04', '+', 'tr_11B05', '+', 'tr_11B06', '+', 'tr_11B07', '+', 'tr_11B08', '+', 'tr_11B09', '+', 'tr_11B10', '+', 'tr_11B11', '+', 'tr_11B12', '+', 'tr_11B13', '+', 'tr_11B14'], 'dependents': ['tr_11G', 'tr_11Q']},
            'tr_11D': {'formula': ['tr_11D01', '+', 'tr_11D02', '+', 'tr_11D03'], 'dependents': ['tr_11G', 'tr_11Q']},
            'tr_11E': {'formula': ['tr_11E01', '+', 'tr_11E02', '+', 'tr_11E03', '+', 'tr_11E04'], 'dependents': ['tr_11G', 'tr_11Q']},
            'tr_11F': {'formula': ['tr_11F01', '+', 'tr_11F02', '+', 'tr_11F03', '+', 'tr_11F04', '+', 'tr_11F05', '+', 'tr_11F06', '+', 'tr_11F07', '+', 'tr_11F08', '+', 'tr_11F09'], 'dependents': ['tr_11G', 'tr_11Q']},
            'tr_11G': {'formula': ['tr_11A', '+', 'tr_11B', '+', 'tr_11C', '+', 'tr_11D', '+', 'tr_11E', '+', 'tr_11F']},
            'tr_11H': {'formula': ['tr_11H01', '+', 'tr_11H02', '+', 'tr_11H03', '+', 'tr_11H04'], 'dependents': ['tr_11Q']},
            'tr_11Q': {'formula': ['tr_11G', '+', 'tr_11H', '+', 'tr_11I', '+', 'tr_11J', '+', 'tr_11K', '+', 'tr_11L', '+', 'tr_11M', '+', 'tr_11N', '+', 'tr_11O', '+', 'tr_11P']}
        };// end of formula definition


        // Function to do calculations in a gas column for given fields, it depends on formulas map
        $scope.doCalculationForFields = function (gasIndex, fields, calculateDependencies) {
            //default value for calculating dependencies is true, for cases where recursion wont end, false should be set
            calculateDependencies = typeof calculateDependencies !== "undefined" ? calculateDependencies : true;

            //check for array definition and if not convert it
            if (!angular.isArray(fields)) {
                fields = [fields];
            }

            for (var i = 0; i < fields.length; i++) {
                var destinationObject = fields[i];
                var formula = $scope.formulasForRows[destinationObject];
                $scope.doCalculationForGas(gasIndex, destinationObject, formula);
                if (calculateDependencies && angular.isDefined(formula.dependents)) {
                    var dependents = angular.isArray(formula.dependents) ? formula.dependents : [formula.dependents];
                    for (var j = 0; j < dependents.length; j++) {
                        $scope.doCalculationForFields(gasIndex, dependents[j]);
                    }
                }
            }
        };// end of function doCalculationForFields

        // Function to calculate a formula
        $scope.doCalculationForGas = function (gasIndex, destinationRow, formulaDefinition) {
            var formula = formulaDefinition.formula;
            var result = $scope.getValueForReportedGasAmountFrom(gasIndex, formula[0]);
            
            if (formula.length > 2) {
                //it is more than just assignment, so calculate value
                var b = $scope.getValueForReportedGasAmountFrom(gasIndex, formula[2]);
                result = $scope.gasCalculationOperators[formula[1]](result, b);

                for (var i = 3; i < formula.length; i += 2) {
                    b = $scope.getValueForReportedGasAmountFrom(gasIndex, formula[i + 1]);
                    result = $scope.gasCalculationOperators[formula[i]](result, b);
                }
            }
            
            if (!objectUtil.isNull(formulaDefinition.coersion)) {
                result = formulaDefinition.coersion(result);
            }

            result = parseFloat(result).toFixed(3);
            var destinationObject = $scope.getGasElementFor(gasIndex, destinationRow);
            if (destinationObject && angular.isDefined(destinationObject.Amount)) {
                destinationObject.Amount = result;
            } else if (destinationObject && angular.isDefined(destinationObject.SumOfPartnerAmounts)) {
                destinationObject.SumOfPartnerAmounts = result;
            }
        };// end of function doCalculationForGas

        // Calculates sum value for trading partner
        $scope.calculateTradingPartnerTotalAmount = function (tradingPartnerElement) {
            var sum = $scope.calculateTradingPartnerSum(tradingPartnerElement);
            tradingPartnerElement.SumOfPartnerAmounts = parseFloat(sum).toFixed(3);
        };// end of function calculateTradingPartnerTotalAmount
        
        $scope.calculateTradingPartnerTotalAmountInteger = function (tradingPartnerElement) {
            var sum = $scope.calculateTradingPartnerSum(tradingPartnerElement);
            tradingPartnerElement.SumOfPartnerAmounts = parseFloat(sum).toFixed(0);
        };// end of function calculateTradingPartnerTotalAmountInteger

        $scope.calculateTradingPartnerSum = function(tradingPartnerElement) {
            var sum = 0;
            
            for (var i = 0; i < tradingPartnerElement.TradePartner.length; i++) {
                var val = (isEmpty(tradingPartnerElement.TradePartner[i].amount) || isNaN(tradingPartnerElement.TradePartner[i].amount)) ? 0.0 : parseFloat(tradingPartnerElement.TradePartner[i].amount);
                sum += val;
            }
            
            return sum;
        };// end of function calculateTradingPartnerTotalAmount

        // Define calculation types for row 'Totals'
        $scope.calculationTypesForRow = ['SumAllGases', 'SumAllGasesCO2Eq'];

     // function to sum all amounts
        $scope.calculateSumAllGases = function (gasArray) {
            var sum = 0.0;
            for (var i = 0; i < gasArray.length; i++) {
                if (gasArray[i].Amount != null) {
                    sum += gasArray[i].Amount;
                }
            }
            return parseFloat(sum).toFixed(3);
        };// end of function calculateSumAllGases
        
        //function to sum all gases amounts with coeefficients
        $scope.calculateSumAllGasesCO2Eq = function (gasArray) {
            var sum = 0.0;
            for (var i = 0; i < gasArray.length; i++) {
                var gasArrayItem = gasArray[i];
                var gas = arrayUtil.selectSingle($scope.instance.FGasesReporting.ReportedGases, function(reportedGas) { 
                    return reportedGas.GasId === gasArrayItem.Id;
                });
                var weightedGWP = parseFloat(gas.GWP_AR4_AnnexIV);
                if (typeof weightedGWP === 'undefined' || weightedGWP == null) {
                    weightedGWP = parseFloat(getWeightedGWP(gas.BlendComponents.Component));
                }
                if (isNaN(weightedGWP)) {
                    weightedGWP = 0;
                }
                if (gasArrayItem.Amount != null) {
                    sum += weightedGWP * gasArrayItem.Amount;
                }
            }
            return Math.round(parseFloat(sum));
        };// end of function calculateSumAllGasesCO2Eq

        //function to sum all gases amounts with coeefficients (HFC)
        $scope.calculateSumAllHFCGasesCO2Eq = function (gasArray) {
            var sum = 0.0;
            for (var i = 0; i < gasArray.length; i++) {
                var gasArrayItem = gasArray[i];
                var gas = arrayUtil.selectSingle($scope.instance.FGasesReporting.ReportedGases, function(reportedGas) { 
                    return reportedGas.GasId === gasArrayItem.Id;
                });
                var weightedGWP = null; // force calculation of Full HFC GWP
                if (typeof weightedGWP === 'undefined' || weightedGWP == null) {
                    weightedGWP = parseFloat(getWeightedFullHfcGwp(gas.BlendComponents.Component));
                }
                if (isNaN(weightedGWP)) {
                    weightedGWP = 0;
                }
                if (gasArrayItem.Amount != null) {
                    sum += weightedGWP * gasArrayItem.Amount;
                }
            }
            return Math.round(parseFloat(sum));
        };// end of function calculateSumAllHFCGasesCO2Eq

        // Calculation type - function map
        $scope.calculationFunctions = {
            'SumAllGases': $scope.calculateSumAllGases,
            'SumAllGasesCO2Eq': $scope.calculateSumAllGasesCO2Eq,
            'SumOfAllHFCsS1': $scope.calculateSumAllGases,
            'SumOfAllHFCsS2': $scope.calculateSumAllGases
        };// end of defining calculation functions map

        // Calculates sum for a given row, form parameter is taken for faster operation.
        //this will work for <xs:element name="Totals">, similar approach can be followed for <xs:element name="SumOfAllHFCsS1"> and so on
        $scope.doCalculationTotalForRow = function (form, gasRow, calculations) {
            //check for calculations, if not set, set for defaults
            calculations = typeof calculations !== 'undefined' ? calculations : $scope.calculationTypesForRow;
            if (!angular.isArray(calculations)) {
                calculations = [calculations];
            }

            var inputArray = [];
            var sourceGases = $scope.instance.FGasesReporting[form].Gas;
            for (var i = 0; i < sourceGases.length; i++) {
                var gas = {};
                gas.Id = sourceGases[i].GasCode;
                gas.Amount = $scope.getValueForReportedGasAmount(sourceGases[i][gasRow]);
                inputArray.push(gas);
            }

            //iterate on each calculation
            for (var i = 0; i < calculations.length; i++) {
                var calculation = calculations[i];
                var destinationObject = gasRow + calculation;
                $scope.instance.FGasesReporting[form].Totals[destinationObject] = $scope.calculationFunctions[calculation](inputArray);
            }
        };// end of function doCalculationTotalForRow

        // Calculates sum for sheet 4 calculated fields, it is not done on the fly.
        $scope.calculateCo2EqForSheet4 = function () {
            var calcs = [
                ['tr_09B', 'F2_S5_exempted_HFCs', 'tr_05H'],
                ['tr_09D', 'F2_S5_exempted_HFCs', 'tr_05I'],
                ['tr_09E', 'F2_S5_exempted_HFCs', 'tr_05J']
            ];

            for (var j = 0; j < calcs.length; j++) {
                var destination = calcs[j][0];
                var form = calcs[j][1];
                var gasRow = calcs[j][2];

                var inputArray = [];
                var sourceGases = $scope.instance.FGasesReporting[form].Gas;
                for (var i = 0; i < sourceGases.length; i++) {
                    var gas = {};
                    gas.Id = sourceGases[i].GasCode;
                    gas.Amount = $scope.getValueForReportedGasAmount(sourceGases[i][gasRow]);
                    inputArray.push(gas);
                }
                //$scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata[destination].Amount = $scope.calculateSumAllGasesCO2Eq(inputArray);
                $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata[destination].Amount = $scope.calculateSumAllHFCGasesCO2Eq(inputArray);
            }

            //now calculate 9a dependents
            $scope.calculate9ADependingFields();
        };// end of function calculateCo2EqForSheet4

        $scope.calculate9ADependingFields = function () {
            var section9Data = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata;
            $scope.calculateTradingPartnerTotalAmountInteger(section9Data.tr_09A_add);
            section9Data.tr_09A.SumOfPartnerAmounts = $scope.getValueForReportedGasAmount(section9Data.tr_09A_imp) + $scope.getValueForReportedGasAmount(section9Data.tr_09A_add);
            $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09C.Amount = $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09B) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A);
            $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09F.Amount = $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09E) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A);
        };//end of function calculate9ADependingFields

        $scope.onTr07AChange = function(gasIndex) {
            $scope.doCalculationTotalForRow('F6_FUDest', 'tr_07A');
            
            
            if (viewModel.sheetActivities.isP() || viewModel.sheetActivities.isI() || viewModel.sheetActivities.isE()) {
                $scope.doCalculationForFields(gasIndex, ['tr_01K']);
            }
        };

        //TODO row sum calculation can be done as dependents to one another
        // Define calculation types for row 'Totals'
        $scope.calculationTypesForRowSheet2 = ['SumOfAllHFCsS1', 'SumOfAllHFCsS2'];
        //TODO this can be merged with upper solution after implementation is done
        // Calculates sum for a given row, form parameter is taken for faster operation.
        //this will work for <xs:element name="Totals">, similar approach can be followed for <xs:element name="SumOfAllHFCsS1"> and so on
        $scope.doCalculationTotalForRowForSheet2 = function (form, gasRows, calculations) {
            //check for calculations, if not set, set for defaults
            calculations = typeof calculations !== 'undefined' ? calculations : $scope.calculationTypesForRowSheet2;
            if (!angular.isArray(calculations)) {
                calculations = [calculations];
            }

            if (!angular.isArray(gasRows)) {
                gasRows = [gasRows];
            }

            for (var j = 0; j < gasRows.length; j++) {
                var gasRow = gasRows[j];

                //TODO change it to an array
                var inputArray = [];
                var sourceGases = $scope.instance.FGasesReporting[form].Gas;
                for (var i = 0; i < sourceGases.length; i++) {
                    var gas = {};
                    gas.Id = sourceGases[i].GasCode;
                    gas.Amount = $scope.getValueForReportedGasAmount(sourceGases[i][gasRow]);
                    inputArray.push(gas);
                }

                //iterate on each calculation
                for (var i = 0; i < calculations.length; i++) {
                    var calculation = calculations[i];
                    var destinationObject = gasRow;
                    $scope.instance.FGasesReporting[form][calculation][destinationObject] = $scope.calculationFunctions[calculation](inputArray);
                }
            }
        };// end of function doCalculationTotalForRowForSheet2

        // delegator function for scope
        $scope.containsHFC = function (gasOrComponent) {
            return containsHFCUtilFn(gasOrComponent) || $scope.isUnspecifiedMix(gasOrComponent);
        };// delegator function for scope

        //utility function to check if validation message has valid gas index
        $scope.validGasIndexForValidationMessage = function (validationMessage) {
            if (validationMessage && angular.isDefined(validationMessage.gasIndex) && validationMessage.gasIndex != null && validationMessage.gasIndex >= 0) {
                return true;
            }
            return false;
        };// end of function validGasIndexForValidationMessage

        //utility function to check if validation message has valid trader partner id
        $scope.validTradePartnerForValidationMessage = function (validationMessage) {
            if (validationMessage && angular.isDefined(validationMessage.tradePartnerId) && validationMessage.tradePartnerId != null && validationMessage.tradePartnerId) {
                return true;
            }
            return false;
        };// end of function validTradePartnerForValidationMessage

        $scope.goToValidationMessageCause = function (validationMessage) {
            var id = validationMessage.transaction;

            if ($scope.validGasIndexForValidationMessage(validationMessage)) {
                id += '_' + $scope.instance.FGasesReporting.ReportedGases[validationMessage.gasIndex].GasId;
            }
            /*
             * nakasnik: commented this part out as it is has no use: the html element ids created in 
             * the markup do not contain that piece of info (trade partner id) in any case, so setting this variable is not only useless,
             * but it will additionally create miss-matches that will break message id clicking functionality.
             * 
            if ($scope.validTradePartnerForValidationMessage(validationMessage)) {
                id += '_' + validationMessage.tradePartnerId;
            }
            */
            var old = $location.hash();
            $timeout(function () {
                $location.hash(id);
                $anchorScroll();
                focus(id);
                $location.hash(old);
            }, 200);
        }; //end of function goToValidationMessageCause

        $scope.form7transactions =
                [
                    'tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14',
                    'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14',
                    'tr_11C',
                    'tr_11D01', 'tr_11D02', 'tr_11D03',
                    'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04',
                    'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09',
                    'tr_11G',
                    'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04',
                    'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q'
                ];
        $scope.form7transactionLabels =
                [
                    'tr_11a1', 'tr_11a2', 'tr_11a3', 'tr_11a4', 'tr_11a5', 'tr_11a6', 'tr_11a7', 'tr_11a8', 'tr_11a9', 'tr_11a10', 'tr_11a11', 'tr_11a12', 'tr_11a13', 'tr_11a14',
                    'tr_11b1', 'tr_11b2', 'tr_11b3', 'tr_11b4', 'tr_11b5', 'tr_11b6', 'tr_11b7', 'tr_11b8', 'tr_11b9', 'tr_11b10', 'tr_11b11', 'tr_11b12', 'tr_11b13', 'tr_11b14',
                    'tr_11c',
                    'tr_11d1', 'tr_11d2', 'tr_11d3',
                    'tr_11e1', 'tr_11e2', 'tr_11e3', 'tr_11e4',
                    'tr_11f1', 'tr_11f2', 'tr_11f3', 'tr_11f4', 'tr_11f5', 'tr_11f6', 'tr_11f7', 'tr_11f8', 'tr_11f9',
                    'tr_11g',
                    'tr_11h1', 'tr_11h2', 'tr_11h3', 'tr_11h4',
                    'tr_11i', 'tr_11j', 'tr_11k', 'tr_11l', 'tr_11m', 'tr_11n', 'tr_11o', 'tr_11p', 'tr_11q'
                ];

        $scope.form7activityLabels = {
            'tr_11A01': 'tr_11a1', 'tr_11A02': 'tr_11a2', 'tr_11A03': 'tr_11a3', 'tr_11A04': 'tr_11a4',
            'tr_11A05': 'tr_11a5', 'tr_11A06': 'tr_11a6', 'tr_11A07': 'tr_11a7', 'tr_11A08': 'tr_11a8',
            'tr_11A09': 'tr_11a9', 'tr_11A10': 'tr_11a10', 'tr_11A11': 'tr_11a11', 'tr_11A12': 'tr_11a12', 'tr_11A13': 'tr_11a13', 'tr_11A14': 'tr_11a14',
            'tr_11B01': 'tr_11b1', 'tr_11B02': 'tr_11b2', 'tr_11B03': 'tr_11b3', 'tr_11B04': 'tr_11b4', 'tr_11B05': 'tr_11b5', 'tr_11B06': 'tr_11b6', 'tr_11B07': 'tr_11b7',
            'tr_11B08': 'tr_11b8', 'tr_11B09': 'tr_11b9', 'tr_11B10': 'tr_11b10', 'tr_11B11': 'tr_11b11', 'tr_11B12': 'tr_11b12', 'tr_11B13': 'tr_11b13', 'tr_11B14': 'tr_11b14',
            'tr_11C': 'tr_11c',
            'tr_11D01': 'tr_11d1', 'tr_11D02': 'tr_11d2', 'tr_11D03': 'tr_11d3',
            'tr_11E01': 'tr_11e1', 'tr_11E02': 'tr_11e2', 'tr_11E03': 'tr_11e3', 'tr_11E04': 'tr_11e4',
            'tr_11F01': 'tr_11f1', 'tr_11F02': 'tr_11f2', 'tr_11F03': 'tr_11f3', 'tr_11F04': 'tr_11f4', 'tr_11F05': 'tr_11f5', 'tr_11F06': 'tr_11f6', 'tr_11F07': 'tr_11f7', 'tr_11F08': 'tr_11f8', 'tr_11F09': 'tr_11f9',
            'tr_11G': 'tr_11g',
            'tr_11H01': 'tr_11h1', 'tr_11H02': 'tr_11h2', 'tr_11H03': 'tr_11h3', 'tr_11H04': 'tr_11h4',
            'tr_11I': 'tr_11i', 'tr_11J': 'tr_11j', 'tr_11K': 'tr_11k', 'tr_11L': 'tr_11l', 'tr_11M': 'tr_11m', 'tr_11N': 'tr_11n', 'tr_11O': 'tr_11o', 'tr_11P': 'tr_11p', 'tr_11Q': 'tr_11q'
        };

        $scope.confirmTransactions = function () {
            $scope.instance.FGasesReporting.F7_s11EquImportTable.transactionsConfirmed = true;
        };

        $scope.unConfirmTransactions = function () {
            $scope.instance.FGasesReporting.F7_s11EquImportTable.transactionsConfirmed = false;
        };

        // All the ranges are in kg, not tonnes!
        $scope.form7specificRanges = {
            'tr_11A01': {'Outside': false, 'QCCode': '2300', 'lower': 0.15, 'upper': 10},
            'tr_11A02': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 100},
            'tr_11A03': {'Outside': false, 'QCCode': '2300', 'lower': 0.15, 'upper': 100},
            'tr_11A04': {'Outside': false, 'QCCode': '2300', 'lower': 3, 'upper': 100},
            'tr_11A05': {'Outside': false, 'QCCode': '2300', 'lower': 0.5, 'upper': 3},
            'tr_11A06': {'Outside': false, 'QCCode': '2300', 'lower': 1.5, 'upper': 100},
            'tr_11A07': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 10},
            'tr_11A08': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 300},
            'tr_11A09': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 300},
            'tr_11A10': {'Outside': false, 'QCCode': '2300', 'lower': 0.5, 'upper': 10},
            'tr_11A11': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 300},
            'tr_11A12': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 300},
            'tr_11A13': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 100},
            'tr_11A14': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 1000},
            'tr_11B01': {'Outside': false, 'QCCode': '2300', 'lower': 0.04, 'upper': 2},
            'tr_11B02': {'Outside': false, 'QCCode': '2300', 'lower': 0.04, 'upper': 10},
            'tr_11B03': {'Outside': false, 'QCCode': '2300', 'lower': 0.04, 'upper': 10},
            'tr_11B04': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B05': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B06': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B07': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B08': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B09': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B10': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B11': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 1000},
            'tr_11B12': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 800},
            'tr_11B13': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 400},
            'tr_11B14': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 800},
            'tr_11C':   {'Outside': false, 'QCCode': '2300', 'lower': 0.15, 'upper': 0.5},
            'tr_11D01': {'Outside': false, 'QCCode': '2300', 'lower': 0.1, 'upper': 100},
            'tr_11D02': {'Outside': false, 'QCCode': '2300', 'lower': 0.1, 'upper': 100},
            'tr_11D03': {'Outside': false, 'QCCode': '2300', 'lower': 0.1, 'upper': 100},
            'tr_11E01': {'Outside': false, 'QCCode': '2300', 'lower': 0.7, 'upper': 13},
            'tr_11E02': {'Outside': false, 'QCCode': '2300', 'lower': 0.8, 'upper': 1.6},
            'tr_11E03': {'Outside': false, 'QCCode': '2300', 'lower': 10, 'upper': 5000},
            'tr_11E04': {'Outside': false, 'QCCode': '2300', 'lower': 0.035, 'upper': 1},
            'tr_11F01': {'Outside': false, 'QCCode': '2300', 'lower': 0.3, 'upper': 1.5},
            'tr_11F02': {'Outside': false, 'QCCode': '2300', 'lower': 7, 'upper': 20},
            'tr_11F03': {'Outside': false, 'QCCode': '2300', 'lower': 0.45, 'upper': 1.5},
            'tr_11F04': {'Outside': false, 'QCCode': '2300', 'lower': 0.7, 'upper': 1.5},
            'tr_11F05': {'Outside': false, 'QCCode': '2300', 'lower': 0.7, 'upper': 2.5},
            'tr_11F06': {'Outside': false, 'QCCode': '2300', 'lower': 5, 'upper': 35},
            'tr_11F07': {'Outside': false, 'QCCode': '2300', 'lower': 0.3, 'upper': 100},
            'tr_11F08': {'Outside': false, 'QCCode': '2300', 'lower': 2, 'upper': 10},
            'tr_11F09': {'Outside': false, 'QCCode': '2300', 'lower': 0.1, 'upper': 100},
            'tr_11H01': {'Outside': false, 'QCCode': '2300', 'lower': 10, 'upper': 100},
            'tr_11H02': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 10},
            'tr_11H03': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 10},
            'tr_11H04_tonnes': {'Outside': false, 'QCCode': '2300', 'lower': 10, 'upper': 100}, // missing
            'tr_11H04_m3': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 10}, // missing
            'tr_11H04_pieces': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 10}, // missing
            'tr_11I': {'Outside': false, 'QCCode': '2300', 'lower': 3, 'upper': 500},
            'tr_11J': {'Outside': false, 'QCCode': '2300', 'lower': 0.007, 'upper': 0.02},
            'tr_11K': {'Outside': false, 'QCCode': '2300', 'lower': 0.05, 'upper': 0.5},
            'tr_11L': {'Outside': false, 'QCCode': '2300', 'lower': 0.01, 'upper': 100}, // missing
            'tr_11M': {'Outside': false, 'QCCode': '2300', 'lower': 1, 'upper': 100},
            'tr_11N': {'Outside': false, 'QCCode': '2300', 'lower': 0.5, 'upper': 500}, // had to swap min, max
            'tr_11O': {'Outside': false, 'QCCode': '2300', 'lower': 0.2, 'upper': 1000},
            'tr_11P_tonnes': {'Outside': false, 'QCCode': '2300', 'lower': 0.01, 'upper': 1000},
            'tr_11P_pieces': {'Outside': false, 'QCCode': '2300', 'lower': 0.01, 'upper': 1000},
            'tr_11P_m3': {'Outside': false, 'QCCode': '2300', 'lower': 0.01, 'upper': 1000}
        };

        // 11HXX and 11PXX are treated as special cases
        $scope.form7specificRangesAutomatic = [
            'tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14',
            'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14',
            'tr_11C', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04',
            'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09',
            'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11M', 'tr_11L', 'tr_11N', 'tr_11O'
        ];



        $scope.form7checkS2Range = function () {
            var tr = '';
            // For regular transactions
            for (var i = 0; i < $scope.form7specificRangesAutomatic.length; i++) {
                tr = $scope.form7specificRangesAutomatic[i];
                $scope.testForm7TransactionS2Range(tr, tr)
            }


            // Testing for tr_11P different options
            // We have to reinitialize all options as the selection might have changed
            tr = '';
            var tr11P = '';
            $scope.form7specificRanges["tr_11P_tonnes"].Outside = false;
            $scope.form7specificRanges["tr_11P_pieces"].Outside = false;
            $scope.form7specificRanges["tr_11P_m3"].Outside = false;

            switch ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit) {
                case 'cubicmetres':
                    tr11P = "tr_11P_m3";
                    break;
                case 'metrictonnes':
                    tr11P = "tr_11P_tonnes";
                    break;
                case 'pieces':
                    tr11P = "tr_11P_pieces";
                    break;
            }
            $scope.testForm7TransactionS2Range("tr_11P", tr11P);

            // Testing for tr_11H04 different options
            var tr11H = '';
            // We have to reinitialize all options as the selection might have changed
            $scope.form7specificRanges["tr_11H04_m3"].Outside = false;
            $scope.form7specificRanges["tr_11H04_tonnes"].Outside = false;
            $scope.form7specificRanges["tr_11H04_pieces"].Outside = false;
            switch ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit) {
                case 'cubicmetres':
                    tr11H = "tr_11H04_m3";
                    break;
                case 'metrictonnes':
                    tr11H = "tr_11H04_tonnes";
                    break;
                case 'pieces':
                    tr11H = "tr_11H04_pieces";
                    break;
            }
            $scope.testForm7TransactionS2Range("tr_11H04", tr11H);
        };


        $scope.testForm7TransactionS2Range = function (sourceTransaction, validationTransaction) {
            if (validationTransaction != null && validationTransaction != ''
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[sourceTransaction] == true
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[sourceTransaction] != null) {

                var amount = $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[sourceTransaction].Amount;

                $scope.form7specificRanges[validationTransaction].Outside = false;
                //console.log(sourceTransaction + " : " + validationTransaction + " : " + amount + " : " + $scope.form7specificRanges[validationTransaction].lower + " / " + $scope.form7specificRanges[validationTransaction].upper);

                if (amount != "-") {
                    if (amount < $scope.form7specificRanges[validationTransaction].lower || amount > $scope.form7specificRanges[validationTransaction].upper) {
                        $scope.form7specificRanges[validationTransaction].Outside = true;
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[sourceTransaction] == null) {
                            $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[sourceTransaction] = "";
                        }
                        //console.log(sourceTransaction + " : " + validationTransaction + " : " + $scope.form7specificRanges[validationTransaction].Outside);
                    }
                }
            } else {
                //console.log(sourceTransaction + " / " + validationTransaction);
            }
            if ($scope.form7specificRanges[validationTransaction] != null && $scope.form7specificRanges[validationTransaction].Outside == false) {
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[sourceTransaction] = "";
            }
        };

        $scope.form7CheckTransaction = function (transaction) {

            if ($scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] == false
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount != null &&
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount > 0) {
                var testDelete = confirm("The selected transaction contains values. Unchecking will delete the values too. Continue?");
                if (!testDelete) {
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] = true;
                }
            }

            if (
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] == true
                    && ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction] == null ||
                            $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount == null ||
                            $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount == 0)
                    ) {
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[transaction] = "";
            }

            if ($scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] == false) {
                $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount = 0;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[transaction].Amount = 0;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[transaction] = "";
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[transaction] = "";
                $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount = "";
                for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {
                    var destinationObject = $scope.getGasElementFor(i, transaction);
                    if (destinationObject && angular.isDefined(destinationObject.Amount) && destinationObject.Amount != null && destinationObject.Amount != '' && parseFloat(destinationObject.Amount) > 0) {
                        destinationObject.Amount = null;
                    }
                }

                if (transaction == 'tr_11P') {
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit = '';
                }

                if (transaction == 'tr_11H04') {
                    $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit = '';
                }

            }
        };

        $scope.qc1056fail = [];
        $scope.qc1057fail = [];
        $scope.qc1058fail = [];

        $scope.calculateForm7Totals = function () {

            // If unit Pieces is selected, only integer numbers can be displayed.
            if ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit == 'pieces'
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11H04.Amount != null
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11H04.Amount != '') {
                $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11H04.Amount = Math.round($scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11H04.Amount);
            }

            if ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit == 'pieces'
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11P.Amount != null
                    && $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11P.Amount != '') {
                $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11P.Amount = Math.round($scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11P.Amount);
            }

            for (var j = 0; j < $scope.form7transactions.length; j++) {
                var total = 0;
                var notNullCount = 0;

                for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {

                    var destinationObject = $scope.getGasElementFor(i, $scope.form7transactions[j]);

                    if (destinationObject && angular.isDefined(destinationObject.Amount) && destinationObject.Amount != null && destinationObject.Amount != '' && parseFloat(destinationObject.Amount) > 0) {
                        total += parseFloat(destinationObject.Amount);
                        notNullCount++;
                    }

                    // This was changed from block beginning to here. Must be doublechecked whether it is OK?
                    $scope.doCalculationForFields(i, ['tr_11A', 'tr_11B', 'tr_11D', 'tr_11E', 'tr_11F', 'tr_11G', 'tr_11H', 'tr_11Q'], false);

                }

                if ($scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[$scope.form7transactions[j]] == true) {

                    $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[$scope.form7transactions[j]].Amount = total;

                    var amounts = 0;
                    if ($scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[$scope.form7transactions[j]] != null) {
                        amounts = $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[$scope.form7transactions[j]].Amount;
                    }

                    //console.log($scope.form7transactions[j] + ": Amounts: " + amounts + ", notNullCount: " + notNullCount + " parseFloat: " + parseFloat(amounts));
                    if (notNullCount > 0 && amounts != null && parseFloat(amounts) > 0) {
                        //console.log("Calculating for: " + $scope.form7transactions[j] );
                        $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[$scope.form7transactions[j]].Amount = Math.round(total / parseFloat(amounts) * 1000 * 1000) / 1000;
                    } else {
                        $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[$scope.form7transactions[j]].Amount = "-";
                    }
                }
            }


            var totalS4q = 0;
            var totalS4g = 0;
            // Calculating S4 for 11Q and 11G
            for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {



                var q = $scope.getGasElementFor(i, "tr_11Q").Amount;
                var g = $scope.getGasElementFor(i, "tr_11G").Amount;



                if (q != null && $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV != null) {
                    totalS4q += q * $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV;
                } else {
                    //console.log("Error calculating CO2EQ for 11Q: " + $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV + " / " + q);
                }

                if (g != null && $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV != null) {
                    totalS4g += g * $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV;
                } else {
                    //console.log("Error calculating CO2EQ for 11G: " + $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_AnnexIV + " / " + g);
                }
            }


            //console.log("Gases CO2EQ for 11Q: " + totalS4q);


            $scope.instance.FGasesReporting.F7_s11EquImportTable.Totals.tr_11QSumAllGasesCO2Eq = totalS4q;
            $scope.instance.FGasesReporting.F7_s11EquImportTable.Totals.tr_11GSumAllGasesCO2Eq = totalS4g;

            $scope.calculateQC_1056_1057_1058();


            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11A.Amount =
                    $scope.getImpEqValue("tr_11A01")
                    + $scope.getImpEqValue("tr_11A02")
                    + $scope.getImpEqValue("tr_11A03")
                    + $scope.getImpEqValue("tr_11A04")
                    + $scope.getImpEqValue("tr_11A05")
                    + $scope.getImpEqValue("tr_11A06")
                    + $scope.getImpEqValue("tr_11A07")
                    + $scope.getImpEqValue("tr_11A08")
                    + $scope.getImpEqValue("tr_11A09")
                    + $scope.getImpEqValue("tr_11A10")
                    + $scope.getImpEqValue("tr_11A11")
                    + $scope.getImpEqValue("tr_11A12")
                    + $scope.getImpEqValue("tr_11A13")
                    + $scope.getImpEqValue("tr_11A14");

            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11B.Amount =
                    $scope.getImpEqValue("tr_11B01")
                    + $scope.getImpEqValue("tr_11B02")
                    + $scope.getImpEqValue("tr_11B03")
                    + $scope.getImpEqValue("tr_11B04")
                    + $scope.getImpEqValue("tr_11B05")
                    + $scope.getImpEqValue("tr_11B06")
                    + $scope.getImpEqValue("tr_11B07")
                    + $scope.getImpEqValue("tr_11B08")
                    + $scope.getImpEqValue("tr_11B09")
                    + $scope.getImpEqValue("tr_11B10")
                    + $scope.getImpEqValue("tr_11B11")
                    + $scope.getImpEqValue("tr_11B12")
                    + $scope.getImpEqValue("tr_11B13")
                    + $scope.getImpEqValue("tr_11B14");
            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11D.Amount =
                    $scope.getImpEqValue("tr_11D01")
                    + $scope.getImpEqValue("tr_11D02")
                    + $scope.getImpEqValue("tr_11D03");
            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11E.Amount =
                    $scope.getImpEqValue("tr_11E01")
                    + $scope.getImpEqValue("tr_11E02")
                    + $scope.getImpEqValue("tr_11E03")
                    + $scope.getImpEqValue("tr_11E04");

            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11F.Amount =
                    $scope.getImpEqValue("tr_11F01")
                    + $scope.getImpEqValue("tr_11F02")
                    + $scope.getImpEqValue("tr_11F03")
                    + $scope.getImpEqValue("tr_11F04")
                    + $scope.getImpEqValue("tr_11F05")
                    + $scope.getImpEqValue("tr_11F06")
                    + $scope.getImpEqValue("tr_11F07")
                    + $scope.getImpEqValue("tr_11F08")
                    + $scope.getImpEqValue("tr_11F09");

            $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment.tr_11G.Amount =
                    $scope.getImpEqValue("tr_11A")
                    + $scope.getImpEqValue("tr_11B")
                    + $scope.getImpEqValue("tr_11C")
                    + $scope.getImpEqValue("tr_11D")
                    + $scope.getImpEqValue("tr_11E")
                    + $scope.getImpEqValue("tr_11F");

             $scope.form7checkS2Range();
        };

        $scope.changeSection11Activities = function () {
            $scope.calculateQC_1056_1057_1058();
            $scope.calculateForm7Totals();
        };

        $scope.QC_1056_1057_transactions = [
            'tr_11A01', 'tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14',
            'tr_11B01', 'tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14',
            'tr_11C', 'tr_11D01', 'tr_11D02', 'tr_11D03', 'tr_11E01', 'tr_11E02', 'tr_11E03', 'tr_11E04',
            'tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09'
        ];

        $scope.QC_1058_transactions = [
            'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11M', 'tr_11L', 'tr_11N', 'tr_11O', 'tr_11P'
        ];


        $scope.calculateQC_1056_1057_1058 = function () {
            // Calculating QC rules 1056, 1057 and 1057
            $scope.qc1056fail = [];
            $scope.qc1057fail = [];
            $scope.qc1058fail = [];

            for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {

                if ($scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC != null && $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC > 0
                        && ($scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-RACHP-HFC'] == null || $scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-RACHP-HFC'] == false)) {
                    $scope.qc1056fail.push(true);
                    $scope.resetSection11GasValues($scope.QC_1056_1057_transactions, i);
                } else {
                    $scope.qc1056fail.push(false);
                }

                if (($scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC == null || $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC == 0)
                        && ($scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-other'] == null || $scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-other'] == false)) {
                    $scope.qc1057fail.push(true);
                    $scope.resetSection11GasValues($scope.QC_1056_1057_transactions, i);
                } else {
                    $scope.qc1057fail.push(false);
                }

                if ($scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-other'] == null || $scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I-other'] == false) {
                    $scope.qc1058fail.push(true);
                    $scope.resetSection11AllValues($scope.QC_1058_transactions, i);
                } else {
                    $scope.qc1058fail.push(false);
                }
            }
        }

        $scope.resetSection11GasValues = function (transactions, gasIndex) {
            for (var i = 0; i < transactions.length; i++) {
                var destinationObject = $scope.getGasElementFor(gasIndex, transactions[i]);
                if (destinationObject) {
                    destinationObject.Amount = null;
                }
            }
        }

        $scope.resetSection11AllValues = function (transactions, gasIndex) {
            for (var i = 0; i < transactions.length; i++) {
                var destinationObject = $scope.getGasElementFor(gasIndex, transactions[i]);
                if (destinationObject) {
                    destinationObject.Amount = null;
                }
                $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transactions[i]].Amount = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transactions[i]] = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[transactions[i]] = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[transactions[i]] = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transactions[i]].Amount = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS2[transactions[i]].Amount = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit = null;
                $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit = null;
            }
        }

        $scope.getImpEqValue = function (transaction) {
            if ($scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] == false
                    || $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction] == null
                    || $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount == null
                    || $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount == "") {
                return 0;
            } else {
                return $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount == null ? 0 : parseFloat($scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount);
            }
        };

        //--- End

        // ------------------------------------------
        // Starting validation part
        // ------------------------------------------

        $scope.transactionValidationErrorsTemplate = {'transaction': null, transactionLabel: null, 'errors': []};
        $scope.validationErrorTemplate = {'QCCode': null, 'gasIndex': null, 'tradePartnerId': null, 'type': null, 'message': null};

        //it would be good to use same ids with tabs,
        // zykaerv: append to the end if new cat
        $scope.valSubCat = ['general', 'activities', 'gases', 'sheet1', 'sheet2', 'sheet3', 'sheet4', 'sheet5', 'sheet6', 'form7', ];
        $scope.errors = {};
        $scope.validationMessages = {};

        for (var i = 0; i < $scope.valSubCat.length; i++) {
            $scope.errors[$scope.valSubCat[i]] = [];
            $scope.validationMessages[$scope.valSubCat[i]] = [];
        }

        $scope.pushError = function (group, transactionIndex, code, message) {
            //console.log("Received error: " + group + ": " + $scope.form7transactions[transactionIndex] + " / " + code);
            $scope.errors[group][transactionIndex].errors.push(clone($scope.validationErrorTemplate));
            var index = $scope.errors[group][transactionIndex].errors.length - 1;
            $scope.errors[group][transactionIndex].errors[index].QCCode = code;
            if (message != null && message.length > 0) {
                $scope.errors[group][transactionIndex].errors[index].message = message;
            }
        };
        $scope.pushWarning = function (group, transactionIndex, code, message) {
            //console.log("Received error: " + group + ": " + $scope.form7transactions[transactionIndex] + " / " + code);
            $scope.errors[group][transactionIndex].errors.push(clone($scope.validationErrorTemplate));
            var index = $scope.errors[group][transactionIndex].errors.length - 1;
            $scope.errors[group][transactionIndex].errors[index].QCCode = code;
            if (message != null && message.length > 0) {
                $scope.errors[group][transactionIndex].errors[index].message = message;
            }
            $scope.errors[group][transactionIndex].errors[index].isNonBlocker = true;
        };

        $scope.updateValidationMessages = function (group) {
            var groupValidationMessages = [];
            var groupErrors = objectUtil.defaultIfNull($scope.errors[group], []);

            for (var i = 0; i < groupErrors.length; i++) {
                var transactionErrorInfo = groupErrors[i];
                
                if (transactionErrorInfo.errors != null && transactionErrorInfo.errors.length > 0) {
                    for (var j = 0; j < transactionErrorInfo.errors.length; j++) {
                        var errorInfo = transactionErrorInfo.errors[j];
                        var messageText;
                        
                        if (objectUtil.isNull(errorInfo.message)) {
                            messageText = $translate.instant("validation_messages.qc_" + errorInfo.QCCode + ".error_text");
                        }
                        else {
                            messageText = errorInfo.message;
                        }
                        
                        var message = {
                            'transaction': transactionErrorInfo.transaction,
                            'transactionLabel': transactionErrorInfo.transactionLabel,
                            'qccode': errorInfo.QCCode,
                            'gasIndex': errorInfo.gasIndex,
                            'tradePartnerId': errorInfo.tradePartnerId,
                            'message': messageText,
                            isBlocker: !errorInfo.isNonBlocker
                        };
                        groupValidationMessages.push(message);
                    }
                }
            }
            
            groupValidationMessages.sort(function(msg1, msg2) {
                var cmp = msg1.transaction.localeCompare(msg2.transaction);
                
                if (cmp !== 0) return cmp;
                
                cmp = Number(msg1.qccode) - Number(msg2.qccode);
                
                if (cmp !== 0) return cmp;
                
                if (!numericUtil.isNum(msg1.gasIndex) || !numericUtil.isNum(msg2.gasIndex)) {
                    return 0;
                }
                
                return Number(msg1.gasIndex) - Number(msg2.gasIndex);
            });
            $scope.validationMessages[group] = groupValidationMessages;
        };

        $scope.refreshValidations = function() {
            arrayUtil.forEach($scope.valSubCat, function(subCat) {
                var tabErrors = $scope.errors[subCat];
                
                if (!objectUtil.isNull(tabErrors) && tabErrors.length > 0) {
                    $scope.validateBySubCat(subCat);
                }
            });
        };

        $scope.validateBySubCat = function(subCat) {
            switch (subCat) {
                case "general":
                    $scope.validateGeneralIssues();
                    break;
                case "activities":
                    $scope.validateActivitiesTab();
                    break;
                case 'gases':
                    $scope.validateGasesTab();
                    break;
                case 'sheet1':
                    $scope.validateSheet1();
                    break;
                case 'sheet2':
                    $scope.validateSheet2();
                    break;
                case 'sheet3':
                    $scope.validateSheet3();
                    break;
                case 'sheet4':
                    $scope.validateSheet4();
                    break;
                case 'sheet5':
                    $scope.validateSheet5();
                    break;
                case 'sheet6':
                    $scope.validateSheet6();
                    break;
                case 'form7':
                    $scope.validateForm7();
                    break;
            }
        };

        $scope.validateGeneralIssues = function () {
            var sheetId = 'general';
            $scope.errors[sheetId] = sheetGeneralValidator.validate(viewModel);
            $scope.updateValidationMessages(sheetId);
        };


        $scope.validateActivitiesTab = function () {
            var sheetId = 'activities';
            $scope.errors[sheetId] = sheetActivitiesValidator.validate(viewModel);
            $scope.updateValidationMessages(sheetId);
        };

        $scope.validateGasesTab = function () {
            var sheetId = 'gases';
            $scope.errors[sheetId] = sheetGasSelectionValidator.validate(viewModel);
            $scope.updateValidationMessages(sheetId);
        };

        // ------ Sheet 1 related Validation Functionality
        // Validation rule definitions for sheet1. This definitions are used in validateSheet1 function.
        $scope.sheet1ValidationRules = [
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"]',
                'transaction': {'id': 'tr_01D', 'label': '01D'},
                'rules': [{'condition': '$scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_01D) <= ($scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_01A) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04C))', 'qccode': 2099}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] && (!$scope.isUnspecifiedMix(reportedGas) && reportedGas.IsBlend)',
                'transaction': {'id': 'tr_01H', 'label': '01H'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_01H.Amount >= 0', 'qccode': 2078}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["I"] && (!($scope.isUnspecifiedMix(reportedGas)) && !($scope.containsHFC(reportedGas) && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I-HFC"]) && !(!$scope.containsHFC(reportedGas) && !$scope.instance.FGasesReporting.GeneralReportData.Activities["I-other"]))',
                'transaction': {'id': 'tr_02B', 'label': '02B'},
                'rules': [{'condition': '$scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_02B) <= ($scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_02A) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04C))', 'qccode': 2098}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["E"]',
                'transaction': {'id': 'tr_03A', 'label': '03A'},
                'rules': [{'condition': '$scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03A) >= ($scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03D) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03E) + $scope.getValueForReportedGasAmount($scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03F))', 'qccode': 2018}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["E"]',
                'transaction': {'id': 'tr_03C', 'label': '03C'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03C.Amount >= 0', 'qccode': 2017}]
            },
            {
                'preCondition': '($scope.instance.FGasesReporting.GeneralReportData.Activities["I"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || !$scope.containsHFC(reportedGas)) && $scope.instance.FGasesReporting.GeneralReportData.Activities["D"]',
                'transaction': {'id': 'tr_04A', 'label': '04A'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04A.Amount >= ($scope.instance.FGasesReporting.F6_FUDest.Gas[gasIndex].tr_08E.Amount)', 'qccode': 2020}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["I"]',
                'transaction': {'id': 'tr_04D', 'label': '04D'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04D.Amount >= 0', 'qccode': 2017}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["I"]',
                'transaction': {'id': 'tr_04E', 'label': '04E'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04E.Amount >= 0', 'qccode': 2017}]
            },
            {
                'preCondition': '($scope.instance.FGasesReporting.GeneralReportData.Activities["I"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || !$scope.containsHFC(reportedGas)) && $scope.instance.FGasesReporting.GeneralReportData.Activities["D"]',
                'transaction': {'id': 'tr_04F', 'label': '04F'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04F.Amount >= ($scope.instance.FGasesReporting.F6_FUDest.Gas[gasIndex].tr_08F.Amount)', 'qccode': 2023}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["I"]',
                'transaction': {'id': 'tr_04I', 'label': '04I'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04I.Amount >= 0', 'qccode': 2017}]
            },
            {
                'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P"] || $scope.instance.FGasesReporting.GeneralReportData.Activities["I"]',
                'transaction': {'id': 'tr_04J', 'label': '04J'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_04J.Amount >= 0', 'qccode': 2017}]
            }
        ]; // End of Validation rule definitions for sheet1

        $scope.producersList = ['fgas22354', 'fgas20495', 'fgas23363', 'fgas24111', 'fgas21223', 'fgas23724', 'fgas21133', 'fgas23460', 'fgas24128', 'fgas30000'];

        // Function to do validation on sheet1. This function heavily depend on sheet1ValidationRules variable.
        // Local variable names are important, some of them are used in eval expressions. See also: $scope.validateSheet
        $scope.validateSheet1 = function () {
            //clear previous error messages
            var sheetId = 'sheet1'; //sheet1
            var formId = 'F1_S1_4_ProdImpExp';
            $scope.errors[sheetId] = [];

            //re calculate necessary values
            $scope.reCalculateSheet1();

            //call validation
            $scope.validateSheet(formId, sheetId, $scope.sheet1ValidationRules, $scope.errors[sheetId]);

            //QC rules 2002, 2003, 2004, 2005, 2006
            var miniValidationRules = [
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P-HFC"]',
                    'transaction': {'id': 'tr_01A', 'label': '01A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && !reportedGas.IsBlend && !$scope.isUnspecifiedMix(reportedGas) && $scope.containsHFC(reportedGas) && $scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_01A.Amount > 0', 'qccode': 2002}]
                },
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["P-other"]',
                    'transaction': {'id': 'tr_01A', 'label': '01A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && !reportedGas.IsBlend && !$scope.isUnspecifiedMix(reportedGas) && !$scope.containsHFC(reportedGas) && $scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_01A.Amount > 0', 'qccode': 2003}]
                },
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["I-HFC"]',
                    'transaction': {'id': 'tr_02A', 'label': '02A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && ($scope.isUnspecifiedMix(reportedGas) || $scope.containsHFC(reportedGas)) && $scope.hasRequiredQuantitiesForQcs_2004_2005(gasIndex, 2004)', 'qccode': 2004}]
                },
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["I-other"]',
                    'transaction': {'id': 'tr_02A', 'label': '02A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && ($scope.isUnspecifiedMix(reportedGas) || !$scope.containsHFC(reportedGas)) && $scope.hasRequiredQuantitiesForQcs_2004_2005(gasIndex, 2005)', 'qccode': 2005}]
                },
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["E"]',
                    'transaction': {'id': 'tr_03A', 'label': '03A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && $scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_03A.Amount > 0', 'qccode': 2006}]
                }
            ];

            var filteredRules = [];
            //no need to check for precondition in each time for gas loop, so filter first and then continue
            for (var i = 0; i < miniValidationRules.length; i++) {
                if (eval(miniValidationRules[i].preCondition)) {
                    filteredRules.push(miniValidationRules[i]);
                }
            }

            //iterate over gases
            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                var reportedGas = $scope.instance.FGasesReporting.ReportedGases[gasIndex];
                //iterate over qc rules to check
                for (var i = 0; i < filteredRules.length; i++) {
                    // if a rule condition is satisfied then we can remove it from rules list
                    var rule = filteredRules[i].rules[0]; //we have one element each, so no need to iterate. to keep previous structure
                    if (eval(rule.condition)) {
                        filteredRules.splice(i, 1);
                        i--;
                    }
                }
            }

            //left overs are real errors
            for (var i = 0; i < filteredRules.length; i++) {
                var rule = filteredRules[i];
                var transactionErrors = clone($scope.transactionValidationErrorsTemplate);
                transactionErrors.transaction = rule.transaction.id;
                transactionErrors.transactionLabel = rule.transaction.label;
                transactionErrors.errors = [];
                var errorVar = clone($scope.validationErrorTemplate);
                errorVar.QCCode = rule.rules[0].qccode;
                errorVar.gasIndex = null;
                transactionErrors.errors.push(errorVar);
                $scope.errors[sheetId].push(transactionErrors);
            }
            //end of qc checks 2002, 2003, 2004, 2005, 2006

            //QC 2016: //calculate total values for 1B
            var rows = ['tr_01B'];
            var totals = {'tr_01B': {'SumAllGases': 0, 'SumAllGasesCO2Eq': 0}};
            var calculations = ['SumAllGases', 'SumAllGasesCO2Eq'];
            //do calculation in loop for each row
            for (var k = 0; k < rows.length; k++) {
                var gasRow = rows[k];
                var inputArray = [];
                var sourceGases = $scope.instance.FGasesReporting[formId].Gas;
                for (var i = 0; i < sourceGases.length; i++) {
                    var gas = {};
                    gas.Id = sourceGases[i].GasCode;
                    gas.Amount = $scope.getValueForReportedGasAmount(sourceGases[i][gasRow]);
                    inputArray.push(gas);
                }

                //iterate on each calculation
                for (var i = 0; i < calculations.length; i++) {
                    var calculation = calculations[i];
                    totals[gasRow][calculation] = $scope.calculationFunctions[calculation](inputArray);
                }
            }

            //QC 2016: if sum of all gases is >1 t or 1000 t CO2 eq reporter must have selected to be D
            if (!$scope.instance.FGasesReporting.GeneralReportData.Activities.D && (totals.tr_01B.SumAllGases > 1 || totals.tr_01B.SumAllGasesCO2Eq > 1000)) {
                //D is not selected and sum of gases are greater than thresholds, so check if fields contain comments
                var commentFound = false;
                for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length && !commentFound; gasIndex++) {
                    if ($scope.instance.FGasesReporting[formId].Gas[gasIndex].tr_01B.Comment != null) {
                        commentFound = true;
                    }
                }

                //if no comment found then add transaction error
                if (!commentFound) {
                    var transactionErrors = clone($scope.transactionValidationErrorsTemplate);
                    transactionErrors.transaction = 'tr_01B';
                    transactionErrors.transactionLabel = '01B';
                    transactionErrors.errors = [];
                    var errorVar = clone($scope.validationErrorTemplate);
                    errorVar.QCCode = 2016;
                    errorVar.gasIndex = null;
                    transactionErrors.errors.push(errorVar);
                    $scope.errors[sheetId].push(transactionErrors);
                }
            }
            
            arrayUtil.pushMany($scope.errors[sheetId], sheet1Validator.validate(viewModel));
            
            //update messages
            $scope.updateValidationMessages(sheetId);
        };// end of function validateSheet1
        
        $scope.hasRequiredQuantitiesForQcs_2004_2005 = function(gasIndex , qcCode) {
            var gasQuantities = $scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex];
            var transactions = [ 'tr_02A', 'tr_04A', 'tr_04B', 'tr_04C' ];

            if ( qcCode === 2004) {
                return arrayUtil.contains(transactions, function(transaction) {
                        var amount = gasQuantities[transaction].Amount;

                        return numericUtil.toNum(amount, 0) > 0 || ( amount == '0' && transaction !== 'tr_02A' ) ;
                    });
            }
            
            return arrayUtil.contains(transactions, function(transaction) {
                var amount = gasQuantities[transaction].Amount;

                return numericUtil.toNum(amount, 0) > 0;
            });
        };
        
        // Function to do validation on sheet2. This function heavily depend on sheet2ValidationRules variable.
        // Local variable names are important, some of them are used in eval expressions. See also: $scope.validateSheet
        $scope.validateSheet2 = function () {
            //clear previous error messages
            var sheetId = 'sheet2'; //sheet2
            $scope.errors[sheetId] = [];
            //re calculate necessary values
            $scope.reCalculateSheet2();
            arrayUtil.pushMany($scope.errors[sheetId], sheet2Validator.validate(viewModel));
            //update messages
            $scope.updateValidationMessages(sheetId);
        };// end of function validateSheet2

        // ------ Sheet 3 related Validation Functionality
        // Validation rule definitions for sheet3. This definitions are used in validateSheet3 function.
        $scope.sheet3ValidationRules = [
            {
                'transaction': {'id': 'tr_06X', 'label': '06X'},
                'rules': [{'condition': '$scope.instance.FGasesReporting.F3A_S6A_IA_HFCs.Gas[gasIndex].tr_06X.Amount >= 0', 'qccode': 2043}]
            }
        ]; // End of Validation rule definitions for sheet3

        // Function to do validation on sheet3. This function heavily depend on sheet3ValidationRules variable.
        // Local variable names are important, some of them are used in eval expressions. See also: $scope.validateSheet
        $scope.validateSheet3 = function () {
            //clear previous error messages
            var sheetId = 'sheet3'; //sheet3
            var formId = 'F3A_S6A_IA_HFCs';
            $scope.errors[sheetId] = [];

            //re calculate necessary values
            $scope.reCalculateSheet3();

            //call validation
            $scope.validateSheet(formId, sheetId, $scope.sheet3ValidationRules, $scope.errors[sheetId]);
            arrayUtil.pushMany($scope.errors[sheetId], sheet3Validator.validate(viewModel));
            //update messages
            $scope.updateValidationMessages(sheetId);
        };// end of function validateSheet3

        $scope.validateSheet4 = function () {
            var sheetId = 'sheet4'; //sheet4
            $scope.reCalculateSheet4();
            $scope.errors[sheetId] = sheet4Validator.validate(viewModel);
            $scope.updateValidationMessages(sheetId);
        };// end of function validateSheet4
        
        $scope.validateSheet5 = function () {
            var sheetId = 'sheet5'; //sheet5
            $scope.updateTradePartnersOnSheet5(); // sync in case of changes in section 9, without visiting section 10
            $scope.errors[sheetId] = sheet5Validator.validate(viewModel);
            $scope.updateValidationMessages(sheetId);
        };
        $scope.validateSheet6 = function () {
            //re calculate necessary values
            $scope.reCalculateSheet6();
            var sheetId = 'sheet6'; //sheet6
            var formId = 'F6_FUDest';
            $scope.errors[sheetId] = [];

            //QC rules 2008, 2009
            var miniValidationRules = [
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["FU"]',
                    'transaction': {'id': 'tr_07A', 'label': '07A'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && $scope.instance.FGasesReporting.F6_FUDest.Gas[gasIndex].tr_07A.Amount > 0', 'qccode': 2008}]
                },
                {
                    'preCondition': '$scope.instance.FGasesReporting.GeneralReportData.Activities["D"]',
                    'transaction': {'id': 'tr_08D', 'label': '08D'},
                    'rules': [{'condition': 'viewModel.getReportedGases().length > 0 && $scope.instance.FGasesReporting.F6_FUDest.Gas[gasIndex].tr_08D.Amount > 0', 'qccode': 2009}]
                }
            ];
            
            var sheet6ValidationRules = [];
            arrayUtil.pushMany($scope.errors[sheetId], sheet6Validator.validate(viewModel));
            var filteredRules = [];
            var reportedGases = $scope.instance.FGasesReporting.ReportedGases;
            //no need to check for precondition in each time for gas loop, so filter first and then continue
            for (var i = 0; i < miniValidationRules.length; i++) {
                if ( eval(miniValidationRules[i].preCondition) ) filteredRules.push(miniValidationRules[i]);
            }

            //iterate over gases
            for (var gasIndex = 0; gasIndex < reportedGases.length; gasIndex++) {
                var reportedGas = $scope.instance.FGasesReporting.ReportedGases[gasIndex];
                //iterate over qc rules to check
                for (var i = 0; i < filteredRules.length; i++) {
                    // if a rule condition is satisfied then we can remove it from rules list
                    var rule = filteredRules[i].rules[0]; //we have one element each, so no need to iterate. to keep previous structure
                    if (eval(rule.condition)) {
                        filteredRules.splice(i, 1);
                        i--;
                    }
                }
                arrayUtil.forEach($scope.getTransactionErrorsForGas(sheet6ValidationRules, gasIndex), function(e) {
                    $scope.errors[sheetId].push(e);
                });
            }

            //left overs are real errors
            for (var i = 0; i < filteredRules.length; i++) {
                var rule = filteredRules[i];
                $scope.errors[sheetId].push($scope.createTransactionError(rule.transaction, rule.rules));
            }
            //end of qc checks 2008, 2009
            $scope.updateValidationMessages(sheetId);
        };
        
        //  a function that iterate all the declared gases and performs validations
        // based on validation rules.
        $scope.getTransactionErrorsForGas = function(definedRules, gasIndex){
            var errors = [];
            for (var i = 0; i < definedRules.length; i++) {
                var definedRule = definedRules[i];
                if(!eval(definedRule.preCondition)) {
                    continue;
                }
                var rulesToCheck = definedRule.rules;
                for(var j=0; j<rulesToCheck.length; j++) {
                    var definedRulesItem = rulesToCheck[j];
                    if (!eval(definedRulesItem.condition)) {
                        errors.push($scope.createTransactionError(definedRule.transaction, rulesToCheck, gasIndex));
                    }
                }
            }
            return errors;
        };
        // TODO: move to external service
        $scope.createTransactionError = function(transaction, rules, gasIndex) {
            var transactionErrors = clone($scope.transactionValidationErrorsTemplate);
            transactionErrors.transaction = transaction.id;
            transactionErrors.transactionLabel = transaction.label;
            transactionErrors.errors = $scope.createRuleError(rules, gasIndex);
            return transactionErrors;
        };
        // TODO(zykaerv): Move to external service
        // Helper method that creates the proper error template for each QC rule
        $scope.createRuleError = function(rules, gasIndex) {
            var errors = [];
            for(var i=0; i < rules.length; i++) {
                var errorTemplate = clone($scope.validationErrorTemplate);
                var currentRule = rules[i];
                errorTemplate.QCCode = currentRule.qccode;
                if(angular.isNumber(gasIndex)) {
                    errorTemplate.gasIndex = gasIndex;
                }
                errors.push(errorTemplate)
            }
            return errors;
        };
        // Generic function used to validates sheets from 1 to 6, it takes rules and errors as parameter
        // function local variable names are used in sheetRules
        $scope.validateSheet = function (formId, sheetId, sheetRules, sheetErrors) {
            for (var i = 0; i < sheetRules.length; i++) {
                //create template
                var transactionErrors = clone($scope.transactionValidationErrorsTemplate);
                transactionErrors.transaction = sheetRules[i].transaction.id;
                transactionErrors.transactionLabel = sheetRules[i].transaction.label;
                transactionErrors.errors = [];

                // iterate on reported gases array. gasIndex is used in eval expressions.
                for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                    //this variable used for eval function
                    var reportedGas = $scope.instance.FGasesReporting.ReportedGases[gasIndex];

                    //check if precondition is satisfied, if it exists
                    if (angular.isDefined(sheetRules[i].preCondition) && !eval(sheetRules[i].preCondition)) {
                        //if there is a pre condition set for one transaction and if it is not satisfied, then we shouldn't do validation on that transaction
                        //so in that case, just continue
                        continue;
                    }

                    var inputField = $scope.instance.FGasesReporting[formId].Gas[gasIndex][transactionErrors.transaction];
                    if (inputField == null || (inputField.Amount == null && inputField.SumOfPartnerAmounts == null)) {
                        //if value is null or not defined then, no need to apply check
                        continue;
                    }

                    for (var j = 0; j < sheetRules[i].rules.length; j++) {
                        var rule = sheetRules[i].rules[j];
                        if (!eval(rule.condition)) {
                            var errorVar = clone($scope.validationErrorTemplate);
                            //'QCCode' : '', 'gasIndex': '', 'tradePartnerId': '', 'type': '', 'message' : ''
                            errorVar.QCCode = rule.qccode;
                            errorVar.gasIndex = gasIndex;
                            transactionErrors.errors.push(errorVar);
                        }
                    }
                }

                //if there is any error, push it for form
                if (transactionErrors.errors.length > 0) {
                    sheetErrors.push(transactionErrors);
                }
            }
        };//end of funcction validateSheet




        $scope.QC2049Enabled = false;
        
        $scope.validateForm7 = function () {

            $scope.calculateForm7Totals();

            $scope.errors['form7'] = [];

            var indexOf11G = 0;
            // Starting to map transaction related errors
            for (var j = 0; j < $scope.form7transactions.length; j++) {
                var total = 0;
                var notNullCount = 0;
                // Initializing values
                $scope.errors['form7'].push(clone($scope.transactionValidationErrorsTemplate));
                $scope.errors['form7'][j].transaction = $scope.form7transactions[j];
                $scope.errors['form7'][j].transactionLabel = $scope.form7transactionLabels[j];
                $scope.errors['form7'][j].errors = [];

                var transaction = $scope.form7transactions[j];

                // In case a transaction is hidden, we shall not check any of its validations
                if ($scope.instance.FGasesReporting.F7_s11EquImportTable.UISelectedTransactions[transaction] == false) {
                    continue;
                }

                if (
                        (transaction == 'tr_11A03' || transaction == 'tr_11A09' || transaction == 'tr_11A12' || transaction == 'tr_11B03'
                                || transaction == 'tr_11B05' || transaction == 'tr_11B07' || transaction == 'tr_11B09'
                                || transaction == 'tr_11D01' || transaction == 'tr_11D02' || transaction == 'tr_11D03'
                                || transaction == 'tr_11E04' || transaction == 'tr_11F09')
                        && ($scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]] == null
                                || $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]].length < 2)
                        ) {
                    $scope.pushError('form7', j, 2048, null);
                }


                if (
                        $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction] != null
                        && $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount > 0

                        && ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction] == null || $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount == 0)
                        ) {
                    $scope.pushError('form7', j, 2051, null);
                }

                if ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction] != null
                        && $scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount > 0
                        && ($scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount == null || $scope.instance.FGasesReporting.F7_s11EquImportTable.AmountOfImportedEquipment[transaction].Amount == 0)
                        ) {
                    $scope.pushError('form7', j, 2065, null);
                }

                if (transaction == 'tr_11H04') {

                    if ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1['tr_11H04'].Amount > 0) {
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]] == null
                                || $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]].length < 2) {
                            $scope.pushError('form7', j, 2087, null);
                        }

                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit == null || 
                                $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit == '') {
                            $scope.pushError('form7', j, 2050, null);
                        }else{
                            $scope.validateForm7Transaction11H04(function(transaction, rangeData, isWarning){
                                if(isWarning){
                                    $scope.pushWarning('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300_warning.error_text', {
                                        transaction: $scope.getForm7TransactionCode(transaction),
                                        min: rangeData.min,
                                        max: rangeData.max,
                                        unit: rangeData.unit
                                    }));
                                } else {
                                    $scope.pushError('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300.error_text', {
                                        transaction: $scope.getForm7TransactionCode(transaction),
                                        min: rangeData.min,
                                        max: rangeData.max,
                                        unit: rangeData.unit
                                    }));
                                }
                            })
                        }
                    }

                } else if (transaction === 'tr_11P') {

                    if ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1['tr_11P'].Amount > 0) {
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.SumOfAllGasesS1[transaction].Amount > 0
                                && ($scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]] == null
                                        || $scope.instance.FGasesReporting.F7_s11EquImportTable.Category[$scope.form7transactions[j]].length < 2)) {
                            $scope.pushError('form7', j, 2079, null);
                        }

                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit == null || 
                                $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit == '') {
                            $scope.pushError('form7', j, 2050, null);
                        }else {
                            $scope.validateForm7Transaction11P(function(transaction, rangeData, isWarning){
                                if(isWarning){
                                    $scope.pushWarning('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300_warning.error_text', {
                                        transaction: $scope.getForm7TransactionCode(transaction),
                                        min: rangeData.min,
                                        max: rangeData.max,
                                        unit: rangeData.unit
                                    }));
                                }else {
                                    $scope.pushError('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300.error_text', {
                                        transaction: $scope.getForm7TransactionCode(transaction),
                                        min: rangeData.min,
                                        max: rangeData.max,
                                        unit: rangeData.unit
                                    }));
                                }
                            });
                        }
                    }

                } else if (transaction == 'tr_11G') {
                    // No selected transactions check as it is a totals transaction.

                    indexOf11G = j;

                } else if (transaction == 'tr_11Q') {

                    // THIS QC IS POSTPONED UNTIL 2017 reporting in 2018 according to ticket "Feature #22234".
                    // To Enable the feature, set QC2049Enabled to true or remove the blocking condition from here and Form7 html.
                    //Testing general validation rules
                    if ($scope.QC2049Enabled) {
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Totals.tr_11QSumAllGasesCO2Eq > 500
                                && ($scope.instance.FGasesReporting.F7_s11EquImportTable.SupportingDocuments == null
                                        || $scope.instance.FGasesReporting.F7_s11EquImportTable.SupportingDocuments.Document == '')) {
                            $scope.pushError('form7', j, 2049, null);
                        }
                    }


                } else {
                    // Testing specific range S2 validation rule
                    // If the transaction is selected, is outside the range and the comment is not filled, validation error occurs.
                    if ($scope.form7specificRanges[$scope.form7transactions[j]].Outside == true) {
                        var rangeData = $scope.getRange(transaction);
                        if(($scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[$scope.form7transactions[j]] == null || $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment[$scope.form7transactions[j]].length < 2)){
                            $scope.pushError('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300.error_text', {
                                transaction: $scope.getForm7TransactionCode(transaction),
                                min: rangeData.min,
                                max: rangeData.max,
                                unit: rangeData.unit
                            }));
                        }else {
                            $scope.pushWarning('form7', j, $scope.form7specificRanges[transaction].QCCode, $translate.instant('validation_messages.qc_2300_warning.error_text', {
                                transaction: $scope.getForm7TransactionCode(transaction),
                                min: rangeData.min,
                                max: rangeData.max,
                                unit: rangeData.unit
                            }));
                        }
                    }
                }                
            }

            // Validating QC 2010  
            var sum11G_HFC = 0;
            var countHFC = 0;
            for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {
                if ($scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC != null && $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC > 0 && viewModel.sheetActivities.isEq_I_RACHP_HFC()) {

                    countHFC++;
                    if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i].tr_11G.Amount != null && $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i].tr_11G.Amount > 0) {
                        sum11G_HFC += $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i].tr_11G.Amount;
                    }
                }
            }
            // If there were HFC containing gases found, but their reported amount is 0, it's a QC 2010 validation mistake.
            if (viewModel.sheetActivities.isEq_I_RACHP_HFC() && (viewModel.getReportedGases().length === 0 || (viewModel.getReportedGases().length > 0 && countHFC === 0) || (sum11G_HFC == 0 && countHFC > 0))) {
                $scope.pushError('form7', indexOf11G, 2010, null);
            }


            // Validating QC 2011
            var sum11_NonHFC = 0;
            var countNonHFC = 0;

            var sum11_HFC = 0;
            countHFC = 0;

            var nonHFC_QC2011Transactions = ['tr_11G', 'tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04', 'tr_11I', 'tr_11J', 'tr_11K', 'tr_11L', 'tr_11M', 'tr_11N', 'tr_11O', 'tr_11P', 'tr_11Q'];
            var HFC_QC2011Transactions = nonHFC_QC2011Transactions.slice(0, nonHFC_QC2011Transactions.length - 1);

            for (var i = 0; i < $scope.instance.FGasesReporting.ReportedGases.length; i++) {
                if (($scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC == null || $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC == 0) && viewModel.sheetActivities.isEq_I_other()) {

                    countNonHFC++;
                    for (var j = 0; j < nonHFC_QC2011Transactions.length; j++) {
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][nonHFC_QC2011Transactions[j]].Amount != null && $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][nonHFC_QC2011Transactions[j]].Amount > 0) {
                            sum11_NonHFC += $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][nonHFC_QC2011Transactions[j]].Amount;
                        }
                    }
                }

                if (($scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC != null || $scope.instance.FGasesReporting.ReportedGases[i].GWP_AR4_HFC > 0) && viewModel.sheetActivities.isEq_I_other()) {

                    countHFC++;
                    for (var j = 0; j < HFC_QC2011Transactions.length; j++) {
                        if ($scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][HFC_QC2011Transactions[j]].Amount != null && $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][HFC_QC2011Transactions[j]].Amount > 0) {
                            sum11_HFC += $scope.instance.FGasesReporting.F7_s11EquImportTable.Gas[i][HFC_QC2011Transactions[j]].Amount;
                        }
                    }
                }
            }
            // If there were HFC containing gases found, but their reported amount is 0, it's a QC 2010 validation mistake.
            if (viewModel.sheetActivities.isEq_I_other() && (viewModel.getReportedGases().length === 0 || (sum11_NonHFC == 0 && countNonHFC > 0) || (sum11_HFC == 0 && countHFC > 0))) {
                $scope.pushError('form7', $scope.form7transactions.length - 1, 2011, null);
            }



            $scope.updateValidationMessages('form7');
        };
        
        $scope.getForm7TransactionCode = function (transaction){
            return $translate.instant('form7.transcation_code.'+transaction);
            
        };
        $scope.validateForm7Transaction11H04 = function(handler){
            var tr11H = '';
            switch ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit) {
                case 'cubicmetres':
                    tr11H = "tr_11H04_m3";
                    break;
                case 'metrictonnes':
                    tr11H = "tr_11H04_tonnes";
                    break;
                case 'pieces':
                    tr11H = "tr_11H04_pieces";
                    break;
            } 
            if(tr11H.length>0) {
                if ($scope.form7specificRanges[tr11H].Outside === true) {
                    var rangeObject = $scope.getRange('tr_11H04', $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11H4_Unit);
                    if(($scope.instance.FGasesReporting.F7_s11EquImportTable.Comment['tr_11H04'] === null ||$scope.instance.FGasesReporting.F7_s11EquImportTable.Comment['tr_11H04'].length < 2)) {
                        handler(tr11H, rangeObject, false); // error                    
                    } else {
                        handler(tr11H, rangeObject, true); // warning          
                    }
                }
            }
        };
        $scope.validateForm7Transaction11P = function(handler){
            var tr11P = '';
            switch ($scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit) {
                case 'cubicmetres':
                    tr11P = "tr_11P_m3";
                    break;
                case 'metrictonnes':
                    tr11P = "tr_11P_tonnes";
                    break;
                case 'pieces':
                    tr11P = "tr_11P_pieces";
                    break;
            } 
            if(tr11P.length>0) {
                if ($scope.form7specificRanges[tr11P].Outside === true) {
                    var rangeObject = $scope.getRange('tr_11P', $scope.instance.FGasesReporting.F7_s11EquImportTable.TR_11P_Unit);
                    if($scope.instance.FGasesReporting.F7_s11EquImportTable.Comment['tr_11P'] === null || $scope.instance.FGasesReporting.F7_s11EquImportTable.Comment['tr_11P'].length < 2){
                        handler(tr11P, rangeObject, false);
                    } else {
                        handler(tr11P, rangeObject, true);
                    }
                    
                }
            }
        };
        $scope.getRange = function(transaction, transactionUnit) {
            var transactionName = transaction;
            var unit = 'kg/piece';
            if(transactionUnit === 'cubicmetres') {
                transactionName = transaction + '_m3';
                unit = 'kg/m3';
            } else if(transactionUnit === 'metrictonnes') {
                transactionName = transaction + '_tonnes';
                unit = 'kg/t';
            } else if(transactionUnit === 'pieces') {
                transactionName = transaction + '_pieces';
                unit = 'kg/piece';
            }
            var object = new Object();
            object.min = $scope.form7specificRanges[transactionName].lower;
            object.max = $scope.form7specificRanges[transactionName].upper;
            object.unit = unit;
            return object;
        }

        //list of functions
        $scope.valFns = [
            $scope.validateGeneralIssues,
            $scope.validateActivitiesTab,
            $scope.validateGasesTab,
            $scope.validateSheet1,
            $scope.validateSheet2,
            $scope.validateSheet3,
            $scope.validateSheet4,
            $scope.validateSheet5,
            $scope.validateSheet6,
            $scope.validateForm7
        ];

        // This function calls validation function for given tab index.
        $scope.validateForm = function (tabIndex) {

            tabIndex--; // we don't have intro, remove it
            $scope.valMsgIndex = 0;
            ($scope.valFns[tabIndex])();
            if ($scope.validationMessages[$scope.valSubCat[tabIndex]].length == 0) {
                $notification.info("Validation", "No validation errors found on current form.");
            }
        };// end of function validateForm

        $scope.formTotalValidated = false;

        $scope.calculateOverallValidationStatus = function () {
            arrayUtil.forEach($scope.valFns, function(valFn) { objectUtil.call(valFn); });
            $scope.validateUnusualGasSelection();

            $scope.formTotalValidated = true;

            arrayUtil.forEach($scope.valSubCat, function(valSubCat, loopContext) {
                var messages = $scope.validationMessages[valSubCat];
                var hasBlockerErrors = arrayUtil.contains(messages, function(message) { return message.isBlocker; });
                
                if (hasBlockerErrors) {
                    $scope.formTotalValidated = false;
                    loopContext.breakLoop = true;
                }
            });
            
            $scope.instance.FGasesReporting.qcWarningFlags = {
                flag: []
            };
            
            arrayUtil.forEach(Object.getOwnPropertyNames($scope.errors), function(tabName) {
                var tabTransactionErrorContainers = $scope.errors[tabName];
                
                arrayUtil.forEach(tabTransactionErrorContainers, function(tabTransactionErrorContainer) {
                    if (!objectUtil.isNull(tabTransactionErrorContainer.flags)) {
                        arrayUtil.pushMany($scope.instance.FGasesReporting.qcWarningFlags.flag, tabTransactionErrorContainer.flags);
                    }
                });
            });
        };

        $scope.unusualGasValidationsGroup1 = [ 
            {
                'form': 'F2_S5_exempted_HFCs',
                'code': 1400,
                'transactions': ['tr_05E'],
                'transactionLabels': ['5E'],
                'gases': ['id-2', 'id-3', 'id-4']
            }, 
            {
                'form': 'F2_S5_exempted_HFCs',
                'code': 1400,
                'transactions': ['tr_05F'],
                'transactionLabels': ['5F'],
                'gases': ['id-7', 'id-11']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06D'],
                'transactionLabels': ['6D'],
                'gases': ['id-2', 'id-3', 'id-5', 'id-7', 'id-9', 'id-190', 'id-26', 'id-27', 'id-29', 'id-28','id-89','id-91','id-52','id-37','id-137','id-38','id-39','id-42','id-43','id-44','id-45','id-46']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06E'],
                'transactionLabels': ['6E'],
                'gases': []
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06F'],
                'transactionLabels': ['6F'],
                'gases': ['id-7', 'id-10', 'id-192', 'id-193']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06G'],
                'transactionLabels': ['6G'],
                'gases': []
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06H'],
                'transactionLabels': ['6H'],
                'gases': ['id-2', 'id-5', 'id-11', 'id-14']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06I'],
                'transactionLabels': ['6I'],
                'gases': ['id-7', 'id-10', 'id-11']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06J'],
                'transactionLabels': ['6J'],
                'gases': ['id-7', 'id-10', 'id-11']
            },
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06K'],
                'transactionLabels': ['6K'],
                'gases': ['id-11', 'id-14', 'id-16', 'id-17', 'id-18', 'id-21', 'id-25']
            },
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06M'],
                'transactionLabels': ['6M'],
                'gases': ['id-2', 'id-3', 'id-4', 'id-19', 'id-20', 'id-21' , 'id-22', 'id-1', 'id-183']
            },
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06N'],
                'transactionLabels': ['6N'],
                'gases': ['id-183']
            },
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06O'],
                'transactionLabels': ['6O'],
                'gases': ['id-19', 'id-25','id-22', 'id-183']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06P'],
                'transactionLabels': ['6P'],
                'gases': ['id-1']
            },
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06Q'],
                'transactionLabels': ['6Q'],
                'gases': ['id-1']
            }, 
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06R'],
                'transactionLabels': ['6R'],
                'gases': ['id-1']
            },  
            {
                'form': 'F3A_S6A_IA_HFCs',
                'code': 1400,
                'transactions': ['tr_06S'],
                'transactionLabels': ['6S'],
                'gases': []
            }, 
            {
                'form': 'F6_FUDest',
                'code': 1400,
                'transactions': ['tr_07A'],
                'transactionLabels': ['7A'],
                'gases': []
            }, {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11A01','tr_11A02', 'tr_11A03', 'tr_11A04', 'tr_11A05', 'tr_11A06', 'tr_11A07', 'tr_11A08', 'tr_11A09', 'tr_11A10', 'tr_11A11', 'tr_11A12', 'tr_11A13', 'tr_11A14'],
                'transactionLabels': ['11A1', '11A2', '11A3', '11A4', '11A5', '11A6', '11A7', '11A8', '11A9', '11A10', '11A11', '11A12', '11A13', '11A14'],
                'gases': ['id-3', 'id-7', 'id-27', 'id-29']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11B01','tr_11B02', 'tr_11B03', 'tr_11B04', 'tr_11B05', 'tr_11B06', 'tr_11B07', 'tr_11B08', 'tr_11B09', 'tr_11B10', 'tr_11B11', 'tr_11B12', 'tr_11B13', 'tr_11B14'],
                'transactionLabels': ['11B1', '11B2', '11B3', '11B4', '11B5', '11B6', '11B7', '11B8', '11B9', '11B10', '11B11', '11B12', '11B13', '11B14'],
                'gases': ['id-7', 'id-26', 'id-27', 'id-29']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11C'],
                'transactionLabels': ['11C'],
                'gases': ['id-7']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11D01','tr_11D02', 'tr_11D03'],
                'transactionLabels': ['11D1', '11D2', '11D3'],
                'gases': ['id-7', 'id-29']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11E01','tr_11E02', 'tr_11E03', 'tr_11E04'],
                'transactionLabels': ['11E1', '11E2', '11E3', '11E4'],
                'gases': ['id-7']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11F01', 'tr_11F02', 'tr_11F03', 'tr_11F04', 'tr_11F05', 'tr_11F06', 'tr_11F07', 'tr_11F08', 'tr_11F09'],
                'transactionLabels': ['11F1', '11F2', '11F3', '11F4', '11F5', '11F6', '11F7', '11F8', '11F9'],
                'gases': ['id-7', 'id-190', 'id-27', 'id-29']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11H01', 'tr_11H02', 'tr_11H03', 'tr_11H04'],
                'transactionLabels': ['11H1', '11H2', '11H3', '11H4'],
                'gases': ['id-7', 'id-10', 'id-147', 'id-227']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11I'],
                'transactionLabels': ['11I'],
                'gases': []
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11J'],
                'transactionLabels': ['11J'],
                'gases': ['id-7']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11K'],
                'transactionLabels': ['11K'],
                'gases': []
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11L'],
                'transactionLabels': ['11L'],
                'gases': []
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11M'],
                'transactionLabels': ['11M'],
                'gases': ['id-1']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11N'],
                'transactionLabels': ['11N'],
                'gases': ['id-1']
            },
            {
                'form': 'F7_s11EquImportTable',
                'code': 1400,
                'transactions': ['tr_11O'],
                'transactionLabels': ['11O'],
                'gases': ['id-1']
            },
        ];


        $scope.validateUnusualGasSelection = function () {
            $scope.instance.FGasesReporting.unusualGasChoises = {};
            $scope.instance.FGasesReporting.unusualGasChoises.unusualGas = [];
            $scope.calculateValidateUnusualGasSelection($scope.unusualGasValidationsGroup1, 'unusualGasesG1');
        }

        $scope.calculateValidateUnusualGasSelection = function (group, outputGroup) {

            $scope.errors[outputGroup] = [];

            for (var i = 0; i < group.length; i++) {

                var qcRules = group[i];

                for (var j = 0; j < $scope.instance.FGasesReporting.ReportedGases.length; j++) {

                    var gas = $scope.instance.FGasesReporting.ReportedGases[j];

                    var isInWhiteList = $scope.isGasInWhiteList(qcRules, gas);

                    if (!isInWhiteList && qcRules.gases.length > 0) {

                        for (var m = 0; m < qcRules.transactions.length; m++) {

                            var transactionErrors = clone($scope.transactionValidationErrorsTemplate);
                            transactionErrors.transaction = qcRules.transactions[m];
                            transactionErrors.transactionLabel = qcRules.transactionLabels[m];
                            transactionErrors.errors = [];

                            var gasElement = $scope.getGasElementFor(j, qcRules.transactions[m]);
                            if ((gasElement.Amount != null && gasElement.Amount != '') ||
                                    (gasElement.SumOfPartnerAmounts != null && gasElement.SumOfPartnerAmounts != '' && gasElement.SumOfPartnerAmounts != 0)) {
                                var errorVar = clone($scope.validationErrorTemplate);
                                //'QCCode' : '', 'gasIndex': '', 'tradePartnerId': '', 'type': '', 'message' : ''
                                errorVar.QCCode = qcRules.code;
                                errorVar.gasIndex = j;
                                errorVar.isNonBlocker = true;
                                transactionErrors.errors.push(errorVar);
                                $scope.errors[outputGroup].push(transactionErrors);

                                // Saving information to instance
                                var unusualGas = {
                                    'gasIndex': j,
                                    'gasName': $scope.instance.FGasesReporting.ReportedGases[j].Name,
                                    'gasCode': $scope.instance.FGasesReporting.ReportedGases[j].Code,
                                    'gasId': $scope.instance.FGasesReporting.ReportedGases[j].GasId,
                                    'contains': "",
                                    'transaction': qcRules.transactions[m],
                                    'qc': qcRules.code,
                                    'confirmed': false
                                };

                                $scope.instance.FGasesReporting.unusualGasChoises.unusualGas.push(unusualGas);
                            }
                        }
                    }
                }
            }
            $scope.updateValidationMessages(outputGroup);
        };
        $scope.isGasInWhiteList = function (qcRules, gas) {
            // Starting to match whether the selected gas contains any components from the qcRules.gases array
            var isInWhitelist = false;

            for (var k = 0; k < qcRules.gases.length; k++) {

                // First testing the gas main component
                if ('id-' + gas.GasId == qcRules.gases[k]) {
                    isInWhitelist = true;
                    break;
                }
            }
            return isInWhitelist;
        };
        $scope.getWhitelistQCRule = function(whitelist, transactionCode, gas){
            for (var i = 0; i < whitelist.length; i++) {
                var qcRules = whitelist[i];
                if (qcRules.transactionLabels.indexOf(transactionCode) > -1) {
                    return qcRules;
                }
            }
            return null;
        };
        $scope.whitelistQCRuleContainsGas = function(whitelist, transactionCode, gas) {
            var qcRule = 
                    $scope.getWhitelistQCRule(whitelist, transactionCode, gas);
            return ( qcRule !== null && 
                    Array.isArray(qcRule.gases) && 
                    qcRule.gases.length > 0);
        };
        $scope.getQC1400Translation = function(whitelist, transactionCode, gas){
            var containsGas = 
                    $scope.whitelistQCRuleContainsGas(whitelist, transactionCode, gas);
            
            var m = "validation_messages.qc_1400_empty_gas_list.error_text";
            if(!containsGas) {
                m =  "validation_messages.qc_1400.error_text";;
            } 
            
            return $translate.instant(m, {
                code: transactionCode,
                gas: gas.Name
            });
        };
        $scope.showWhitelistModalWindow = function(whitelist, transactionCode, gas){
            for (var i = 0; i < whitelist.length; i++) {
                var isInWhiteList = true;
                var qcRules = whitelist[i];
                if (qcRules.transactionLabels.indexOf(transactionCode) > -1) {
                    isInWhiteList = $scope.isGasInWhiteList(qcRules, gas);
                    break;
                }
            }
            return !isInWhiteList;
        };
        $scope.confirmNotInWhitelist = function (transactionCode, gas, tr, amountElem, confirmFunc, cancelFunc) {
            if (tr[amountElem] > 0) {
                var whitelist =  $scope.unusualGasValidationsGroup1;
                var showModalWindow = $scope.showWhitelistModalWindow(whitelist, transactionCode, gas);
                if (showModalWindow) {
                    var errorMessage = $scope.getQC1400Translation(whitelist, transactionCode, gas);
                    messageBox.confirm(errorMessage, function(accept){
                        if(accept) {
                            if(angular.isDefined(confirmFunc)){
                                confirmFunc(transactionCode, gas, tr, amountElem);
                            }
                        }else {
                            if(angular.isDefined(cancelFunc)){
                                cancelFunc(transactionCode, gas, tr, amountElem);
                            }else {
                                tr.Amount = null;
                            }
                            
                        }
                    });
                }
            }
        };

        // ------------------------------------------
        // End of validation part
        // ------------------------------------------


        // ------------------------------------------
        // Start form submission related issues
        // ------------------------------------------

        $scope.submitReport = function () {
            if (transactionYearProvider.getTransactionYear() !== transactionYearProvider._maxTransactionYear()){
                if ( confirm("In this reporting season, reports on 2016 are expected. This report currently refers to 2015 (maybe because you copied an older delivery as a starting point).\n" +
                        "Do you want to set the transaction year to 2016 [OK], or should 2015 be kept as the transaction year [Cancel]?")){
                    $scope.instance.FGasesReporting.GeneralReportData.TransactionYear = 2016 ;
                    $scope.onTransactionYearChanged( $scope.calculateOverallValidationStatus );
                    alert('Transaction year has been set to 2016. Registry and stock data for 2016 are loaded. Please review sections 4 and 9 of the report.');
                    return;
                }
            }
            $scope.calculateOverallValidationStatus();
            var save = false;
            
            if ($scope.formTotalValidated) {
                $scope.instance.FGasesReporting.GeneralReportData['@status'] = "completed";
                save = true;
            } else {
                save = confirm("Please note that a submission of this report will be automatically rejected as not acceptable.");
            }
            
            if (!save) {
                return;
            }
            
            dataRepository.saveInstanceXml($scope.instance).error(function () {
                $notification.error("Save", "Data is not saved due to technical problems!");
            }).success(function (response) {
                if (response.code === 0) {
                    $notification.error("Save", "Data is not saved due to technical problems!");
                    return;
                }
                
                $scope.submitted = true;
                $scope.appForm.$setPristine(true);
                $scope.$root.allowNavigation();
                $notification.success("Save", "Data is saved successfully.");
                $scope.close();
            });
        };

        $scope.reopenReport = function () {
            $scope.calculateOverallValidationStatus();
            $scope.instance.FGasesReporting.GeneralReportData['@status'] = "incomplete";
            if (transactionYearProvider.getTransactionYear() !== transactionYearProvider._maxTransactionYear()){
                if ( confirm("In this reporting season, reports on 2016 are expected. This report currently refers to 2015 (maybe because you copied an older delivery as a starting point).\n" +
                        "Do you want to set the transaction year to 2016 [OK], or should 2015 be kept as the transaction year [Cancel]?")){
                    $scope.instance.FGasesReporting.GeneralReportData.TransactionYear = 2016 ;
                    $scope.onTransactionYearChanged( $scope.calculateOverallValidationStatus );
                    alert('Transaction year has been set to 2016. Registry and stock data for 2016 are loaded. Please review sections 4 and 9 of the report.');
                    return;
                }
            }
        };

        $scope.isFormSubmitted = function () {
            if ($scope.instance.FGasesReporting.GeneralReportData['@status'] == "completed") {
                return true;
            } else {
                return false;
            }
        };

        // ------------------------------------------
        // End form submission related issues
        // ------------------------------------------

        // Re calculation of sheet values.

        //This function recalculates all values related to sheet1
        $scope.reCalculateSheet1 = function () {
            var formId = 'F1_S1_4_ProdImpExp';

            //calculate total gas reports
            var totalRowCalculations = ['tr_01A', 'tr_02A', 'tr_03A'];
            for (var i = 0; i < totalRowCalculations.length; i++) {
                $scope.doCalculationTotalForRow(formId, totalRowCalculations[i]);
            }

            //calculate trading partner total amounts and execute necessary formulas
            var tradingPartnerTotalAmounts = ['tr_01C'];
            var fieldsToCalculate = ['tr_01D', 'tr_01H', 'tr_01K', 'tr_03C', 'tr_04D', 'tr_04E', 'tr_04I', 'tr_04J', 'tr_08D'];

            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                //sum trading partner values
                for (var i = 0; i < tradingPartnerTotalAmounts.length; i++) {
                    $scope.calculateTradingPartnerTotalAmount($scope.instance.FGasesReporting[formId].Gas[gasIndex][tradingPartnerTotalAmounts[i]]);
                }
                //calculate formula based fields
                $scope.doCalculationForFields(gasIndex, fieldsToCalculate);
            }
        }; //end of function reCalculateSheet1

        //This function recalculates all values related to sheet2
        $scope.reCalculateSheet2 = function () {
            var formId = 'F2_S5_exempted_HFCs';

            //calculate trading partner total amounts and execute necessary formulas
            var tradingPartnerTotalAmounts = ['tr_05A', 'tr_05B', 'tr_05C', 'tr_05D', 'tr_05E', 'tr_05F', 'tr_05R'];
            var fieldsToCalculate = ['tr_05G', 'tr_04D', 'tr_04I', 'tr_04M'];

            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                //sum trading partner values
                for (var i = 0; i < tradingPartnerTotalAmounts.length; i++) {
                    $scope.calculateTradingPartnerTotalAmount($scope.instance.FGasesReporting[formId].Gas[gasIndex][tradingPartnerTotalAmounts[i]]);
                }
                //calculate formula based fields
                $scope.doCalculationForFields(gasIndex, fieldsToCalculate);
            }

            //calculate total gas reports
            var totalRowCalculations = ['tr_05G', 'tr_05I', 'tr_05J'];
            $scope.doCalculationTotalForRowForSheet2(formId, totalRowCalculations);
            //end finally re-calculate 5C_exempted
            $scope.doCalculationTotalForRow(formId, 'tr_05C');
        }; //end of function reCalculateSheet2

        //This function recalculates all values related to sheet3
        $scope.reCalculateSheet3 = function () {
            var formId = 'F3A_S6A_IA_HFCs';

            //execute necessary formulas
            var fieldsToCalculate = ['tr_06X', 'tr_06W'];

            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                //calculate formula based fields
                $scope.doCalculationForFields(gasIndex, fieldsToCalculate);
            }
        }; //end of function reCalculateSheet3

        //This function recalculates all values related to sheet4
        $scope.reCalculateSheet4 = function () {
            $scope.calculateCo2EqForSheet4();

            if (!$scope.isSheet4VerificationRequired()) {
                $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.Verified = false;
                var documents = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.SupportingDocuments.Document;

                while (documents.length > 0) {
                    $scope.remove(documents, 0, documents[0], false);
                }
            }
        }; //end of function reCalculateSheet4

        $scope.isSheet4VerificationRequired = function() {
            return $scope.isTr_09COver10000() || $scope.tr05CValueHasValueDefined();
        };

        $scope.isTr_09COver10000 = function () {
            return $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09C.Amount >= 10000;
        };

        $scope.tr05CValueHasValueDefined = function () {
            var gases = $scope.instance.FGasesReporting.F2_S5_exempted_HFCs.Gas;
            for(var i=0; i < gases.length;i++) {
                var gasObject = gases[i];
                var tradePartners = gasObject.tr_05C.TradePartner;
                for(var j=0; j<tradePartners.length; j++) {
                    var tradePartner = tradePartners[j];
                    if(tradePartner.amount > 0) {
                        return true;
                    }
                }
            }
            return false;
        };
        //This function recalculates all values related to sheet6
        $scope.reCalculateSheet6 = function () {
            var formId = 'F6_FUDest';

            //execute necessary formulas
            var fieldsToCalculate = ['tr_08D'];

            for (var gasIndex = 0; gasIndex < $scope.instance.FGasesReporting.ReportedGases.length; gasIndex++) {
                //calculate formula based fields
                $scope.doCalculationForFields(gasIndex, fieldsToCalculate);
            }

            //calculate total gas reports
            var totalRowCalculations = ['tr_07A', 'tr_08D'];
            for (var i = 0; i < totalRowCalculations.length; i++) {
                $scope.doCalculationTotalForRow(formId, totalRowCalculations[i]);
            }
        }; //end of function reCalculateSheet6

        $scope.removeFirst = function (array) {
            if (!array) {
                return;
            }

            //For arrays are specified as
            // <item>
            //  <code></code>
            //  <label></label>
            // </item
            if (angular.isDefined(array[0].code) && array[0].code === "") {
                array.splice(0, 1);
                return array;
            }

            //For grouped arrays
            //<group>
            //  <name></name>
            //  <additionalInfo></additionalInfo>
            //  <item>
            //      <code/>
            //      <label/>
            //  </item>
            //</group>
            if (angular.isDefined(array[0].item) && array[0].item.code === "") {
                array.splice(0, 1);
                return array;
            }

            return array;
        };

        // get code list label by code
        $scope.getCodeListLabel = function (codelist, code) {
            //Do not try to get codeList before it actually exists.
            if (!$scope.codeList) {
                return;
            }

            //Escape codelists that are not arrays by default (has only one element)
            // This code can be removed when changes are made to codeList file.
            if (!($scope.codeList.FGasesCodelists[codelist].item.length > 0)
                    && $scope.codeList.FGasesCodelists[codelist].item.code == code) {
                return $scope.codeList.FGasesCodelists[codelist].item.label;
            }

            var retValue;
            for (var i = 0; i <= $scope.codeList.FGasesCodelists[codelist].item.length - 1; i++) {
                if ($scope.codeList.FGasesCodelists[codelist].item[i].code == code) {
                    retValue = $scope.codeList.FGasesCodelists[codelist].item[i].label;
                    break;
                }
            }
            return retValue;
        };

        $scope.getInstanceByPath = function (root, identifier) {
            if (!$scope.instance) {
                return null;
            }

            var tokens = root.split(".");
            var result = $scope;
            while (tokens.length) {
                result = result[tokens.shift()];
                if (!result) {
                    return null;
                }
            }

            tokens = identifier.split(".");
            while (tokens.length) {
                result = result[tokens.shift()];
            }

            return result;
        };

        // save instance data.
        $scope.saveInstance = function(saveOptions) {
            $scope.submitted = true;
            var options = objectUtil.defaultIfNull(saveOptions, { });
            dataRepository.saveInstanceXml($scope.instance).error(function () {
                $notification.error("Save", "System Error. Data is not saved !");
            }).success(function (response) {
                if ( response.code === 0 ) {
                    $notification.error("Save", "System Error. Data is not saved !");
                    return;
                }
                if (!options.validationOff && $scope.appForm.$invalid) {
                    $notification.warning("Save", "Warning! Data is saved, but the questionnaire contains validation errors.");
                } else {
                    $notification.success("Save", "Data is saved successfully.");
                }
            });
            $scope.appForm.$setPristine(true);
        };

        $scope.validationOnOff = function () {
            $scope.submitted = !$scope.submitted;
        };

        // save instance data.
        $scope.close = function () {
            if (baseUri == '') {
                baseUri = "/"
            }
            ;
            var windowLocation = (envelope && envelope.length > 0) ? envelope : baseUri;
            if ($scope.appForm.$dirty) {
                if (confirm('You have made changes in the questionnaire! \n\n Do you want to leave without saving the data?')) {
                    window.location = windowLocation;
                }
            } else {
                //console.log("Failed to confirm");
                window.location = windowLocation;
            }
        };
        // convert XML to HTML in new window.
        $scope.printPreview = function () {
            dataRepository.saveInstanceXml($scope.instance).success(function () {
                var win = window.open($scope.conversionLink, '_blank');
                win.focus;
            });
        };

        $scope.windowSearch = window.location.search;

        $scope.phoneNumberPattern = /^[ 0-9\(\)\+\-]{7,25}$/;
        $scope.positiveIntegerPattern = /^\d+$/;
        $scope.decimalNumberPattern = /^\d*\.?\d*$/;
        $scope.websiteAddressPattern = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;
        $scope.percentage = (function () {
            return {
                test: function (value) {

                    if ($scope.decimalNumberPattern.test(value) &&
                            0 <= value &&
                            value <= 100)
                    {
                        return true;
                    } else {
                        return false;
                    }
                }
            };
        })();

        $scope.isFixedQuestion = function (dataPath) {
            var tokens = dataPath.split('.');
            var lastToken = tokens.pop();
            //console.log(lastToken);
            //console.log(lastToken == 'FixedQuestion');
            return (lastToken == 'FixedQuestion');
        };

        $scope.clearSubFormData = function (dataPaths, identifierPath, changeValueTo) {

            var elementCount = 0;
            for (var i = 0; i < dataPaths.length; i++) {
                var formElementInstance = $scope.getInstanceByPath('instance.FGasesReporting', dataPaths[i]);
                elementCount += countNonEmptyProperties(formElementInstance, $scope.isFixedQuestion(dataPaths[i]));
            }

            // Need to get parent path of yes/no question otherwise assigning new value
            // to property does not work.
            var tokens = identifierPath.split('.');

            // Parent property of actual yes/no question
            var subFormInstanceIdentifier = tokens.shift();

            // Parent instance object that contains actual yes/no question property
            var parentInstance = $scope.getInstanceByPath('instance.FGasesReporting', subFormInstanceIdentifier);
            var objectName = tokens.shift();

            var needsToClearData = true;

            if (needsToClearData) {
                // When element count is more than 0 then we have to ask confirmation from user whether to delete the data.
                if (elementCount > 0 && !confirm('When changing answer all data under this sub-form will be lost?')) {
                    // toke.shift() extracts yes/no question name.
                    // Assing yes value to question
                    parentInstance[objectName] = changeValueTo;
                    return;
                } else {
                    for (var i = 0; i < dataPaths.length; i++) {
                        var formElementInstance = $scope.getInstanceByPath('instance.FGasesReporting', dataPaths[i]);

                        // For fields where there is only one field and it can be null. Just ignore it.
                        if (!formElementInstance) {
                            continue;
                        }

                        // This if-else is to differentiate just a string field from array or object.
                        if (formElementInstance instanceof Array || !formElementInstance.length) {
                            clearObject(formElementInstance, $scope.isFixedQuestion(dataPaths[i]));
                        } else {
                            var tokens = dataPaths[i].split('.');
                            var objectIdentifier = tokens.shift();
                            var parentObject = $scope.getInstanceByPath('instance.FGasesReporting', objectIdentifier);
                            parentObject[tokens.shift()] = null;
                        }
                    }
                }
            } else {
                // Do nothing.
            }
        };
        $scope.configureUploader = new function () {
            var uploadUri;
            var domain = getDomain(window.location.href);

            if (isEmpty(envelope)) {
                //just for testing - uploads XML file to WebQ sesison files (does not require authentication).
                uploadUri = domain + "/" + baseUri + "/uploadXml";
                $scope.uploader.alias = "userFiles";
            } else {
                var webqUri = getWebQUrl('/restProxyFileUpload');
                uploadUri = domain + webqUri + "&uri=" + envelope + "/manage_addDocument";
            }
            $scope.uploader.url = uploadUri;
            $scope.uploader.onErrorItem = function (item, response, status, headers) {
                alert("Document upload failed! Please try again.");
                $scope.uploader.clearQueue();
            };
        };

        $scope.uploadFile = function (documentPath) {
            $scope.uploader.onSuccessItem = function (item, response, status, headers) {
                // TODO check if the document was uploaded to envelope
                newDocument = $scope.addItem(documentPath, { Url: null, Title: null });
                if (!isEmpty(envelope)) {
                    newDocument.Url = envelope + "/" + item.file.name;
                } else {
                    //testing
                    newDocument.Url = getDomain(window.location.href) + "/" + baseUri + "/" + item.file.name;
                }
                $scope.saveInstance({ validationOff: true });
                $scope.uploader.clearQueue();

                if (documentPath == 'FGasesReporting.F7_s11EquImportTable.SupportingDocuments.Document') {
                    $scope.calculateForm7Totals();
                }
            };
            //$files: an array of files selected, each file has name, size, and type.
            for (var i = 0; i < $scope.uploader.queue.length; i++) {
                var item = $scope.uploader.queue[i];
                item.upload();
            }
        };

        $scope.removeDocument = function (documnetArray, index, document) {
            if (confirm("Do you want to delete document '" + document.Url + "' ?")) {
                //TODO remove from BDR
                $scope.remove(documnetArray, index, document);
            }
        };

        $scope.gotoTab = function (tab) {
            $scope.sendCdrPing();
            tabService.gotoTab(tab);
            //call ng click events, when a tab is clicked
            $scope.onTabChange(tab);
        };//end of method gotoTab
        $scope.sendCdrPing = function () {
            if (!isEmpty(envelope)) {

                //var url = getWebQUrl('/restProxy') + '&uri=' + encodeURIComponent(envelope + "/webqKeepAlive");
                var url = envelope + "/webqKeepAlive";
                $http.get(url, {withCredentials: true}).success(function (data) {
                });
            }

        }

        // this function contains conditions for each tab (if it is visible or not)
        $scope.isTabVisible = function (tabId) {
            //create two main conditions
            var mainCondition = angular.isDefined($scope.instance) && $scope.instance.FGasesReporting.GeneralReportData['@status'] != 'completed';
            var subMainCondition = mainCondition && $scope.instance.FGasesReporting.GeneralReportData.Company['@status'] == 'confirmed';
            var atLeastOneActivitySelected =
                    mainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['P'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['I']
                            || $scope.instance.FGasesReporting.GeneralReportData.Activities['E'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['FU']
                            || $scope.instance.FGasesReporting.GeneralReportData.Activities['D'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I']
                            || $scope.instance.FGasesReporting.GeneralReportData.Activities['auth'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['auth-NER']);

            var nilSelected = mainCondition && $scope.instance.FGasesReporting.GeneralReportData.Activities['NIL-Report'];
            //switch over tab id
            switch (tabId) {
                case 'CompanyInfo':
                    return mainCondition;
                case 'Activities':
                    return subMainCondition;
                case 'Gases':
                    return subMainCondition && atLeastOneActivitySelected;
                case 'Submission':
                    return (subMainCondition && (atLeastOneActivitySelected || nilSelected))
                            || (angular.isDefined($scope.instance) && $scope.instance.FGasesReporting.GeneralReportData['@status'] == 'completed');
                case 'Sheet1':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['P'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['I'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['E']);
                case 'Sheet2':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['P-HFC'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['I-HFC']);
                case 'Sheet3':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['P'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['I']);
                case 'Sheet4':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['P-HFC'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['I-HFC'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['auth']);
                case 'Sheet5':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['auth'] && $scope.instance.FGasesReporting.GeneralReportData.Activities['auth-NER']);
                case 'Sheet6':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['FU'] || $scope.instance.FGasesReporting.GeneralReportData.Activities['D']);
                case 'Sheet7':
                    return subMainCondition && ($scope.instance.FGasesReporting.GeneralReportData.Activities['Eq-I']);
                default:
                    return true;
            }
        };//end of function isTabVisible

        $scope.onTabChange = function(tabId) {
            $scope.valMsgIndex = 0;
            
            switch (tabId) {
                case 'CompanyInfo':
                    break;
                case 'Activities':
                    break;
                case 'Gases':
                    break;
                case 'Submission':
                    $scope.calculateOverallValidationStatus();
                    break;
                case 'Sheet1':
                    break;
                case 'Sheet2':
                    break;
                case 'Sheet3':
                    break;
                case 'Sheet4':
                    $scope.reCalculateSheet4();
                    break;
                case 'Sheet5':
                    $scope.onSheet5Selected();
                    break;
                case 'Sheet6':
                    break;
                case 'Sheet7':
                    $scope.calculateForm7Totals();
                    break;
                default:
                    break;
            }
            
            $scope.sendCdrPing();
        };

        $scope.getValMsgIndex = function() {
            return $scope.valMsgIndex;
        };
        
        $scope.setValMsgIndex = function(value) {
            $scope.valMsgIndex = value;
        };

        $scope.gotoNextTab = function (activeTabIndex) {
            var i = 0;
            for (i = activeTabIndex + 1; i < FormConstants.TabIds.length; i++) {
                if ($scope.isTabVisible(FormConstants.TabIds[i])) {
                    break;
                }
            }

            if (i > activeTabIndex && i < FormConstants.TabIds.length) {
                $scope.gotoTab(FormConstants.TabIds[i]);
            }
        };//end of method gotoNextTab

        $scope.gotoPreviousTab = function (activeTabIndex) {
            var i = 0;
            for (i = activeTabIndex - 1; i >= 0; i--) {
                if ($scope.isTabVisible(FormConstants.TabIds[i])) {
                    break;
                }
            }

            if (i < activeTabIndex && i >= 0) {
                $scope.gotoTab(FormConstants.TabIds[i]);
            }
        };//end of method gotoPreviousTab

        $scope.isLastTab = function (activeTabIndex) {
            var countTabs = 0;
            var currentTabIdx = 0;
            for (var i = 0; i < FormConstants.TabIds.length; i++) {
                if ($scope.isTabVisible(FormConstants.TabIds[i])) {
                    if (FormConstants.TabIds[i] == FormConstants.TabIds[activeTabIndex]) {
                        currentTabIdx = countTabs;
                    }
                    countTabs++;
                }
            }
            return currentTabIdx == countTabs - 1;
        };//end of method gotoNextTab

        $scope.onSheet5Selected = function() {
            $scope.updateTradePartnersOnSheet5();
        };

// chages for sheet5

        // When a new Parner is created on sheet5 this is called
        $scope.createSumsArrayItem = function (newPartnerId) {
            $scope.instance.FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS1.tr_10A.push({"Amount": 0.0, "TradePartnerID": newPartnerId});
            $scope.instance.FGasesReporting.F5_S10_Auth_NER.SumOfAllHFCsS2.tr_10A.push({"Amount": 0.0, "TradePartnerID": newPartnerId});
        };


        // When a new trading partner is created on sheet5 this is called 
        $scope.createNewSupportingDocument = function (newPartnerId) {
            $scope.instance.FGasesReporting.F5_S10_Auth_NER.SupportingDocuments.tr_10A.push({
                Document: [],
                TradePartnerID: newPartnerId
            });
        };

        $scope.updateTradePartnersOnSheet5 = function () {
            var section10 = $scope.instance.FGasesReporting.F5_S10_Auth_NER;
            var sheet4Tr09ATradePartners = viewModel.sheet4.section9.getTr09ATradePartners();
            var sheet5Tr10ATradePartners = section10.tr_10A_TradePartners.Partner;
            // iterate all trade partners in sheet4 tr09A
            arrayUtil.forEach(sheet4Tr09ATradePartners, function(sheet4Tr09TradePartner) {
                var sheet5Tr10APartnerIndex = arrayUtil.indexOf(sheet5Tr10ATradePartners, function(sheet5Tr10ATradePartner) {
                    return sheet5Tr10ATradePartner.PartnerId === sheet4Tr09TradePartner.PartnerId;
                });
                
                if (sheet5Tr10APartnerIndex  > -1) {
                    if (sheet5Tr10APartnerIndex < sheet5Tr10ATradePartners.length) {
                        section10.tr_10A_TradePartners.Partner[sheet5Tr10APartnerIndex] = clone(sheet4Tr09TradePartner);
                    }
                    
                    return;
                }
                
                sheet5Tr10APartnerIndex = arrayUtil.indexOf(sheet5Tr10ATradePartners, function(sheet5Tr10ATradePartner) {
                    if (sheet5Tr10ATradePartner.isEUBased !== sheet4Tr09TradePartner.isEUBased) {
                        return false;
                    }
                    
                    if (sheet5Tr10ATradePartner.isEUBased) {
                        return sheet5Tr10ATradePartner.EUVAT === sheet4Tr09TradePartner.EUVAT;
                    }
                    else {
                        if (!stringUtil.equalsIgnoreCase(sheet5Tr10ATradePartner.CompanyName, sheet4Tr09TradePartner.CompanyName)) {
                            return false;
                        }
                        
                        return sheet5Tr10ATradePartner.NonEUCountryCodeOfEstablishment === sheet4Tr09TradePartner.NonEUCountryCodeOfEstablishment;
                    }
                });
                
                if (sheet5Tr10APartnerIndex < 0) {
                    section10.tr_10A_TradePartners.Partner.push(clone(sheet4Tr09TradePartner));
                    $scope.createSumsArrayItem(sheet4Tr09TradePartner.PartnerId);
                    $scope.createNewSupportingDocument(sheet4Tr09TradePartner.PartnerId);
                    for (var j = 0; j < section10.Gas.length; j++) {
                        section10.Gas[j].tr_10A.TradePartner.push({
                            Comment: null,
                            TradePartnerID: sheet4Tr09TradePartner.PartnerId,
                            amount: null
                        });
                    }
                }
                else {
                    section10.tr_10A_TradePartners.Partner[sheet5Tr10APartnerIndex] = clone(sheet4Tr09TradePartner);
                    section10.SumOfAllHFCsS1.tr_10A[sheet5Tr10APartnerIndex].TradePartnerID = sheet4Tr09TradePartner.PartnerId;
                    section10.SumOfAllHFCsS2.tr_10A[sheet5Tr10APartnerIndex].TradePartnerID = sheet4Tr09TradePartner.PartnerId;
                    section10.SupportingDocuments.tr_10A[sheet5Tr10APartnerIndex].TradePartnerID = sheet4Tr09TradePartner.PartnerId;
                    
                    arrayUtil.forEach(section10.Gas, function(section10Gas) {
                        section10Gas.tr_10A.TradePartner[sheet5Tr10APartnerIndex].TradePartnerID = sheet4Tr09TradePartner.PartnerId;
                    });
                }
            });
        };
        
        $scope.isTradePartnerFrom09A_imp = function(tradePartner) {
            var tradePartners09A_imp = $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_imp_TradePartners.Partner;
            return arrayUtil.contains(tradePartners09A_imp, function(tradePartner09A_imp) {
                return tradePartner09A_imp.PartnerId === tradePartner.PartnerId;
            });
        };
        
        $scope.isTradePartnerFromSheet4 = function(tradePartner) {
            var sheet4Tr09ATradePartners = viewModel.sheet4.section9.getTr09ATradePartners();
            return arrayUtil.contains(sheet4Tr09ATradePartners, function(sheet4TradePartner) {
                return sheet4TradePartner.PartnerId === tradePartner.PartnerId;
            });
        };
        
        $scope.gasContainsComment = function(gasArray, propertyName) {
            for(var i=0; i<gasArray.length;i++) {
                var gas = gasArray[i];
                var item = gas[propertyName];
                if(angular.isUndefined(item.Comment) || item.Comment === null) {
                    return false;
                }
            }
            return true;
        };        
        $scope.valueGreaterThanZero = function(inputValue) {
            return angular.isDefined(inputValue) && inputValue !== null &&
                    inputValue > 0;
        }
        $scope.floatValueGreaterThanZero = function(value) {
            var inputValue = parseFloat(value);
            return $scope.valueGreaterThanZero(inputValue);
        }
        $scope.integerValueGreaterThanZero = function(value) {
            var inputValue = parseInt(value);
            return $scope.valueGreaterThanZero(inputValue);
        }
        
        $scope.hasValue = function(data) {
            return angular.isDefined(data) && data !== null && data !== "";
        };
        
        $scope.stringNotEmpty = function(data) {
            return data !== null && angular.isString(data) && data.length > 0;
        };

        $scope.mandatoryCommentForTr02B = function(gasIndex) {
            var data = $scope.getCommentDataForTr02B(gasIndex);
            var caption = $scope.getCommentModalCaptionForTr02B(gasIndex);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.reCalculateSheet1();
            }, $translate.instant( "sheet1.tr-02b-mandatory-comment" ) );
        };

        $scope.getCommentDataForTr02B = function(gasIndex) {
            return $scope.instance.FGasesReporting.F1_S1_4_ProdImpExp.Gas[gasIndex].tr_02B;
        };

        $scope.getCommentModalCaptionForTr02B = function(gasIndex) {
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            return "[gas] re-exports in products (2B)".replace("[gas]", gasName);
        };

        $scope.openCommentModalForTr02B = function(gasIndex) {
            var data = $scope.getCommentDataForTr02B(gasIndex);
            $scope.openCommentModal(data);
        };
        
        $scope.mandatoryCommentForTr05B = function(gasIndex, tradePartnerIndex) {
            var data = $scope.getCommentDataForTr05B(gasIndex, tradePartnerIndex);
            var caption = $scope.getCommentModalCaptionForTr05B(gasIndex, tradePartnerIndex);
            $scope.mandatoryCommentForGasAmountTradePartner(data, caption, function() {
                $scope.reCalculateSheet2();
            }, $translate.instant( "validation_messages.qc_1401.error_text" ));
        };
        
        $scope.openCommentModalForTr05B = function(gasIndex, tradePartnerIndex) {
            var data = $scope.getCommentDataForTr05B(gasIndex, tradePartnerIndex);
            $scope.openCommentModalTradePartner(data);
        };
        
        $scope.getCommentDataForTr05B = function(gasIndex, tradePartnerIndex) {
            return $scope.instance.FGasesReporting.F2_S5_exempted_HFCs.Gas[gasIndex].tr_05B.TradePartner[tradePartnerIndex];
        };
        
        $scope.getCommentModalCaptionForTr05B = function(gasIndex, tradePartnerIndex) {
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            var tradePartnerName = viewModel.sheet2.section5.getTr05BTradePartners()[tradePartnerIndex].CompanyName;
            
            return "[gas] supplies to [company]".replace("[gas]", gasName).replace("[company]", tradePartnerName);
        };
        
        $scope.mandatoryCommentForTr06L = function(gasIndex) {
            var data = $scope.getCommentDataForTr06L(gasIndex);
            var caption = $scope.getCommentModalCaptionForTr06L(gasIndex);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.doCalculationForFields(gasIndex, ['tr_06W']);
            } , $translate.instant( "validation_messages.qc_1401.error_text" ));
        };
        $scope.openCommentModalForTr06L= function(gasIndex) {
            var data = $scope.getCommentDataForTr06L(gasIndex);
            $scope.openCommentModal(data);
        };
        $scope.getCommentDataForTr06L = function(gasIndex) {
            return $scope.instance.FGasesReporting.F3A_S6A_IA_HFCs.Gas[gasIndex].tr_06L;
        };
        
        $scope.getCommentModalCaptionForTr06L = function(gasIndex) {
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            
            return "[gas] feedstock use".replace("[gas]", gasName);
        };
        
        $scope.mandatoryCommentForTr06T = function(gasIndex) {
            var data = $scope.getCommentDataForTr06T(gasIndex);
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            var caption = "[gas] other or unknown application".replace("[gas]", gasName);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.doCalculationForFields(gasIndex, ['tr_06W']);
            }, $translate.instant("validation_messages.qc_1403_06T.error_text", {
                gasName: gasName
            }));
        };
        
        $scope.openCommentModalForTr06T = function(gasIndex) {
            var data = $scope.getCommentDataForTr06T(gasIndex);
            $scope.openCommentModal(data);
        };
        
        $scope.getCommentDataForTr06T = function(gasIndex) {
            return $scope.instance.FGasesReporting.F3A_S6A_IA_HFCs.Gas[gasIndex].tr_06T;
        };
        
        $scope.mandatoryCommentForTr06U = function(gasIndex) {
            var data = $scope.getCommentDataForTr06U(gasIndex);
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            var caption = "[gas] leakage".replace("[gas]", gasName);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.doCalculationForFields(gasIndex, ['tr_06W']);
            }, $translate.instant("validation_messages.qc_1403_06U.error_text", {
                gasName: gasName
            }));
        };
        
        $scope.openCommentModalForTr06U = function(gasIndex) {
            var data = $scope.getCommentDataForTr06U(gasIndex);
            $scope.openCommentModal(data);
        };
        
        $scope.getCommentDataForTr06U = function(gasIndex) {
            return $scope.instance.FGasesReporting.F3A_S6A_IA_HFCs.Gas[gasIndex].tr_06U;
        };
        
        $scope.mandatoryCommentForTr06V = function(gasIndex) {
            var data = $scope.getCommentDataForTr06V(gasIndex);
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            var caption = "[gas] accountancy adjustments".replace("[gas]", gasName);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.doCalculationForFields(gasIndex, ['tr_06W']);
            }, $translate.instant("validation_messages.qc_1403_06V.error_text", {
                gasName: gasName
            }));
        };
        
        $scope.openCommentModalForTr06V = function(gasIndex) {
            var data = $scope.getCommentDataForTr06V(gasIndex);
            $scope.openCommentModal(data);
        };
        
        $scope.getCommentDataForTr06V = function(gasIndex) {
            return $scope.instance.FGasesReporting.F3A_S6A_IA_HFCs.Gas[gasIndex].tr_06V;
        };
        
        $scope.mandatoryCommentForTr07A = function(gasIndex) {
            var data = $scope.getCommentDataForTr07A(gasIndex);
            var caption = $scope.getCommentModalCaptionForTr07A(gasIndex);
            $scope.mandatoryCommentForGasAmount(data, caption, function() {
                $scope.reCalculateSheet6();
            }, $translate.instant( "validation_messages.qc_1401.error_text" ));
        };
        
        $scope.openCommentModalForTr07A = function(gasIndex) {
            var data = $scope.getCommentDataForTr07A(gasIndex);
            $scope.openCommentModal(data);
        };
        
        $scope.getCommentDataForTr07A = function(gasIndex) {
            return $scope.instance.FGasesReporting.F6_FUDest.Gas[gasIndex].tr_07A;
        };
        
        $scope.getCommentModalCaptionForTr07A = function(gasIndex) {
            var gasName = viewModel.getReportedGases()[gasIndex].Name;
            
            return "[gas] feedstock use".replace("[gas]", gasName);
        };
        
        $scope.mandatoryCommentForTr09A_add = function(tradePartnerIndex) {
            var data = $scope.getCommentDataForTr09A_add(tradePartnerIndex);
            var caption = $scope.getCommentModalCaptionForTr09A_add(tradePartnerIndex);
            $scope.mandatoryCommentForGasAmountTradePartner(data, caption, function() {
                $scope.reCalculateSheet4();
            }, $translate.instant('sheet4.tr-09A_add-mandatory-comment'));
        };
        
        $scope.openCommentModalForTr09A_add = function(tradePartnerIndex) {
            var data = $scope.getCommentDataForTr09A_add(tradePartnerIndex);
            $scope.openCommentModalTradePartner(data);
        };
        
        $scope.getCommentDataForTr09A_add = function(tradePartnerIndex) {
            return $scope.instance.FGasesReporting.F4_S9_IssuedAuthQuata.tr_09A_add.TradePartner[tradePartnerIndex];
        };
        
        $scope.getCommentModalCaptionForTr09A_add = function(tradePartnerIndex) {
            var tradePartnerName = viewModel.sheet4.section9.getTr09ATradePartners()[tradePartnerIndex].CompanyName;
            
            return "Authorizations to [company]".replace("[company]", tradePartnerName);
        };
        
        $scope.mandatoryCommentForGasAmountTradePartner = function(data, confirmationCaption, resetAmountCallback, bodyText) {
            if(numericUtil.toNum(data.amount, 0) !== 0 && stringUtil.isBlank(data.Comment)) {
                $scope.showCommentConfirmationModalTradePartner(data, confirmationCaption, resetAmountCallback, bodyText);
            }else {
                $scope.resetGasCommentTradePartner(data);
            }
        };
        
        $scope.showCommentConfirmationModalTradePartner = function (data, confirmationCaption, resetAmountCallback, bodyText) { 
            commentModalService.open($scope, 'lg', 'comment-confirmation-modal.html', 'ConfirmCommentDialogController', data, function(){
                $scope.openCommentModalTradePartner(data, resetAmountCallback);
            }, function(){
                $scope.onTradePartnerGasAmountCommentReset(data, resetAmountCallback);
            }, {
                title: confirmationCaption,
                body: bodyText
            });
            
        };
        
        $scope.openCommentModalTradePartner = function(data, resetAmountCallback) {
            var onCommentReset = null;
            
            if (!objectUtil.isNull(resetAmountCallback)) {
                onCommentReset = function() {
                    $scope.onTradePartnerGasAmountCommentReset(data, resetAmountCallback);
                };
            }
            
            commentModalService.open($scope, 'lg', 'CommentAddEditModal.html', 'CommentAddEditModalInstanceController', data, onCommentReset, onCommentReset);
        };
        
        $scope.onTradePartnerGasAmountCommentReset = function(data, callback) {
            if(stringUtil.isBlank(data.Comment)) {
                data.amount = null;
                objectUtil.call(callback);
            }
        };
        
        $scope.resetGasCommentTradePartner = function(data) {
            if(numericUtil.toNum(data.amount, 0) === 0) {
                data.Comment = null;
            }
        };
        
        $scope.mandatoryCommentForGasAmount = function(data, confirmationCaption, resetAmountCallback, bodyText) {
            if(numericUtil.toNum(data.amount, 0) !== 0 && stringUtil.isBlank(data.Comment)) {
                $scope.showCommentConfirmationModal(data, confirmationCaption, resetAmountCallback, bodyText);
            }else {
                $scope.resetGasComment(data);
            }
        };
        
        $scope.showCommentConfirmationModal = function (data, confirmationCaption, resetAmountCallback, bodyText) {
            commentModalService.open($scope, 'lg', 'comment-confirmation-modal.html', 'ConfirmCommentDialogController', data, function(){
                $scope.openCommentModal(data, resetAmountCallback);
            }, function(){
                if(stringUtil.isBlank(data.Comment)) {
                    data.Amount = null;
                    objectUtil.call(resetAmountCallback);
                }
            }, {
                title: confirmationCaption,
                body: bodyText
            });
            
        };
        
        $scope.openCommentModal = function(data, resetAmountCallback) {
            var onCommentReset = null;
            
            if (!objectUtil.isNull(resetAmountCallback)) {
                onCommentReset = function() {
                    if(stringUtil.isBlank(data.Comment)) {
                        data.Amount = null;
                        objectUtil.call(resetAmountCallback);
                    }
                };
            }
            
            commentModalService.open($scope, 'lg', 'CommentAddEditModal.html', 'CommentAddEditModalInstanceController', data, onCommentReset, onCommentReset);
        };
        
        $scope.resetGasComment = function(data) {
            if(numericUtil.toNum(data.Amount, 0) === 0) {
                data.Comment = null;
            }
        };
        $scope.isPositiveNumber = function(number) {
            var expression = parseFloat(number) > 0;
            return expression;
        }
        
        $scope.start();
        
    }); // end of main controller FGases "questionnaire"
    
    
})();
