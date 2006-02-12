package org.openmrs.web.taglib;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.User;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.util.OpenmrsConstants;
import org.openmrs.web.WebConstants;

public class RequireTag extends TagSupport {

	public static final long serialVersionUID = 122998L;
	
	private final Log log = LogFactory.getLog(getClass());

	private String privilege;
	private String otherwise;
	private String redirect;
	private boolean errorOccurred;
	public int doStartTag() {
		
		errorOccurred = false;
		HttpServletResponse httpResponse = (HttpServletResponse)pageContext.getResponse();
		HttpSession httpSession = pageContext.getSession();
		HttpServletRequest request = (HttpServletRequest)pageContext.getRequest();
		String request_ip_addr = request.getLocalAddr();
		String session_ip_addr = (String)httpSession.getAttribute(WebConstants.OPENMRS_CLIENT_IP_HTTPSESSION_ATTR);
		
		Context context = (Context)httpSession.getAttribute(WebConstants.OPENMRS_CONTEXT_HTTPSESSION_ATTR);
		if (context == null && privilege != null) {
			log.error("openmrs_context_httpsession_attr is null. Did this pass through a filter?");
			httpSession.removeAttribute(WebConstants.OPENMRS_CONTEXT_HTTPSESSION_ATTR);
			//TODO find correct error to throw 
			throw new APIException("The context is currently null.  Please try reloading the site.");
		}
		
		if (!context.isAuthenticated()) {
			errorOccurred = true;
			httpSession.setAttribute(WebConstants.OPENMRS_MSG_ATTR, "require.login");
		}
		else {
			User user = context.getAuthenticatedUser();
			Boolean forcePasswordChange = new Boolean(user.getProperties().get(OpenmrsConstants.USER_PROPERTY_CHANGE_PASSWORD));
			log.debug(redirect);
			if (forcePasswordChange && !redirect.contains("options.form")) {
				httpSession.setAttribute(WebConstants.OPENMRS_ERROR_ATTR, "User.password.change");
				errorOccurred = true;
				redirect = request.getContextPath() + "/options.form#Change Login Info";
				otherwise = redirect;
				try {
					httpResponse.sendRedirect(redirect);
					return SKIP_BODY;
				}
				catch (IOException e) {
					// oops, cannot redirect
					log.error(e);
					throw new APIException(e);
				}
			}
			
			else if (!privilege.equals("") && !context.hasPrivilege(privilege)) {
				errorOccurred = true;
				log.warn(context.getAuthenticatedUser() + " attempted access to: " + redirect);
				httpSession.setAttribute(WebConstants.OPENMRS_ERROR_ATTR, "require.unauthorized");
			}
			else if (session_ip_addr != null && !session_ip_addr.equals(request_ip_addr)){
				errorOccurred = true;
				log.warn("Invalid ip addr: expected " + session_ip_addr + ", but found: " + request_ip_addr);
				httpSession.setAttribute(WebConstants.OPENMRS_ERROR_ATTR, "require.ip_addr");
				//TODO test this security
			}
		}
		log.debug("session ip addr: " + session_ip_addr);
		
		if (errorOccurred) {
			
			String url = "";
			if (redirect != null && !redirect.equals(""))
				url = request.getContextPath() + redirect;
			else
				url = request.getRequestURI();
			
			if (request.getQueryString() != null)
				url = url + "?" + request.getQueryString();
			httpSession.setAttribute(WebConstants.OPENMRS_LOGIN_REDIRECT_HTTPSESSION_ATTR, url);
			try {
				httpResponse.sendRedirect(request.getContextPath() + otherwise);
				return SKIP_BODY;
			}
			catch (IOException e) {
				// oops, cannot redirect
				throw new APIException(e);
			}
		}
		
		return SKIP_BODY;
	}

	public int doEndTag() {
		if ( errorOccurred )
			return SKIP_PAGE;
		else
			return EVAL_PAGE;
	}
	
	public String getPrivilege() {
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}

	public String getOtherwise() {
		return otherwise;
	}

	public void setOtherwise(String otherwise) {
		this.otherwise = otherwise;
	}

	public String getRedirect() {
		return redirect;
	}

	public void setRedirect(String redirect) {
		this.redirect = redirect;
	}
	
}
