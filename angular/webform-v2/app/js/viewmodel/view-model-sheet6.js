
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet6', [
        
        'ViewModelObjectBase', 'ViewModelSheet6Section7', 'ViewModelSheet6Section8', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet6Section7, ViewModelSheet6Section8, objectUtil) {
            
            function ViewModelSheet6(viewModel) {
                if (!(this instanceof ViewModelSheet6)) {
                    return new ViewModelSheet6(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section7 = new ViewModelSheet6Section7(this);
                this.section8 = new ViewModelSheet6Section8(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet6);
            
            return ViewModelSheet6;
        }
    ]).factory('ViewModelSheet6Section7', [
        
        'ViewModelSectionBase', 'objectUtil',
        
        function (ViewModelSectionBase, objectUtil) {
            
            function ViewModelSheet6Section7(sheet6ViewModel) {
                if (!(this instanceof ViewModelSheet6Section7)) {
                    return new ViewModelSheet6Section7(sheet6ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet6ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet6Section7);
            
            ViewModelSheet6Section7.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F6_FUDest;
            };
            
            return ViewModelSheet6Section7;
        }
    ]).factory('ViewModelSheet6Section8', [
        
        'ViewModelSectionBase', 'objectUtil',
        
        function (ViewModelSectionBase, objectUtil) {
            
            function ViewModelSheet6Section8(sheet6ViewModel) {
                if (!(this instanceof ViewModelSheet6Section8)) {
                    return new ViewModelSheet6Section8(sheet6ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet6ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet6Section8);
            
            ViewModelSheet6Section8.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F6_FUDest;
            };
            
            return ViewModelSheet6Section8;
        }
    ]);
})();
