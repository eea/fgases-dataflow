// Module that provides multiselect box to webform from json-ld format.
//
// Usage Example:
// <div multiselect class="multiselect" name="TypeOfUse" multiple="true"
//      ng-model="row.TypeOfUse"
//      options="gas.GasId as gas.Code for gas in codeList.FGasesCodelists.FGases.Gas"
//      change="selected()" required></div>
//
// Note! options instead of ng-options is used.
angular.module('ui.multiselect', [
        'multiselect.tpl.html'
    ])

    //from bootstrap-ui typeahead parser
    .factory('optionParser', ['$parse', function ($parse) {

        //                      00000111000000000000022200000000000000003333333333333330000000000044000
        var TYPEAHEAD_REGEXP = /^\s*(.*?)(?:\s+as\s+(.*?))?\s+for\s+(?:([\$\w][\$\w\d]*))\s+in\s+(.*)$/;

        return {
            parse: function (input) {

                var match = input.match(TYPEAHEAD_REGEXP), modelMapper, viewMapper, source;
                if (!match) {
                    throw new Error(
                        "Expected typeahead specification in form of '_modelValue_ (as _label_)? for _item_ in _collection_'" +
                            " but got '" + input + "'.");
                }

                return {
                    itemName: match[3],
                    source: $parse(match[4]),
                    viewMapper: $parse(match[2] || match[1]),
                    modelMapper: $parse(match[1])
                };
            }
        };
    }])

    .directive('multiselect', ['$parse', '$document', '$compile', '$interpolate', 'optionParser',

        function ($parse, $document, $compile, $interpolate, optionParser) {
            return {
                restrict: 'AE',
                require: 'ngModel',
                link: function (originalScope, element, attrs, modelCtrl) {

                    var exp = attrs.options,
                        parsedResult = optionParser.parse(exp),
                        isMultiple = (attrs.multiple === "true") ? true : false,
                        showCheckAll = (attrs.showcheckall === "true") ? true : false,
                        showFilter = (attrs.showfilter === "true") ? true : false,
                        showGroups = (attrs.showgroups === "true") ? true : false,
                        dataFormat = (attrs.dataformat || 'default'),
                        //TODO a better solution can be provided
                        modelIdFieldName = attrs.modelidfieldname || 'GasId',
                        required = false,
                        scope = originalScope.$new(),
                        changeHandler = attrs.change || angular.noop;

                    scope.groups = [];
                    scope.header = 'Select';
                    scope.multiple = isMultiple;
                    scope.disabled = false;
                    scope.showCheckAll = showCheckAll;
                    scope.showFilter = showFilter;
                    scope.dataFormat = dataFormat;
                    scope.showGroups = showGroups;
                    scope.modelIdFieldName = modelIdFieldName;

                    originalScope.$on('$destroy', function () {
                        scope.$destroy();
                    });

                    var popUpEl = angular.element('<multiselect-popup></multiselect-popup>');

                    //required validator
                    if (attrs.required || attrs.ngRequired) {
                        required = true;
                    }
                    attrs.$observe('required', function(newVal) {
                        required = newVal;
                    });

                    //watch disabled state
                    scope.$watch(function () {
                        return $parse(attrs.disabled)(originalScope);
                    }, function (newVal) {
                        scope.disabled = newVal;
                    });

                    //watch single/multiple state for dynamically change single to multiple
                    scope.$watch(function () {
                        return $parse(attrs.multiple)(originalScope);
                    }, function (newVal) {
                        isMultiple = newVal || false;
                    });

                    //watch option changes for options that are populated dynamically
                    scope.$watch(function () {
                        return parsedResult.source(originalScope);
                    }, function (newVal) {
                        if (angular.isDefined(newVal))
                            parseModel();
                    }, true);

                    //watch model change
                    scope.$watch(function () {
                        return modelCtrl.$modelValue;
                    }, function (newVal, oldVal) {
                        //when directive initialize, newVal usually undefined. Also, if model value already set in the controller
                        //for preselected list then we need to mark checked in our scope item. But we don't want to do this every time
                        //model changes. We need to do this only if it is done outside directive scope, from controller, for example.
                        if (angular.isDefined(newVal)) {
                            markChecked(newVal);
                            scope.$eval(changeHandler);
                        }
                        getHeaderText();
                        modelCtrl.$setValidity('required', scope.valid());
                    }, true);

                    //TODO this code should be updated to be more generic
                    function parseModel() {
                        scope.groups.length = 0;
                        var model = parsedResult.source(originalScope);
                        var groupIndex = 0;
                        var groupIdIndexMap = {};
                        var defaultGroup = {};
                        defaultGroup.items = [];
                        if(!angular.isDefined(model)) return;

                        switch (scope.dataFormat){
                            case 'json-ld':
                                //TODO not working properly, for json-ld data format, this part should be updated!
                                for (var i = 0; i < model.length; i++) {
                                    if (angular.isDefined(model[i].narrower) && model[i].narrower.length > 0){
                                        //now we have groups
                                        scope.groups[groupIndex] = { "name" : model[i].prefLabel[0]['@value'], "items" : []};
                                        groupIdIndexMap[model[i]['@id']] = groupIndex;
                                        groupIndex++;
                                        continue;
                                    }

                                    var group = defaultGroup; //if there is no group or group cannot be found, then add it to default group
                                    if (angular.isDefined(model[i].broader) && model[i].broader.length == 1 && angular.isDefined(groupIdIndexMap[model[i].broader[0]['@id']])) {
                                        //now we have a sub element
                                        group = scope.groups[groupIdIndexMap[model[i].broader[0]['@id']]];
                                    }

                                    var local = {};
                                    local[parsedResult.itemName] = model[i];
                                    var checked = false;
                                    if (modelCtrl.$modelValue) {
                                        if(!(modelCtrl.$modelValue instanceof Array) && model[i]['@id'] === modelCtrl.$modelValue) {
                                            checked = true;
                                        } else if((modelCtrl.$modelValue instanceof Array) && contains(modelCtrl.$modelValue, model[i]['@id'])) {
                                            checked = true;
                                        }
                                    }

                                    group.items.push({
                                        label: parsedResult.viewMapper(local),
                                        model: model[i]['@id'],
                                        checked: checked
                                    });
                                }

                                // now add default group
                                scope.groups[groupIndex] = defaultGroup;
                                break; //end of json-ld data format parsing
                            case 'default':
                            default:
                                for (var i = 0; i < model.length; i++) {
                                    var group = defaultGroup;
                                    if (angular.isDefined(model[i].GasGroupId) && model[i].GasGroupId != null){
                                        //now we have groups
                                        var groupId = model[i].GasGroupId;
                                        var groupName = model[i].GasGroupName;
                                        var codeId = model[i][scope.modelIdFieldName];

                                        // different display groups for blends: 404A, 407C,410A & 507A
                                        if (groupId == 7) {
                                            if (codeId == 26 || codeId == 27 || codeId == 28 || codeId == 29) {
                                                groupId = "77";
                                                groupName = "Most commonly used mixtures";
                                            }
                                            else {
                                                groupName = "Other commonly used mixtures";
                                            }
                                        }
                                        if (angular.isDefined(groupIdIndexMap[groupId])){
                                            group = scope.groups[groupIdIndexMap[groupId]];
                                        }else {
                                            scope.groups[groupIndex] = { "name" : groupName, "items" : []};
                                            groupIdIndexMap[groupId] = groupIndex;
                                            group = scope.groups[groupIndex];
                                            groupIndex++;
                                        }
                                    }

                                    var local = {};
                                    local[parsedResult.itemName] = model[i];
                                    var checked = false;
                                    if (modelCtrl.$modelValue) {
                                        if(!(modelCtrl.$modelValue instanceof Array) && model[i][scope.modelIdFieldName] === modelCtrl.$modelValue) {
                                            checked = true;
                                        } else if((modelCtrl.$modelValue instanceof Array) && contains(modelCtrl.$modelValue, model[i][scope.modelIdFieldName])) {
                                            checked = true;
                                        }
                                    }

                                    group.items.push({
                                        label: parsedResult.viewMapper(local),
                                        model: model[i][scope.modelIdFieldName],
                                        checked: checked
                                    });
                                }

                                // now add default group
                                //scope.groups.push(defaultGroup);
                                // now add default group
                                scope.groups[groupIndex] = defaultGroup;
                                break; //end of default data format parsing
                        }
                    } //end of function parseModel

                    function contains(array, needle) {
                        for (var i = 0; i < array.length; i++){
                            if (array[i] == needle) {
                                return true;
                            }
                        }
                        return false;
                    }

                    parseModel();

                    element.append($compile(popUpEl)(scope));

                    function getHeaderText() {
                        var defaultHeader = 'Select';

                        if (!modelCtrl.$modelValue) return scope.header = attrs.msHeader || defaultHeader;

                        if (modelCtrl.$modelValue && modelCtrl.$modelValue instanceof Array) {
                            if (attrs.msSelected) {
                                scope.header = $interpolate(attrs.msSelected)(scope);
                            } else {
                                scope.header = modelCtrl.$modelValue[0] != ''? modelCtrl.$modelValue.length + ' ' + 'selected' : defaultHeader;
                            }

                        } else if(modelCtrl.$modelValue && typeof 0){
                            scope.header = '1 selected';
                        } else {
                            var local = {};
                            local[parsedResult.itemName] = modelCtrl.$modelValue;
                            scope.header = parsedResult.viewMapper(local);
                        }
                    }

                    function is_empty(obj) {
                        if (!obj) return true;
                        if (obj.length && obj.length > 0) return false;
                        for (var prop in obj) if (obj[prop]) return false;
                        return true;
                    };

                    scope.valid = function validModel() {
                        if(!required) return true;
                        var value = modelCtrl.$modelValue;
                        return (angular.isArray(value) && value.length > 0) || (!angular.isArray(value) && value != null);
                    };

                    function selectSingle(item) {
                        if (item.checked) {
                            scope.uncheckAll();
                        } else {
                            scope.uncheckAll();
                            item.checked = !item.checked;
                        }
                        setModelValue(false);
                    }

                    function selectMultiple(item) {
                        item.checked = !item.checked;
                        setModelValue(true);
                    }

                    function setModelValue(isMultiple) {
                        var value;

                        if (isMultiple) {
                            value = [];
                            angular.forEach(scope.groups, function (group) {
                                angular.forEach(group.items, function (item) {
                                    if (item.checked == true){
                                        value.push(item.model);
                                    }
                                })
                            })
                        } else {
                            angular.forEach(scope.groups, function (group) {
                                angular.forEach(group.items, function (item) {
                                    if (item.checked == true) {
                                        value = item.model;
                                        return false;
                                    }
                                })
                            })
                        }
                        modelCtrl.$setViewValue(value);
                        modelCtrl.$render();
                    }

                    function markChecked(newVal) {
                        if (!angular.isArray(newVal)) {
                            if (!!newVal && typeof newVal !== "string") {
                                newVal = newVal.toString();
                            }
                            angular.forEach(scope.groups, function (group) {
                                angular.forEach(group.items, function (item) {
                                    if (angular.equals(item.model, newVal)) {
                                        item.checked = true;
                                        return false;
                                    }
                                })
                            });
                        } else {
                            angular.forEach(scope.groups, function (group) {
                                angular.forEach(group.items, function (item) {
                                    item.checked = false;
                                    angular.forEach(newVal, function (i) {
                                        if (!!i && typeof i !== "string") {
                                            i = i.toString();
                                        }
                                        if (angular.equals(item.model.toString(), i)) {
                                            item.checked = true;
                                        }
                                    });
                                })
                            });
                        }
                    }

                    scope.checkAll = function () {
                        if (!isMultiple) return;
                        angular.forEach(scope.groups, function (group) {
                            angular.forEach(group.items, function (item) {
                                item.checked = true;
                            })
                        });
                        setModelValue(true);
                    };

                    scope.uncheckAll = function () {
                        angular.forEach(scope.groups, function (group) {
                            angular.forEach(group.items, function (item) {
                                item.checked = false;
                            })
                        });
                        setModelValue(true);
                    };

                    scope.select = function (item) {
                        if (isMultiple === false) {
                            selectSingle(item);
                            scope.toggleSelect();
                        } else {
                            selectMultiple(item);
                        }
                    }
                }
            };
        }])

    .directive('multiselectPopup', ['$document', function ($document) {
        return {
            restrict: 'AE',
            scope: false,
            replace: true,
            templateUrl: 'multiselect.tpl.html',
            link: function (scope, element, attrs) {

                scope.isVisible = false;

                scope.toggleSelect = function () {
                    if (element.hasClass('open')) {
                        element.removeClass('open');
                        $document.unbind('click', clickHandler);
                    } else {
                        element.addClass('open');
                        $document.bind('click', clickHandler);
                        //scope.focus();
                    }
                };

                function clickHandler(event) {
                    if (elementMatchesAnyInArray(event.target, element.find(event.target.tagName)))
                        return;
                    element.removeClass('open');
                    $document.unbind('click', clickHandler);
                    scope.$apply();
                }

//                scope.focus = function focus(){
//                    var searchBox = element.find('input')[0];
//                    searchBox.focus();
//                }

                var elementMatchesAnyInArray = function (element, elementArray) {
                    for (var i = 0; i < elementArray.length; i++)
                        if (element == elementArray[i])
                            return true;
                    return false;
                }
            }
        }
    }]);

