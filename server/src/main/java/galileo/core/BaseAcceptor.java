package galileo.core;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.channels.ServerSocketChannel;

public abstract class BaseAcceptor<T> implements Acceptor<T> {
    private final ServerSocketChannel serverChannel;

    private final DataWriterFactory<T> dataWriterFactory;
    private final DataReaderFactory<T> dataReaderFactory;

    private final ConnectionFactory<T> connectionFactory;

    public BaseAcceptor(DataWriterFactory<T> dataWriterFactory,
                        DataReaderFactory<T> dataReaderFactory,
                        ConnectionFactory<T> connectionFactory) throws IOException {
        this.serverChannel = ServerSocketChannel.open();
        this.serverChannel.socket().bind(new InetSocketAddress(0));

        this.dataWriterFactory = dataWriterFactory;
        this.dataReaderFactory = dataReaderFactory;
        this.connectionFactory = connectionFactory;
    }

    public BaseAcceptor(int port,
                        DataWriterFactory<T> dataWriterFactory,
                        DataReaderFactory<T> dataReaderFactory,
                        ConnectionFactory<T> connectionFactory) throws IOException {
        this.serverChannel = ServerSocketChannel.open();
        this.serverChannel.socket().bind(new InetSocketAddress(port));

        this.dataWriterFactory = dataWriterFactory;
        this.dataReaderFactory = dataReaderFactory;
        this.connectionFactory = connectionFactory;
    }

    @Override
    public Connection<T> acceptConnection() throws Exception {
        var connectionChannel = serverChannel.accept();

        var dataReader = dataReaderFactory.createDataReader(connectionChannel);
        var dataWriter = dataWriterFactory.createDataWriter(connectionChannel);

        var incomingChannel = new SimpleIncomingChannel<>(dataReader);
        var outgoingChannel = new SimpleOutgoingChannel<>(dataWriter);

        return connectionFactory.createNewConnection(incomingChannel, outgoingChannel);
    }

    @Override
    public int getPort() {
        return serverChannel.socket().getLocalPort();
    }

    @Override
    public void close() throws Exception {
        serverChannel.close();
    }
}
