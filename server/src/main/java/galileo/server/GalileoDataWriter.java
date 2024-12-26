package galileo.server;

import galileo.core.SocketDataWriter;

import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;

public class GalileoDataWriter extends SocketDataWriter<Packet> {
    public GalileoDataWriter(SocketChannel channel) {
        super(channel);
    }

    @Override
    public void writeData(Packet data) throws Exception {
        var buffer = ByteBuffer.allocate(Integer.BYTES + data.getPayload().getBytes().length);
        buffer.putInt(data.getPayload().getBytes().length);
        buffer.put(data.getPayload().getBytes());
        buffer.flip();

        channel.write(buffer);
    }
}
