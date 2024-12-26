package galileo.server;

import galileo.core.Connection;
import galileo.core.ConnectionFactory;
import galileo.core.IncomingChannel;
import galileo.core.OutgoingChannel;

public class GalileoConnectionFactory implements ConnectionFactory<Packet> {
    @Override
    public Connection<Packet> createNewConnection(IncomingChannel<Packet> incomingChannel,
                                                  OutgoingChannel<Packet> outgoingChannel) {
        return new GalileoConnection(incomingChannel, outgoingChannel);
    }
}
