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
<!-- currently general/common HTML5 and ES5 support is currently required, so check for IE and older browsers -->
<!-- TODO: check for older versions of various browsers, or for HTML5 features like input/etc.@form attribute, ES5 stuff -->
<script>
    var UA = window.navigator.userAgent.toLowerCase();
    var isIE = UA && /msie|trident/.test(UA);
    if (isIE) $("#browser-warning").removeClass("hidden");
</script>

<div class="text-center form-signin">
    <#-- Login only; Reset Password is now a modal dialog -->
    <div class="tab-content" style="margin-top: 0;">
        <div id="login" class="tab-pane active">
            <form method="post" action="${sri.buildUrl("login").url}" class="form-signin" id="login_form">
                <input type="hidden" name="initialTab" value="login">

                <input id="login_form_username" name="username" type="text" value="${(username!"")?html}"
                        <#if username?has_content && secondFactorRequired>disabled="disabled"</#if>
                        required="required" class="form-control top"
                        placeholder="${ec.l10n.localize("Username")}" aria-label="${ec.l10n.localize("Username")}">

                <#-- secondFactorRequired will only be set if a user is pre-authenticated, and in that case password not required again -->
                <#if secondFactorRequired>
                    <input id="login_form_code" name="code" type="text" inputmode="numeric" autocomplete="one-time-code"
                           required="required" class="form-control bottom"
                           placeholder="${ec.l10n.localize("Authentication Code")}" aria-label="${ec.l10n.localize("Authentication Code")}">
                <#else>
                    <div class="password-wrap">
                        <input type="password" name="password" required="required"
                               class="pw-field form-control bottom"
                               placeholder="${ec.l10n.localize("Password")}" aria-label="${ec.l10n.localize("Password")}">
                        <button type="button" class="pw-reveal" aria-label="${ec.l10n.localize("Show password")}" title="${ec.l10n.localize("Show password")}">
                            <i class="fa fa-eye"></i>
                        </button>
                    </div>
                </#if>

                <button class="btn btn-lg btn-primary btn-block" type="submit">${ec.l10n.localize("Sign in")}</button>

                <#-- Links below login -->
                <div class="text-center" style="margin-top:10px;">
                    <button type="button" class="btn btn-link" data-toggle="modal" data-target="#forgotUsernameModal" style="padding:0;">
                        ${ec.l10n.localize("Forgot Username")}
                    </button>
                    <span style="margin:0 10px; color:#ccc;">|</span>
                    <button type="button" class="btn btn-link" data-toggle="modal" data-target="#resetPwModal" style="padding:0;">
                        ${ec.l10n.localize("Reset Password")}
                    </button>
                </div>

                <#if expiredCredentials><p class="text-warning text-center" style="margin-top:10px;">WARNING: Your password has expired</p></#if>
                <#if passwordChangeRequired><p class="text-warning text-center" style="margin-top:10px;">WARNING: Password change required</p></#if>
            </form>
        </div>

        <#-- Optional SSO section (kept, but not in tabs). If you want it as a button too, say so. -->
        <#if authFlowList?has_content && !authFlowList.isEmpty()>
            <div style="margin-top:12px;">
                <#list authFlowList as authFlow>
                    <form method="post" action="/sso/login" class="form-signin" style="margin:0 0 8px 0;">
                        <input type="hidden" name="authFlowId" value="${authFlow.authFlowId}">
                        <button class="btn btn-lg btn-primary btn-block" type="submit">${authFlow.description}</button>
                    </form>
                </#list>
            </div>
        </#if>
    </div>
</div>

