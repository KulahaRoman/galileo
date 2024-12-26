package galileo.server;

import galileo.core.BaseConnector;
import galileo.core.ConnectionFactory;
import galileo.core.DataReaderFactory;
import galileo.core.DataWriterFactory;

public class GalileoConnector extends BaseConnector<Packet> {
    public GalileoConnector(DataWriterFactory<Packet> dataWriterFactory,
                            DataReaderFactory<Packet> dataReaderFactory,
                            ConnectionFactory<Packet> connectionFactory) {
        super(dataWriterFactory, dataReaderFactory, connectionFactory);
    }
}
