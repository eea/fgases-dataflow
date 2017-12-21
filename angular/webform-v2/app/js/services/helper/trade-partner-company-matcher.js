
(function() {
    angular.module('FGases.helper').factory('tradePartnerCompanyMatcher', [
        
        'stringUtil',
        
        function(stringUtil) {
            function TradePartnerCompanyMatcher() { }
            
            TradePartnerCompanyMatcher.prototype.isOwnCompany = function (ownCompanyData, tradePartnerData) {
                var isCompanyEuBased = stringUtil.equalsIgnoreCase(ownCompanyData.Country.Type, 'EU_TYPE');
                
                if (isCompanyEuBased !== tradePartnerData.isEUBased) {
                    return false;
                }
                
                if (isCompanyEuBased) {
                    return stringUtil.equalsIgnoreCase(ownCompanyData.VATNumber, tradePartnerData.EUVAT);
                }
                else {
                    try {
                        return stringUtil.equalsIgnoreCase(ownCompanyData.CompanyId.toString(), tradePartnerData.NonEUDgClimaRegCode.toString());
                    } catch (e) {
                        console.log(tradePartnerData.CompanyName + " has no NonEUDgClimaRegCode. Continuing...!")
                        return false;
                    }
                }
            };
            
            TradePartnerCompanyMatcher.prototype.areEqual = function(partner1, partner2) {
                if (partner1.isEUBased !== partner2.isEUBased) {
                    return false;
                }
                
                if (partner1.isEUBased) {
                    return stringUtil.equalsIgnoreCase(partner1.EUVAT, partner2.EUVAT);
                }
                else {
                    try {
                        return stringUtil.equalsIgnoreCase(partner1.NonEUDgClimaRegCode && partner1.NonEUDgClimaRegCode.toString(), partner2.NonEUDgClimaRegCode && partner2.NonEUDgClimaRegCode.toString());
                    } catch (e) {
                        console.log(partner1.CompanyName + " or " + partner2.CompanyName  + " has no NonEUDgClimaRegCode. Continuing...!");
                        return false;
                    }
                }
            };
            
            return new TradePartnerCompanyMatcher();
        }
    ]);
})();
