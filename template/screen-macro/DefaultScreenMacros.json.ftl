<#-- Copyright 2014-2017 Spokane Software Systems, Inc. All Rights Reserved. -->

<#macro jsonValue textValue>
    <#-- This escaping looks for the JSON reserved characters that are potentially present in strings and escapes them -->
    <#--   Newline is replaced with \n          -->
    <#--   Carriage return is replaced with \r  -->
    <#--   Tab is replaced with \t              -->
    <#--   Double quote is replaced with \"     -->
    <#--   Backslash is replaced with \\        -->
    <#t><#if textValue??><#if fieldPrinted!false>,</#if><#assign fieldPrinted = true>"${textValue?replace("\n", "\\n")?replace("\r", "\\r")?replace("\t", "\\t")?replace("\"", "\\\"")?replace("\\", "\\\\")}"</#if>
</#macro>

<#macro @element><#-- do nothing for unknown elements --></#macro>
<#macro screen><#recurse></#macro>
<#macro widgets>
    <#if !singleFormTitle?has_content><#assign singleFormTitle = ""></#if>
    <#assign foundContainer = false>
    <#recurse>
</#macro>
<#macro "fail-widgets"><#recurse></#macro>

<#-- ================ Subscreens ================ -->
<#macro "subscreens-menu"></#macro>
<#macro "subscreens-active">${sri.renderSubscreen()}</#macro>
<#macro "subscreens-panel">${sri.renderSubscreen()}</#macro>

<#-- ================ Section ================ -->
<#macro section>${sri.renderSection(.node["@name"])}</#macro>
<#macro "section-iterate">${sri.renderSection(.node["@name"])}</#macro>

<#-- ================ Containers ================ -->
<#macro container><#recurse></#macro>
<#macro "container-box">
    <#assign boxHeader = .node["box-header"][0]!>
    <#assign boxTitle = ec.getResource().expand(boxHeader["@title"]!"", "")>
    <#if !singleFormTitle?has_content || singleFormTitle == boxTitle>
        <#t><#if foundContainer>,<#else><#assign foundContainer = true></#if>{"title":"${boxTitle}",

        <#t><#if .node["box-body"]?has_content><#recurse .node["box-body"][0]></#if>
        <#t><#if .node["box-body-nopad"]?has_content><#recurse .node["box-body-nopad"][0]></#if>
        <#t>}
    </#if>
</#macro>
<#macro "container-panel">
    <#t><#if .node["panel-header"]?has_content><#recurse .node["panel-header"][0]></#if>
    <#t><#if .node["panel-left"]?has_content><#recurse .node["panel-left"][0]></#if>
    <#t><#recurse .node["panel-center"][0]>
    <#t><#if .node["panel-right"]?has_content><#recurse .node["panel-right"][0]></#if>
    <#t><#if .node["panel-footer"]?has_content><#recurse .node["panel-footer"][0]></#if>
</#macro>
<#macro "container-dialog"><#recurse></#macro>

<#-- ==================== Includes ==================== -->
<#macro "include-screen">${sri.renderIncludeScreen(.node["@location"], .node["@share-scope"]!)}</#macro>

<#-- ============== Tree ============== -->
<#-- TABLED, not to be part of 1.0:
<#macro tree>
</#macro>
<#macro "tree-node">
</#macro>
<#macro "tree-sub-node">
</#macro>
-->

<#-- ============== Render Mode Elements ============== -->
<#macro "render-mode">
<#t><#if .node["text"]?has_content>
    <#list .node["text"] as textNode><#if !textNode["@type"]?has_content || textNode["@type"] == "any"><#local textToUse = textNode/></#if></#list>
    <#list .node["text"] as textNode><#if textNode["@type"]?has_content && textNode["@type"]?split(",")?seq_contains(sri.getRenderMode())><#local textToUse = textNode></#if></#list>
    <#t><#if textToUse??>
        <#t><#if textToUse["@location"]?has_content>
            <#-- NOTE: this still won't encode templates that are rendered to the writer -->
            <#t><#if .node["@encode"]! == "true">${sri.renderText(textToUse["@location"], textToUse["@template"]!)?html}<#else>${sri.renderText(textToUse["@location"], textToUse["@template"]!)}</#if>
        </#if>
        <#assign inlineTemplateSource = textToUse?string/>
        <#t><#if inlineTemplateSource?has_content>
            <#t><#if !textToUse["@template"]?has_content || textToUse["@template"] == "true">
                <#assign inlineTemplate = [inlineTemplateSource, sri.getActiveScreenDef().location + ".render_mode.text"]?interpret>
                <#t><@inlineTemplate/>
            <#else>
                <#t>${inlineTemplateSource}
            </#if><#t>
        </#if>
    </#if>
