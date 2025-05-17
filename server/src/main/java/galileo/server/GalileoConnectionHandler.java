package galileo.server;

import com.fasterxml.jackson.databind.ObjectMapper;
import galileo.core.Connection;
import galileo.core.ConnectionHandler;
import galileo.server.model.Payload;
import galileo.server.model.Player;
import lombok.extern.slf4j.Slf4j;

import java.util.Map;
import java.util.concurrent.ExecutorService;

@Slf4j
public class GalileoConnectionHandler implements ConnectionHandler<Packet> {
    private static final long TIMEOUT = 3000;

    private final Map<Connection<Packet>, Player> connectionPlayer;
    private final Map<Connection<Packet>, String> connectionServer;

    public GalileoConnectionHandler(Map<Connection<Packet>, Player> connectionPlayer,
                                    Map<Connection<Packet>, String> connectionServer) {
        this.connectionPlayer = connectionPlayer;
        this.connectionServer = connectionServer;
    }

    @Override
    public void handleConnection(Connection<Packet> connection, ExecutorService executor) throws Exception {
        try {
            var mapper = new ObjectMapper();
            while (true) {
                var now = System.currentTimeMillis();

                // receive and process player info
                var incomingPacket = connection.receiveData();
                log.debug("GalileoConnectionHandler: packet received: {}", incomingPacket.getPayload());

                var payload = mapper.readValue(incomingPacket.getPayload(), Payload.class);

                var server = payload.getServer();
                var player = payload.getPlayer();
                player.setTimestamp(now);

                connectionPlayer.put(connection, player);
                connectionServer.put(connection, server);

                // prepare players list
                // filter players by current player's server address
                // to prevent sending players from another samp server,
                // even though all players are connected to this galileo server
                var players = connectionServer.entrySet().stream()
                        .filter(entry -> entry.getValue().equals(server))
                        .map(Map.Entry::getKey)
                        .map(connectionPlayer::get)
                        .filter(p -> p.getId() != player.getId())
                        .toList();

                // update afk status if required
                for (var p : players) {
                    var time = now - p.getTimestamp();
                    if (time > TIMEOUT) {
                        p.setAfk(true);
                    }
                }

                log.debug("Players table size: {}", players.size());

                // convert player list into packet
                var json = mapper.writeValueAsString(players);
                var outgoingPacket = new Packet(json);

                // send packet
                connection.sendData(outgoingPacket);
                log.debug("GalileoConnectionHandler: packet sent: {}", outgoingPacket.getPayload());
            }
        } catch (Exception e) {
            log.warn("GalileoConnectionHandler: error while handling connection.", e);
        } finally {
            connectionPlayer.remove(connection);
            connectionServer.remove(connection);
        }
    }
}