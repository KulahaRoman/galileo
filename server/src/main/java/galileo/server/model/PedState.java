package galileo.server.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PedState {
    @JsonProperty("state")
    private String state;
    @JsonProperty("vehicleType")
    private String vehicleType;
    @JsonProperty("isInInterior")
    private boolean isInInterior;
}
