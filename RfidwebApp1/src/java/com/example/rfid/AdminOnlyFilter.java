package com.example.rfid;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = { "/deleteCard", "/exportCsv", "/registerCard.jsp" })
public class AdminOnlyFilter implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse resp = (HttpServletResponse) response;
    HttpSession s = req.getSession(false);
    boolean isAdmin = s != null && "ADMIN".equals(s.getAttribute("role"));
    if (!isAdmin) {
      resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin only");
      return;
    }
    chain.doFilter(request, response);
  }
}
