<#-- ChangePassword.ftl (normal text inputs version) -->

<div id="browser-warning" class="hidden text-center" style="margin-bottom: 80px;">
    <h4 class="text-danger">Your browser is not supported, please use a recent version of one of the following:</h4>
    <div class="row" style="font-size: 4em;">
        <div class="col-sm-2"></div>
        <div class="col-sm-2"><a href="https://www.google.com/chrome/"><i class="fa fa-chrome"></i></a></div>
        <div class="col-sm-2"><a href="https://www.mozilla.org/firefox/"><i class="fa fa-firefox"></i></a></div>
        <div class="col-sm-2"><a href="https://www.apple.com/safari/"><i class="fa fa-safari"></i></a></div>
        <div class="col-sm-2"><a href="https://www.microsoft.com/windows/microsoft-edge"><i class="fa fa-edge"></i></a></div>
        <div class="col-sm-2"></div>
    </div>
</div>
<script>
    var UA = window.navigator.userAgent.toLowerCase();
    var isIE = UA && /msie|trident/.test(UA);
    if (isIE) $("#browser-warning").removeClass("hidden");
</script>

<#assign errs = ec.web.getSavedErrors()!>
<#if errs?has_content>
  <div class="alert alert-danger" style="max-width:420px; margin:0 auto 10px; text-align:left;">
    <ul style="margin:0; padding-left:18px;">
      <#list errs as e><li>${e?html}</li></#list>
    </ul>
  </div>
</#if>

<div class="text-center form-signin" style="max-width:420px; margin:0 auto;">
    <form method="post" action="${sri.buildUrl("changePassword").url}" class="form-signin" id="change_form">
        <p class="text-muted text-center">${ec.l10n.localize("Enter details to change your password")}</p>

        <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
        <input type="hidden" name="initialTab" value="change">

        <input id="change_form_username" name="username" type="text" value="${(username!"")?html}"
                <#if username?has_content && secondFactorRequired>disabled="disabled"</#if>
                required="required" class="form-control top"
                placeholder="${ec.l10n.localize("Username")}" aria-label="${ec.l10n.localize("Username")}">

        <#if secondFactorRequired>
            <input type="hidden" name="resetPassword" value="ignored">
            <input id="change_form_code" name="code" type="text" inputmode="numeric" autocomplete="one-time-code"
                    required="required" class="form-control middle"
                    placeholder="${ec.l10n.localize("Authentication Code")}" aria-label="${ec.l10n.localize("Authentication Code")}">
        <#else>
            <input type="text"
                   name="resetPassword"
                   required="required"
                   class="form-control middle"
                   placeholder="${ec.l10n.localize("Reset Password")}" aria-label="${ec.l10n.localize("Reset Password")}">
        </#if>

        <div class="alert alert-info" style="padding:8px; margin:10px 0; text-align:left;">
            <strong>${ec.l10n.localize("Password rules")}:</strong>
            <ul style="margin:6px 0 0 18px;">
                <li>${ec.l10n.localize("At least")} ${minLength} ${ec.l10n.localize("characters")}</li>
                <li>${ec.l10n.localize("At least")} ${minDigits} ${ec.l10n.localize("number")}<#if (minDigits > 1)>s</#if></li>
                <#if (minOthers > 0)><li>${ec.l10n.localize("At least")} ${minOthers} ${ec.l10n.localize("special character")}<#if (minOthers > 1)>s</#if></li></#if>
                <li>${ec.l10n.localize("Do not reuse one of your last 5 passwords")}</li>
            </ul>
        </div>

        <input type="text"
               name="newPassword"
               required="required"
               class="form-control middle"
               placeholder="${ec.l10n.localize('New Password')}"
               aria-label="${ec.l10n.localize('New Password')}">

        <input type="text"
               name="newPasswordVerify"
               required="required"
               class="form-control bottom"
               placeholder="${ec.l10n.localize('New Password Verify')}"
               aria-label="${ec.l10n.localize('New Password Verify')}">

        <button class="btn btn-lg btn-danger btn-block" type="submit">${ec.l10n.localize("Change Password")}</button>

        <div class="text-center" style="margin-top:10px;">
            <a class="btn btn-link" href="${sri.buildUrl("/Login").url}" style="padding:0;">
                ${ec.l10n.localize("Back to Login")}
            </a>
        </div>
    </form>
</div>

<#if secondFactorRequired>
    <p class="text-center">${ec.l10n.localize("An authentication code is required for your account, you have these options:")}</p>
    <ul class="form-signin" style="padding-left:40px;">
        <#list factorTypeDescriptions as factorType>
            <li>${factorType}</li>
        </#list>
    </ul>
    <#list sendableFactors as userAuthcFactor>
        <div class="text-center">
            <form method="post" action="${sri.buildUrl("sendOtp").url}" class="form-signin">
                <input type="hidden" name="factorId" value="${userAuthcFactor.factorId}">
                <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
                <button class="btn btn-lg btn-primary" type="submit">${ec.l10n.localize("Send code to")} ${userAuthcFactor.factorOption!}</button>
            </form>
        </div>
    </#list>
</#if>