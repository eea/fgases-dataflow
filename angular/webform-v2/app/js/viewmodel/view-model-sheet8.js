
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet8', [
        
        'ViewModelObjectBase', 'ViewModelSheet8Section12', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet8Section12, objectUtil) {
            
            function ViewModelSheet8(viewModel) {
                if (!(this instanceof ViewModelSheet8)) {
                    return new ViewModelSheet8(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section12 = new ViewModelSheet8Section12(this);
            }

            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet8);
            
            return ViewModelSheet8;
        }
    ]).factory('ViewModelSheet8Section12', [
        
        'ViewModelSectionBase', 'objectUtil', 'gasHelper', 'arrayUtil',
        
        function (ViewModelSectionBase, objectUtil, gasHelper, arrayUtil) {
            
            function ViewModelSheet8Section12(sheet8ViewModel) {
                if (!(this instanceof ViewModelSheet8Section12)) {
                    return new ViewModelSheet8Section12(sheet8ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet8ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet8Section12);
            
            ViewModelSheet8Section12.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F8_S12;
            };

            ViewModelSheet8Section12.prototype.getGasesWithProblem12C = function() {
                var result = [];
                var gasArray = this.getSectionData().Gas;
                for (var i=0; i < gasArray.length; i++) {
                    if (gasArray[i].Totals) {
                        if (parseInt(gasArray[i].Totals.tr_12C) < 0) {
                            result.push(gasArray[i].GasCode);
                        }
                    }
                }
                return result;
            };

            ViewModelSheet8Section12.prototype.hasCommentsForGasId = function(gasId) {
                var gasArray = this.getSectionData().Gas;
                for (var i=0; i < gasArray.length; i++) {
                    if (gasArray[i].GasCode == gasId) {
                        for (var j=0; j < gasArray[i].tr_12A.Transaction.length; j++) {
                            if (gasArray[i].tr_12A.Transaction[j].Comment) {
                                return true;
                            }
                        }
                    }
                }
                return false;
            };

            return ViewModelSheet8Section12;
        }
    ]);
})();