</#if>
</#macro>

<#macro text><#-- do nothing, is used only through "render-mode" --></#macro>

<#-- ================== Standalone Fields ==================== -->
<#macro link><#if .node?parent?node_name?ends_with("-field") && (.node["@link-type"]! == "anchor" || .node["@link-type"]! == "hidden-form-link")>
    <#assign linkNode = .node>
    <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#if linkNode["@entity-name"]?has_content>
            <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
        <#else>
            <#assign textMap = "">
            <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
            <#if textMap?has_content><#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
                <#else><#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")></#if>
        </#if>
        <#if linkText == "null"><#assign linkText = ""></#if>
        <#t><@jsonValue linkText/>
    </#if>
</#if></#macro>

<#macro image><#-- do nothing for image, most likely part of screen and is funny in csv file: <@jsonValue .node["@alt"]!"image"/> --></#macro>
<#macro label><#-- do nothing for label, most likely part of screen and is funny in csv file: <#assign labelValue = ec.resource.expand(.node["@text"], "")><@jsonValue labelValue/> --></#macro>
<#macro parameter><#-- do nothing, used directly in other elements --></#macro>


<#-- ====================================================== -->
<#-- ======================= Form ========================= -->

<#-- NOTE: form-single in a csv file is a bit funny, ignoring in case there is a form-single and form-list
on the same screen to increase reusability of those screens -->
<#macro "form-single"></#macro>

<#macro "form-list">
    <#-- Use the formNode assembled based on other settings instead of the straight one from the file: -->
    <#assign formInstance = sri.getFormInstance(.node["@name"])>
    <#assign formListInfo = formInstance.makeFormListRenderInfo()>
    <#assign formNode = formListInfo.getFormNode()>
    <#assign formListColumnList = formListInfo.getAllColInfo()>
    <#assign listObject = formListInfo.getListObject(false)!>
    <#assign listName = formNode["@list"]>
    <#assign fieldPrinted = false>
    <@compress single_line=true>
    <#t>"columns": [
    <#t><#list formListColumnList as columnFieldList>
        <#t><#list columnFieldList as fieldNode>
            <#t><@formListHeaderField fieldNode/>
        <#t></#list>
    <#t></#list>]
    </@compress>
    <#assign fieldPrinted = false>
    <#if formListColumnList?size &gt; 0 && listObject?size &gt; 0><#t>,</#if>
    <#if listObject?size &gt; 0><#t>"data":[</#if>
    <@compress>
    <#list listObject as listEntry>
        <#-- NOTE: the form-list.@list-entry attribute is handled in the ScreenForm class through this call: -->
        ${sri.startFormListRow(formListInfo, listEntry, listEntry_index, listEntry_has_next)}<#t>
        <#lt><#if listEntry_index &gt; 0>,</#if>
        <@compress single_line=true>
        <#t><#assign fieldPrinted = false>[<#list formListColumnList as columnFieldList>
            <#t><#list columnFieldList as fieldNode>
                <#t><@formListSubField fieldNode/>
            <#t></#list>
        <#t></#list>]
        </@compress>
        ${sri.endFormListRow()}<#t>
    </#list>
    <#if listObject?size &gt; 0><#t>]</#if>
    </@compress>
    ${sri.safeCloseList(listObject)}<#t><#-- if listObject is an EntityListIterator, close it -->
</#macro>
<#macro formListHeaderField fieldNode>
    <#if fieldNode["header-field"]?has_content>
        <#assign fieldSubNode = fieldNode["header-field"][0]>
    <#elseif fieldNode["default-field"]?has_content>
        <#assign fieldSubNode = fieldNode["default-field"][0]>
    <#else>
        <#-- this only makes sense for fields with a single conditional -->
        <#assign fieldSubNode = fieldNode["conditional-field"][0]>
    </#if>
    <#t><@fieldTitle fieldSubNode/>
</#macro>
<#macro formListSubField fieldNode>
    <#list fieldNode["conditional-field"] as fieldSubNode>
        <#if ec.resource.condition(fieldSubNode["@condition"], "")>
            <#t><@formListWidget fieldSubNode/>
            <#return>
        </#if>
    </#list>
    <#if fieldNode["default-field"]?has_content>
        <#t><@formListWidget fieldNode["default-field"][0]/>
        <#return>
    </#if>
</#macro>
<#macro formListWidget fieldSubNode>
    <#if fieldSubNode["ignored"]?has_content || fieldSubNode["hidden"]?has_content || fieldSubNode["submit"]?has_content><#return/></#if>
    <#if fieldSubNode?parent["@hide"]! == "true"><#return></#if>
    <#t><#recurse fieldSubNode>
</#macro>
<#macro "row-actions"><#-- do nothing, these are run by the SRI --></#macro>

