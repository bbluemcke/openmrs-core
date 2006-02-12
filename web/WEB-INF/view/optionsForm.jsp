<%@ include file="/WEB-INF/template/include.jsp"%>

<%@ include file="/WEB-INF/template/header.jsp"%>

<openmrs:require privilege="" otherwise="/login.htm"
	redirect="/options.form" />

<script type="text/javascript">

window.onload = init;

function init() {
	var sections = new Array();
	var optform = document.getElementById("optionsForm");
	children = optform.childNodes;
	var seci = 0;
	for(i=0;i<children.length;i++) {
		if(children[i].nodeName.toLowerCase().indexOf('fieldset') != -1) {
			children[i].id = 'optsection-' + seci;
			children[i].className = 'optsection';
			legends = children[i].getElementsByTagName('legend');
			sections[seci] = new Object();
			if(legends[0] && legends[0].firstChild.nodeValue)
				sections[seci].text = legends[0].firstChild.nodeValue;
			else
				sections[seci].text = '# ' + seci;
			sections[seci].secid = children[i].id;
			sections[seci].error = containsError(children[i]);
			seci++;
			if(sections.length != 1)
				children[i].style.display = 'none';
			else
				var selectedid = children[i].id;
		}
	}
	
	var toc = document.createElement('ul');
	toc.id = 'optionsTOC';
	toc.selectedid = selectedid;
	for(i=0;i<sections.length;i++) {
		var li = document.createElement('li');
		if(i == 0) li.className = 'selected';
		var a =  document.createElement('a');
		a.href = '#' + sections[i].secid;
		a.onclick = uncoversection;
		a.appendChild(document.createTextNode(sections[i].text));
		a.secid = sections[i].secid;
		a.id = sections[i].secid + "_link";
		if (sections[i].error) {
			a.className = "error";
		}
		li.appendChild(a);
		toc.appendChild(li);
	}
	optform.insertBefore(toc, children[0]);

	var hash = document.location.hash;
	if (hash.length > 1) {
		var autoSelect = hash.substring(1, hash.length);
		for(i=0;i<sections.length;i++) {
			if (sections[i].text == autoSelect)
				uncoversection(sections[i].secid + "_link");
		}
	}
}

function uncoversection(secid) {
	var obj = this;
	if (typeof secid == 'string') {
		obj = document.getElementById(secid);
		if (obj == null)
			return false;
	}

	var ul = document.getElementById('optionsTOC');
	var oldsecid = ul.selectedid;
	var newsec = document.getElementById(obj.secid);
	if(oldsecid != obj.secid) {
		document.getElementById(oldsecid).style.display = 'none';
		newsec.style.display = 'block';
		ul.selectedid = obj.secid;
		lis = ul.getElementsByTagName('li');
		for(i=0;i< lis.length;i++) {
			lis[i].className = '';
		}
		obj.parentNode.className = 'selected';
	}
	newsec.blur();
	return false;
}

function containsError(element) {
	if (element) {
		var child = element.firstChild;
		while (child != null) {
			if (child.className == 'error') {
				return true;
			}
			else if (containsError(child) == true) {
				return true;
			}
			child = child.nextSibling;
		}
	}
	return false;
}

</script>

<h2><spring:message code="options.title" /></h2>

<spring:hasBindErrors name="opts">
	<spring:message code="fix.error" />
	<div class="error"><c:forEach items="${errors.allErrors}" var="error">
		<spring:message code="${error.code}" text="${error.code}" />
		<br />
		<!-- ${error} -->
	</c:forEach></div>
	<br />
</spring:hasBindErrors>

<form method="post">

