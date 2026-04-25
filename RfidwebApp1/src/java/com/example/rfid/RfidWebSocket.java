package com.example.rfid;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/rfidws")
public class RfidWebSocket {
    private static final Set<Session> sessions = ConcurrentHashMap.newKeySet();

    @OnOpen
    public void onOpen(Session session) { sessions.add(session); }

    @OnClose
    public void onClose(Session session) { sessions.remove(session); }

    @OnError
    public void onError(Session session, Throwable thr) {
        sessions.remove(session);
        thr.printStackTrace();
    }

    public static void broadcast(String message) {
        for (Session s : sessions) {
            if (s.isOpen()) {
                try { s.getBasicRemote().sendText(message); } 
                catch (IOException e) { e.printStackTrace(); }
            }
        }
    }
}
