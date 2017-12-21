
(function() {
    // Directive for gas input fields. It is used as an attribute
    // Unit parameter can be given for non mmt reporting units
    angular.module('FGases.directives').directive('gasInput', [
        
        '$rootScope', '$translate', 'objectUtil', 'stringUtil', 'gasAmountValidator', 'messageBox', 'viewModel',
        
        function ($rootScope, $translate, objectUtil, stringUtil, gasAmountValidator, messageBox, viewModel) {
            return {
                restrict: 'A',
                require: 'ngModel',
                scope: {
                    ngModelValue: '=ngModel'
                },
                link: function (scope, element, attrs, modelCtrl) {
                    //unit can be mmt or co2eq
                    var unit = scope.$eval(attrs.unit) || 'mmt';
                    var threshold = scope.$eval(attrs.threshold) || 1000;
                    var allowNegative = scope.$eval(attrs.allowNegative) || false;
                    var onlyInteger = scope.$eval(attrs.integer) || false;
                    
                    //TODO check better solutions
                    scope.ngModelValueWatchInit = true;
                    //watch changes
                    scope.$watch('ngModelValue', function(newValue, oldValue) {
                        if (scope.ngModelValueWatchInit){
                            //if UI is being initialized, then dont control, just return
                            scope.ngModelValueWatchInit = false;
                            return;
                        }

                        // It's possible that the parameter is modified after initialization.
                        onlyInteger = scope.$eval(attrs.integer)
                        var revert = false, revertAsync = false;;
                        var revertValue = oldValue;
                        
                        switch(unit){
                            case 'co2eq':
                                var metadata = createValidationMetadata(allowNegative, true, null);
                                revert = mustRevert(newValue, metadata, {
                                    onThousandSeparatorError: onThousandSeparatorError
                                });
                                break; //end of 'co2eq' switch
                            case 'mmt': //Metric Ton
                            // 'mmt' is default behaviour, if user enters wrong unit, just process as mmt
                            default:
                                var metadata = createValidationMetadata(allowNegative, onlyInteger, onlyInteger ? null : threshold);
                                revert = mustRevert(newValue, metadata, {
                                    onThousandSeparatorError: onThousandSeparatorError,
                                    onThresholdError: function(eventArgs) {
                                        if (!viewModel.isLargeCompany() && $rootScope.showConfirmationForThreashold && !scope.hasUserOverridenThresholdRevert) {
                                            revertAsync = true;
                                            messageBox.confirm($translate.instant("common.gas-input-mmt-threshold-violation"), function(overrideRevert) {
                                                eventArgs.overrideRevert = overrideRevert;
                                                scope.hasUserOverridenThresholdRevert = scope.hasUserOverridenThresholdRevert || overrideRevert;
                                                messageBox.confirm($translate.instant("common.gas-input-mmt-threshold-violation-dissmiss-dialog"), function(disableConfirmationForThreashold) {
                                                    $rootScope.showConfirmationForThreashold = !disableConfirmationForThreashold;
                                                });
                                                
                                                if (!overrideRevert) {
                                                    revertValue = calculateBellowThresholdValue(newValue, oldValue, threshold);
                                                    performValueRevert(modelCtrl, revertValue);
                                                }
                                            });
                                        }
                                        else {
                                            eventArgs.overrideRevert = true;
                                        }
                                        
                                        if (!eventArgs.overrideRevert && !revertAsync) {
                                            revertValue = calculateBellowThresholdValue(newValue, oldValue, threshold);
                                        }
                                    }
                                });
                                break; //end of default/'mmt' switch
                        }
                        
                        if (revert && !revertAsync) {
                            performValueRevert(modelCtrl, revertValue);
                        }
                    });
                }
            };
            
            function createValidationMetadata(allowNegative, integerOnly, threshold) {
                return {
                    allowNegative: allowNegative,
                    integerOnly: integerOnly,
                    threshold: threshold
                };
            }
            
            function mustRevert(value, metadata, errorHandlers) {
                var validationResult = gasAmountValidator.validate(value, metadata);

                if (validationResult.isSuccess()) {
                    return false;
                }
                
                var eventArgs = {
                    overrideRevert: false
                };
                
                if (validationResult.isThousandSeparatorError()) {
                    objectUtil.call(errorHandlers.onThousandSeparatorError, eventArgs);
                }
                else if (validationResult.isNegativeNumberError()) {
                    objectUtil.call(errorHandlers.onNegativeNumberError, eventArgs);
                }
                else if (validationResult.isDecimalNumberError()) {
                    objectUtil.call(errorHandlers.onDecimalNumberError, eventArgs);
                }
                else if (validationResult.isNaNError()) {
                    objectUtil.call(errorHandlers.onNaNError, eventArgs);
                }
                else if (validationResult.isThresholdError()) {
                    objectUtil.call(errorHandlers.onThresholdError, eventArgs);
                }

                return !eventArgs.overrideRevert;
            }
            
            function onThousandSeparatorError() {
                messageBox.alert($translate.instant('common.gas-input-thousand-separator-error'));
            }
            
            function calculateBellowThresholdValue(newValue, oldValue, threshold) {
                if (stringUtil.isEmpty(oldValue) || Number(oldValue) <= threshold) {
                    return oldValue;
                }
                
                for (var i = newValue.length - 1; i > 0; --i) {
                    var tvalue = newValue.substring(0, i);
                    
                    if (Number(tvalue) <= threshold) {
                        return tvalue;
                    }
                }
                
                return null;
            }
            
            function performValueRevert(modelCtrl, revertValue) {
                var valueToRevert = revertValue;
                
                if (modelCtrl.$isEmpty(revertValue)){
                    valueToRevert = null;
                }
                modelCtrl.$setViewValue(valueToRevert);
                modelCtrl.$render();
            }
            
        } // end of directive definition 'gasInput'
    ]);
    
})();
