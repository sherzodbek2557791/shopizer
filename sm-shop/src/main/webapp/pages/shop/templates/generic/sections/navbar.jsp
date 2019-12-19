
<%
response.setCharacterEncoding("UTF-8");
response.setHeader("Cache-Control","no-cache");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", -1);
%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="/WEB-INF/shopizer-tags.tld" prefix="sm"%>
<%@ taglib uri="/WEB-INF/shopizer-functions.tld" prefix="display"%>


<c:set var="req" value="${request}" />

<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<script type="text/javascript">
//***** Search code *****
$(document).ready(function() {

    //post search form
   $(".searchButton").click(function(e){
			var searchQuery = $('#searchField').val();
			var q = searchQuery;
			if(q==null || q =='') {
				return;
			}
			$('#hiddenQuery').val(q);
			//log('Search string : ' + searchQuery);
			var uri = '<c:url value="/shop/search/search.html"/>?q=' + q;
            var res = encodeURI(uri);
			e.preventDefault();//action url will be overriden
	        $('#hiddenSearchForm').attr('action',res).submit();
   });




   var searchElements = new Bloodhound({
		datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
		queryTokenizer: Bloodhound.tokenizers.whitespace,
		<c:if test="${requestScope.CONFIGS['useDefaultSearchConfig'][requestScope.LANGUAGE.code]==true}">
		  <c:if test="${requestScope.CONFIGS['defaultSearchConfigPath'][requestScope.LANGUAGE.code]!=null}">
		     prefetch: '<c:out value="${requestScope.CONFIGS['defaultSearchConfigPath'][requestScope.LANGUAGE.code]}"/>',
		  </c:if>
	    </c:if>
	    remote: {
    		url: '<c:url value="/services/public/search/${requestScope.MERCHANT_STORE.code}/${requestScope.LANGUAGE.code}/autocomplete.json"/>?q=%QUERY',
        	filter: function (parsedResponse) {
            	// parsedResponse is the array returned from your backend
            	console.log(parsedResponse);

            	// do whatever processing you need here
            	return JSON.parse(parsedResponse);
        	}
    	}
	});

   searchElements.initialize();


	var searchTemplate =  Hogan.compile([
				     '<p class="suggestion-text"><font color="black">{{value}}</font></p>'
	             ].join(''));


    //full view search
	$('#searchField.typeahead').typeahead({
	    hint: true,
	    highlight: true,
	    minLength: 1
	}, {
		name: 'shopizer-search',
	    displayKey: 'value',
	    source: searchElements.ttAdapter(),
	    templates: {
	    	suggestion: function (data) { return searchTemplate.render(data); }
	    }
	});

    //responsive
	$('#responsiveSearchField.typeahead').typeahead({
	    hint: true,
	    highlight: true,
	    minLength: 1
	}, {
		name: 'modal-shopizer-search',
	    displayKey: 'value',
	    source: searchElements.ttAdapter(),
	    templates: {
	    	suggestion: function (data) { return searchTemplate.render(data); }
	    }
	});

});

</script>
<%----%>
<nav class="navbar navbar-default" style="box-shadow: -2px 2px 6px 4px cadetblue;">
	<div class="container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
<%--			--%>

<%--			--%>
			<a class="navbar-brand" href="#">

				<c:choose>
					<c:when test="${requestScope.CONTENT['logo']!=null}">
						<!-- A content logo exist -->
						<sm:pageContent contentCode="logo"/>
					</c:when>
					<c:otherwise>
						<c:choose>
							<c:when test="${not empty requestScope.MERCHANT_STORE.storeLogo}">
								<!--  use merchant store logo -->
								<a class="grey store-name" href="<c:url value="/shop/"/>">
									<img class="logoImage" src="<sm:storeLogo/>"/>
								</a>
							</c:when>
							<c:otherwise>
								<!-- Use store name -->
								<h1>
									<a class="grey store-name" href="<c:url value="/shop/"/>">
										<c:out value="${requestScope.MERCHANT_STORE.storename}"/>
									</a>
								</h1>
							</c:otherwise>
						</c:choose>
					</c:otherwise>
				</c:choose>
			</a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1" style="display: grid;">
			<ul class="nav navbar-nav">
