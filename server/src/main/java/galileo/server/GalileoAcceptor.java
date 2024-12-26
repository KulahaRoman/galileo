package galileo.server;

import galileo.core.BaseAcceptor;
import galileo.core.ConnectionFactory;
import galileo.core.DataReaderFactory;
import galileo.core.DataWriterFactory;

import java.io.IOException;

/**
 *
 */
public class GalileoAcceptor extends BaseAcceptor<Packet> {
    public GalileoAcceptor(DataWriterFactory<Packet> dataWriterFactory,
                           DataReaderFactory<Packet> dataReaderFactory,
                           ConnectionFactory<Packet> connectionFactory) throws IOException {
        super(dataWriterFactory, dataReaderFactory, connectionFactory);
    }

    public GalileoAcceptor(int port,
                           DataWriterFactory<Packet> dataWriterFactory,
                           DataReaderFactory<Packet> dataReaderFactory,
                           ConnectionFactory<Packet> connectionFactory) throws IOException {
        super(port, dataWriterFactory, dataReaderFactory, connectionFactory);
    }
}
