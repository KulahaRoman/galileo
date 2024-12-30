package galileo.server.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlayerState {
    @JsonProperty("pedState")
    private PedState pedState;
    @JsonProperty("pedCoords")
    private Vector3D pedCoords;
    @JsonProperty("pedVelocity")
    private Vector3D pedVelocity;
    @JsonProperty("pedAcceleration")
    private Vector3D pedAcceleration;
    @JsonProperty("pedColor")
    private String pedColor;
    @JsonProperty("pedHP")
    private int pedHP;
    @JsonProperty("pedAP")
    private int pedAP;
}
