
(function() {
    // Definition of trading partner modal instance controller
    angular.module('FGases.controllers').controller('TradingPartnerModalInstanceController', function($rootScope, $scope, $modalInstance, modalData, modalExtras, FormConstants, dataRepository, objectUtil, arrayUtil, stringUtil) {
        $scope.tradePartnerModalTitle = modalExtras && typeof modalExtras.title !== 'undefined' ? modalExtras.title : 'common.trade-partner-modal-title';
        $scope.isMinimalDialog = modalExtras && modalExtras.isMinimalDialog;
        
        if (!angular.isDefined(modalExtras.arrayToPush)){
            alert("Trade Partner array is not defined, data entered may be lost.");
        }

        if(angular.isDefined(modalExtras.index)){
            //Note: modalData can be used instead of this. it is matter of choice.
            var pd = modalExtras.arrayToPush[modalExtras.index];
            $scope.tempPartnerDefinition = {
                "PartnerId": pd.PartnerId,
                "CompanyName": pd.CompanyName,
                "isEUBased": pd.isEUBased,
                "EUVAT": pd.EUVAT,
                "NonEUCountryOfEstablishment": pd.NonEUCountryOfEstablishment,
                "NonEUCountryCodeOfEstablishment": pd.NonEUCountryCodeOfEstablishment,
                "NonEUDgClimaRegCode": pd.NonEUDgClimaRegCode,
                "NonEURepresentativeName": pd.NonEURepresentativeName,
                "NonEURepresentativeVAT": pd.NonEURepresentativeVAT,
                "QCWarning": pd.QCWarning
            };
            //Now set correct NonEUCountryOfEstablishment object
            if (!pd.isEUBased && angular.isDefined(modalExtras.nonEuCountries)){
                for (var i = 0; i < modalExtras.nonEuCountries.length; i++){
                    var concept = modalExtras.nonEuCountries[i];
                    if (pd.NonEUCountryCodeOfEstablishment == concept['@id']){
                        $scope.tempPartnerDefinition.NonEUCountryOfEstablishment = concept;
                        break;
                    }
                }
            }
            $scope.isEUBasedClicked = true;
        }else{
            $scope.tempPartnerDefinition = {
                "PartnerId": "TradePartner_" + Date.now(),
                "CompanyName": null,
                "isEUBased": null,
                "EUVAT": null,
                "NonEUCountryOfEstablishment": null,
                "NonEUCountryCodeOfEstablishment": null,
                "NonEUDgClimaRegCode": null,
                "NonEURepresentativeName": null,
                "NonEURepresentativeVAT": null,
                "QCWarning": null
            };
            $scope.isEUBasedClicked = false;
        }

        $scope.fieldName = modalExtras && typeof modalExtras.fieldName !== 'undefined' ? modalExtras.fieldName : '';

        $scope.isOnlyEU = $scope.fieldName.substr(0, 5) === "tr_05" && $scope.fieldName !== "tr_05C";

        if ($scope.isOnlyEU){
            $scope.tempPartnerDefinition.isEUBased = true;
            $scope.isEUBasedClicked = true;
        }

        //define controller variables
        $scope.alerts = [];
        $scope.warnings = [];
        $scope.previouslyStoredQcWwarnings = 0;
        if ($scope.tempPartnerDefinition.QCWarning != null){
            if (!angular.isArray($scope.tempPartnerDefinition.QCWarning)){
                $scope.tempPartnerDefinition.QCWarning = [$scope.tempPartnerDefinition.QCWarning];
            }

            $scope.previouslyStoredQcWwarnings = $scope.tempPartnerDefinition.QCWarning.length;

            for (var i = 0; i < $scope.tempPartnerDefinition.QCWarning.length; i++){
                var warning = {};
                warning.msg = 'validation_messages.qc_' + $scope.tempPartnerDefinition.QCWarning[i] + '.error_text';
                $scope.warnings.push(warning);
            }
        }
        $scope.tradingPartnerModalData = angular.copy(modalData);

        //define on click function for EU Based
        $scope.euBasedClicked = function(){
            $scope.isEUBasedClicked = true;

            if ($scope.tempPartnerDefinition.isEUBased){
                $scope.tempPartnerDefinition.NonEUCountryOfEstablishment = null;
                $scope.tempPartnerDefinition.NonEUCountryCodeOfEstablishment = null;
                $scope.tempPartnerDefinition.NonEUDgClimaRegCode = null;
                $scope.tempPartnerDefinition.NonEURepresentativeName = null;
                $scope.tempPartnerDefinition.NonEURepresentativeVAT = null;
            }
            else {
                $scope.tempPartnerDefinition.EUVAT = null;
            }
        };//end of function euBasedClicked

        $scope.alert = function(msg){
           alert(msg);
        };

        //define OK button action function
        $scope.ok = function(result){
            $scope.alerts = [];
            $scope.warnings = [];
            $scope.tempPartnerDefinition.QCWarning = [];
            if ($scope.tempPartnerDefinition.CompanyName == null || $scope.tempPartnerDefinition.CompanyName.length < 2){
                var alert = {};
                alert.type = 'danger';
                alert.msg = 'common.trading-partner-company-name-should-be-at-least-two-characters';
                $scope.alerts.push(alert);
            }
            else {
                //check for alpha numeric characters and at least having one latin letter
                //var alphaNumericAndSpaceRegEx = FormConstants.AlphaNumericAndSpaceRegEx;
                //var startingAlphaNumeric = FormConstants.StartingAlphaNumeric;
                var commentsRegEx = FormConstants.CommentsRegEx;
                if (!commentsRegEx.test($scope.tempPartnerDefinition.CompanyName)){
                //if(!alphaNumericAndSpaceRegEx.test($scope.tempPartnerDefinition.CompanyName) ||
                //    !startingAlphaNumeric.test($scope.tempPartnerDefinition.CompanyName)){
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-company-name-should-contain-alpha-numeric-characters';
                    $scope.alerts.push(alert);
                }
            }

            if ($scope.tempPartnerDefinition.isEUBased == null){
                var alert = {};
                alert.type = 'danger';
                alert.msg = 'common.trading-partner-set-eu-based-field';
                $scope.alerts.push(alert);
            }else if ($scope.tempPartnerDefinition.isEUBased){
                if ($scope.tempPartnerDefinition.EUVAT == null || $scope.tempPartnerDefinition.EUVAT.length == 0){
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-all-fields-should-be-set';
                    $scope.alerts.push(alert);
                }
            }else if ($scope.tempPartnerDefinition.NonEUCountryOfEstablishment == null || $scope.tempPartnerDefinition.NonEUCountryOfEstablishment['@id'] == null ||
                    (!$scope.isMinimalDialog && ($scope.tempPartnerDefinition.NonEUDgClimaRegCode == null || $scope.tempPartnerDefinition.NonEUDgClimaRegCode.length == 0)) ||
                    (!$scope.isMinimalDialog && ($scope.tempPartnerDefinition.NonEURepresentativeName == null || $scope.tempPartnerDefinition.NonEURepresentativeName.length == 0)) ||
                    (!$scope.isMinimalDialog && ($scope.tempPartnerDefinition.NonEURepresentativeVAT == null || $scope.tempPartnerDefinition.NonEURepresentativeVAT.length == 0)) ) {
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-all-fields-should-be-set';
                    $scope.alerts.push(alert);
            }

            if (!$scope.tempPartnerDefinition.isEUBased && $scope.fieldName.substr(0, 5) === "tr_05" && $scope.fieldName !== "tr_05C") {
                //QC 1061
                var alert = {};
                alert.type = 'danger';
                alert.msg = "common.trading-partner-must-be-eu";
                $scope.alerts.push(alert);
            }

            //first check if VAT is valid, and then check for if it is found in envelope (same applies to registration code)
            var vat = $scope.tempPartnerDefinition.isEUBased ? $scope.tempPartnerDefinition.EUVAT : $scope.tempPartnerDefinition.NonEURepresentativeVAT;
            if (!isEmpty(vat)) {
                var vatProblemFound = false;
                if ($scope.fieldName === "tr_05C" && vat === $rootScope.vat) {
                    //QC 1068
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-own-vat';
                    $scope.alerts.push(alert);
                    vatProblemFound = true;
                }

                if ( vat.length <= 3 || ! ( /[a-zA-Z]{2}\-?[0-9]/.test(vat) ) ){
                    //QC 1060 & 1064
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-vat-not-registered';
                    $scope.alerts.push(alert);
                    vatProblemFound = true;
                }

                //Now check if company is in previously defined trade partner list. QC 2097
                if ($scope.tempPartnerDefinition.isEUBased && !vatProblemFound){
                    var tradePartnersArray = modalExtras.arrayToPush;
                    if (tradePartnersArray != null && tradePartnersArray.length > 0){
                        var indexToSkip = angular.isDefined(modalExtras.index) ? modalExtras.index : -1;
                        for (var i = 0; i < tradePartnersArray.length; i++){
                            if (i != indexToSkip && vat == tradePartnersArray[i].EUVAT){
                                var alert = {};
                                alert.type = 'danger';
                                alert.msg = 'common.trading-partner-already-exist';
                                $scope.alerts.push(alert);
                            }
                        }
                    }
                }
            }

            //registration code checks
            if (!$scope.tempPartnerDefinition.isEUBased) {
                if ($scope.isMinimalDialog) {
                    var indexToSkip = angular.isDefined(modalExtras.index) ? modalExtras.index : -1;
                    
                    arrayUtil.forEach(modalExtras.arrayToPush, function(tradePartner, loopContext) {
                        if (loopContext.index === indexToSkip) {
                            return;
                        }
                        
                        if (tradePartner.isEUBased) {
                            return;
                        }
                        
                        if (objectUtil.isNull($scope.tempPartnerDefinition.NonEUCountryOfEstablishment)) {
                            return;
                        }
                        
                        if (!stringUtil.equalsIgnoreCase($scope.tempPartnerDefinition.CompanyName, tradePartner.CompanyName)) {
                            return;
                        }
                        
                        if ($scope.tempPartnerDefinition.NonEUCountryOfEstablishment['@id'] === tradePartner.NonEUCountryCodeOfEstablishment) {
                            $scope.alerts.push({
                                type: 'danger',
                                msg: 'common.trading-partner-already-exist'
                            });
                        }
                    });
                }
                else if (!isEmpty($scope.tempPartnerDefinition.NonEUDgClimaRegCode)) {
                    var regCodeProblemFound = false;
                    if ($scope.fieldName === "tr_05C" && $scope.tempPartnerDefinition.NonEUDgClimaRegCode == $rootScope.companyId) {
                        //QC 1069
                        var alert = {};
                        alert.type = 'danger';
                        alert.msg = 'common.trading-partner-own-id';
                        $scope.alerts.push(alert);
                        regCodeProblemFound = true;
                    }


                    if ($scope.tempPartnerDefinition.NonEUDgClimaRegCode.length <= 3) {
                        var alert = {};
                        alert.type = 'danger';
                        alert.msg = 'common.trading-partner-reg-code-not-registered';
                        $scope.alerts.push(alert);
                        regCodeProblemFound = true;
                    }

                    //Now check if company is in previously defined trade partner list. QC 2097
                    if (!regCodeProblemFound){
                        var tradePartnersArray = modalExtras.arrayToPush;
                        if (tradePartnersArray != null && tradePartnersArray.length > 0){
                            var indexToSkip = angular.isDefined(modalExtras.index) ? modalExtras.index : -1;
                            for (var i = 0; i < tradePartnersArray.length; i++){
                                if (i != indexToSkip && $scope.tempPartnerDefinition.NonEUDgClimaRegCode == tradePartnersArray[i].NonEUDgClimaRegCode){
                                    var alert = {};
                                    alert.type = 'danger';
                                    alert.msg = 'common.trading-partner-already-exist';
                                    $scope.alerts.push(alert);
                                }
                            }
                        }
                    }
                }
            }

            // check VAT code exists in company registry service. do this operation after there is no other error
            // Exception: does not apply to 5C_voluntary
            if ($scope.tempPartnerDefinition.isEUBased == null || $scope.alerts.length > 0 || $scope.fieldName == "tr_05R") {
                $scope.checkAndCloseIfSuccess();
                return;
            }
            
            if ($scope.isMinimalDialog) {

                if ($scope.tempPartnerDefinition.isEUBased) {
                    dataRepository.checkCompanyExistByVat(vat).error(function () {
                                    $scope.alert("Failed to connect F-Gases portal to validate VAT number. Please try to insert company a bit later!");
                    }).success(function (companyData) {
                    // EU company VAT code must be registered in portal and have a portal code.
                    // non-EU company OR_VAT doesn't have to be registered as a separate company, but it has to be registered under non-EU copmany. This is checked by QC2074
                    if ( companyData == null || companyData.exists == null || companyData.exists == false ) {
                        $scope.checkAndCloseIfSuccess();
                        return;
                    }
                        var companyName = $scope.tempPartnerDefinition.CompanyName;
                        //$scope.alert("2. dataRepository.checkCompanyExistByVatAndName(vat, companyName) - //QC 2064");
                        dataRepository.checkCompanyExistByVatAndName($scope.tempPartnerDefinition.EUVAT, $scope.tempPartnerDefinition.CompanyName).error(function () {
                            $scope.alert("Failed to connect F-Gases portal to validate VAT number. Please try to insert company a bit later!");
                        }).success(function (companyData) {
                            //QC 2064
                            if (companyData == null || companyData.exists == null || companyData.exists == false) {
                                var alert = {};
                                var qcCode = 2064;
                                alert.msg = 'validation_messages.qc_' + qcCode + '.error_text';
                                $scope.warnings.push(alert);
                                $scope.tempPartnerDefinition.QCWarning.push(qcCode);
                            }
                            $scope.checkAndCloseIfSuccess();
                        });
                    });
                }else {
                     $scope.checkAndCloseIfSuccess();
                     return;
                 }
            }
            
            //QC 1060 & 1064 & 2074
            //$scope.alert("1. dataRepository.checkCompanyExistByVat(vat) - //QC 1060 & 1064 & 2074");
            dataRepository.checkCompanyExistByVat(vat).error(function () {
                $scope.alert("Failed to connect F-Gases portal to validate VAT number. Please try to insert company a bit later!");
            }).success(function (companyData) {
                // EU company VAT code must be registered in portal and have a portal code.
                // non-EU company OR_VAT doesn't have to be registered as a separate company, but it has to be registered under non-EU copmany. This is checked by QC2074
                if (companyData == null || companyData.exists == null || (companyData.exists == false && $scope.tempPartnerDefinition.isEUBased)) {
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'common.trading-partner-vat-not-registered';
                    $scope.alerts.push(alert);
                }else if ($scope.tempPartnerDefinition.isEUBased){
                    var companyName = $scope.tempPartnerDefinition.CompanyName;
                    //$scope.alert("2. dataRepository.checkCompanyExistByVatAndName(vat, companyName) - //QC 2064");
                    dataRepository.checkCompanyExistByVatAndName($scope.tempPartnerDefinition.EUVAT, $scope.tempPartnerDefinition.CompanyName).error(function () {
                        $scope.alert("Failed to connect F-Gases portal to validate VAT number. Please try to insert company a bit later!");
                    }).success(function (companyData) {
                        //QC 2064
                        if (companyData == null || companyData.exists == null || companyData.exists == false) {
                            var alert = {};
                            var qcCode = 2064;
                            alert.msg = 'validation_messages.qc_' + qcCode + '.error_text';
                            $scope.warnings.push(alert);
                            $scope.tempPartnerDefinition.QCWarning.push(qcCode);
                        }
                        $scope.checkAndCloseIfSuccess();
                    });
                } else {//now check for non - eu based controls
                    //QC 1063 & 2074
                    //$scope.alert("3. dataRepository.checkCompanyExistById($scope.tempPartnerDefinition.NonEUDgClimaRegCode) - //QC 1063 & 2074");
                    dataRepository.checkCompanyExistById($scope.tempPartnerDefinition.NonEUDgClimaRegCode).error(function () {
                        $scope.alert("Failed to connect F-Gases portal to validate registry code. Please try to insert company a bit later!");
                    }).success(function (companyData) {
                        //QC 1063, this should be updated to check only code
                        if (companyData == null || companyData.exists == null || companyData.exists == false) {
                            var alert = {};
                            alert.type = 'danger';
                            alert.msg = 'common.trading-partner-reg-code-not-registered';
                            $scope.alerts.push(alert);
                        }
                        else {
                            //$scope.alert("4. dataRepository.checkCompanyExistByIdAndName($scope.tempPartnerDefinition.NonEUDgClimaRegCode, $scope.tempPartnerDefinition.CompanyName) - //QC 2075");
                            //QC 2075
                            dataRepository.checkCompanyExistByIdAndName($scope.tempPartnerDefinition.NonEUDgClimaRegCode, $scope.tempPartnerDefinition.CompanyName).error(function () {
                                $scope.alert("Failed to connect F-Gases portal to validate registry code. Please try to insert company a bit later!");
                            }).success(function (companyData) {
                                if (companyData == null || companyData.exists == null || companyData.exists == false) {
                                    var alert = {};
                                    var qcCode = 2075;
                                    alert.msg = 'validation_messages.qc_' + qcCode + '.error_text';
                                    $scope.warnings.push(alert);
                                    $scope.tempPartnerDefinition.QCWarning.push(qcCode);
                                }

                                //QC 2074: previously missed part, checking combinations and compare vat stored in db
                                //$scope.alert("5. dataRepository.checkCompanyExistByIdAndCountryCodeOrVat($scope.tempPartnerDefinition.NonEUDgClimaRegCode, $scope.tempPartnerDefinition.NonEUCountryOfEstablishment['@id'], vat) - //QC 2074");
                                dataRepository.checkCompanyExistByIdAndCountryCodeOrVat($scope.tempPartnerDefinition.NonEUDgClimaRegCode, $scope.tempPartnerDefinition.NonEUCountryOfEstablishment['@id'], $scope.tempPartnerDefinition.NonEURepresentativeVAT).error(function () {
                                    $scope.alert("Failed to connect F-Gases portal to validate registry code. Please try to insert company a bit later!");
                                }).success(function (companyData) {
                                    if (companyData == null || companyData.exists == null || companyData.exists == false) {
                                        var alert = {};
                                        alert.type = 'danger';
                                        alert.msg = 'common.trading-partner-country-does-not-match-for-given-reg-code';
                                        $scope.alerts.push(alert);
                                    }

                                    //$scope.alert("6. dataRepository.checkCompanyExistByVatAndName(vat, companyName) - //QC 2076");
                                    dataRepository.checkCompanyExistByIdOrNameOrVat($scope.tempPartnerDefinition.NonEUDgClimaRegCode, $scope.tempPartnerDefinition.NonEURepresentativeName, $scope.tempPartnerDefinition.NonEURepresentativeVAT).error(function () {
                                        $scope.alert("Failed to connect F-Gases portal to validate VAT number. Please try to insert company a bit later!");
                                    }).success(function (companyData) {
                                        //QC 2076
                                        if (companyData == null || companyData.exists == null || companyData.exists == false) {
                                            var alert = {};
                                            var qcCode = 2076;
                                            alert.msg = 'validation_messages.qc_' + qcCode + '.error_text';
                                            $scope.warnings.push(alert);
                                            $scope.tempPartnerDefinition.QCWarning.push(qcCode);
                                        }
                                        $scope.checkAndCloseIfSuccess();
                                    });
                                });
                            });
                        }
                    });
                }
            });
            
        };//end of ok function

        // checks if there is no error and closes in case of success. called from ok function
        $scope.checkAndCloseIfSuccess = function(){
            if ($scope.alerts.length == 0) {
                var results = {};

                if ($scope.warnings.length > 0){

                    if ($scope.previouslyStoredQcWwarnings != $scope.tempPartnerDefinition.QCWarning.length){
                        alert("Please check warning messages and confirm by clicking 'Ok' button again.");
                        $scope.previouslyStoredQcWwarnings = $scope.tempPartnerDefinition.QCWarning.length;
                        return;
                    }

                    // no need to show double warning
                    //if (!confirm("There are warnings regarding to data of this partner, do you want to continue?")){
                    //    return;
                    //}
                }

                if (!$scope.tempPartnerDefinition.isEUBased){
                    //When closing store country code and labels on different fields
                    $scope.tempPartnerDefinition.NonEUCountryCodeOfEstablishment =  $scope.tempPartnerDefinition.NonEUCountryOfEstablishment['@id'];
                    $scope.tempPartnerDefinition.NonEUCountryOfEstablishment =  $scope.tempPartnerDefinition.NonEUCountryOfEstablishment.prefLabel[0]['@value'];
                }
                results.tempPartnerDefinition = $scope.tempPartnerDefinition;
                results.modalExtras = modalExtras;
                if (angular.isDefined(modalExtras) && angular.isDefined(modalExtras.index)){
                    //update existing trade partner
                    results.index = modalExtras.index;
                }
                else {
                    //add new trade partner
                    results.index = -1;
                }
                $modalInstance.close(results);
            }
        };//end of checkAndCloseIfSuccess function

        //define CANCEL button action function
        $scope.cancel = function(){
            $modalInstance.dismiss('cancel');
        };//end of cancel function
    });//end of app controller 'TradingPartnerModalInstanceController'
})();
