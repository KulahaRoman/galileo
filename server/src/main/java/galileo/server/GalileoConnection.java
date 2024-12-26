package galileo.server;

import galileo.core.BaseConnection;
import galileo.core.IncomingChannel;
import galileo.core.OutgoingChannel;

public class GalileoConnection extends BaseConnection<Packet> {
    public GalileoConnection(IncomingChannel<Packet> incomingChannel,
                             OutgoingChannel<Packet> outgoingChannel) {
        super(incomingChannel, outgoingChannel);
    }
}
