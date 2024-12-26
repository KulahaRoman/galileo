package galileo.core;

import java.nio.channels.SocketChannel;

public interface DataReaderFactory<T> {
    DataReader<T> createDataReader(SocketChannel socket);
}
