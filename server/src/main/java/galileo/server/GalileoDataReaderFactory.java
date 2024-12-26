package galileo.server;

import galileo.core.DataReader;
import galileo.core.DataReaderFactory;

import java.nio.channels.SocketChannel;

public class GalileoDataReaderFactory implements DataReaderFactory<Packet> {
    @Override
    public DataReader<Packet> createDataReader(SocketChannel channel) {
        return new GalileoDataReader(channel);
    }
}
