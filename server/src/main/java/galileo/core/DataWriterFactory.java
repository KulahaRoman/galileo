package galileo.core;

import java.nio.channels.SocketChannel;

public interface DataWriterFactory<T> {
    DataWriter<T> createDataWriter(SocketChannel socket);
}
