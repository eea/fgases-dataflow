
(function() {
    angular.module('FGases.services.data').factory('dataProxy', [
        
        '$rootScope', '$http', 'objectUtil', 'arrayUtil',
        
        function($rootScope, $http, objectUtil, arrayUtil) {
            function DataProxy() { }
            
            DataProxy.prototype.getInstance = function() {
                var url = null;
                
                if (fileId){
                    url = getWebQUrl("/download/converted_user_file");
                } else{
                    // testing on non-production workflow
                    url = "fgases-instance-test.xml?format=json";
                }
                
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.saveInstance = function(data) {
                var url = getWebQUrl("/saveXml");
                return $http.post(url, data, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getFGases = function() {
                var convertedJsonGasUrl = "fgases-gases-2015.xml?format=json";
                
                return $http.get(convertedJsonGasUrl, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getEmptyInstance = function() {
                var url = 'fgases-instance-empty.xml?format=json';
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getInstanceMetadata = function() {
                var url = getWebQUrl("/file/info");
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getCompanyData = function(companyId) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation?id=" + companyId);
                }
                else {
                    url = 'fgases-company-info-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistById = function(companyId) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?id=" + companyId);
                }
                else {
                    url = 'fgases-company-reg-code-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdAndName = function(companyId, companyName) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?id=" + companyId + "&name=" + encodeURIComponent(companyName));
                }
                else {
                    url = 'fgases-company-reg-code-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdAndCountryCodeOrVat = function(companyId, countryCode, vat) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?id=" + companyId + "&countrycode=" + countryCode + "&OR_vat=" + vat);
                }
                else {
                    url = 'fgases-company-reg-code-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdOrNameOrVat = function(companyId, legalRepresentativeName, legalRepresentativeVat) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?id=" + companyId + "&OR_name==" + encodeURIComponent(legalRepresentativeName) + "&OR_vat=" + legalRepresentativeVat);
                }
                else {
                    url = 'fgases-company-reg-code-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByVat = function(vatCode) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?vat=" + vatCode);
                }
                else {
                    url = 'fgases-company-vat-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByVatAndName = function(vatCode, companyName) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?vat=" + vatCode + "&name=" + encodeURIComponent(companyName)) ;
                }
                else {
                    url = 'fgases-company-vat-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByNameAndCountryCode = function(companyName, countryCode) {
                var url;
                // https://bdr-test.eionet.europa.eu/fgases_registry/organisation?id=9989
                var webqUri = getWebQUrl('/restProxy');
                if (!isTestSession) {
                    url = webqUri + "&uri=" +  encodeURIComponent(getDomain(envelope) + "/fgases_registry/organisation_exists?name=" + encodeURIComponent(companyName) + "&countrycode=" + countryCode) ;
                }
                else {
                    url = 'fgases-company-vat-test.json';
                }
                return $http.get(url, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getRegistryData = function(companyId, transactionYear, onSuccess, onError) {
                var xmlUri, xsltUri;
                
                if (isTestSession) {
                    xmlUri = "https://converterstest.eionet.europa.eu/xmlfile/fgases-extra-registry-data-test.xml";
                    xsltUri = "https://converterstest.eionet.europa.eu/xsl/fgases-extra-registry-data.xsl";
                }
                else {
                    xmlUri = getDomain(envelope) + "/xmlexports/fgases/fgases-extra-registry-data-" + transactionYear + ".xml";
                    xsltUri = "https://convertersbdr.eionet.europa.eu/xsl/fgases-extra-registry-data.xsl";
                }
                
                this._getDataByXsltConversion(companyId, xmlUri, xsltUri).success(function(data) {
                    objectUtil.call(onSuccess, data);
                }).error(onError);
            };
            
            DataProxy.prototype.getLabelsFile = function(filename) {
                var resourceUrl = filename + '.xml?format=json';
                return $http.get(resourceUrl, {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype._getDataByXsltConversion = function(companyId, xmlUri, xsltUri, params) {
                var webqUri;
                
                if (isTestSession) {
                    webqUri = baseUri + "/proxyXmlWithConversion?fileId=0";
                }
                else {
                    webqUri = getWebQUrl('/proxyXmlWithConversion');
                }
                
                var url = webqUri + "&xmlUri=" + xmlUri + "&xsltUri=" + xsltUri + "&format=json&companyId=" + companyId;
                var extraParams = objectUtil.isNull(params) ? { } : params;
                
                arrayUtil.forEach(Object.getOwnPropertyNames(extraParams), function(paramName) {
                    var paramValue = extraParams[paramName];
                    
                    if (!objectUtil.isNull(paramValue)) {
                        url += "&" + paramName + "=" + paramValue;
                    }
                });
                
                return $http.get(url, { tracker : $rootScope.loadingTracker });
            };
            
            return new DataProxy();
        }
    ]);
})();
