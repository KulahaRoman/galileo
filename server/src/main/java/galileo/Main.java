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
        var connectionPlayer = new ThreadSafeHashMap<Connection<Packet>, Player>();
        var connectionServer = new ThreadSafeHashMap<Connection<Packet>, String>();

        int port = Integer.parseInt(System.getenv("PORT"));
        try (var server = new GalileoServer(port,
                new GalileoConnectionHandlerFactory(connectionPlayer, connectionServer))) {
            server.run();
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }
}
