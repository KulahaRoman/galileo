package galileo.server;

import galileo.core.SocketDataReader;
import lombok.extern.slf4j.Slf4j;

import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;

@Slf4j
public class GalileoDataReader extends SocketDataReader<Packet> {
    public GalileoDataReader(SocketChannel channel) {
        super(channel);
    }

    @Override
    public Packet readData() throws Exception {
        var payloadSizeBuffer = ByteBuffer.allocate(Integer.BYTES);
        channel.read(payloadSizeBuffer);
        payloadSizeBuffer.flip();
        var payloadSize = payloadSizeBuffer.getInt();

        byte[] payloadBytes = new byte[payloadSize];
        var payloadBuffer = ByteBuffer.wrap(payloadBytes);
        channel.read(payloadBuffer);
        var payload = new String(payloadBytes);

        var packet = new Packet();
        packet.setPayload(payload);

        return packet;
    }
}