<div id="optionsForm">
<fieldset><legend><spring:message code="options.default.legend" /></legend>
<table>
	<tr>
		<td><spring:message code="options.default.location" /></td>
		<td>
			<spring:bind path="opts.defaultLocation">
				<select name="${status.expression}">
					<c:forEach items="${locations}" var="loc">
						<option value="${loc.locationId}" <c:if test="${loc.locationId == status.value}">selected</c:if>>${loc.name}</option>
					</c:forEach>
				</select>
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.default.language" /></td>
		<td>
			<spring:bind path="opts.defaultLanguage">
				<select name="${status.expression}">
					<c:forEach items="${languages}" var="map">
						<option value="${map.key}" <c:if test="${map.key == status.value}">selected</c:if>>${map.value}</option>
					</c:forEach>
				</select>
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.showRetiredMessage" /></td>
		<td>
			<spring:bind path="opts.showRetiredMessage">
				<input type="hidden" name="_${status.expression}" value="true" />
				<input type="checkbox" name="${status.expression}" value="true" <c:if test="${status.value == true}">checked</c:if> />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.default.verbose" /></td>
		<td>
			<spring:bind path="opts.verbose">
				<input type="hidden" name="_${status.expression}" value="true" />
				<input type="checkbox" name="${status.expression}" value="true" <c:if test="${status.value == true}">checked</c:if> />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
</table>
<br /><br />
<br />
</fieldset>

<fieldset><legend><spring:message code="options.login.legend" /></legend>
<table>
	<tr>
		<td><spring:message code="options.login.username" /></td>
		<td>
			<spring:bind path="opts.username">
				<input type="text" name="${status.expression}" value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr><td colspan="2"><br/></td></tr>
	<tr>
		<td><spring:message code="options.login.password.old" /></td>
		<td>
			<spring:bind path="opts.oldPassword">
				<input type="password" name="${status.expression}" value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.login.password.new" /></td>
		<td>
			<spring:bind path="opts.newPassword">
				<input type="password" name="${status.expression}"
			value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.login.password.confirm" /></td>
		<td>
			<spring:bind path="opts.confirmPassword">
				<input type="password" name="${status.expression}"
			value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr><td colspan="2"><br/></td></tr>
	<tr><td colspan="2"><spring:message code="options.login.secretQuestion.about" /></td></tr>
	<tr>
		<td><spring:message code="options.login.password.old" /></td>
		<td>
			<spring:bind path="opts.secretQuestionPassword">
				<input type="password" name="${status.expression}" value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.login.secretQuestionNew" /></td>
		<td>
			<spring:bind path="opts.secretQuestionNew">
				<input type="text" name="${status.expression}"
			value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.login.secretAnswerNew" /></td>
		<td>
			<spring:bind path="opts.secretAnswerNew">
				<input type="password" name="${status.expression}"
			value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
	<tr>
		<td><spring:message code="options.login.secretAnswerConfirm" /></td>
		<td>
			<spring:bind path="opts.secretAnswerConfirm">
				<input type="password" name="${status.expression}"
					value="${status.value}" />
				<c:if test="${status.errorMessage != ''}">
					<span class="error">${status.errorMessage}</span>
				</c:if>
			</spring:bind>
		</td>
	</tr>
</table>
<br /><br />
<br />
</fieldset>

<fieldset><legend><spring:message code="options.notify.legend" /></legend>
<table>
	<tr>
		<td><input type="radio" name="notification" value="internalOnly" <c:if test="${opts.notification == 'internalOnly'}">checked</c:if> /></td>
		<td><spring:message code="options.notify.internalOnly" /></td>
	</tr>
	<tr>
		<td><input type="radio" name="internal" value="internal" <c:if test="${opts.notification == 'internal'}">checked</c:if> /></td>
		<td><spring:message code="options.notify.internal" /></td>
	</tr>
	<tr>
		<td><input type="radio" name="internalProtected" value="internalProtected" <c:if test="${opts.notification == 'internalProtected'}">checked</c:if> /></td>
		<td><spring:message code="options.notify.internalProtected" /></td>
	</tr>
	<tr>
		<td><input type="radio" name="email" value="email" <c:if test="${opts.notification == 'email'}">checked</c:if> /></td>
		<td><spring:message code="options.notify.email" /></td>
	</tr>
</table>
<br />
<br />
</fieldset>

</div>
<br />
<input type="submit" value="<spring:message code="options.save"/>">
</form>

<%@ include file="/WEB-INF/template/footer.jsp"%>
