
package us.kbase.expressionutils;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: getExprMatrixOutput</p>
 * 
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "exprMatrix_FPKM_ref",
    "exprMatrix_TPM_ref"
})
public class GetExprMatrixOutput {

    @JsonProperty("exprMatrix_FPKM_ref")
    private String exprMatrixFPKMRef;
    @JsonProperty("exprMatrix_TPM_ref")
    private String exprMatrixTPMRef;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("exprMatrix_FPKM_ref")
    public String getExprMatrixFPKMRef() {
        return exprMatrixFPKMRef;
    }

    @JsonProperty("exprMatrix_FPKM_ref")
    public void setExprMatrixFPKMRef(String exprMatrixFPKMRef) {
        this.exprMatrixFPKMRef = exprMatrixFPKMRef;
    }

    public GetExprMatrixOutput withExprMatrixFPKMRef(String exprMatrixFPKMRef) {
        this.exprMatrixFPKMRef = exprMatrixFPKMRef;
        return this;
    }

    @JsonProperty("exprMatrix_TPM_ref")
    public String getExprMatrixTPMRef() {
        return exprMatrixTPMRef;
    }

    @JsonProperty("exprMatrix_TPM_ref")
    public void setExprMatrixTPMRef(String exprMatrixTPMRef) {
        this.exprMatrixTPMRef = exprMatrixTPMRef;
    }

    public GetExprMatrixOutput withExprMatrixTPMRef(String exprMatrixTPMRef) {
        this.exprMatrixTPMRef = exprMatrixTPMRef;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((("GetExprMatrixOutput"+" [exprMatrixFPKMRef=")+ exprMatrixFPKMRef)+", exprMatrixTPMRef=")+ exprMatrixTPMRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
