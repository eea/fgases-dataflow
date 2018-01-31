(function () {
    angular.module('FGases.services.validation.qcs').factory('sheet9Validator', [
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'objectUtil', 'arrayUtil', 'stringUtil', 'numericUtil',
        function ($translate, sheetTransactionValidator, sheetValidationObjectFactory, objectUtil, arrayUtil, stringUtil, numericUtil) {

            function Sheet9Validator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: { id: 'AuthBalance', label: '13A' },
                        rules: [ that._createRuleQc21302() ]
                    },
                    {
                        transaction: { id: 'tr_13B', label: '13B' },
                        rules: [ that._createRuleQc21303() ]
                    },
                    {
                        transaction: { id: 'tr_13C', label: '13C' },
                        rules: [ that._createRuleQc21301() ]
                    }
                ];
            }
            Sheet9Validator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                return transactionErrors;
            };

            Sheet9Validator.prototype._createRuleQc21302 = function() {
              return {
                qccode: 21302,
                validate: function(viewModel) {
                  var result = sheetValidationObjectFactory.createValidationResult();
                  var data = viewModel.sheet9.section13.getSectionData();

                  var tr_13a = data.AuthBalance.Amount;
                  var tr_13d = data.Totals.tr_13D.Amount;

                  var valid = tr_13a >= tr_13d;
                  if (!valid) {
                    var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                    error.isNonBlocker = true;
                    result.errors.push(error);
                  }

                  return result;
                }
              };
            };

            Sheet9Validator.prototype._createRuleQc21303 = function() {
              return {
                qccode: 21303,
                validate: function(viewModel) {
                  var result = sheetValidationObjectFactory.createValidationResult();
                  var data = viewModel.sheet9.section13.getSectionData();

                  var tr_13b = data.Totals.tr_13B.Amount;
                  var verified = data.Verified;

                  var valid = (tr_13b >= 100) && (verified === true);
                  if (!valid) {
                    var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                    error.isNonBlocker = false;
                    result.errors.push(error);
                  }

                  return result;
                }
              };
            };

            Sheet9Validator.prototype._createRuleQc21301 = function() {
              return {
                qccode: 21301,
                validate: function(viewModel) {
                  var result = sheetValidationObjectFactory.createValidationResult();
                  var data = viewModel.sheet9.section13.getSectionData();

                  var tr_13c = data.Totals.tr_13C.Amount;
                  var tr_13b = data.Totals.tr_13B.Amount;

                  var valid = tr_13c <= tr_13b;
                  if (!!valid) {
                    var error = sheetValidationObjectFactory.createValidationError(this.qccode);
                    error.isNonBlocker = false;
                    result.errors.push(error);

                    var flag = sheetValidationObjectFactory.createQcFlag(
                      '13C', this.qccode, null, null, $translate.instant("validation_messages.qc_21301.comment")
                    );
                    result.flags.push(flag);
                  }

                  return result;
                }
              };
            };

            return new Sheet9Validator();
        }
    ]);
})();

