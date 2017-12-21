
(function() {
    angular.module('FGases.helper').factory('gasHelper', [
        
        'FormConstants', 'jsonNormalizer', 'objectUtil', 'arrayUtil', 'numericUtil',
        
        function(FormConstants, jsonNormalizer, objectUtil, arrayUtil, numericUtil) {
            
            function GasHelper() { }
            
            GasHelper.prototype.isUnspecifiedMix = function(gasObject) {
                return gasObject.GasId == FormConstants.UnspecifiedGasMixId;
            };
            
            GasHelper.prototype.isHfcBasedGas = function(gasObject) {
                return containsHFCUtilFn(gasObject) || this.isUnspecifiedMix(gasObject);
            };
            
            GasHelper.prototype.calculateSum = function(gasAmounts) {
                var sum = 0.0;
                
                arrayUtil.forEach(gasAmounts, function(gasAmount) {
                    if (!objectUtil.isNull(gasAmount.amount)) {
                        sum += gasAmount.amount;
                    }
                });
                
                return sum;
            };
            
            GasHelper.prototype.calculateSumOfAllCO2Eq = function(reportedGases, gasAmounts) {
                var gwpSelector = function(reportedGas) {
                    return reportedGas.GWP_AR4_AnnexIV;
                };
                var weightedGwpCalculator = function(gasComponents) {
                    return getWeightedGWP(gasComponents);
                };
                return this._calculateSumOfCO2Eq(reportedGases, gasAmounts, gwpSelector, weightedGwpCalculator);
            };
            
            GasHelper.prototype.calculateSumOfHfcCO2Eq = function(reportedGases, gasAmounts) {
                var gwpSelector = function(reportedGas) {
                    return null; // force calculation of Full HFC GWP
                };
                var weightedGwpCalculator = function(gasComponents) {
                    return getWeightedFullHfcGwp(gasComponents);
                };
                return this._calculateSumOfCO2Eq(reportedGases, gasAmounts, gwpSelector, weightedGwpCalculator);
            };
            
            GasHelper.prototype._calculateSumOfCO2Eq = function(reportedGases, gasAmounts, gwpSelector, weightedGwpCalculator) {
                var sum = 0.0;
                
                arrayUtil.forEach(gasAmounts, function(gasAmount) {
                    var reportedGas = arrayUtil.selectSingle(reportedGases, function(gas) {
                        return gas.GasId === gasAmount.id;
                    });
                    
                    if (objectUtil.isNull(gasAmount.amount)) {
                        return;
                    }
                    
                    var weightedGWP = objectUtil.call(gwpSelector, reportedGas);
                    
                    if (objectUtil.isNull(weightedGWP)) {
                        weightedGWP = objectUtil.call(weightedGwpCalculator, reportedGas.BlendComponents.Component);
                        
                        if (objectUtil.isNull(weightedGWP) || isNaN(weightedGWP)) {
                            return;
                        }
                    }
                    
                    sum += weightedGWP * gasAmount.amount;
                });
                
                return Math.round(sum);
            };
            
            GasHelper.prototype.mixtureEquals = function(gas1, gas2) {
                if (gas1 === gas2) {
                    return true;
                }
                
                var mix1Components = this.getBlendComponents(gas1);
                var mix2Components = this.getBlendComponents(gas2);
                
                if (mix1Components.length !== mix2Components.length) {
                    return false;
                }
                
                var result = true;
                var that = this;
                
                arrayUtil.forEach(mix1Components, function(mix1Component, loopContext) {
                    var found = arrayUtil.contains(mix2Components, function(mix2Component) { 
                        return that.componentEquals(mix1Component, mix2Component);
                    });
                    
                    if (!found) {
                        result = false;
                        loopContext.breakLoop = true;
                    }
                });
                
                return result;
            };
            
            GasHelper.prototype.componentEquals = function(component1, component2) {
                if (component1 === component2) {
                    return true;
                }
                
                if (this.isOtherComponent(component1) !== this.isOtherComponent(component2)) {
                    return false;
                }
                
                if (!this.isOtherComponent(component1)) {
                    if (component1.ComponentId !== component2.ComponentId) {
                        return false;
                    }
                }
                else {
                    if (component1.Code !== component2.Code) {
                        return false;
                    }
                }
                
                return component1.Percentage == component2.Percentage;
            };
            
            GasHelper.prototype.isOtherComponent = function(component) {
                return numericUtil.toNum(component.ComponentId) === FormConstants.OtherComponentId || component.IsOther === true;
            };
            
            GasHelper.prototype.getBlendComponents = function(gas) {
                return jsonNormalizer.getArrayPropertyValue(gas.BlendComponents, 'Component');
            };
            
            return new GasHelper();
        }
    ]);
})();
