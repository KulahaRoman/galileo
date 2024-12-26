package galileo.server;

import galileo.core.Connection;
import galileo.core.ConnectionHandler;
import galileo.core.ConnectionHandlerFactory;
import galileo.server.model.Player;

import java.util.Map;

public class GalileoConnectionHandlerFactory implements ConnectionHandlerFactory<Packet> {
    private final Map<Connection<Packet>, Player> players;

    public GalileoConnectionHandlerFactory(Map<Connection<Packet>, Player> players) {
        this.players = players;
    }

    @Override
    public ConnectionHandler<Packet> createConnectionHandler() {
        return new GalileoConnectionHandler(players);
    }
}