angular.module('multiselect.tpl.html', [])

    .run(['$templateCache', function($templateCache) {
        $templateCache.put('multiselect.tpl.html',

            "<div class=\"dropdown\">\n" +
                "  <button type=\"button\" class=\"btn btn-default\" ng-click=\"toggleSelect()\" ng-disabled=\"disabled\" ng-class=\"{'error': !valid()}\">\n" +
                "    {{header}} <span class=\"caret\"></span>\n" +
                "  </button>\n" +
                "  <ul class=\"dropdown-menu\">\n" +
                "    <li ng-show=\"showFilter\">\n" +
                "      <input class=\"form-control input-sm\" type=\"text\" ng-model=\"searchText.label\" autofocus=\"autofocus\" placeholder=\"Filter\" />\n" +
                "    </li>\n" +
                "    <li ng-show=\"multiple && showCheckAll\" role=\"presentation\" class=\"\">\n" +
                "      <button class=\"btn btn-link btn-xs\" ng-click=\"checkAll()\" type=\"button\"><i class=\"glyphicon glyphicon-ok\"></i> Check all</button>\n" +
                "      <button class=\"btn btn-link btn-xs\" ng-click=\"uncheckAll()\" type=\"button\"><i class=\"glyphicon glyphicon-remove\"></i> Uncheck all</button>\n" +
                "    </li>\n" +
                "    <div ng-repeat=\"i in groups\">\n" +
                "       <div ng-show=\"showGroups\" class=\"multiselect-group-heading\">\n" +
                "           <h5>{{i.name}}</h5>"+
                "       </div>\n" +
                "       <div class=\"dropdown-container\" ng-repeat=\"j in i.items | filter:searchText\">\n" +
                "           <a ng-click=\"select(j); focus()\">\n" +
                //"             <i ng-class=\"{'glyphicon glyphicon-ok': j.checked, 'glyphicon glyphicon-empty': !j.checked}\"></i> {{j.label}}</a>\n" + updated from habides multiselect
                "               <span ng-if=\"j.checked\" class=\"glyphicon glyphicon-ok\"></span><span ng-if=\"!j.checked\" class=\"glyphicon glyphicon-empty\"></span><label><span ng-if=\"showCode\" >{{j.model}} - </span>{{j.label}}</label></a>\n" +
                "       </div>\n" +
                "    </div>\n" +
                "  </ul>\n" +
                "</div>");
    }]);
