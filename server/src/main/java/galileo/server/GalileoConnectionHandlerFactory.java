package galileo.server;

import galileo.core.Connection;
import galileo.core.ConnectionHandler;
import galileo.core.ConnectionHandlerFactory;
import galileo.server.model.Player;

import java.util.Map;

public class GalileoConnectionHandlerFactory implements ConnectionHandlerFactory<Packet> {
    private final Map<Connection<Packet>, Player> connectionPlayer;
    private final Map<Connection<Packet>, String> connectionServer;

    public GalileoConnectionHandlerFactory(Map<Connection<Packet>, Player> connectionPlayer,
                                           Map<Connection<Packet>, String> connectionServer) {
        this.connectionPlayer = connectionPlayer;
        this.connectionServer = connectionServer;
    }

    @Override
    public ConnectionHandler<Packet> createConnectionHandler() {
        return new GalileoConnectionHandler(connectionPlayer, connectionServer);
    }
}
