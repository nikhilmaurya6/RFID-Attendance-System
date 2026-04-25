package com.example.rfid;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {
  "/dashboard.jsp", "/registerCard.jsp",
  "/attendance", "/deleteCard", "/exportCsv", "/rfid"
})
public class AuthFilter implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse resp = (HttpServletResponse) response;

    // BYPASS device endpoint: no login redirect for /rfid
    String uri = req.getRequestURI();
    if (uri != null && uri.endsWith("/rfid")) {
      chain.doFilter(request, response);
      return;
    }

    HttpSession s = req.getSession(false);
    boolean loggedIn = s != null && s.getAttribute("role") != null;
    if (!loggedIn) {
      resp.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }
    chain.doFilter(request, response);
  }
}
