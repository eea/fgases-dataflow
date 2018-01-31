(function () {
    angular.module('FGases.services.validation.qcs').factory('sheet8Validator', [
        '$translate', 'sheetTransactionValidator', 'sheetValidationObjectFactory', 'objectUtil', 'arrayUtil', 'stringUtil', 'numericUtil',
        function ($translate, sheetTransactionValidator, sheetValidationObjectFactory, objectUtil, arrayUtil, stringUtil, numericUtil) {

            function Sheet8Validator() {
                var that = this;
                this.transactionValidations = [
                    {
                        transaction: {id: 'tr_12C', label: 'tr_12C'},
                        rules: [that._createRuleQc2120x()]
                    }
                ];
            }
            Sheet8Validator.prototype.validate = function(viewModel) {
                var transactionErrors = sheetTransactionValidator.validate(viewModel, this.transactionValidations);
                return transactionErrors;
            };
            Sheet8Validator.prototype._createRuleQc2120x = function () {
                return {
                    qccode: [21201, 21202],
                    validate: function (viewModel) {
                        var result = sheetValidationObjectFactory.createValidationResult();
                        var p_gases = viewModel.sheet8.section12.getGasesWithProblem12C();
                        var that = this;

                        for (var i=0; i < p_gases.length; i++) {
                            if (!viewModel.sheet8.section12.hasCommentsForGasId(p_gases[i])) {
                                var qc21201_error = sheetValidationObjectFactory.createValidationError(21201);
                                qc21201_error.gasIndex = p_gases[i];
                                qc21201_error.message = $translate.instant("validation_messages.qc_21201.error_text", {
                                    gas: viewModel.getReportedGasById(p_gases[i]).Name,
                                });
                                result.errors.push(qc21201_error);
                            } else {
                                var qc21202_error = sheetValidationObjectFactory.createValidationError(21202);
                                qc21202_error.isNonBlocker = true;
                                qc21202_error.message = $translate.instant('validation_messages.qc_21202.warning_text', {
                                    gas: viewModel.getReportedGasById(p_gases[i]).Name,
                                });
                                result.errors.push(qc21202_error);
                                var flag = sheetValidationObjectFactory.createQcFlag('12C', 21202, p_gases[i], null, $translate.instant("validation_messages.qc_21202.comment", {
                                    gas: viewModel.getReportedGasById(p_gases[i]).Name,
                                }));
                                result.flags.push(flag);
                            }
                        }
                        return result;
                    }
                };
            };
            return new Sheet8Validator();
        }
    ]);
})();

