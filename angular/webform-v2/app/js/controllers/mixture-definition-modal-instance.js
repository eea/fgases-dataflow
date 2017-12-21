
(function() {
    // definition of mixture definition modal instance controller
    angular.module('FGases.controllers').controller('MixtureDefinitionModalInstanceController', 
    
    function($rootScope, $scope, $modalInstance, modalData, modalExtras, FormConstants, gasHelper, objectUtil, arrayUtil) {
        //define controller variables
        $scope.alerts = [];
        $scope.tempPredefinedGases = {"fgases": null, "nonfgases": null}; //magic change to make it work in multiselect
        $scope.previosLengthOfTempPredefinedFGases = 0;
        $scope.previosLengthOfTempPredefinedNonFGases = 0;

        if (modalData == null){
            //add a new mixture
            $scope.mixtureModalTitle = 'gases.add-mixture';
            var reportedGas = {};
            reportedGas.GasGroup = 'CustomMixture';
            reportedGas.GasId = 'CM_' + Date.now();
            reportedGas.Code = null;
            reportedGas.Name = null;
            reportedGas.IsBlend = true;
            reportedGas.IsCustomComposition = true;
            reportedGas.PreparationCompositions = null;
            reportedGas.GWP_AR4_AnnexIV = null;
            reportedGas.GWP_AR4_HFC = null;
            reportedGas.BlendComponents = {};
            reportedGas.BlendComponents.Component = [];
            $scope.mixtureDefinitionModalData = reportedGas;
        }
        else {
            //update existing mixture
            $scope.tempPredefinedGases.fgases = [];
            $scope.tempPredefinedGases.nonfgases = [];
            $scope.mixtureModalTitle = 'gases.edit-mixture';
            $scope.mixtureDefinitionModalData = angular.copy(modalData);
            //$scope.previosLengthOfTempPredefinedFGases = 0;
            //$scope.previosLengthOfTempPredefinedNonFGases = 0;
            for (var i = 0; i < $scope.mixtureDefinitionModalData.BlendComponents.Component.length; i++){
                var component = $scope.mixtureDefinitionModalData.BlendComponents.Component[i];
                if (!component.IsOther){
                    if (!component.IsNonFGas) {
                        $scope.previosLengthOfTempPredefinedFGases++;
                        $scope.tempPredefinedGases.fgases.push(component.ComponentId);
                    }else {
                        $scope.previosLengthOfTempPredefinedNonFGases++;
                        $scope.tempPredefinedGases.nonfgases.push(component.ComponentId);
                    }
                }
            }
            $scope.previosLengthOfTempPredefinedFGases = $scope.tempPredefinedGases.fgases.length;
            if ($scope.previosLengthOfTempPredefinedFGases == 0){
                $scope.tempPredefinedGases.fgases = null;
            }

            $scope.previosLengthOfTempPredefinedNonFGases = $scope.tempPredefinedGases.nonfgases.length;
            if ($scope.previosLengthOfTempPredefinedNonFGases == 0){
                $scope.tempPredefinedGases.nonfgases = null;
            }
        }

        // addItem can also be used but our model is not mapped in instance.
        $scope.addOtherGas = function(){
            var component = {};
            component.ComponentId = 'CM_OG_' + Date.now();
            component.Code = null;
            component.IsOther = true;
            component.IsNonFGas = null;
            //component.DescriptionIfOther = null;
            component.Percentage = null;
            component.GWP_AR4_AnnexIV = null;
            component.GWP_AR4_HFC = null;
            $scope.mixtureDefinitionModalData.BlendComponents.Component.push(component);
        };

        // update f-gases based on selection
        $scope.mixturePredefinedFGasSelectionChanged = function(listOfGases){
            //if there is nothing, then just return
            if ($scope.tempPredefinedGases.fgases == null){
                return;
            }

            if ($scope.tempPredefinedGases.fgases.length > $scope.previosLengthOfTempPredefinedFGases){
                var i = -1;
                //item added, find it and add to array
                var copyOfSelectedGases = angular.copy($scope.tempPredefinedGases.fgases);
                for (var j = 0; j < $scope.mixtureDefinitionModalData.BlendComponents.Component.length; j++){
                    var component = $scope.mixtureDefinitionModalData.BlendComponents.Component[j];
                    if (!component.IsOther && !component.IsNonFGas && (i = copyOfSelectedGases.indexOf(component.ComponentId)) > -1){
                        copyOfSelectedGases.splice(i, 1);
                    }
                }

                i = copyOfSelectedGases.length;
                while(i--){
                    var component = {};
                    component.GasGroupId = null;
                    component.GasGroup = null;
                    component.ComponentId = copyOfSelectedGases.shift();
                    component.Code = null;
                    component.IsOther = false;
                    component.IsNonFGas = false;
                    //component.DescriptionIfOther = null;
                    component.Percentage = null;
                    component.GWP_AR4_AnnexIV = null;
                    component.GWP_AR4_HFC = null;
                    if (typeof listOfGases !== 'undefined' && !isEmpty(listOfGases) && angular.isArray(listOfGases)){
                        for (var k = 0; k < listOfGases.length; k++){
                            if (component.ComponentId == listOfGases[k].GasId &&
                                    angular.isDefined(listOfGases[k].BlendComponents) && angular.isDefined(listOfGases[k].BlendComponents.Component)){
                                //TODO these part should be update after fgases-gases changed for components as well
                                component.GWP_AR4_AnnexIV = getWeightedGWP(listOfGases[k].BlendComponents.Component);
                                component.GWP_AR4_HFC = getWeightedHFCGWP(listOfGases[k].BlendComponents.Component);
                                component.GasGroup = listOfGases[k].GasGroup;
                                component.GasGroupId = listOfGases[k].GasGroupId;
                                break;
                            }
                        }
                    }
                    $scope.mixtureDefinitionModalData.BlendComponents.Component.push(component);
                }
            }
            else {
                //item removed find it and remove it from array
                var copyOfComponents = angular.copy($scope.mixtureDefinitionModalData.BlendComponents.Component);
                var i = copyOfComponents.length;
                while (i--){
                    if (!copyOfComponents[i].IsOther && !copyOfComponents[i].IsNonFGas && $scope.tempPredefinedGases.fgases.indexOf(copyOfComponents[i].ComponentId) > -1){
                        copyOfComponents.splice(i, 1);
                    }
                }

                var i = copyOfComponents.length;
                while (i--){
                    var toBeRemoved = copyOfComponents.shift();
                    for (var j = 0; j < $scope.mixtureDefinitionModalData.BlendComponents.Component.length; j++){
                        var component = $scope.mixtureDefinitionModalData.BlendComponents.Component[j];
                        if (!component.IsOther && !component.IsNonFGas && component.ComponentId == toBeRemoved.ComponentId){
                            $scope.mixtureDefinitionModalData.BlendComponents.Component.splice(j, 1);
                            break;
                        }
                    }
                }
            }
            $scope.previosLengthOfTempPredefinedFGases = $scope.tempPredefinedGases.fgases.length;
        };// end of function mixturePredefinedFGasSelectionChanged

        // update non f-gases based on selection
        $scope.mixturePredefinedNonFGasSelectionChanged = function(listOfComponets){
            //if there is nothing, then just return
            if ($scope.tempPredefinedGases.nonfgases == null){
                return;
            }

            if ($scope.tempPredefinedGases.nonfgases.length > $scope.previosLengthOfTempPredefinedNonFGases){
                var i = -1;
                //item added, find it and add to array
                var copyOfSelectedGases = angular.copy($scope.tempPredefinedGases.nonfgases);
                for (var j = 0; j < $scope.mixtureDefinitionModalData.BlendComponents.Component.length; j++){
                    var component = $scope.mixtureDefinitionModalData.BlendComponents.Component[j];
                    if (!component.IsOther && component.IsNonFGas && (i = copyOfSelectedGases.indexOf(component.ComponentId)) > -1){
                        copyOfSelectedGases.splice(i, 1);
                    }
                }

                i = copyOfSelectedGases.length;
                while(i--){
                    var component = {};
                    component.GasGroupId = null;
                    component.GasGroup = null;
                    component.ComponentId = copyOfSelectedGases.shift();
                    component.Code = null;
                    component.IsOther = false;
                    component.IsNonFGas = true;
                    //component.DescriptionIfOther = null;
                    component.Percentage = null;
                    component.GWP_AR4_AnnexIV = null;
                    component.GWP_AR4_HFC = null;
                    if (typeof listOfComponets !== 'undefined' && !isEmpty(listOfComponets) && angular.isArray(listOfComponets)){
                        for (var k = 0; k < listOfComponets.length; k++){
                            if (component.ComponentId == listOfComponets[k].ComponentId){
                                component.GWP_AR4_AnnexIV = listOfComponets[k].GWP_AR4_AnnexIV;
                                component.GWP_AR4_HFC = listOfComponets[k].GWP_AR4_HFC;
                                component.GasGroupId = listOfComponets[k].GasGroupId;
                                component.GasGroup = listOfComponets[k].GasGroup;
                                break;
                            }
                        }
                    }
                    $scope.mixtureDefinitionModalData.BlendComponents.Component.push(component);
                }
            }
            else {
                //item removed find it and remove it from array
                var copyOfComponents = angular.copy($scope.mixtureDefinitionModalData.BlendComponents.Component);
                var i = copyOfComponents.length;
                while (i--){
                    if (!copyOfComponents[i].IsOther && copyOfComponents[i].IsNonFGas && $scope.tempPredefinedGases.nonfgases.indexOf(copyOfComponents[i].ComponentId) > -1){
                        copyOfComponents.splice(i, 1);
                    }
                }

                var i = copyOfComponents.length;
                while (i--){
                    var toBeRemoved = copyOfComponents.shift();
                    for (var j = 0; j < $scope.mixtureDefinitionModalData.BlendComponents.Component.length; j++){
                        var component = $scope.mixtureDefinitionModalData.BlendComponents.Component[j];
                        if (!component.IsOther && component.IsNonFGas && component.ComponentId == toBeRemoved.ComponentId){
                            $scope.mixtureDefinitionModalData.BlendComponents.Component.splice(j, 1);
                            break;
                        }
                    }
                }
            }
            $scope.previosLengthOfTempPredefinedNonFGases = $scope.tempPredefinedGases.nonfgases.length;
        };// end of function mixturePredefinedNonFGasSelectionChanged

        //remove added gas for user
        $scope.removeAddedGasFromMixture = function(index){
            var component = $scope.mixtureDefinitionModalData.BlendComponents.Component.splice(index, 1);
            if (!component[0].IsOther){
                if (!component[0].IsNonFGas){
                    var i = $scope.tempPredefinedGases.fgases.indexOf(component[0].ComponentId);
                    $scope.tempPredefinedGases.fgases.splice(i, 1);
                    $scope.previosLengthOfTempPredefinedFGases--;
                }
                else{
                    var i = $scope.tempPredefinedGases.nonfgases.indexOf(component[0].ComponentId);
                    $scope.tempPredefinedGases.nonfgases.splice(i, 1);
                    $scope.previosLengthOfTempPredefinedNonFGases--;
                }
            }
        };

        //define function to calculate sum of mixture
        $scope.calculateSumForMixture = function(mixture, keepPreviousAlerts) {
            var retVal = true;

            keepPreviousAlerts = typeof keepPreviousAlerts !== 'undefined' ? keepPreviousAlerts : false;
            if(!keepPreviousAlerts) {
                $scope.alerts = [];
            }

            var total = -1;
            if (mixture && mixture.IsBlend && mixture.IsCustomComposition && mixture.BlendComponents.Component.length > 0){
                total = 0;
                var invalidInputRangeFound = false;
                for (var i = 0; i < mixture.BlendComponents.Component.length; i++){
                    var val = Number(mixture.BlendComponents.Component[i].Percentage);
                    val = val ? val : 0;
                    total += val;
                    if (val <= 0 || val >=100){
                        invalidInputRangeFound = true;
                    }
                }

                if (invalidInputRangeFound){
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'gases.mixture-input-invalid-range';
                    $scope.alerts.push(alert);
                    retVal = false;
                }

                //for double fields
                if ( ! ( Math.round(parseFloat(total)*10000) == 100 * 10000 )){
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'gases.mixture-total-100';
                    $scope.alerts.push(alert);
                    retVal =  false;
                }
            }
            return retVal;
        };//end of function calculateSumForMixture

        //define OK button action function, actually we dont need result parameter in this case.
        $scope.ok = function(result){
            $scope.alerts = [];

            var includingOtherComponent = false;

            var alphaNumericAndSpaceRegEx = FormConstants.AlphaNumericAndSpaceRegEx;
            var startingAlphaNumeric = FormConstants.StartingAlphaNumeric;
            var commentsRegEx = FormConstants.CommentsRegEx;

            //do validation
            var reportedGas = $scope.mixtureDefinitionModalData;

            //check if name is defined for mixture
            if (reportedGas.Code == null || reportedGas.Code.length == 0){
                var alert = {};
                alert.type = 'danger';
                alert.msg = 'gases.mixture-name-missing';
                $scope.alerts.push(alert);
            //} else if(!alphaNumericAndSpaceRegEx.test(reportedGas.Code) ||
            //            !startingAlphaNumeric.test(reportedGas.Code)) {
            } else if (!commentsRegEx.test(reportedGas.Code) || reportedGas.Code.length < 2){
                //check for alpha numeric characters and at least having one latin letter
                var alert = {};
                alert.type = 'danger';
                alert.msg = 'gases.mixture-name-should-contain-alpha-numeric-characters';
                $scope.alerts.push(alert);
            }


            var numberOfGases = reportedGas.BlendComponents.Component.length;
            if (numberOfGases < 2){
                $scope.alerts = [];
                var alert = {};
                alert.type = 'danger';
                alert.msg = 'gases.select-at-least-two-gases';
                $scope.alerts.push(alert);
                return; //user should at least choose two elements
            }

            for (var i = 0; i < numberOfGases; i++){
                var component = reportedGas.BlendComponents.Component[i];
                if (component.IsOther){
                    includingOtherComponent = true;
                    if (component.Code == null || component.Code.length == 0) {
                        var alert = {};
                        alert.type = 'danger';
                        alert.msg = 'gases.define-name-and-desc-for-other-gas';
                        $scope.alerts.push(alert);
                    } else if (!commentsRegEx.test(component.Code) || component.Code.length < 2){
                        //check for alpha numeric characters and at least having one latin letter
                        var alert = {};
                        alert.type = 'danger';
                        alert.msg = 'gases.other-gas-name-should-contain-alpha-numeric-characters';
                        $scope.alerts.push(alert);
                    }
                }
            }

            //check if sum is correct
            $scope.calculateSumForMixture(reportedGas, true);

            //set GWP values
            $scope.mixtureDefinitionModalData.GWP_AR4_AnnexIV = getWeightedGWP($scope.mixtureDefinitionModalData.BlendComponents.Component);
            $scope.mixtureDefinitionModalData.GWP_AR4_HFC = getWeightedHFCGWP($scope.mixtureDefinitionModalData.BlendComponents.Component);

            //now check if mixture is in pre-defined list (if it is given as parameter). It should not include 'Other' gas to be checked.
            if (angular.isDefined(modalExtras) && (angular.isDefined(modalExtras.preDefinedMixtureList) || angular.isDefined(modalExtras.existingCustomMixtures))){
                var preDefinedGasList = [];
                
                if (angular.isDefined(modalExtras.preDefinedMixtureList)){
                    preDefinedGasList = preDefinedGasList.concat(modalExtras.preDefinedMixtureList);
                }
                
                if (angular.isDefined(modalExtras.existingCustomMixtures)){
                    preDefinedGasList = preDefinedGasList.concat(modalExtras.existingCustomMixtures);
                }

                var matchFound = arrayUtil.selectSingle(preDefinedGasList, function(gas) {
                    if (!objectUtil.isNull(modalData) && modalData.GasId === gas.GasId) {
                        return false;
                    }
                    
                    return gasHelper.mixtureEquals(gas, $scope.mixtureDefinitionModalData);
                });

                //do not compare by itself
                if (matchFound != null && (modalData == null || modalData.GasId != matchFound.GasId)){
                    //TODO localization is missing here :\
                    //The mixture specified is identical to the known [mixture name from shortlist] mixture. Please revise the composition or select [mixture name from shortlist] for your report.
                    var alert = {};
                    alert.type = 'danger';
                    alert.msg = 'The mixture specified is identical to ';

                    if (matchFound.IsCustomComposition){
                        alert.msg += 'the previously defined [' + matchFound.Name + '] custom mixture. Please revise the composition or use [' + matchFound.Name + '] for your report.';
                    }else {
                        alert.msg += 'the known [' + matchFound.Name + '] mixture. Please revise the composition or select [' + matchFound.Name + '] for your report.';
                    }
                    $scope.alerts.push(alert);
                }
            }


            if ($scope.alerts.length == 0) {
                var results = {};
                //set mixture name same with code
                $scope.mixtureDefinitionModalData.Name = $scope.mixtureDefinitionModalData.Code;
                results.mixture = $scope.mixtureDefinitionModalData;
                if (angular.isDefined(modalExtras) && angular.isDefined(modalExtras.index)){
                    //update existing mixture
                    results.index = modalExtras.index;
                }
                else {
                    //add new mixture
                    results.index = -1;
                }
                $modalInstance.close(results);
            }
        };//end of ok function

        //define CANCEL button action function
        $scope.cancel = function(){
            $modalInstance.dismiss('cancel');
        };//end of cancel function

    });//end of app controller 'MixtureDefinitionModalInstanceController'
})();
