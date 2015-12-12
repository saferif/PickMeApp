/**
 * Created by Administrator on 12/8/2015.
 */
public class Main {

    public static void main(String[] args) {
        SimpleSocketServer server = new SimpleSocketServer(8000);
        server.start();
    }
}
