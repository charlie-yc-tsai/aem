<%@include file="/libs/foundation/global.jsp"%>
<%@page session="false" %>
<%@page contentType="text/html"
        pageEncoding="utf-8"
        import="com.day.text.Text,
                org.slf4j.Logger,org.slf4j.LoggerFactory,
                org.apache.jackrabbit.api.security.user.*,
                org.apache.sling.api.resource.ResourceResolver,
                javax.jcr.Session" %>
<%@taglib prefix="cq" uri="http://www.day.com/taglibs/cq/1.0" %>
<cq:defineObjects/>
<%!
    private final Logger log = LoggerFactory.getLogger(getClass());
%>
<%
    java.util.Iterator<Authorizable> users, groups ;
    Object obj = null; 
    User user = null;
    String id = null;    
    UserManager userManager = resourceResolver.adaptTo(UserManager.class);
    
try{
    groups = userManager.findAuthorizables("jcr:primaryType", "rep:Group");
    while(groups.hasNext()){
			Authorizable group = groups.next();
	    if (group.isGroup()) {
			log.info("Group found {}", group.getID());
			String groupName=group.getID();
		    Group groupd = (Group) userManager.getAuthorizable(groupName);
            %><font><br/><%=groupd%><br/><%
            users = groupd.getMembers();
            int i=0;
            while(users.hasNext()){
                obj = users.next();
                if(!(obj instanceof User)){
                     continue;
                 }
                user = (User)obj;
                id = user.getID();
                i++;
                %><br/><%=id%><%
            }
	    	%><br/><%
		}
    }
    
}catch(Exception e){
%><br/>Group Not Found<br/><%
}
%></font>


