
(function() {
    angular.module('FGases.viewmodel').factory('ViewModelActivities', [
       
        'ViewModelObjectBase', 'objectUtil',
        
        function(ViewModelObjectBase, objectUtil) {
            
            function ViewModelActivities(viewModel) {
                if (!(this instanceof ViewModelActivities)) {
                    return new ViewModelActivities(viewModel);
                }
                
                ViewModelObjectBase.call(this, viewModel);
            }
            
            objectUtil.chainConstructor(ViewModelObjectBase, ViewModelActivities);
            
            ViewModelActivities.prototype.getSectionData = function() {
                return this.getRoot().getDataSource().FGasesReporting.GeneralReportData.Activities;
            };
            
            ViewModelActivities.prototype.isP = function() {
                return this._is("P");
            };
            
            ViewModelActivities.prototype.isP_HFC = function() {
                return this._is("P-HFC");
            };
            
            ViewModelActivities.prototype.isP_Other = function() {
                return this._is("P-other");
            };
            
            ViewModelActivities.prototype.isI = function() {
                return this._is("I");
            };
            
            ViewModelActivities.prototype.isI_HFC = function() {
                return this._is("I-HFC");
            };
            
            ViewModelActivities.prototype.isI_Other = function() {
                return this._is("I-other");
            };
            
            ViewModelActivities.prototype.isE = function() {
                return this._is("E");
            };
            
            ViewModelActivities.prototype.isFU = function() {
                return this._is("FU");
            };
            
            ViewModelActivities.prototype.isD = function() {
                return this._is("D");
            };
            
            ViewModelActivities.prototype.isEq_I = function() {
                return this._is("Eq-I");
            };
            
            ViewModelActivities.prototype.isEq_I_RACHP_HFC = function() {
                return this._is("Eq-I-RACHP-HFC");
            };
            
            ViewModelActivities.prototype.isEq_I_other = function() {
                return this._is("Eq-I-other");
            };
            
            ViewModelActivities.prototype.isAuth = function() {
                return this._is("auth");
            };
            
            ViewModelActivities.prototype.isAuth_NER = function() {
                return this._is("auth-NER");
            };
            
            ViewModelActivities.prototype.isNilReport = function() {
                return this._is("NIL-Report");
            };
            
            ViewModelActivities.prototype._is = function(activityCode) {
                return this.getSectionData()[activityCode] == true;
            };
            
            return ViewModelActivities;
        }
    ]);
})();
