
package com.hospital.filter;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = {
	    "/dashboard",
	    "/search",
	    "/departments", "/departments/*",
	    "/patients", "/patients/*",
	    "/doctors", "/doctors/*",
	    "/staff", "/staff/*",
	    "/users", "/users/*",
	    "/staff-attendance", "/staff-attendance/*",
	    "/doctor-schedules", "/doctor-schedules/*",
	    "/appointments", "/appointments/*",
	    "/appointment-doctors", "/appointment-slots"
})
public class AuthenticationFilter implements Filter {
	
	private static final Map<String, Set<String>> ALLOWED_ROLES =
		    Map.ofEntries(
		        Map.entry("/dashboard",
		            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/departments",
		            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/patients",
		            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/doctors",
		            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/staff",
		            Set.of("ADMIN", "RECEPTIONIST")),

		        Map.entry("/users",
		            Set.of("ADMIN")),

		        Map.entry("/staff-attendance",
		            Set.of("ADMIN", "STAFF","RECEPTIONIST")),
		        
		        Map.entry("/staff-shifts",
		        	    Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),
		        
		        Map.entry("/resources",
		        	    Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/doctor-schedules",
		            Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST")),

		        Map.entry("/appointments",
		            Set.of("ADMIN", "DOCTOR", "RECEPTIONIST")),

		        Map.entry("/appointment-doctors",
		            Set.of("ADMIN", "RECEPTIONIST")),

		        Map.entry("/appointment-slots",
		            Set.of("ADMIN", "RECEPTIONIST")),
		        
		        Map.entry("/search",
		        	    Set.of("ADMIN", "DOCTOR", "STAFF", "RECEPTIONIST"))
		        
		    );


    @Override
    public void doFilter(
            jakarta.servlet.ServletRequest request,
            jakarta.servlet.ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Prevent browsers from caching protected pages.
        res.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate"
        );
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        // Require an authenticated user.
        HttpSession session = req.getSession(false);

        if (session == null
                || session.getAttribute("userId") == null) {

            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        // Resolve the requested servlet path.
        String path = req.getServletPath();
        String pathInfo = req.getPathInfo();

        if (pathInfo != null) {
            path += pathInfo;
        }

        // Normalize a trailing slash.
        if (path.length() > 1 && path.endsWith("/")) {
            path = path.substring(0, path.length() - 1);
        }

        // Map subpaths to their module permission.
        String permissionPath = path;
        if (path.equals("/search") || path.startsWith("/search/")) {
            permissionPath = "/search";
        } else if (path.equals("/departments")
                || path.startsWith("/departments/")) {
            permissionPath = "/departments";
        } else if (path.equals("/patients")
                || path.startsWith("/patients/")) {
            permissionPath = "/patients";
        } else if (path.equals("/doctors")
                || path.startsWith("/doctors/")) {
            permissionPath = "/doctors";
        } else if (path.equals("/staff")
                || path.startsWith("/staff/")) {
            permissionPath = "/staff";
        } else if (path.equals("/users")
                || path.startsWith("/users/")) {
            permissionPath = "/users";
        } else if (path.equals("/staff-attendance")
                || path.startsWith("/staff-attendance/")) {
            permissionPath = "/staff-attendance";
        } else if (path.equals("/doctor-schedules")
                || path.startsWith("/doctor-schedules/")) {
            permissionPath = "/doctor-schedules";
        } else if (path.equals("/appointments")
                || path.startsWith("/appointments/")) {
            permissionPath = "/appointments";
        }

        // Verify module access.
        Set<String> allowedRoles = ALLOWED_ROLES.get(permissionPath);

        if (role == null
                || allowedRoles == null
                || !allowedRoles.contains(role)) {

            res.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "You do not have permission to access this module."
            );
            return;
        }

        // Only ADMIN can modify departments.
        if (permissionPath.equals("/departments")
                && !"ADMIN".equals(role)) {

            boolean isDepartmentList = path.equals("/departments");
            boolean isReadOnlyRequest =
                "GET".equalsIgnoreCase(req.getMethod());

            if (!isDepartmentList || !isReadOnlyRequest) {
                res.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only administrators can modify departments."
                );
                return;
            }
        }

        // Additional staff and doctor-schedule rules are enforced
        // by their respective servlets.
        chain.doFilter(request, response);
    }
}