<#-- Forgot Username Modal -->
<div class="modal fade" id="forgotUsernameModal" tabindex="-1" role="dialog" aria-labelledby="forgotUsernameModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document" style="max-width:420px;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="${ec.l10n.localize("Close")}"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="forgotUsernameModalLabel">${ec.l10n.localize("Forgot Username")}</h4>
            </div>
            <div class="modal-body">
                <form method="post" action="${sri.buildUrl("forgotUsername").url}" class="form-signin" id="forgot_username_form" style="margin:0;">
                    <p class="text-muted text-center">${ec.l10n.localize("Enter your email address to receive your username")}</p>
                    <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
                    <input type="hidden" name="initialTab" value="login">
                    <input id="forgot_form_email" name="userEmail" type="email" value="${(userEmail!"")?html}"
                            required="required" class="form-control"
                            placeholder="${ec.l10n.localize("Email Address")}" aria-label="${ec.l10n.localize("Email Address")}">
                    <button class="btn btn-lg btn-danger btn-block" type="submit" style="margin-top:10px;">
                        ${ec.l10n.localize("Email Username")}
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<#-- Reset Password Modal -->
<div class="modal fade" id="resetPwModal" tabindex="-1" role="dialog" aria-labelledby="resetPwModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document" style="max-width:420px;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="${ec.l10n.localize("Close")}"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="resetPwModalLabel">${ec.l10n.localize("Reset Password")}</h4>
            </div>
            <div class="modal-body">
                <form method="post" action="${sri.buildUrl("resetPassword").url}" class="form-signin" id="reset_form" style="margin:0;">
                    <p class="text-muted text-center">${ec.l10n.localize("Enter your username to email a reset password")}</p>
                    <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
                    <input type="hidden" name="initialTab" value="reset">
                    <input id="reset_form_username" name="username" type="text" value="${(username!"")?html}"
                            <#if username?has_content && secondFactorRequired>disabled="disabled"</#if>
                            required="required" class="form-control"
                            placeholder="${ec.l10n.localize("Username")}" aria-label="${ec.l10n.localize("Username")}">
                    <button class="btn btn-lg btn-danger btn-block" type="submit" style="margin-top:10px;">
                        ${ec.l10n.localize("Email Reset Password")}
                    </button>
                </form>
            </div>
        </div>
    </div>
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
                <input type="hidden" name="initialTab" class="initial-tab" value="login">
                <button class="btn btn-lg btn-primary" type="submit">${ec.l10n.localize("Send code to")} ${userAuthcFactor.factorOption!}</button>
            </form>
        </div>
    </#list>
</#if>

<#if (ec.web.sessionAttributes.get("moquiPreAuthcUsername"))?has_content>
    <form method="post" action="${sri.buildUrl("removePreAuth").url}" class="form-signin" id="remove_preauth_form">
        <input type="hidden" name="moquiSessionToken" value="${ec.web.sessionToken}">
        <button class="btn btn-lg btn-block" type="submit">${ec.l10n.localize("Change User")}</button>
    </form>
</#if>

<style>
/* password reveal inside the input */
.password-wrap { position: relative; }
.password-wrap .pw-field { padding-right: 2.25em; } /* room for the eye */
.password-wrap .pw-reveal {
position: absolute;
right: 0.6em;
top: 50%;
transform: translateY(-50%);
border: 0;
background: transparent;
padding: 0;
line-height: 1;
color: #777;
cursor: pointer;
}
.password-wrap .pw-reveal:focus { outline: none; }
.password-wrap .pw-reveal:hover { color: #333; }
</style>

<script>
$(function () {
// Default focus
<#if username?has_content && secondFactorRequired>
$("#login_form_code").focus();
<#else>
$("#login_form_username").focus();
</#if>

// When reset modal opens, focus username
$('#resetPwModal').on('shown.bs.modal', function () {
$("#reset_form_username").focus();
});

    // When forgot username modal opens, focus email
    $('#forgotUsernameModal').on('shown.bs.modal', function () {
$("#forgot_form_email").focus();
});

    // Password reveal toggles (works for all password fields wrapped in .password-wrap)
    $(document).on("click", ".pw-reveal", function () {
var $btn = $(this);
var $wrap = $btn.closest(".password-wrap");
var $pw = $wrap.find("input.pw-field").first();
if (!$pw.length) return;

var isHidden = $pw.attr("type") === "password";
$pw.attr("type", isHidden ? "text" : "password");

$btn.attr("title", isHidden ? "${ec.l10n.localize("Hide password")}" : "${ec.l10n.localize("Show password")}");
$btn.attr("aria-label", isHidden ? "${ec.l10n.localize("Hide password")}" : "${ec.l10n.localize("Show password")}");
$btn.find("i").toggleClass("fa-eye fa-eye-slash");
$pw.trigger("focus");
});
});
</script>
