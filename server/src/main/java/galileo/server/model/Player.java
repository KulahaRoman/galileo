package galileo.server.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Player {
    @JsonProperty("id")
    private int id;
    @JsonProperty("nck")
    private String nickname;
    @JsonProperty("crd")
    private Vector3D coords;
    @JsonProperty("vel")
    private Vector3D velocity;
    @JsonProperty("acc")
    private Vector3D acceleration;
    @JsonProperty("col")
    private long color;
    @JsonProperty("hp")
    private int hp;
    @JsonProperty("ap")
    private int ap;
    @JsonProperty("veh")
    private int vehicle;
    @JsonProperty("int")
    private int interior;
    @JsonProperty("afk")
    private boolean afk;
}