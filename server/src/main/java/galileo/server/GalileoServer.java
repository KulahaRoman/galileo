package galileo.server;

import galileo.core.BaseServer;
import galileo.core.ConnectionHandlerFactory;
import galileo.core.Server;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;

@Slf4j
public class GalileoServer implements Server<Packet> {
    private final BaseServer<Packet> server;

    public GalileoServer(ConnectionHandlerFactory<Packet> connectionHandler) throws IOException {
        this(0, connectionHandler);
    }

    public GalileoServer(int port, ConnectionHandlerFactory<Packet> connectionHandler) throws IOException {
        var dataWriterFactory = new GalileoDataWriterFactory();
        var dataReaderFactory = new GalileoDataReaderFactory();
        var connectionFactory = new GalileoConnectionFactory();

        var acceptor = new GalileoAcceptor(port, dataWriterFactory, dataReaderFactory, connectionFactory);

        this.server = new BaseServer<>(acceptor, connectionHandler) {
        };
    }

    @Override
    public void run() throws Exception {
        server.run();
    }

    @Override
    public void close() throws Exception {
        server.close();
    }
}
