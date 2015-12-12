
import javax.xml.ws.handler.Handler;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.AsynchronousServerSocketChannel;
import java.nio.channels.AsynchronousSocketChannel;
import java.nio.channels.CompletionHandler;
import java.util.Map;


/**
 * Created by Administrator on 12/12/2015.
 */
public class AsyncSocketServer {
    int portNumber;
    public AsyncSocketServer(int portNumber) {
        this.portNumber = portNumber;
    }
    public void start() {
        try {
            final AsynchronousServerSocketChannel listener =
                    AsynchronousServerSocketChannel.open().bind(new InetSocketAddress(portNumber));
            listener.accept(null, new CompletionHandler<AsynchronousSocketChannel, Void>() {
                @Override
                public void completed(final AsynchronousSocketChannel client, Void attachment) {
                    System.out.println("New connection accepted");
                    listener.accept(null, this);
                    read(client);
                }

                @Override
                public void failed(Throwable ex, Void attachment) {
                    System.err.println("Exception " + ex + "in attachment " + attachment);
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public void read(final AsynchronousSocketChannel client) {
        final ByteBuffer buffer = ByteBuffer.allocate(48);
        client.read(buffer, buffer, new CompletionHandler<Integer, ByteBuffer>() {
            @Override
            public void completed(Integer result, ByteBuffer attachment) {
            //    if (attachment)
                read(client);
            }

            @Override
            public void failed(Throwable exc, ByteBuffer attachment) {

            }

        });

    }

   /* public String formWrite() {
        String s = "";
        for (Map.Entry<Integer, Coords> e : coords_map.entrySet()) {
            s += e.getKey() + " " + e.getValue() + ",";
        }
        return s.substring(0, s.length() - 1) + "\n";
    }*/
}
