
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet3', [
        
        'ViewModelObjectBase', 'ViewModelSheet3Section6','objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet3Section6,objectUtil) {
            
            function ViewModelSheet3(viewModel) {
                if (!(this instanceof ViewModelSheet3)) {
                    return new ViewModelSheet3(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section6 = new ViewModelSheet3Section6(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet3);
            
            return ViewModelSheet3;
        }
    ]).factory('ViewModelSheet3Section6', [
        
        'ViewModelSectionBase', 'objectUtil',
        
        function (ViewModelSectionBase, objectUtil) {
            
            function ViewModelSheet3Section6(sheet3ViewModel) {
                if (!(this instanceof ViewModelSheet3Section6)) {
                    return new ViewModelSheet3Section6(sheet3ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet3ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet3Section6);
            
            ViewModelSheet3Section6.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F3A_S6A_IA_HFCs;
            };
            
            return ViewModelSheet3Section6;
        }
    ])
})();
