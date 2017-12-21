
(function() {
    angular.module('FGases.services.data').factory('dataProxy', [
        
        '$window', '$rootScope', '$http', 'HttpMock', 'objectUtil', 'transactionYearProvider',
        
        function($window, $rootScope, $http, HttpMock, objectUtil, transactionYearProvider) {
            function DataProxy() { }
            
            DataProxy.prototype.LOCALSTORE_KEY = "eea_fgases_data";
            
            DataProxy.prototype.getInstance = function() {
                if ($window.localStorage[DataProxy.prototype.LOCALSTORE_KEY]) {
                    var data = angular.fromJson($window.localStorage[DataProxy.prototype.LOCALSTORE_KEY]);
                    return new HttpMock(true, data, 200);
                }
                
                return $http.get('mock/data/instance.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.saveInstance = function(data) {
                $window.localStorage[DataProxy.prototype.LOCALSTORE_KEY] = angular.toJson(data);
                return new HttpMock(true, { code: 1 }, 200);
            };
            
            DataProxy.prototype.getFGases = function() {
                return $http.get('mock/data/gases.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getEmptyInstance = function() {
                return $http.get('mock/data/instance.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getInstanceMetadata = function() {
                return $http.get('mock/data/instance-metadata.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getCompanyData = function(companyId) {
                return $http.get('mock/data/companies.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistById = function(companyId) {
                return $http.get('mock/data/company-reg-code-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdAndName = function(companyId, companyName) {
                return $http.get('mock/data/company-reg-code-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdAndCountryCodeOrVat = function(companyId, countryCode, vat) {
                return $http.get('mock/data/company-reg-code-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByIdOrNameOrVat = function(companyId, legalRepresentativeName, legalRepresentativeVat) {
                return $http.get('mock/data/company-reg-code-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByVat = function(vatCode) {
                return $http.get('mock/data/company-vat-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByVatAndName = function(vatCode, companyName) {
                return $http.get('mock/data/company-vat-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.checkCompanyExistByNameAndCountryCode = function(companyName, countryCode) {
                return $http.get('mock/data/company-vat-test.json', {tracker : $rootScope.loadingTracker});
            };
            
            DataProxy.prototype.getRegistryData = function(companyId, transactionYear, onSuccess, onError) {
                var resourceUri;
                        
                if (transactionYear == transactionYearProvider._maxTransactionYear()) {
                    resourceUri = 'mock/data/extra-company-data.json';
                }
                else {
                    resourceUri = 'mock/data/extra-company-data-old.json';
                }
                
                return $http.get('mock/data/extra-company-data.json', {tracker : $rootScope.loadingTracker})
                        .success(function(data) { 
                            objectUtil.call(onSuccess, data); 
                        }).error(function() { 
                            objectUtil.call(onError); 
                        });
            };
            
            DataProxy.prototype.getLabelsFile = function(filename) {
                var resourceUrl = 'mock/data/labels/' + filename + '.json';
                return $http.get(resourceUrl, {tracker : $rootScope.loadingTracker});
            };

            return new DataProxy();
        }
    ]);
    
    angular.module('FGases').factory('HttpMock', [ 

        '$q',

        function($q) {
            function HttpMock(isSuccess, data, status, headers, config) {
                if (!(this instanceof HttpMock)) {
                    return new HttpMock(isSuccess, data, status, headers, config);
                }
                
                this.isSuccess = isSuccess;
                this.data = data;
                this.status = status;
                this.headers = headers;
                this.config = config;
                this.deferred = $q.defer();
            }

            HttpMock.prototype.success = function(callback) {
                if (this.isSuccess) {
                    var that = this;
                    this.deferred.promise.then(function() {
                        callback(that.data, that.status, that.headers, that.config);
                    });
                    this.deferred.resolve();
                }

                return this;
            };

            HttpMock.prototype.error = function(callback) {
                if (!this.isSuccess) {
                    var that = this;
                    this.deferred.promise.then(null, function() {
                        callback(that.data, that.status, that.headers, that.config);
                    });
                    this.deferred.reject();
                }

                return this;
            };

            return HttpMock;
        }
    ]);
    
})();
