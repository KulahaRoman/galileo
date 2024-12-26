package galileo.core;

import java.io.IOException;
import java.nio.channels.SocketChannel;

public abstract class SocketDataWriter<T> implements DataWriter<T> {
    protected final SocketChannel channel;

    public SocketDataWriter(SocketChannel channel) {
        this.channel = channel;
    }

    @Override
    public void close() throws IOException {
        if (channel.isOpen()) {
            channel.close();
        }
    }
}
