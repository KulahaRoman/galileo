package galileo.core;

import java.net.InetSocketAddress;
import java.nio.channels.SocketChannel;

public abstract class BaseConnector<T> implements Connector<T> {
    private final DataWriterFactory<T> dataWriterFactory;
    private final DataReaderFactory<T> dataReaderFactory;

    private final ConnectionFactory<T> connectionFactory;

    protected BaseConnector(DataWriterFactory<T> dataWriterFactory,
                            DataReaderFactory<T> dataReaderFactory,
                            ConnectionFactory<T> connectionFactory) {
        this.dataWriterFactory = dataWriterFactory;
        this.dataReaderFactory = dataReaderFactory;
        this.connectionFactory = connectionFactory;
    }

    @Override
    public Connection<T> connect(String address, int port) throws Exception {
        var connectionChannel = SocketChannel.open();
        connectionChannel.connect(new InetSocketAddress(address, port));

        var dataReader = dataReaderFactory.createDataReader(connectionChannel);
        var dataWriter = dataWriterFactory.createDataWriter(connectionChannel);

        var incomingChannel = new SimpleIncomingChannel<>(dataReader);
        var outgoingChannel = new SimpleOutgoingChannel<>(dataWriter);

        return connectionFactory.createNewConnection(incomingChannel, outgoingChannel);
    }
}