<#macro fieldTitle fieldSubNode><#t>
    <#t><#if (fieldSubNode?node_name == 'header-field')>
        <#local fieldNode = fieldSubNode?parent>
        <#local headerFieldNode = fieldNode["header-field"][0]!>
        <#local defaultFieldNode = fieldNode["default-field"][0]!>
        <#t><#if headerFieldNode["@title"]?has_content><#local fieldSubNode = headerFieldNode><#elseif defaultFieldNode["@title"]?has_content><#local fieldSubNode = defaultFieldNode></#if>
    </#if>
    <#t><#assign titleValue><#if fieldSubNode["@title"]?has_content>${ec.getResource().expand(fieldSubNode["@title"], "")}<#else><#list fieldSubNode?parent["@name"]?split("(?=[A-Z])", "r") as nameWord>${nameWord?cap_first?replace("Id", "ID")}<#if nameWord_has_next> </#if></#list></#if></#assign><@jsonValue ec.getL10n().localize(titleValue)/>
</#macro>

<#macro "field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "conditional-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>
<#macro "default-field"><#-- shouldn't be called directly, but just in case --><#recurse/></#macro>

<#-- ================== Form Field Widgets ==================== -->

<#macro "check">
    <#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)>
    <#if !currentValue?has_content><#assign currentValue = ec.getResource().expandNoL10n(.node["@no-current-selected-key"]!, "")/></#if>
    <#t><@jsonValue (options.get(currentValue))!(currentValue)/>
</#macro>

<#macro "date-find"></#macro>
<#macro "date-time">
    <#assign fieldValue = sri.getFieldValue(.node?parent?parent, .node["@default-value"]!"")!>
    <#if .node["@format"]?has_content><#assign fieldValue = ec.l10n.format(fieldValue, .node["@format"])></#if>
    <#if .node["@type"]! == "time"><#assign size=9/><#assign maxlength=12/><#elseif .node["@type"]! == "date"><#assign size=10/><#assign maxlength=10/><#else><#assign size=23/><#assign maxlength=23/></#if>
    <#t><@jsonValue fieldValue/>
</#macro>

<#macro "display">
    <#assign fieldValue = ""/>
    <#assign dispFieldNode = .node?parent?parent>
    <#if .node["@text"]?has_content>
        <#assign textMap = "">
        <#if .node["@text-map"]?has_content><#assign textMap = ec.getResource().expression(.node["@text-map"], "")!></#if>
        <#if textMap?has_content>
            <#assign fieldValue = ec.getResource().expand(.node["@text"], "", textMap)>
        <#else>
            <#assign fieldValue = ec.getResource().expand(.node["@text"], "")>
        </#if>
        <#if .node["@currency-unit-field"]?has_content>
            <#assign fieldValue = ec.getL10n().formatCurrency(fieldValue, ec.getResource().expression(.node["@currency-unit-field"], ""))>
        </#if>
    <#elseif .node["@currency-unit-field"]?has_content>
        <#assign fieldValue = ec.getL10n().formatCurrency(sri.getFieldValue(dispFieldNode, ""), ec.getResource().expression(.node["@currency-unit-field"], ""))>
    <#else>
        <#assign fieldValue = sri.getFieldValueString(.node)>
    </#if>
    <#t><@jsonValue fieldValue/>
</#macro>
<#macro "display-entity">
    <#assign fieldValue = ""/><#assign fieldValue = sri.getFieldEntityValue(.node)/>
    <#t><@jsonValue fieldValue/>
</#macro>

<#macro "drop-down">
    <#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)/>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]!""/></#if>
    <#t><@jsonValue (options.get(currentValue))!(currentValue)/>
</#macro>

<#macro "file"></#macro>
<#macro "hidden"></#macro>
<#macro "ignored"><#-- shouldn't ever be called as it is checked in the form-* macros --></#macro>
<#macro "password"></#macro>

<#macro "radio">
    <#assign options = {"":""}/><#assign options = sri.getFieldOptions(.node)>
    <#assign currentValue = sri.getFieldValueString(.node)/>
    <#if !currentValue?has_content><#assign currentValue = .node["@no-current-selected-key"]!""/></#if>
    <#t><@jsonValue (options.get(currentValue))!(currentValue)/>
</#macro>

<#macro "range-find"></#macro>
<#macro "reset"></#macro>

<#macro "submit">
    <#assign fieldValue><@fieldTitle .node?parent/></#assign>
    <#t><@jsonValue fieldValue/>
</#macro>

<#macro "text-area">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@jsonValue fieldValue/>
</#macro>

<#macro "text-line">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@jsonValue fieldValue/>
</#macro>

<#macro "text-find">
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#t><@jsonValue fieldValue/>
</#macro>
