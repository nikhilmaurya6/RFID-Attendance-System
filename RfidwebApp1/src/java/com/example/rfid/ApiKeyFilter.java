package com.example.rfid;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = { "/rfid" })
public class ApiKeyFilter implements Filter {
  private static final String SECRET = "RFID_SECRET_123"; // choose your secret

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse resp = (HttpServletResponse) response;

    String key = req.getHeader("X-API-Key");
    if (!SECRET.equals(key)) {
      resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid key");
      return;
    }
    chain.doFilter(request, response);
  }
}
