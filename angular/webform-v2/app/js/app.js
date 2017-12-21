
(function() {
    angular.module('FGases.services.util', []);
    angular.module('FGases.helper', []);
    angular.module('FGases.services.data', [
        'FGases.services.util'
    ]);
    angular.module('FGases.services.ui', [
        'FGases.services.util',
        'ui.bootstrap'
    ]);
    angular.module('FGases.services.validation', [
        'FGases.services.util'
    ]);
    angular.module('FGases.services.validation.qcs', [
        'FGases.services.util',
        'FGases.helper',
        'pascalprecht.translate'
    ]);
    
    angular.module('FGases.filters', [
        'FGases.services.util'
    ]);
    
    angular.module('FGases.viewmodel', [
        'FGases.services.util',
        'FGases.services.data',
        'FGases.services.validation.qcs',
        'FGases.helper'
    ]);
    
    angular.module('FGases.controllers', [
        'FGases.services.util',
        'FGases.services.ui',
        'FGases.viewmodel',
        'ui.bootstrap',
        'pascalprecht.translate'
    ]);
    
    angular.module('FGases.directives', [
        'FGases.services.util',
        'FGases.services.validation',
        'FGases.services.ui',
        'pascalprecht.translate'
    ]);
    
    var app = angular.module('FGases', [
        'FGases.filters',
        'FGases.directives',
        'FGases.controllers',
        'FGases.services.data',
        'FGases.services.validation.qcs',
        'FGases.services.ui',
        'ui.bootstrap',
        'ngAnimate',
        'ajoslin.promise-tracker',
        'navigation.navigationBlocker',
        'translate.languageChanger',
        'ui.multiselect',
        'tabs.formTabs',
        'ui.errorMapper',
        'monospaced.elastic',
        'notifications',
        'angularFileUpload']);
        
    app.run(function($rootScope, promiseTracker, $location, tabService, errorMapperService) {
        $rootScope.loadingTracker = promiseTracker({});
        tabService.setTabs([
            {"id":"Intro",            "active" : true},
            {"id":"CompanyInfo",      "active" : false},
            {"id":"Activities",       "active" : false},
            {"id":"Gases",            "active" : false},
            {"id":"Sheet1",           "active" : false},
            {"id":"Sheet2",           "active" : false},
            {"id":"Sheet3",           "active" : false},
            {"id":"Sheet4",           "active" : false},
            {"id":"Sheet5",           "active" : false},
            {"id":"Sheet6",           "active" : false},
            {"id":"Sheet7",           "active" : false},
            {"id":"Submission",       "active" : false}
        ]);
        //, {"id":"Debug",            "active" : false}

        errorMapperService.addErrorMapping("total100", "Sum of the amounts reported here must be 100");
    });

    // app constanst are defined here
    app.constant('FormConstants', {
        // set defaults
        "HFCsGasGroupId": 1,
        "PFCsGasGroupId": 2,
        "SF6GasGroupId": 10,
        "UnsaturatedHFCsHCFCGasGroupId": 3,
        "FluorinatedEthersAlcoholsGasGroupId": 4,
        "OtherPrefluorinatedCompoundsGasGroupId": 5,
        "NonFGasesGroupId": 6,
        "CommonlyUsedMixturesGasGroupId": [7, 9],
        "AlphaNumericAndSpaceRegEx": /^\d*[a-zA-Z][a-zA-Z0-9 ,_\.\(\)\-]*$/,
        "StartingAlphaNumeric":      /^[a-zA-Z0-9].+$/,
        "CommentsRegEx":             /.*[a-zA-Z]+.*/,
        "CommentLimit": 15,
        "StartingYear": 2014,
        "ToBeConfirmedGasesIds": [6, 8, 143],
        "ToBeConfirmedGasesCodes": ['HFC-134', 'HFC-143', 'HFC-152'],
        "ToBeConfirmedGasesCodesA": ['HFC-134a', 'HFC-143a', 'HFC-152a'],
        "UnspecifiedGasMixId": 187,
        OtherComponentId: 128,
        "TabIds": [
            "Intro",
            "CompanyInfo",
            "Activities",
            "Gases",
            "Sheet1",
            "Sheet2",
            "Sheet3",
            "Sheet4",
            "Sheet5",
            "Sheet6",
            "Sheet7",
            "Submission"
        ]
    });// end of constant definitions

    app.config(function(languageChangerProvider) {
        languageChangerProvider.setDefaultLanguage('en');
        languageChangerProvider.setLanguageFilePrefix('fgases-labels-');
        languageChangerProvider.setAvailableLanguages({ "item" :[{
            "code": "bg",
            "label": "Български (bg)"}, {
            "code": "es",
                "label": "Español (es)"}, {
            "code": "cs",
                "label": "Čeština (cs)"}, {
            "code": "da",
                "label": "Dansk (da)"}, {
            "code": "de",
                "label": "Deutsch (de)"}, {
            "code": "et",
                "label": "Eesti (et)"}, {
            "code": "el",
                "label": "ελληνικά (el)"}, {
            "code": "en",
                "label": "English (en)"}, {
            "code": "fr",
                "label": "Français (fr)"}, {
            "code": "hr",
                "label": "Hrvatski (hr)"}, {
            "code": "it",
                "label": "Italiano (it)"}, {
            "code": "lv",
                "label": "Latviešu valoda (lv)"}, {
            "code": "lt",
                "label": "Lietuvių kalba (lt)"}, {
            "code": "hu",
                "label": "Magyar (hu)"}, {
            "code": "hr",
                "label": "Hrvatski (hr)"}, {
            "code": "mt",
                "label": "Malti (mt)"}, {
            "code": "nl",
                "label": "Nederlands (nl)"}, {
            "code": "pl",
                "label": "Polski (pl)"}, {
            "code": "pt",
                "label": "Português (pt)"}, {
            "code": "ro",
                "label": "Română (ro)"}, {
            "code": "sk",
                "label": "Slovenčina (sk)"}, {
            "code": "sl",
                "label": "Slovenščina (sl)"}, {
            "code": "fi",
                "label": "Suomi (fi)"}, {
            "code": "sv",
                "label": "Svenska (sv)"}] });
    });
})();