<%--				--%>
	<c:set var="code" value="${category.code}"/>
	<c:forEach items="${requestScope.TOP_CATEGORIES}" var="category">
		<li class="<sm:activeLink linkCode="${category.description.friendlyUrl}" activeReturnCode="active"/>"><a href="<c:url value="/shop/category/${category.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${category.id}"/>"><c:out value="${category.description.name}"/></a>
			<c:if test="${fn:length(category.children)>0}">
				<ul>
					<c:forEach items="${category.children}" var="child">
						<li><a href="<c:url value="/shop/category/${child.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${child.id}"/>"><c:out value="${child.description.name}"/></a></li>
					</c:forEach>
				</ul>
			</c:if>
		</li>
	</c:forEach>
	<c:forEach items="${requestScope.CONTENT_PAGE}" var="content">
		<c:if test="${content.content.linkToMenu}">
			<li><a href="<c:url value="/shop/pages/${content.seUrl}.html"/>" class="current">${content.name}</a></li>
		</c:if>
	</c:forEach>
<%--				--%>
			</ul>
			<form class="navbar-form navbar-left" role="search">
				<div class="form-group">
<%--					--%>

	<c:if test="${requestScope.CONFIGS['displaySearchBox'] == true}">

	<div class="input-group menu-search-box">
		<input type="text" class="form-control typeahead" type="search" name="q" id="searchField" placeholder="<s:message code="label.generic.search" text="Search"/>" value="" />
		<span class="input-group-btn">
        							<button class="btn btn-default searchButton" type="submit"><s:message code="label.generic.search" text="Search"/></button>
   								</span>
		<!-- important for submitting search -->
		<form id="hiddenSearchForm" method="post" action="<c:url value="/shop/search/search.html"/>">
			<input type="hidden" id="hiddenQuery" name="q">
		</form>
	</div>


	</c:if>
<%--					--%>
			</form>

		</div><!-- /.navbar-collapse -->
	</div><!-- /.container-fluid -->
</nav>
<!-- mainmenu-area-start -->
		<div class="mainmenu-area bg-color-1" id="main_h">
			<div class="container">
				<div class="row">
					<div class="col-lg-12 col-md-12 col-sm-12 hidden-xs">
						<div class="mainmenu hidden-xs">
							<nav>
								<ul>
								<c:set var="code" value="${category.code}"/>
								<c:forEach items="${requestScope.TOP_CATEGORIES}" var="category">
									   <li class="<sm:activeLink linkCode="${category.description.friendlyUrl}" activeReturnCode="active"/>"><a href="<c:url value="/shop/category/${category.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${category.id}"/>"><c:out value="${category.description.name}"/></a>
										<c:if test="${fn:length(category.children)>0}">
										<ul>
											<c:forEach items="${category.children}" var="child">
												<li><a href="<c:url value="/shop/category/${child.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${child.id}"/>"><c:out value="${child.description.name}"/></a></li>
											</c:forEach>
										</ul>
										</c:if>
									   </li>
								</c:forEach>
							    <c:forEach items="${requestScope.CONTENT_PAGE}" var="content">
										<c:if test="${content.content.linkToMenu}">
												<li><a href="<c:url value="/shop/pages/${content.seUrl}.html"/>" class="current">${content.name}</a></li>
										</c:if>
								</c:forEach>
								</ul>
							</nav>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- mobile menu -->
		<div class="mobile-menu-area hidden-sm hidden-md hidden-lg">
			<div class="container">
				<div class="row">
					<div class="col-md-12">
						<div class="mobile-menu">
							<nav id="mobile-menu">
								<ul>
								<c:set var="code" value="${category.code}"/>
								<c:forEach items="${requestScope.TOP_CATEGORIES}" var="category">
									   <li class="<sm:activeLink linkCode="${category.description.friendlyUrl}" activeReturnCode="active"/>"><a href="<c:url value="/shop/category/${category.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${category.id}"/>"><c:out value="${category.description.name}"/></a>
										<c:if test="${fn:length(category.children)>0}">
										<ul>
											<c:forEach items="${category.children}" var="child">
												<li><a href="<c:url value="/shop/category/${child.description.friendlyUrl}.html"/><sm:breadcrumbParam categoryId="${child.id}"/>"><c:out value="${child.description.name}"/></a></li>
											</c:forEach>
										</ul>
										</c:if>
									   </li>
								</c:forEach>
								</ul>
							</nav>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- mainmenu-area-end -->
