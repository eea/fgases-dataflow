
(function() {
    
    var ValidationErrorTypes = {
        NONE: 0,
        THOUSAND_SEPARATOR: 1,
        NEGATIVE: 2,
        DECIMAL: 3,
        NAN: 4,
        DECIMAL_DIGITS: 5,
        THRESHOLD: 6
    };

    function GasAmountValidationResult(code, value, metadata) {
        this.code = code;
        this.value = value;
        this.metadata = metadata;
    }

    GasAmountValidationResult.prototype.isSuccess = function() {
        return this.code === ValidationErrorTypes.NONE;
    };

    GasAmountValidationResult.prototype.isThousandSeparatorError = function() {
        return this.code === ValidationErrorTypes.THOUSAND_SEPARATOR;
    };

    GasAmountValidationResult.prototype.isNegativeNumberError = function() {
        return this.code === ValidationErrorTypes.NEGATIVE;
    };

    GasAmountValidationResult.prototype.isDecimalNumberError = function() {
        return this.code === ValidationErrorTypes.DECIMAL;
    };

    GasAmountValidationResult.prototype.isNaNError = function() {
        return this.code === ValidationErrorTypes.NAN;
    };

    GasAmountValidationResult.prototype.isThresholdError = function() {
        return this.code === ValidationErrorTypes.THRESHOLD;
    };
    
    angular.module('FGases.services.validation').factory('gasAmountValidator', [
        'objectUtil', 'stringUtil',
        function(objectUtil, stringUtil) {
            function GasAmountValidator() { }
            
            GasAmountValidator.prototype.validate = function(value, metadata) {
                if (stringUtil.isEmpty(value)) {
                    return new GasAmountValidationResult(ValidationErrorTypes.NONE, value, metadata);
                }
                
                var stringValue = value.toString();
                
                if (stringValue === "-" && metadata.allowNegative) {
                    return new GasAmountValidationResult(ValidationErrorTypes.NONE, value, metadata);
                }
                
                if (stringUtil.contains(stringValue, ",")) {
                    return new GasAmountValidationResult(ValidationErrorTypes.THOUSAND_SEPARATOR, value, metadata);
                }
                
                if (isNaN(stringValue)) {
                    return new GasAmountValidationResult(ValidationErrorTypes.NAN, value, metadata);
                }
                
                if (!metadata.allowNegative && stringUtil.startsWith(stringValue, "-")) {
                    return new GasAmountValidationResult(ValidationErrorTypes.NEGATIVE, value, metadata);
                }
                
                if (metadata.integerOnly) {
                    if (stringUtil.contains(stringValue, ".")) {
                        return new GasAmountValidationResult(ValidationErrorTypes.DECIMAL, value, metadata);
                    }
                }
                else {
                    var decimalSeparatorIndex = stringValue.indexOf(".");
                    
                    if (decimalSeparatorIndex > -1 && stringValue.length - decimalSeparatorIndex > 4) {
                        return new GasAmountValidationResult(ValidationErrorTypes.DECIMAL_DIGITS, value, metadata);
                    }
                }
                
                if (!objectUtil.isNull(metadata.threshold) && Number(stringValue) > metadata.threshold) {
                    return new GasAmountValidationResult(ValidationErrorTypes.THRESHOLD, value, metadata);
                }
                
                return new GasAmountValidationResult(ValidationErrorTypes.NONE, value, metadata);
            };
            
            return new GasAmountValidator();
        }
    ]);
})();
