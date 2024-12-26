package galileo.core;

import java.io.IOException;
import java.nio.channels.SocketChannel;

public abstract class SocketDataReader<T> implements DataReader<T> {
    protected final SocketChannel channel;

    public SocketDataReader(SocketChannel channel) {
        this.channel = channel;
    }

    @Override
    public void close() throws IOException {
        if (channel.isOpen()) {
            channel.close();
        }
    }
}