// Window globals

// request parameters
var baseUri = getParameterByName('base_uri');
var fileId = getParameterByName('fileId');
var companyId = getParameterByName('companyId');
var envelope = getParameterByName('envelope');
var sessionId = getParameterByName('sessionid');
var testCompanyId = getParameterByName('testCompanyId');
var isTestSession = false;

// if companyId parameter is missing, then run the form in test mode.
// it is possible to set test company id with testCopmanyId parameter
if (!sessionId) {
    isTestSession = true;
}

var DD_VOCABULARY_BASE_URI = "http://test.tripledev.ee/datadict/vocabulary/";

function isEmpty(value){
    return (!value || value == null || value.length === 0);
}

function getStringValue(object, property) {
    if (object.hasOwnProperty(property)) {
        return "";
    }
    else if (isEmpty(object[property])) {
        return "";
    }
    else{
        return object[property];
    }
}

/**
 * Utility function to calculate weighted GWP
 * @param componentsForGWP
 * @returns {*}
 */
function getWeightedGWP(componentsForGWP){
    var copyOfGasComponentsForGWP = clone(componentsForGWP);
    if (!(copyOfGasComponentsForGWP instanceof Array)){
        copyOfGasComponentsForGWP = [copyOfGasComponentsForGWP];
    }

    var weightedGwp = 0;
    var percentageTotal = 0;
    for (var l = 0; l < copyOfGasComponentsForGWP.length; l++){
        //then component should have values for percentage and
        if (copyOfGasComponentsForGWP[l].GWP_AR4_AnnexIV){
            weightedGwp += parseFloat(copyOfGasComponentsForGWP[l].Percentage) * parseFloat(copyOfGasComponentsForGWP[l].GWP_AR4_AnnexIV);
        }
        percentageTotal += parseFloat(copyOfGasComponentsForGWP[l].Percentage);
    }

    if (percentageTotal > 0){
        return weightedGwp / percentageTotal;
    }

    return null;
}// end of function getWeightedGWP

/**
 * Utility function to calculate weighted HFC GWP
 * @param componentsForGWP
 * @returns {*}
 */
function getWeightedHFCGWP(componentsForGWP){
    var copyOfGasComponentsForGWP = clone(componentsForGWP);
    if (!(copyOfGasComponentsForGWP instanceof Array)){
        copyOfGasComponentsForGWP = [copyOfGasComponentsForGWP];
    }

    var weightedGwp = 0;
    var percentageTotal = 0;
    for (var l = 0; l < copyOfGasComponentsForGWP.length; l++){
        //then component should have values for percentage and
        if (copyOfGasComponentsForGWP[l].GWP_AR4_HFC){
            weightedGwp += parseFloat(copyOfGasComponentsForGWP[l].Percentage) * parseFloat(copyOfGasComponentsForGWP[l].GWP_AR4_HFC);
        }
        percentageTotal += parseFloat(copyOfGasComponentsForGWP[l].Percentage);
    }

    if (percentageTotal > 0){
        return weightedGwp / percentageTotal;
    }

    return null;
}// end of function getWeightedHFCGWP

function getWeightedFullHfcGwp(components) {
    var gwpComponents = components instanceof Array ? components : [ components ];
    
    for (var i = 0; i < gwpComponents.length; i++) {
        // if gas is HFC or contains at least one HFC
        if (gwpComponents[i].GWP_AR4_HFC) {
            return getWeightedGWP(components);
        }
    }
    
    return 0;
}

/**
 * Utility function to check if gas or component is HFC or containing HFC.
 * In current implementation, this is determined based on HFC GWP field.
 *
 * @param componentOrGas component or gas
 */
function containsHFCUtilFn(componentOrGas){
    //if GWP_AR4_HFC field is defined and it is value is greater than 0 then it is an HFC.
    if (componentOrGas && typeof componentOrGas.GWP_AR4_HFC !== 'undefined' && componentOrGas.GWP_AR4_HFC && Number(componentOrGas.GWP_AR4_HFC) > 0){
       return true;
    }
    return false;
}// end of function containsHFCUtilFn

function getWebQUrl(path){
    var url = baseUri + path;
    url += "?fileId=" + fileId;
    if (sessionId && sessionId != null) {
        url += "&sessionid=" + sessionId;
    }
    return url;
}
// helper function for getting query string parameter values. AngularJS solution $location.search() doesn't work in IE8.
function getParameterByName(name) {
    var searchArr = window.location.search.split('?');
    var search = '?' + searchArr[searchArr.length - 1];
    var match = new RegExp('[?&]' + name + '=([^&]*)').exec(search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
};
function getDomain(url) {
    return url.split("/").slice(0,3).join("/");
}
