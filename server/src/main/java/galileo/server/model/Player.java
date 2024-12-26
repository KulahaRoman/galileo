package galileo.server.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Player {
    @JsonProperty("nickname")
    private String nickname;
    @JsonProperty("state")
    private PlayerState state;
}
