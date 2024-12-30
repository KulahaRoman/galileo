package galileo;

import galileo.core.Connection;
import galileo.server.GalileoConnectionHandlerFactory;
import galileo.server.GalileoServer;
import galileo.server.Packet;
import galileo.server.model.Player;
import galileo.utils.ThreadSafeHashMap;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class Main {
    public static void main(String[] args) {
        var players = new ThreadSafeHashMap<Connection<Packet>, Player>();

        int port = Integer.parseInt(System.getenv("PORT"));
        try (var server = new GalileoServer(port, new GalileoConnectionHandlerFactory(players))) {
            server.run();
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }
}
