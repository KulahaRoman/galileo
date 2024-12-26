package galileo.core;

public interface Connector<T> {
    Connection<T> connect(String address, int port) throws Exception;
}
