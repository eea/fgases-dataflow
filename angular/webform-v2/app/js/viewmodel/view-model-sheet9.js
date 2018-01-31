(function() {
  angular.module('FGases.viewmodel')
    .factory('ViewModelSheet9', [
      'ViewModelObjectBase', 'ViewModelSheet9Section13', 'objectUtil',

      function(ViewModelObjectBase, ViewModelSheet9Section13, objectUtil) {

        function ViewModelSheet9(viewModel) {
          if (!(this instanceof ViewModelSheet9)) {
            return new ViewModelSheet9(viewModel);
          }

          ViewModelObjectBase.call(this, viewModel);
          this.section13 = new ViewModelSheet9Section13(this);
        }

        objectUtil.chainConstructor(ViewModelObjectBase, ViewModelSheet9);

        return ViewModelSheet9;
      }
    ])
    .factory('ViewModelSheet9Section13', [
      'ViewModelSectionBase', 'objectUtil', 'gasHelper', 'arrayUtil',

      function (ViewModelSectionBase, objectUtil, gasHelper, arrayUtil) {

        function ViewModelSheet9Section13(sheet9ViewModel) {
          if (!(this instanceof ViewModelSheet9Section13)) {
            return new ViewModelSheet9Section13(sheet9ViewModel);
          }

          ViewModelSectionBase.call(this, sheet9ViewModel);
        }

        objectUtil.chainConstructor(ViewModelSectionBase, ViewModelSheet9Section13);

        ViewModelSheet9Section13.prototype.getSectionData = function() {
          return this.getRoot().getDataSource().FGasesReporting.F9_S13;
        };

        return ViewModelSheet9Section13;
      }
    ]);
})();
