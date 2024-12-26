package galileo.server;

import galileo.core.DataWriter;
import galileo.core.DataWriterFactory;

import java.nio.channels.SocketChannel;

public class GalileoDataWriterFactory implements DataWriterFactory<Packet> {
    @Override
    public DataWriter<Packet> createDataWriter(SocketChannel channel) {
        return new GalileoDataWriter(channel);
    }
}
