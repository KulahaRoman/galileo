package galileo.server.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Vector3D {
    @JsonProperty("x")
    private double x;
    @JsonProperty("y")
    private double y;
    @JsonProperty("z")
    private double z;
}
