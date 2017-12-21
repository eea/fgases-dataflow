
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet1', [
        
        'ViewModelObjectBase', 'ViewModelSheet1Section1', 'ViewModelSheet1Section2', 
        'ViewModelSheet1Section3', 'ViewModelSheet1Section4', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet1Section1, ViewModelSheet1Section2, 
                ViewModelSheet1Section3, ViewModelSheet1Section4, objectUtil) {
            
            function ViewModelSheet1(viewModel) {
                if (!(this instanceof ViewModelSheet1)) {
                    return new ViewModelSheet1(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section1 = new ViewModelSheet1Section1(this);
                this.section2 = new ViewModelSheet1Section2(this);
                this.section3 = new ViewModelSheet1Section3(this);
                this.section4 = new ViewModelSheet1Section4(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet1);
            
            return ViewModelSheet1;
        }
    ]).factory('ViewModelSheet1Section1', [
        
        'ViewModelSectionBase', 'gasHelper', 'objectUtil',
        
        function (ViewModelSectionBase, gasHelper, objectUtil) {
            
            function ViewModelSheet1Section1(sheet1ViewModel) {
                if (!(this instanceof ViewModelSheet1Section1)) {
                    return new ViewModelSheet1Section1(sheet1ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet1ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet1Section1);
            
            ViewModelSheet1Section1.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F1_S1_4_ProdImpExp;
            };
            
            ViewModelSheet1Section1.prototype.isGasApplicableToTr01A = function(reportedGas) {
                return this._isHfcApplicable(reportedGas);
            };
            
            ViewModelSheet1Section1.prototype.isGasApplicableToTr01B = function(reportedGas) {
                return this._isHfcApplicable(reportedGas);
            };
            
            ViewModelSheet1Section1.prototype.isGasApplicableToTr01C = function(reportedGas) {
                return this._isHfcApplicable(reportedGas);
            };
            
            ViewModelSheet1Section1.prototype.isGasApplicableToTr01F = function(reportedGas) {
                return this._isMixtureApplicable(reportedGas);
            };
            
            ViewModelSheet1Section1.prototype.isGasApplicableToTr01G = function(reportedGas) {
                return this._isMixtureApplicable(reportedGas);
            };
            
            ViewModelSheet1Section1.prototype._isHfcApplicable = function(reportedGas) {
                return !gasHelper.isUnspecifiedMix(reportedGas) && !reportedGas.IsBlend &&
                        (!gasHelper.isHfcBasedGas(reportedGas) || this.getRoot().sheetActivities.isP_HFC()) &&
                        (gasHelper.isHfcBasedGas(reportedGas) || this.getRoot().sheetActivities.isP_Other());
            };
            
            ViewModelSheet1Section1.prototype._isMixtureApplicable = function(reportedGas) {
                return !gasHelper.isUnspecifiedMix(reportedGas) && reportedGas.IsBlend;
            };
            
            return ViewModelSheet1Section1;
        }
    ]).factory('ViewModelSheet1Section2', [

        'ViewModelSectionBase', 'objectUtil',

        function (ViewModelSectionBase, objectUtil) {

            function ViewModelSheet1Section2(sheet1ViewModel) {
                if (!(this instanceof ViewModelSheet1Section2)) {
                    return new ViewModelSheet1Section2(sheet1ViewModel);
                }

                ViewModelSectionBase.call(this, sheet1ViewModel);
            }

            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet1Section2);

            ViewModelSheet1Section2.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F1_S1_4_ProdImpExp;
            };

            return ViewModelSheet1Section2;
        }
    ]).factory('ViewModelSheet1Section3', [
        
        'ViewModelSectionBase', 'objectUtil',

        function (ViewModelSectionBase, objectUtil) {

            function ViewModelSheet1Section3(sheet1ViewModel) {
                if (!(this instanceof ViewModelSheet1Section3)) {
                    return new ViewModelSheet1Section3(sheet1ViewModel);
                }

                ViewModelSectionBase.call(this, sheet1ViewModel);
            }

            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet1Section3);

            ViewModelSheet1Section3.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F1_S1_4_ProdImpExp;
            };

            return ViewModelSheet1Section3;
        }
    ]).factory('ViewModelSheet1Section4', [
        
        'ViewModelSectionBase', 'gasHelper', 'objectUtil', 'numericUtil',
        
        function (ViewModelSectionBase, gasHelper, objectUtil, numericUtil) {
            
            function ViewModelSheet1Section4(sheet1ViewModel) {
                if (!(this instanceof ViewModelSheet1Section4)) {
                    return new ViewModelSheet1Section4(sheet1ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet1ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet1Section4);
            
            ViewModelSheet1Section4.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F1_S1_4_ProdImpExp;
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04A = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04B = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04C = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04F = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04G = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.isGasApplicableToTr04H = function(reportedGas) {
                return this._isSection4ApplicableGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype._isSection4ApplicableGas = function(reportedGas) {
                var activities = this.getRoot().sheetActivities;
                
                return activities.isI() || activities.isP() || !gasHelper.isHfcBasedGas(reportedGas);
            };
            
            ViewModelSheet1Section4.prototype.applyStockValues = function(gas, forceOverwrite) {
                if (!this._isStockApplicable(gas)) {
                    return false;
                }
                
                var gasId = gas.GasId;
                var stock04FApplied = this._applyStockValues(gasId, '4F', 'tr_04A', forceOverwrite);
                var stock04GApplied = this._applyStockValues(gasId, '4G', 'tr_04B', forceOverwrite);
                var stock04HApplied = this._applyStockValues(gasId, '4H', 'tr_04C', forceOverwrite);
                
                return stock04FApplied || stock04GApplied || stock04HApplied;
            };
            
            ViewModelSheet1Section4.prototype._isStockApplicable = function(gas) {
                var activities = this.getRoot().sheetActivities;
                
                if (gasHelper.isHfcBasedGas(gas)) {
                    return activities.isP_HFC() || activities.isI_HFC();
                }
                else {
                    return activities.isP_Other() || activities.isI_Other();
                }
            };
            
            ViewModelSheet1Section4.prototype._applyStockValues = function(gasId, stockTransactionCode, targetTransaction, forceOverwrite) {
                var stock04F = this.getRoot().getGasStockByTransaction(stockTransactionCode, gasId);
            
                if (objectUtil.isNull(stock04F)) {
                    return false;
                }
                
                var amountEntry = this.getBindableGasAmount(targetTransaction, gasId);

                if (!objectUtil.isNull(amountEntry) && (!numericUtil.isNum(amountEntry.Amount) || forceOverwrite)) {
                    amountEntry.Amount = stock04F.amount;
                    return true;
                }
                
                return false;
            };
            
            return ViewModelSheet1Section4;
        }
    ]);
})();
