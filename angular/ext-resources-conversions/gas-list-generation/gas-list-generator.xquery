
declare namespace office = "urn:oasis:names:tc:opendocument:xmlns:office:1.0";
declare namespace table = "urn:oasis:names:tc:opendocument:xmlns:table:1.0";
declare namespace text = "urn:oasis:names:tc:opendocument:xmlns:text:1.0";

(: declare option saxon:output "method=xml"; :)

declare variable $other-component-id := 128;
declare variable $gas-list-ods-uri as xs:string external;
declare variable $old-gas-list-xml-uri as xs:string external;

declare function local:read-mixes-from-odf($sourceUrl as xs:string, $oldGasListUrl as xs:string)
as element(FGases)
{
    let $odfDoc := doc($sourceUrl)
    let $tableRows := $odfDoc/*/office:body/office:spreadsheet/table:table/table:table-row[local:get-gas-id-text(.) castable as xs:integer]
    let $gasIds := distinct-values(
        for $tableRow in $tableRows
        return local:get-gas-id($tableRow)
    )
    let $gases :=
        for $gasId in $gasIds
        let $componentRows := 
            for $tableRow in $tableRows[local:get-gas-id(.) = $gasId]
            return local:fix-row-cell-cardinality($tableRow)
        let $gasName := string($componentRows[1]/table:table-cell[5]/text:p)
        let $componentCount := count($componentRows)
        let $isBlend := $componentCount > 1
        where $componentCount > 0 
        return
            <Gas>
                <GasId>{ $gasId }</GasId>
                <Code>{ local:get-gas-code($componentRows[1]) }</Code>
                <Name>{ $gasName }</Name>
                <GasGroupId>{ local:get-gas-group-id($componentRows[1]) }</GasGroupId>
                <GasGroupName>{ local:get-gas-group-name($componentRows[1]) }</GasGroupName>
                <GWP_AR4_HFC>
                {
                    sum(
                        for $componentRow in $componentRows
                        let $gwp := local:get-component-gwp-hfc($componentRow)
                        let $percentage := local:get-component-percentage($componentRow)
                        return (if (empty($gwp)) then 0 else $gwp) * $percentage div  xs:decimal(100)
                    )
                }
                </GWP_AR4_HFC>
                <GWP_AR4_AnnexIV>
                {
                    sum(
                        for $componentRow in $componentRows
                        let $gwp := local:get-component-gwp($componentRow)
                        let $percentage := local:get-component-percentage($componentRow)
                        return (if (empty($gwp)) then 0 else $gwp) * $percentage div  xs:decimal(100)
                    )
                }
                </GWP_AR4_AnnexIV>
                <IsShortlisted>{ $isBlend }</IsShortlisted>
                <IsCustom>false</IsCustom>
                <IsBlend>{ $isBlend }</IsBlend>
                <BlendComponents>
                {
                    for $componentRow in $componentRows
                    return
                        <Component>
                            <ComponentId>{ local:get-component-id($componentRow) }</ComponentId>
                            <Code>{ local:get-component-code($componentRow) }</Code>
                            <Name>{ local:get-component-name($componentRow) }</Name>
                            <GasGroupId>{ local:get-component-group-id($componentRow) }</GasGroupId>
                            <GasGroupName>{ local:get-component-group-name($componentRow) }</GasGroupName>
                            <GWP_AR4_HFC>{ local:get-component-gwp-hfc($componentRow) }</GWP_AR4_HFC>
                            <GWP_AR4_AnnexIV>{ local:get-component-gwp($componentRow) }</GWP_AR4_AnnexIV>
                            <Percentage>{ local:get-component-percentage($componentRow) }</Percentage>
                        </Component>
                }
                </BlendComponents>
                {
                    if ($isBlend) then
                        <BlendComposition>{ local:get-gas-blend-composition($componentRows) }</BlendComposition>
                    else
                        ()
                }
            </Gas>
    let $oldComponents := doc($oldGasListUrl)/FGases/Component
    let $newComponentIds := distinct-values($gases/BlendComponents/Component/ComponentId)
    (: Skip Other so that it gets included from past year list, to avoid picking an "Other" component with custom Code :)
    let $newComponents :=
        for $componentId in $newComponentIds
        let $component := ($gases/BlendComponents/Component[ComponentId = $componentId])[1]
        where $componentId != $other-component-id 
        return
            <Component>
            {
                $component/*[local-name() != "Percentage"]
            }
            </Component>
    let $components := (
        $newComponents,
        for $oldComponent in $oldComponents
        let $oldComponentId := xs:integer($oldComponent/ComponentId)
        where $oldComponentId = $other-component-id or not($oldComponentId = $newComponentIds)
        return $oldComponent
    )
    return
        <FGases>
            { for $gas in $gases order by xs:integer($gas/GasGroupId), xs:integer($gas/GasId) return $gas }
            { for $component in $components order by xs:integer($component/GasGroupId), xs:integer($component/ComponentId) return $component }
        </FGases>
};

declare function local:fix-row-cell-cardinality($tableRow as element(table:table-row))
as element(table:table-row)
{
    if (empty($tableRow/table:table-cell[@table:number-columns-repeated > 1])) then
        $tableRow
    else
        <table:table-row>
        {
            for $cell in $tableRow/table:table-cell
            let $repeat := max((1, xs:integer($cell/@table:number-columns-repeated)))
            return
                for $i in 1 to $repeat
                return $cell
            
        }
        </table:table-row>
};

declare function local:get-table-row-value($tableRow as element(table:table-row), $index as xs:integer)
as xs:string?
{
    let $value := $tableRow/table:table-cell[$index]/text:p
    return if (empty($value)) then $value else fn:normalize-space($value)
};

declare function local:get-gas-id-text($componentRow as element(table:table-row))
as xs:string?
{
    local:get-table-row-value($componentRow, 1)
};

declare function local:get-gas-id($componentRow as element(table:table-row))
as xs:integer
{
    xs:integer(local:get-gas-id-text($componentRow))
};

declare function local:get-gas-group-id($componentRow as element(table:table-row))
as xs:integer
{
    xs:integer(local:get-table-row-value($componentRow, 3))
};

declare function local:get-gas-group-name($componentRow as element(table:table-row))
as xs:string
{
    string(local:get-table-row-value($componentRow, 4))
};

declare function local:get-gas-name($componentRow as element(table:table-row))
as xs:string
{
    string(local:get-table-row-value($componentRow, 5))
};

declare function local:get-gas-code($componentRow as element(table:table-row))
as xs:string
{
    string(local:get-table-row-value($componentRow, 6))
};

declare function local:get-component-id($componentRow as element(table:table-row))
as xs:integer
{
    xs:integer(local:get-table-row-value($componentRow, 7))
};

declare function local:get-component-group-id($componentRow as element(table:table-row))
as xs:integer
{
    xs:integer(local:get-table-row-value($componentRow, 8))
};

declare function local:get-component-group-name($componentRow as element(table:table-row))
as xs:string
{
    string(local:get-table-row-value($componentRow, 9))
};

declare function local:get-component-name($componentRow as element(table:table-row))
as xs:string
{
    string(local:get-table-row-value($componentRow, 10))
};

declare function local:get-component-code($componentRow as element(table:table-row))
as xs:string?
{
    let $otherCode := local:get-component-other-code($componentRow)
    return
        if (local:get-component-id($componentRow) = $other-component-id and $otherCode != "") then
            $otherCode
        else
            string(local:get-table-row-value($componentRow, 11))
};

declare function local:get-component-other-code($componentRow as element(table:table-row))
as xs:string?
{
    string(local:get-table-row-value($componentRow, 12))
};

declare function local:get-component-percentage($componentRow as element(table:table-row))
as xs:decimal
{
    let $text := local:get-table-row-value($componentRow, 13)
    return xs:decimal(if (ends-with($text, "%")) then substring($text, 1, string-length($text) - 1) else $text)
};

declare function local:get-component-gwp($componentRow as element(table:table-row))
as xs:decimal
{
    let $value := xs:decimal(local:get-table-row-value($componentRow, 14))
    return if (empty($value)) then 0 else $value
};

declare function local:get-component-gwp-hfc($componentRow as element(table:table-row))
as xs:decimal?
{
    if (local:get-component-group-id($componentRow) = 1) then
        xs:decimal(local:get-table-row-value($componentRow, 14))
    else
        0
};

declare function local:get-gas-blend-composition($componentRows as element(table:table-row)*)
as xs:string
{
    let $blendParts := 
        for $componentRow in $componentRows
        return concat(local:get-component-code($componentRow), ":", local:get-component-percentage($componentRow), "%")
    return string-join($blendParts, "; ")
};

local:read-mixes-from-odf($gas-list-ods-uri, $old-gas-list-xml-uri);
