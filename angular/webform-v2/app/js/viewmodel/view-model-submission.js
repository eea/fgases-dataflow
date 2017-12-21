
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelSubmission', [
       
        '$translate', 'ViewModelObjectBase', 'objectUtil',
        
        function($translate, ViewModelObjectBase, objectUtil) {
            function ViewModelSubmission(viewModel) {
                if (!(this instanceof ViewModelSubmission)) {
                    return new ViewModelSubmission(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSubmission);
            
            ViewModelSubmission.prototype.getErrorCategoryName = function(errorMessage) {
                var id;
                
                if (errorMessage.isBlocker) {
                    id = "submission.error-level-blocker";
                }
                else {
                    id = "submission.error-level-warning";
                }
                
                return $translate.instant(id);
            };
            
            ViewModelSubmission.prototype.getErrorCategoryClass = function(errorMessage) {
                if (errorMessage.isBlocker) {
                    return "text-danger";
                }
                else {
                    return "text-warning";
                }
            };
            
            return ViewModelSubmission;
        }
    ]);
})();
