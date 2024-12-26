package galileo.server;

import com.fasterxml.jackson.databind.ObjectMapper;
import galileo.core.Connection;
import galileo.core.ConnectionHandler;
import galileo.server.model.Player;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;
import java.util.concurrent.ExecutorService;

@Slf4j
public class GalileoConnectionHandler implements ConnectionHandler<Packet> {
    private final Map<Connection<Packet>, Player> players;

    public GalileoConnectionHandler(Map<Connection<Packet>, Player> players) {
        this.players = players;
    }

    @Override
    public void handleConnection(Connection<Packet> connection, ExecutorService executor) throws Exception {
        try {
            var mapper = new ObjectMapper();
            while (true) {
                // receive and process player info
                var incomingPacket = connection.receiveData();
                log.debug("GalileoConnectionHandler: packet received: {}", incomingPacket.getPayload());

                var player = mapper.readValue(incomingPacket.getPayload(), Player.class);
                players.put(connection, player);

                // prepare and send players data
                var players = this.players.values();
                log.debug("Players table size: {}", players.size());

                var json = mapper.writeValueAsString(players);
                var outgoingPacket = new Packet(json);

                connection.sendData(outgoingPacket);
                log.debug("GalileoConnectionHandler: packet sent: {}", outgoingPacket.getPayload());
            }
        } catch (Exception e) {
            players.remove(connection);
            log.warn("GalileoConnectionHandler: error while handling connection.", e);
        }
    }
}