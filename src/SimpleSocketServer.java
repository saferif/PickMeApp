import com.sun.corba.se.impl.encoding.OSFCodeSetRegistry;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import javax.swing.text.html.parser.Entity;
import java.io.*;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by Administrator on 12/8/2015.
 */
public class SimpleSocketServer {
    int portNumber;
    ConcurrentHashMap<Integer, Coords> coords_map = new ConcurrentHashMap<Integer, Coords>(16, 0.75f, 10000);
    public SimpleSocketServer(int portNumber) {
        this.portNumber = portNumber;
    }
    public void start(){
      /*  try {
            HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
            server.createContext("/test", new MyHandler());
            server.setExecutor(null); // creates a default executor
            server.start();
        } catch (Exception e) {

        }*/
        try {
            ServerSocket serverSocket = new ServerSocket(portNumber);
            coords_map.put(0, new Coords(37.33, -122.5));
            coords_map.put(1, new Coords(37.34, -121.3));
            coords_map.put(2, new Coords(37.32, -123.6));
          /*  String s = "jfhsdhdjkvhdjvfhdjkvhdfjkshdjvdhvjkfhvjksvfvjkbfsjbfkvjdsbfvdbjks";
            for (int i = 0; i < 12; i ++) {
                s += s;
            }
            s+="\n";
            System.out.println(s.getBytes("UTF-8").length);
            System.out.println(s.length());
            System.out.println(s.getBytes().length);*/
            System.out.println(serverSocket.getInetAddress().getHostAddress());
         //   serverSocket.bind(new InetSocketAddress("192.168.1.2", portNumber));
            Socket clientSocket = serverSocket.accept();
            System.out.println("Someone connected");
            PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
           // out.println("Hello from server!");
           // out.println("Message A!");
            /*out.println("Message B!");
            out.println("Message c!");
            out.println("Message D!");
            out.println("Message E!");
            out.println("Message F!");*/
            out.printf(formWrite());
            String inputLine;
           // while ((inputLine = in.readLine()) != null) {
            while (true) {
                final Random random = new Random();
                for (Coords coord : coords_map.values()) {
                    coord.latitude += -1.0 + 2.0*random.nextDouble();
                    coord.longitude += -1.0 + 2.0*random.nextDouble();
                }
                out.printf(formWrite());
                Thread.sleep(500);
               // System.out.println("Client says: " + inputLine);
               // out.println(inputLine);

              /*  if (inputLine.equals("Bye."))
                    break;*/
            }
          /*  out.close();
            in.close();
            clientSocket.close();
            serverSocket.close();*/
        } catch (IOException e) {
            System.out.println("IOException in SimpleSocketServer.start() " + e);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    public String formWrite() {
        String s = "";
        for (Map.Entry<Integer, Coords> e : coords_map.entrySet()) {
            s += e.getKey() + " " + e.getValue() + ",";
        }
        return s.substring(0, s.length() - 1) + "\n";
    }

   /* static class MyHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange t) throws IOException {
            String response = "This is the response";
            t.sendResponseHeaders(200, response.length());
            OutputStream os = t.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }*/
}
