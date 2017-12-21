
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSheet7', [
        
        'ViewModelObjectBase', 'ViewModelSheet7Section11', 'objectUtil',
        
        function(ViewModelObjectBase, ViewModelSheet7Section11, objectUtil) {
            
            function ViewModelSheet7(viewModel) {
                if (!(this instanceof ViewModelSheet7)) {
                    return new ViewModelSheet7(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
                this.section11 = new ViewModelSheet7Section11(this);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet7);
            
            return ViewModelSheet7;
        }
    ]).factory('ViewModelSheet7Section11', [
        
        'ViewModelSectionBase', 'objectUtil',
        
        function (ViewModelSectionBase, objectUtil) {
            
            function ViewModelSheet7Section11(sheet7ViewModel) {
                if (!(this instanceof ViewModelSheet7Section11)) {
                    return new ViewModelSheet7Section11(sheet7ViewModel);
                }
                
                ViewModelSectionBase.call(this, sheet7ViewModel);
            }
            
            objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet7Section11);
            
            ViewModelSheet7Section11.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.F7_s11EquImportTable;
            };
            
            return ViewModelSheet7Section11;
        }
    ]);
})();
