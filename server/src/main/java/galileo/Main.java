package galileo;

import galileo.core.Connection;
import galileo.server.GalileoConnection;
import galileo.server.GalileoConnectionHandlerFactory;
import galileo.server.GalileoServer;
import galileo.server.Packet;
import galileo.server.model.PedState;
import galileo.server.model.Player;
import galileo.server.model.PlayerState;
import galileo.server.model.Vector3D;
import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.ConcurrentHashMap;

@Slf4j
public class Main {
    public static void main(String[] args) {
        var players = new ConcurrentHashMap<Connection<Packet>, Player>();

        var debugPlayerName = "Debug_Player";
        var debugPlayerState = new PlayerState();
        debugPlayerState.setPedState(new PedState("foot", "null", false));
        debugPlayerState.setPedCoords(new Vector3D(0.0, 0.0, 0.0));
        debugPlayerState.setPedHP(100);
        debugPlayerState.setPedAP(100);

        var debugPlayer = new Player(debugPlayerName, debugPlayerState);
        players.put(new GalileoConnection(null, null), debugPlayer);

        try (var server = new GalileoServer(5000, new GalileoConnectionHandlerFactory(players))) {
            server.run();
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }
}
